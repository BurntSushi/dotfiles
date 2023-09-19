// Install:
//
//   cargo install --git https://github.com/BurntSushi/dotfiles ppbinary
//
// Usage:
//
//   cat some-binary-data | ppbinary
//
// Basically, this is a stupid simple program for printing binary data using
// the bstr crate's formatting routine.

use std::io::{Read, Write};

use bstr::ByteSlice;

fn main() -> anyhow::Result<()> {
    let mut data = vec![];
    std::io::stdin().lock().read_to_end(&mut data)?;
    writeln!(&mut std::io::stdout(), "{:?}", data.as_bstr())?;
    Ok(())
}
