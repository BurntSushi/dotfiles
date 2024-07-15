/*!
This is a simple program that parses XML dumps from the "SMS Backup & Restore"
Android app. It converts both SMS and MMS messages into readable text along
with some obvious structured data (contact names, phone numbers and dates).

This doesn't try to display threaded discussions and also skips any media
entirely. It's just a simple conversion from XML to something more readable and
searchable by a human.

Use it like this:

    searchsms '.*' sms-*.xml > sms.txt

Where '.*' is a regex that is applied to the body of every message. Any message
that doesn't match is skipped. The -c/--contact flag applies a regex to each
contact and the -r/--reverse flag prints messages in reverse chronological
order.
*/

use std::path::{Path, PathBuf};

use anyhow::Context;
use jiff::{civil, fmt::strtime, tz::TimeZone, Timestamp};
use regex::Regex;
use roxmltree::{Document, Node};

fn main() -> anyhow::Result<()> {
    env_logger::init();

    let config = Config::parse(std::env::args_os())?;
    let mut raws: Vec<(&Path, String)> = vec![];
    for path in config.paths.iter() {
        log::trace!("reading {}", path.display());
        let raw = std::fs::read_to_string(path)
            .with_context(|| format!("{}", path.display()))?;
        raws.push((path, raw));
    }
    let mut docs = vec![];
    for (path, raw) in raws.iter() {
        log::trace!("parsing {}", path.display());
        let doc = Document::parse(raw)
            .with_context(|| format!("{}", path.display()))?;
        docs.push(Doc { path: path.to_path_buf(), doc });
    }
    let mut msgs = vec![];
    for doc in docs.iter() {
        log::trace!("searching {}", doc.path.display());
        let smses = doc.find_smses()?;
        for c in smses.children() {
            let Some(msg) = doc.extract(c)? else { continue };
            if let Some(ref re) = config.body_regex {
                if !re.is_match(&msg.body) {
                    continue;
                }
            }
            if let Some(ref re) = config.contact_regex {
                if !msg.contacts.iter().any(|c| re.is_match(c)) {
                    continue;
                }
            }
            msgs.push(msg);
        }
    }
    if config.reverse {
        msgs.sort_by(|m1, m2| m1.date.cmp(&m2.date).reverse());
    } else {
        msgs.sort_by(|m1, m2| m1.date.cmp(&m2.date));
    }
    output_human(&msgs, &mut std::io::stdout())?;
    Ok(())
}

#[derive(Debug)]
struct Message {
    /// Whether the message was sent by me or received by me.
    kind: MessageKind,
    /// The literal timestamp string associated with this message. This is
    /// useful as an ID of sorts for error reporting.
    timestamp: String,
    /// All of the contact names found in the message. This is the result of
    /// splitting the 'contact_name' string by comma.
    contacts: Vec<String>,
    /// All of the addresses found in the message.
    addresses: Vec<String>,
    /// The actual body of the message. For mms messages, this corresponds
    /// to the part that is 'text/plain'.
    body: String,
    /// A date associated with the message. It corresponds to the 'date'
    /// attribute and is in units of milliseconds. It is *probably* the
    /// "received datetime." It always appears to be in UTC.
    date: Timestamp,
    /// A readable date string devoid of timezone info. It's probably just
    /// "naive local time."
    ///
    /// We currently don't use this because 'date' appears sufficient.
    #[allow(dead_code)]
    date_readable: Option<civil::DateTime>,
    /// From what I can tell, this is equivalent to 'date', but with
    /// milliseconds always set to `0`. (Its units is still milliseconds for
    /// 'sms' but apparently seconds for 'mms'. It appears to always be in
    /// UTC.
    ///
    /// We currently don't use this because 'date' appears sufficient.
    #[allow(dead_code)]
    date_sent: Option<Timestamp>,
}

#[derive(Clone, Copy, Debug)]
enum MessageKind {
    Sent,
    Recv,
}

#[derive(Debug)]
struct Doc<'i> {
    path: PathBuf,
    doc: Document<'i>,
}

