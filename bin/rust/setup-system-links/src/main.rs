#[cfg(not(unix))]
compile_error!("setup-system-links only works on Unix systems");

use std::collections::{BTreeMap, BTreeSet};
use std::env;
use std::ffi::{OsStr, OsString};
use std::io::{self, Write};
#[cfg(unix)]
use std::os::unix;
use std::path::{Path, PathBuf};

use anyhow::Context;
use bstr::{BString, ByteSlice, ByteVec};
use walkdir::WalkDir;

fn main() -> anyhow::Result<()> {
    let args = Args::parse()?;
    let mut links = Links::discover(&args.system, &args.hostname)?;
    if let Some(ref backup_dir) = args.backup {
        links.backup(backup_dir.to_owned());
    }
    if args.dry_run {
        links.dry_run(std::io::stdout())?;
    } else {
        links.run(std::io::stdout())?;
    }
    Ok(())
}

/// Represents a collection of links derived from this machine's ~/system
/// directory.
#[derive(Debug)]
struct Links {
    links: Vec<Link>,
    backup: Option<PathBuf>,
}

impl Links {
    /// Determine the full set of system config links for this machine given
    /// the system configuration directory and this machine's hostname.
    fn discover(system: &Path, hostname: &str) -> anyhow::Result<Links> {
        // Collect all leaf files in ~/system, creating a map, e.g.,
        // etc/default/grub |--> {default, krusty, frink, ...}
        // Note that the key lack the leading slash. We add that below.
        let mut all: BTreeMap<PathBuf, BTreeSet<String>> = BTreeMap::new();
        for result in WalkDir::new(system) {
            let dent = result.with_context(|| {
                format!("{}: failed to walk directory", system.display())
            })?;
            if dent.file_type().is_dir() {
                continue;
            }

            let machine_config_name = dent
                .file_name()
                .to_str()
                .with_context(|| {
                    format!("{} is not valid UTF-8", dent.path().display())
                })?
                .to_string();
            // Should never fail since 'system' is our root and is guaranteed
            // to be non-empty.
            let dst = dent
                .path()
                .strip_prefix(system)
                .unwrap()
                .parent()
                .unwrap()
                .to_path_buf();
            if dst.as_os_str().is_empty() {
                // These are files directly in ~/system/ like
                // ~/system/README.md and are not part of our config.
                continue;
            }
            all.entry(dst)
                .or_insert_with(|| BTreeSet::new())
                .insert(machine_config_name);
        }
        // Now organize them into links by choosing the appropriate specific
        // config for this machine.
        let mut links = vec![];
        for (relative_dst, configs) in all {
            let dst = Path::new("/").join(&relative_dst);
            for &attempt in &[hostname, "default"] {
                if configs.contains(attempt) {
                    let src = system.join(relative_dst).join(attempt);
                    links.push(Link { src, dst });
                    break;
                }
            }
        }
        Ok(Links { links, backup: None })
    }

    /// Indicates that the destination of each link should be backed up
    /// first.
    fn backup(&mut self, dir: PathBuf) {
        self.backup = Some(dir);
    }

    /// Create the links that do not yet exist.
    ///
    /// When backup is enabled (the default), then all config files will be
    /// backed up before attempting any link. If any backup fails, then no
    /// link will be created.
    ///
    /// The equivalent Unix command to each operation will be written to the
    /// given writer (like during a dry run).
    fn run<W: Write>(&self, mut wtr: W) -> anyhow::Result<()> {
        let mut to_link = vec![];
        for link in &self.links {
            if link.exists()? {
                continue;
            }
            to_link.push(link);
        }
        if let Some(ref backup_dir) = self.backup {
            for link in &to_link {
                link.backup(&mut wtr, backup_dir)?;
            }
        }
        for link in to_link {
            link.link(&mut wtr)?;
        }
        Ok(())
    }

