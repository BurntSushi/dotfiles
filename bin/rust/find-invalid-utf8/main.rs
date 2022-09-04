use std::{ffi::OsString, fs::File, io::BufRead, path::Path};

use anyhow::Context;
use bstr::{io::BufReadExt, ByteSlice};
use termcolor::{Color, ColorChoice, ColorSpec, WriteColor};

fn main() -> anyhow::Result<()> {
    let mut args: Vec<OsString> = std::env::args_os().skip(1).collect();
    let dir = match args.pop() {
        None => OsString::from("."),
        Some(dir) => {
            anyhow::ensure!(
                args.is_empty(),
                "Usage: find-invalid-utf8 [<dir>]"
            );
            dir
        }
    };
    // Basically just iterate over every line in every file in a directory
    // tree, and if a line contains invalid UTF-8, print it. Invalid UTF-8
    // bytes are colorized and printed in their hexadecimal format.
    //
    // As a heuristic, files containing a NUL byte are assumed to be binary
    // and are skipped.
    let wtr = termcolor::BufferWriter::stdout(ColorChoice::Auto);
    let mut buf = termcolor::Buffer::ansi();
    for result in walkdir::WalkDir::new(dir) {
        let dent = result?;
        if !dent.file_type().is_file() {
            continue;
        }

        let file = File::open(dent.path())
            .with_context(|| format!("{}", dent.path().display()))?;
        let rdr = std::io::BufReader::new(file);

        buf.clear();
        let is_binary = print_utf8_errors(dent.path(), rdr, &mut buf)
            .with_context(|| format!("{}", dent.path().display()))?;
        if !is_binary {
            wtr.print(&buf)?;
        }
    }
    Ok(())
}

/// Print lines that contain bytes that aren't valid UTF-8. Bytes that aren't
/// valid UTF-8 are printed in hexadecimal format.
///
/// This returns true if the reader is suspected of being a binary file. In
/// that case, printing to `wtr` is stopped and `true` is returned.
fn print_utf8_errors<R: BufRead, W: WriteColor>(
    path: &Path,
    mut rdr: R,
    mut wtr: W,
) -> anyhow::Result<bool> {
    let mut is_binary = false;
    let (mut lineno, mut offset) = (1, 0);
    rdr.for_byte_line_with_terminator(|line| {
        if line.find_byte(b'\x00').is_some() {
            is_binary = true;
            return Ok(false);
        }

        let (cur_lineno, cur_offset) = (lineno, offset);
        lineno += 1;
        offset += line.len();
        if line.is_utf8() {
            return Ok(true);
        }
        write!(wtr, "{}:{}:{}:", path.display(), cur_lineno, cur_offset)?;
        for chunk in line.utf8_chunks() {
            if !chunk.valid().is_empty() {
                write!(wtr, "{}", chunk.valid())?;
            }
            if !chunk.invalid().is_empty() {
                let mut color = ColorSpec::new();
                color.set_fg(Some(Color::Red)).set_bold(true);
                wtr.set_color(&color)?;
                for &b in chunk.invalid().iter() {
                    write!(wtr, r"\x{:X}", b)?;
                }
                wtr.reset()?;
            }
        }
        Ok(true)
    })?;
    Ok(is_binary)
}