impl<'i> Doc<'i> {
    fn find_smses<'a>(&'a self) -> anyhow::Result<Node<'a, 'i>> {
        for c in self.doc.root().children() {
            if c.tag_name().name() == "smses" {
                return Ok(c);
            }
        }
        anyhow::bail!(
            "{}: could not find first child of root",
            self.path.display()
        )
    }

    fn extract<'a>(
        &'a self,
        node: Node<'a, 'i>,
    ) -> anyhow::Result<Option<Message>> {
        if !node.is_element() {
            return Ok(None);
        }
        let msg = match node.tag_name().name() {
            // All SMS are just plain text, so we always get a message.
            "sms" => {
                let Some(timestamp) = node.attribute("date") else {
                    anyhow::bail!("failed to find timestamp for <sms> node")
                };
                Some(
                    self.extract_from_sms(node, timestamp)
                        .with_context(|| format!("{}", self.path.display()))
                        .with_context(|| {
                            format!("timestamp of <sms> node: {}", timestamp)
                        })?,
                )
            }
            // ... but an MMS might just be an image, so we might not get an
            // actual plain text message.
            "mms" => {
                let Some(timestamp) = node.attribute("date") else {
                    anyhow::bail!("failed to find timestamp for <mms> node")
                };
                self.extract_from_mms(node, timestamp)
                    .with_context(|| format!("{}", self.path.display()))
                    .with_context(|| {
                        format!("timestamp of <mms> node: {}", timestamp)
                    })?
            }
            unknown => anyhow::bail!(
                "{}: unknown child of 'smses': {}",
                self.path.display(),
                unknown
            ),
        };
        Ok(msg)
    }

    fn extract_from_sms<'a>(
        &'a self,
        node: Node<'a, 'i>,
        timestamp: &str,
    ) -> anyhow::Result<Message> {
        let mut kind = None;
        let mut contacts = vec![];
        let mut addresses = vec![];
        let mut body = None;
        let mut date = None;
        let mut date_readable = None;
        let mut date_sent = None;
        for a in node.attributes() {
            if a.name() == "type" {
                match a.value() {
                    "1" => kind = Some(MessageKind::Recv),
                    "2" => kind = Some(MessageKind::Sent),
                    unknown => {
                        anyhow::bail!("unknown SMS type '{:?}'", unknown)
                    }
                }
            } else if a.name() == "contact_name" {
                // Since this is just SMS, the contact name should always be
                // singular. I think...
                contacts.push(a.value().to_string());
            } else if a.name() == "address" {
                // Same as for contacts. For SMS, there should only be one.
                addresses.push(a.value().to_string());
            } else if a.name() == "body" {
                body = Some(a.value().to_string());
            } else if a.name() == "date" {
                date = Some(
                    parse_timestamp_millis(a.value())
                        .context("'date' attribute")?,
                );
            } else if a.name() == "readable_date" {
                date_readable = Some(
                    parse_readable_date(a.value())
                        .context("'readable_date attribute")?,
                );
            } else if a.name() == "date_sent" && a.value() != "0" {
                date_sent = Some(
                    parse_timestamp_millis(a.value())
                        .context("'date_sent' attribute")?,
                );
            }
        }
        let Some(kind) = kind else {
            anyhow::bail!("failed to find SMS message kind")
        };
        if contacts.is_empty() {
            anyhow::bail!("failed to find SMS message contacts")
        }
        let Some(body) = body else {
            anyhow::bail!("failed to find SMS message body")
        };
        let Some(date) = date else {
            anyhow::bail!("failed to find date for message")
        };
        Ok(Message {
            kind,
            timestamp: timestamp.to_string(),
            contacts,
            addresses,
            body,
            date,
            date_readable,
            date_sent,
        })
    }

    fn extract_from_mms<'a>(
        &'a self,
        node: Node<'a, 'i>,
        timestamp: &str,
    ) -> anyhow::Result<Option<Message>> {
        let Some(body) = self.extract_body_from_mms(node)? else {
            return Ok(None);
        };
        let mut kind = None;
        let mut contacts = vec![];
        let mut addresses = vec![];
        let mut date = None;
        let mut date_readable = None;
        let mut date_sent = None;
        for a in node.attributes() {
            if a.name() == "m_type" {
                match a.value() {
                    "132" => kind = Some(MessageKind::Recv),
                    "128" => kind = Some(MessageKind::Sent),
                    unknown => {
                        anyhow::bail!("unknown SMS type '{:?}'", unknown)
                    }
                }
            } else if a.name() == "contact_name" {
                contacts.extend(
                    a.value().split(",").map(|s| s.trim().to_string()),
                );
            } else if a.name() == "address" {
                addresses.extend(
                    a.value().split("~").map(|s| s.trim().to_string()),
                );
            } else if a.name() == "date" {
                date = Some(
                    parse_timestamp_millis(a.value())
                        .context("'date' attribute")?,
                );
            } else if a.name() == "readable_date" {
                date_readable = Some(
                    parse_readable_date(a.value())
                        .context("'readable_date attribute")?,
                );
            } else if a.name() == "date_sent" && a.value() != "0" {
                date_sent = Some(
                    parse_timestamp_seconds(a.value())
                        .context("'date_sent' attribute")?,
                );
            }
        }
        let Some(kind) = kind else {
            anyhow::bail!("failed to find SMS message kind")
        };
        if contacts.is_empty() {
            anyhow::bail!("failed to find SMS message contacts")
        }
        let Some(date) = date else {
            anyhow::bail!("failed to find date for message")
        };
        Ok(Some(Message {
            kind,
            timestamp: timestamp.to_string(),
            contacts,
            addresses,
            body,
            date,
            date_readable,
            date_sent,
        }))
    }

    fn extract_body_from_mms<'a>(
        &'a self,
        node: Node<'a, 'i>,
    ) -> anyhow::Result<Option<String>> {
        let mut body: Option<String> = None;
        for c in node.descendants() {
            if c.tag_name().name() != "part" {
                continue;
            }
            let Some(content_type) = c.attribute("ct") else { continue };
            if content_type != "text/plain" {
                continue;
            }
            let Some(text) = c.attribute("text") else {
                anyhow::bail!("'text/plain' part node has no 'text' attr")
            };
            if let Some(ref mut body) = body {
                body.push_str(" ... ");
                body.push_str(text);
            } else {
                body = Some(text.to_string());
            }
        }
        Ok(body)
    }
}

