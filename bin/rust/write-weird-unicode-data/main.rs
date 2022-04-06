// Currently this program just writes all Unicode codepoints to stdout.

use std::io::{self, Write};

use anyhow::Context;

fn main() -> anyhow::Result<()> {
    let stdout = io::stdout();
    let mut bufwtr = io::BufWriter::new(stdout.lock());

    let _ = Args::parse()?;
    for cp in 0..=0x10FFFF {
        let ch = match char::from_u32(cp) {
            None => continue,
            Some(cp) => cp,
        };
        bufwtr
            .write_all(ch.encode_utf8(&mut [0; 4]).as_bytes())
            .context("failed to write to stdout")?;
    }
    Ok(())
}

#[derive(Debug)]
struct Args {}

impl Args {
    fn parse() -> anyhow::Result<Args> {
        use clap::{crate_authors, crate_version, App};

        let _ = App::new("Write weird Unicode data to stdout.")
            .author(crate_authors!())
            .version(crate_version!())
            .max_term_width(80)
            .get_matches();

        Ok(Args {})
    }
}