    /// Print the equivalent Unix commands that this would execute if we were
    /// running for real, but make no changes to the file system.
    fn dry_run<W: Write>(&self, mut wtr: W) -> anyhow::Result<()> {
        let mut to_link = vec![];
        for link in &self.links {
            if link.exists()? {
                continue;
            }
            to_link.push(link);
        }
        if let Some(ref backup_dir) = self.backup {
            for link in &to_link {
                link.dry_backup(&mut wtr, backup_dir)?;
            }
        }
        for link in to_link {
            link.dry_link(&mut wtr)?;
        }
        Ok(())
    }
}

/// Represents a link between a file in ~/system and an actual system
/// configuration path on the system. e.g., ~/system/etc/default/grub/krusty
/// will link to /etc/default/grub on my 'krusty' laptop.
#[derive(Debug)]
struct Link {
    /// The ~/system/ path to this machine's config.
    src: PathBuf,
    /// The path to where this config lives on the system.
    dst: PathBuf,
}

impl Link {
    /// Write the equivalent Unix command we would execute if we were running
    /// for real.
    fn dry_link<W: Write>(&self, mut wtr: W) -> io::Result<()> {
        writeln!(
            wtr,
            "ln \"{}\" \"{}\"",
            self.src.display(),
            self.dst.display()
        )
    }

    /// Write the equivalent Unix command we would execute to backup the config
    /// file if we were running for real.
    fn dry_backup<W: Write>(&self, mut wtr: W, dir: &Path) -> io::Result<()> {
        if !self.dst.exists() {
            return Ok(());
        }
        let backup_dst = dir.join(self.relative_dst());
        // OK since self.dst is guaranteed to be non-empty.
        let parent = backup_dst.parent().unwrap();
        writeln!(wtr, "mkdir -p \"{}\"", parent.display(),)?;
        writeln!(
            wtr,
            "cp \"{}\" \"{}\"",
            self.dst.display(),
            backup_dst.display()
        )
    }

    /// Link the source to the destination, overwriting the destination if it
    /// exists. Callers should ensure that the destination is backed up before
    /// executing.
    fn link<W: Write>(&self, wtr: W) -> anyhow::Result<()> {
        if self.dst.exists() {
            std::fs::remove_file(&self.dst).with_context(|| {
                format!(
                    "failed to delete {} before creating symlink from {}",
                    self.dst.display(),
                    self.src.display()
                )
            })?;
        }
        unix::fs::symlink(&self.src, &self.dst).with_context(|| {
            format!(
                "failed to link {} to {}",
                self.src.display(),
                self.dst.display()
            )
        })?;
        self.dry_link(wtr)?;
        Ok(())
    }

    /// Backup the destination to the directory given.
    fn backup<W: Write>(&self, wtr: W, dir: &Path) -> anyhow::Result<()> {
        if !self.dst.exists() {
            return Ok(());
        }

        let backup_dst = dir.join(self.relative_dst());
        // OK since self.dst is guaranteed to be non-empty.
        let parent = backup_dst.parent().unwrap();
        std::fs::create_dir_all(parent).with_context(|| {
            format!(
                "failed to create parent directory {} for backup",
                parent.display()
            )
        })?;
        std::fs::copy(&self.dst, &backup_dst).with_context(|| {
            format!(
                "failed to backup {} to {}",
                self.dst.display(),
                backup_dst.display()
            )
        })?;
        self.dry_backup(wtr, dir)?;
        Ok(())
    }

    /// Returns true if and only if this link already exists in the file
    /// system. That is, when the src and dst refer to the same underlying
    /// file.
    fn exists(&self) -> anyhow::Result<bool> {
        if !self.dst.exists() {
            return Ok(false);
        }
        same_file::is_same_file(&self.src, &self.dst).with_context(|| {
            format!(
                "failed to determine if {} == {}",
                self.src.display(),
                self.dst.display(),
            )
        })
    }

    /// Returns the destination path without its leading /.
    fn relative_dst(&self) -> &Path {
        // OK because dst is always absolute, by construction.
        self.dst.strip_prefix("/").unwrap()
    }
}