#[derive(Clone, Debug, Default)]
struct Config {
    body_regex: Option<Regex>,
    contact_regex: Option<Regex>,
    paths: Vec<PathBuf>,
    reverse: bool,
}

impl Config {
    /// Parse the given OS string args into a `window-grep`
    /// configuration.
    fn parse<I>(args: I) -> anyhow::Result<Config>
    where
        I: IntoIterator<Item = std::ffi::OsString> + 'static,
    {
        use lexopt::{Arg::*, ValueExt};

        const USAGE: &str = "
Usage: searchsms [options] <body-regex> <path> ...

Options:
  -c, --contact <REGEX>
    Only show text messages with a contact name matching the given regex.

  -r, --reverse
    Sort in reverse chronological order.
";

        let mut config = Config::default();
        let mut parser = lexopt::Parser::from_iter(args);
        while let Some(arg) = parser.next()? {
            match arg {
                Short('h') | Long("help") => {
                    anyhow::bail!(USAGE);
                }
                Short('c') | Long("contact") => {
                    let pat = parser.value()?.parse::<String>()?;
                    config.contact_regex = Some(Regex::new(&pat)?);
                }
                Short('r') | Long("reverse") => {
                    config.reverse = true;
                }
                Value(v) => {
                    if config.body_regex.is_none() {
                        let pat = v.parse::<String>()?;
                        config.body_regex = Some(Regex::new(&pat)?);
                    } else {
                        config.paths.push(PathBuf::from(v));
                    }
                }
                _ => return Err(arg.unexpected().into()),
            }
        }
        anyhow::ensure!(
            config.body_regex.is_some(),
            "must provide regex to search body of SMS",
        );
        anyhow::ensure!(
            !config.paths.is_empty(),
            "must provide at least one path"
        );
        Ok(config)
    }
}

fn output_human(
    msgs: &[Message],
    mut wtr: impl std::io::Write,
) -> anyhow::Result<()> {
    let tz = TimeZone::system();
    for (i, msg) in msgs.iter().enumerate() {
        if i > 0 {
            writeln!(wtr, "{}", "-".repeat(79))?;
        }
        match msg.kind {
            MessageKind::Sent => write!(wtr, "   TO: ")?,
            MessageKind::Recv => write!(wtr, " FROM: ")?,
        }
        writeln!(wtr, "{}", msg.contacts.join(", "))?;
        writeln!(wtr, "PHONE: {}", msg.addresses.join(", "))?;
        writeln!(wtr, "STAMP: {}", msg.timestamp)?;
        writeln!(
            wtr,
            " DATE: {}",
            strtime::format("%F %T %Z", &msg.date.to_zoned(tz.clone()))?,
        )?;
        writeln!(wtr, "")?;
        writeln!(wtr, "{}", textwrap::wrap(&msg.body, 79).join("\n"))?;
    }
    Ok(())
}

fn parse_timestamp_seconds(value: &str) -> anyhow::Result<Timestamp> {
    let seconds = value
        .parse::<i64>()
        .context("failed to parse timestamp as seconds")?;
    Timestamp::from_second(seconds).context("invalid timestamp")
}

fn parse_timestamp_millis(value: &str) -> anyhow::Result<Timestamp> {
    let millis = value
        .parse::<i64>()
        .context("failed to parse timestamp as milliseconds")?;
    Timestamp::from_millisecond(millis).context("invalid timestamp")
}

fn parse_readable_date(value: &str) -> anyhow::Result<civil::DateTime> {
    // Example: Apr 1, 2022 20:46:15
    strtime::parse("%h %d, %Y %H:%M:%S", value)
        .context("failed to parse readable date")?
        .to_datetime()
        .context("failed to convert parsed readable date to datetime")
}
