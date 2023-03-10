/*
Install:

  cargo install --git https://github.com/BurntSushi/dotfiles sampler

Usage:

  sampler <line-count> <regex> <path>

This program reads all lines from <path> and outputs an equivalent file with
at most <line-count> lines. Those lines are guaranteed to include at least all
lines matching the given regex. Non-matching lines are then randomly selected
from <path> until <line-count> is reached, or until there are no remaining
lines. If <regex> matches more than <line-count> lines, then the program
outputs an error.

The output is guaranteed to produce lines in the same order as the lines in
<path>.

The basic idea of this tool is to create haystacks that contain some subset
of lines that you care about, but where the remaining lines are just randomly
drawn from the lines you don't care about.
*/
use std::{cmp::min, io::Write, path::PathBuf};

use {anyhow::Context, bstr::ByteSlice, regex::bytes::Regex};

fn main() -> anyhow::Result<()> {
    let args: Vec<String> = std::env::args().collect();
    if args.len() != 4 {
        eprintln!("Usage: sampler <line-count> <regex> <path>");
        std::process::exit(1);
    }
    let count = args[1].parse::<usize>().context("<line-count>")?;
    let re = Regex::new(&args[2]).context("<regex>")?;
    let path = PathBuf::from(&args[3]);
    let raw = std::fs::read(&path)?;
    let lines: Vec<&[u8]> = raw.lines_with_terminator().collect();
    let (mut keep, mut sample_from) = (vec![], vec![]);
    for (i, line) in lines.iter().enumerate() {
        if re.is_match(line) {
            keep.push(i);
        } else {
            sample_from.push(i);
        }
    }
    let sample_len = match count.checked_sub(keep.len()) {
        Some(sample_len) => sample_len,
        None => {
            anyhow::bail!(
                "found {} matching lines, which exceeds sample size of {}",
                keep.len(),
                count,
            )
        }
    };
    fastrand::shuffle(&mut sample_from);
    keep.extend_from_slice(&sample_from[..min(sample_from.len(), sample_len)]);
    keep.sort_unstable();

    let mut stdout = std::io::stdout().lock();
    for i in keep {
        stdout.write_all(&lines[i])?;
    }
    Ok(())
}