#[derive(Debug)]
struct Args {
    /// The directory in which to copy the contents of system configuration
    /// files before removing them and putting a symlink in its place.
    backup: Option<PathBuf>,
    /// When true, make no changes to the file system and instead print what
    /// we would do instead.
    dry_run: bool,
    /// The hostname of this machine (possibly derived from ~/.myhostname).
    hostname: String,
    /// The path to the directory containing this machine's system
    /// configuration. This is currently hard-coded to ~/system.
    system: PathBuf,
}

impl Args {
    fn parse() -> anyhow::Result<Args> {
        use clap::{crate_authors, crate_version, App, Arg};

        let parsed = App::new("Install system configuration symlinks.")
            .author(crate_authors!())
            .version(crate_version!())
            .max_term_width(80)
            .arg(Arg::with_name("no-backup").long("no-backup"))
            .arg(Arg::with_name("dry-run").long("dry-run"))
            .get_matches();

        let home = match env::var_os("HOME") {
            None => anyhow::bail!("HOME environment variable not set"),
            Some(home) => PathBuf::from(home),
        };
        let system = home.join("system");
        if !system.is_dir() {
            anyhow::bail!(
                "{}: system directory does not exist",
                system.display()
            );
        }

        let dry_run = parsed.is_present("dry-run");
        let hostname = runcmd(&["myhostname"])?;
        let backup = if parsed.is_present("no-backup") {
            None
        } else if dry_run {
            let parent = home.join("tmp").join("setup-system-links-backup");
            Some(parent.join("backup-{timestamp}"))
        } else {
            let parent = home.join("tmp").join("setup-system-links-backup");
            Some(
                create_unique_dir_in(parent, "backup")
                    .context("failed to create backup directory")?,
            )
        };
        Ok(Args { backup, dry_run, hostname, system })
    }
}

fn runcmd<A: AsRef<OsStr>>(
    argv: impl IntoIterator<Item = A>,
) -> anyhow::Result<String> {
    let args: Vec<OsString> =
        argv.into_iter().map(|a| a.as_ref().to_os_string()).collect();
    let output = std::process::Command::new(&args[0])
        .args(&args[1..])
        .output()
        .context("failed to run 'myhostname'")?;
    if !output.status.success() {
        let stderr = BString::from(output.stderr.trim().to_vec());
        let args: Vec<Vec<u8>> = args
            .into_iter()
            .map(|a| Vec::from_os_str_lossy(&a).into_owned())
            .collect();
        let mut command = BString::from(bstr::join(" ", args));
        if let Some(code) = output.status.code() {
            command =
                BString::from(format!("`{}` (exit code {})", command, code));
        } else {
            command = BString::from(format!("`{}`", command));
        }
        anyhow::bail!("failed to run {}, stderr:\n\n{}", command, stderr)
    }

    let stdout = output
        .stdout
        .to_str()
        .context("hostname is not valid UTF-8")?
        .trim()
        .to_string();
    Ok(stdout)
}

fn create_unique_dir_in<P: AsRef<Path>, S: AsRef<str>>(
    parent: P,
    prefix: S,
) -> anyhow::Result<PathBuf> {
    use std::time::{Duration, SystemTime};

    let parent = parent.as_ref();
    let prefix = prefix.as_ref();
    std::fs::create_dir_all(&parent).with_context(|| {
        format!("{}: failed to create parent directory", parent.display())
    })?;
    for _ in 0..100 {
        let ts = SystemTime::now()
            .duration_since(SystemTime::UNIX_EPOCH)
            .context("system time is borked")?;
        let name =
            format!("{}-{}-{}", prefix, ts.as_secs(), ts.subsec_nanos());
        let dir = parent.join(name);
        if std::fs::create_dir(&dir).is_err() {
            std::thread::sleep(Duration::from_secs(1));
            continue;
        }
        return Ok(dir);
    }
    anyhow::bail!(
        "failed to create unique directory inside of {}",
        parent.display()
    );
}
