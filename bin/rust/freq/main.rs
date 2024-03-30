/*!
Install:

  cargo install --git https://github.com/BurntSushi/dotfiles sampler

Usage:

  freq [options] [<path> ...]

See `freq --help` for more detail.
*/

#![allow(warnings)]

use std::{
    borrow::Cow,
    io::Write,
    path::{Path, PathBuf},
};

use {
    anyhow::Context, bstr::ByteSlice, regex::bytes::Regex,
    rustc_hash::FxHashMap,
};

fn main() -> anyhow::Result<()> {
    let config = Config::parse(std::env::args_os())?;
    let mut freqs = Freqs::new(&config);
    for path in config.paths.iter() {
        if path == Path::new("-") {
            let data = read_stdin()?;
            freqs.add_data(&config, &data);
            continue;
        }
        for result in walkdir::WalkDir::new(path) {
            let dent = result?;
            if !dent.file_type().is_file() {
                continue;
            }
            let data = std::fs::read(dent.path())
                .with_context(|| format!("{}", dent.path().display()))?;
            if config.skip_binary {
                let look_for_nul_upto = &data[..data.len().min(1 << 20)];
                if memchr::memchr(0, look_for_nul_upto).is_some() {
                    continue;
                }
            }
            freqs.add_data(&config, &data);
        }
    }

    let mut table = freqs.into_table(&config);
    if config.reverse {
        table.rows.sort_unstable_by_key(|row| row.freq);
    } else {
        table.rows.sort_unstable_by(|r1, r2| r1.freq.cmp(&r2.freq).reverse())
    }

    let mut out = tabwriter::TabWriter::new(std::io::stdout().lock())
        .alignment(tabwriter::Alignment::Left);
    for row in table.rows.into_iter().take(config.count) {
        let percent = 100.0 * ((row.freq as f64) / (table.total as f64));
        row.atom.write(&mut out)?;
        writeln!(out, "\t{}\t{:0.03}%", row.freq, percent)?;
    }
    out.flush()?;
    Ok(())
}

type Writer = tabwriter::TabWriter<std::io::StdoutLock<'static>>;

#[derive(Default)]
struct Table {
    total: u64,
    rows: Vec<Row>,
}

struct Row {
    atom: Atom,
    freq: u64,
}

enum Freqs {
    Bytes(FreqsBytes),
    Codepoint(FreqsOther),
    Grapheme(FreqsOther),
    Word(FreqsOther),
}

impl Freqs {
    fn new(config: &Config) -> Freqs {
        match config.unit {
            Unit::Byte => Freqs::Bytes(FreqsBytes::new(config)),
            Unit::Codepoint => Freqs::Codepoint(FreqsOther::new(config)),
            Unit::Grapheme => Freqs::Grapheme(FreqsOther::new(config)),
            Unit::Word => Freqs::Word(FreqsOther::new(config)),
        }
    }

    fn add_data(&mut self, config: &Config, data: &[u8]) {
        match *self {
            Freqs::Bytes(ref mut f) => {
                // For bytes, our raw data is our units.
                f.add_units(config, data);
            }
            Freqs::Codepoint(ref mut f) => {
                let codepoints: Vec<&[u8]> =
                    data.char_indices().map(|(s, e, _)| &data[s..e]).collect();
                f.add_units(config, &codepoints);
            }
            Freqs::Grapheme(ref mut f) => {
                let graphemes: Vec<&[u8]> =
                    data.graphemes().map(|s| s.as_bytes()).collect();
                f.add_units(config, &graphemes);
            }
            Freqs::Word(ref mut f) => {
                let words: Vec<&[u8]> =
                    data.words().map(|s| s.as_bytes()).collect();
                f.add_units(config, &words);
            }
        }
    }

    fn into_table(self, config: &Config) -> Table {
        match self {
            Freqs::Bytes(f) => f.into_table(config),
            Freqs::Codepoint(f) => f.into_table(config),
            Freqs::Grapheme(f) => f.into_table(config),
            Freqs::Word(f) => f.into_table(config),
        }
    }
}

enum FreqsBytes {
    Single(FreqsBytesSingle),
    Many(FreqsBytesMany),
}

impl FreqsBytes {
    fn new(config: &Config) -> FreqsBytes {
        if config.length == 1 {
            FreqsBytes::Single(FreqsBytesSingle::default())
        } else {
            FreqsBytes::Many(FreqsBytesMany::default())
        }
    }

    fn add_units(&mut self, config: &Config, units: &[u8]) {
        match *self {
            FreqsBytes::Single(ref mut f) => f.add_units(config, units),
            FreqsBytes::Many(ref mut f) => f.add_units(config, units),
        }
    }

    fn into_table(self, config: &Config) -> Table {
        match self {
            FreqsBytes::Single(f) => f.into_table(config),
            FreqsBytes::Many(f) => f.into_table(config),
        }
    }
}

enum FreqsOther {
    Single(FreqsOtherSingle),
    Many(FreqsOtherMany),
}

impl FreqsOther {
    fn new(config: &Config) -> FreqsOther {
        if config.length == 1 {
            FreqsOther::Single(FreqsOtherSingle::default())
        } else {
            FreqsOther::Many(FreqsOtherMany::default())
        }
    }

    fn add_units(&mut self, config: &Config, units: &[&[u8]]) {
        match *self {
            FreqsOther::Single(ref mut f) => f.add_units(config, units),
            FreqsOther::Many(ref mut f) => f.add_units(config, units),
        }
    }

    fn into_table(self, config: &Config) -> Table {
        match self {
            FreqsOther::Single(f) => f.into_table(config),
            FreqsOther::Many(f) => f.into_table(config),
        }
    }
}

struct FreqsBytesSingle {
    /// Always has length == 256.
    map: Vec<u64>,
}

impl Default for FreqsBytesSingle {
    fn default() -> FreqsBytesSingle {
        FreqsBytesSingle { map: vec![0; 256] }
    }
}

impl FreqsBytesSingle {
    fn add_units(&mut self, config: &Config, units: &[u8]) {
        assert_eq!(config.length, 1);
        assert_eq!(config.unit, Unit::Byte);
        if config.case_insensitive {
            for atom in units.iter().copied() {
                let atom = atom.to_ascii_lowercase();
                self.map[usize::from(atom)] += 1;
            }
        } else {
            for atom in units.iter().copied() {
                self.map[usize::from(atom)] += 1;
            }
        }
    }

    fn into_table(self, config: &Config) -> Table {
        let mut table = Table::default();
        for unit in 0u8..=255 {
            let freq = self.map[usize::from(unit)];
            table.total += freq;

            if !config.include_unit(std::slice::from_ref(&unit)) {
                continue;
            }
            let atom = Atom::Byte(unit);
            table.rows.push(Row { atom, freq });
        }
        table
    }
}

#[derive(Default)]
struct FreqsBytesMany {
    map: FxHashMap<Vec<u8>, u64>,
}

impl FreqsBytesMany {
    fn add_units(&mut self, config: &Config, units: &[u8]) {
        assert!(config.length > 1);
        assert_eq!(config.unit, Unit::Byte);

        match (config.case_insensitive, config.overlapping) {
            (false, false) => {
                for chunk in units.chunks(config.length) {
                    let atom = chunk.to_vec();
                    *self.map.entry(atom).or_insert(0) += 1;
                }
            }
            (false, true) => {
                for window in units.windows(config.length) {
                    let atom = window.to_vec();
                    *self.map.entry(atom).or_insert(0) += 1;
                }
            }
            (true, false) => {
                for chunk in units.chunks(config.length) {
                    let atom = chunk.to_ascii_lowercase();
                    *self.map.entry(atom).or_insert(0) += 1;
                }
            }
            (true, true) => {
                for window in units.windows(config.length) {
                    let atom = window.to_ascii_lowercase();
                    *self.map.entry(atom).or_insert(0) += 1;
                }
            }
        }
    }

    fn into_table(self, config: &Config) -> Table {
        let mut table = Table::default();
        for (unit, freq) in self.map {
            table.total += freq;
            if !config.include_unit(&unit) {
                continue;
            }
            let atom = Atom::Single(unit);
            table.rows.push(Row { atom, freq });
        }
        table
    }
}

#[derive(Default)]
struct FreqsOtherSingle {
    map: FxHashMap<Vec<u8>, u64>,
}

impl FreqsOtherSingle {
    fn add_units(&mut self, config: &Config, units: &[&[u8]]) {
        assert_eq!(config.length, 1);

        if config.case_insensitive {
            for unit in units.iter().copied() {
                let atom = unit.to_lowercase();
                *self.map.entry(atom).or_insert(0) += 1;
            }
        } else {
            for unit in units.iter().copied() {
                let atom = unit.to_vec();
                *self.map.entry(atom).or_insert(0) += 1;
            }
        }
    }

    fn into_table(self, config: &Config) -> Table {
        let mut table = Table::default();
        for (unit, freq) in self.map {
            table.total += freq;
            if !config.include_unit(&unit) {
                continue;
            }
            let atom = Atom::Single(unit);
            table.rows.push(Row { atom, freq });
        }
        table
    }
}

#[derive(Default)]
struct FreqsOtherMany {
    map: FxHashMap<Vec<Vec<u8>>, u64>,
}

impl FreqsOtherMany {
    fn add_units(&mut self, config: &Config, units: &[&[u8]]) {
        assert!(config.length > 1);

        match (config.case_insensitive, config.overlapping) {
            (false, false) => {
                for chunk in units.chunks(config.length) {
                    let atom =
                        chunk.iter().copied().map(|c| c.to_vec()).collect();
                    *self.map.entry(atom).or_insert(0) += 1;
                }
            }
            (false, true) => {
                for window in units.windows(config.length) {
                    let atom =
                        window.iter().copied().map(|c| c.to_vec()).collect();
                    *self.map.entry(atom).or_insert(0) += 1;
                }
            }
            (true, false) => {
                for chunk in units.chunks(config.length) {
                    let mut atom = vec![];
                    for unit in chunk.iter().copied() {
                        atom.push(unit.to_lowercase());
                    }
                    *self.map.entry(atom).or_insert(0) += 1;
                }
            }
            (true, true) => {
                for window in units.windows(config.length) {
                    let mut atom = vec![];
                    for unit in window.iter().copied() {
                        atom.push(unit.to_lowercase());
                    }
                    *self.map.entry(atom).or_insert(0) += 1;
                }
            }
        }
    }

    fn into_table(self, config: &Config) -> Table {
        let mut table = Table::default();
        for (units, freq) in self.map {
            use std::fmt::Write;

            table.total += freq;
            if !units.iter().all(|unit| config.include_unit(&unit)) {
                continue;
            }
            let atom = Atom::Multi(units);
            table.rows.push(Row { atom, freq });
        }
        table
    }
}

enum Atom {
    Byte(u8),
    Single(Vec<u8>),
    Multi(Vec<Vec<u8>>),
}

impl Atom {
    fn write(self, wtr: &mut Writer) -> std::io::Result<()> {
        match self {
            Atom::Byte(atom) => {
                let slice = std::slice::from_ref(&atom);
                write!(wtr, "{}", slice.escape_bytes())
            }
            Atom::Single(atom) => {
                write!(wtr, "{}", atom.escape_bytes())
            }
            Atom::Multi(atom) => {
                write!(wtr, "[")?;
                for (i, unit) in atom.into_iter().enumerate() {
                    if i > 0 {
                        write!(wtr, ", ")?;
                    }
                    write!(wtr, "{}", unit.escape_bytes())?;
                }
                write!(wtr, "]")
            }
        }
    }
}

/// The configuration parsed from the CLI.
#[derive(Clone, Debug)]
struct Config {
    paths: Vec<PathBuf>,
    case_insensitive: bool,
    overlapping: bool,
    length: usize,
    unit: Unit,
    count: usize,
    reverse: bool,
    min: Option<usize>,
    max: Option<usize>,
    regex: Option<Regex>,
    skip_binary: bool,
}

impl Config {
    /// Parse the given OS string args into a `Config`.
    fn parse<I>(args: I) -> anyhow::Result<Config>
    where
        I: IntoIterator<Item = std::ffi::OsString> + 'static,
    {
        use lexopt::{Arg::*, ValueExt};

        const USAGE: &str = r#"
Usage: freq [options] [<path> ...]

This command transforms the input from stdin into one or more units, where
a unit is determined by the `--unit` flag. A unit can be a byte, codepoint,
grapheme cluster or word. Units are then combined into atoms according to the
`--case-insensitive`, `--overlapping` and `--length` flags. The default is that
every non-overlapping unit corresponds to a single atom. The atoms are then
ranked according to their frequency.

The default behavior of this command is to print the frequency distribution of
case sensitive words in the input.

Note that this consumes all data from stdin before the input is divided into
units.

Options:
  -i, --case-insensitive
    When true, "simple" Unicode case folding is applied. For example, when
    this flag is given, the atoms `BAR` and `bar` are treated as equivalent.

    This is achieved by normalizing the atoms by converting them all to
    lowercase. This isn't strictly correct, but probably good enough in most
    cases. ("default" case folding should be used instead.)

  -o, --overlapping
    When true, the collection of atoms is expanded to include all possible
    overlappings. When disabled, atoms are determined by non-overlapping
    sequences when read from a lower memory address to a higher memory
    address.

  -l, --length <number>
    The number of units to concatenate to make up an atom.

    The default length is `1`.

  -u, --unit <byte | codepoint | grapheme | word>
    The type of unit to use.

    The default unit is `word`.

    When unit is `byte`, atoms are determined by a fixed length of bytes. For
    example, `--length 2 --unit byte --overlapping` on the corpus `abcd` would
    collect the following atoms: `ab`, `bc` and `cd`.

    When unit is `codepoint`, atoms are determined by a fixed length of
    codepoints (more precisely, Unicode scalar values). For example,
    `--length 2 --unit codepoint --overlapping` on the corpus `πεδμ` would
    collect the following atoms: `πε`, `εδ` and `δμ`.

    When unit is `grapheme`, atoms are determined by a fixed length of grapheme
    clusters. For example, `--length 2 --unit grapheme --overlapping` on the
    corpus `àb̀c̀d̀` would collect the following atoms: `àb̀`, `b̀c̀` and
    `c̀d̀`. Note that each character in `àb̀c̀d̀` is written in decomposed
    normal form so that each character is made up of two distinct Unicode
    scalar values. For example, `à` is `U+0061 U+0300`.

    When unit is `word`, atoms are determined by a fixed length of words. For
    example, `--length 2 --unit word --overlapping` on the corpus `foo bar quux
    baz` would collect the following atoms: `foo bar`, `bar quux` and `quux
    baz`.

  -n, --count <number>
    Limits the number of atoms to show to the top most frequently occurring
    atoms. If, if -r/--reverse is given, then the top least frequently
    occurring atoms that occur at least once. (Except in the case of bytes of
    length 1. Since the number of possible bytes is small, even bytes that
    never appear will be included in the output.)

    When set to `0`, no limit will be imposed. All atoms and their counts will
    be printed in the output.

    The default is to show the top 20 most frequently occurring atoms.

  -r, --reverse
    When given, the top least frequently occurring atoms will be shown. This
    only includes atoms that occur at least once except when the unit is
    `byte` and the length is `1`. In that case, bytes that never occur are
    included in the ranking.

  --min <number>
    The minimum length of a unit. Atoms with any unit less than this length
    will be omitted from the output. They will still however be counted
    and used to compute the percent of total for all other atoms.

    This has no effect for `byte` units. For `codepoint` units, this applies
    to the number of bytes in the UTF-8 encoding of that codepoint. For
    `grapheme` units, this applies to the number of codepoints in the grapheme
    cluster. For `word` units, this applies to the number of grapheme clusters
    in the word.

  --max <number>
    The maximum length of a unit. Atoms with any unit greater than this length
    will be omitted from the output. They will still however be counted
    and used to compute the percent of total for all other atoms.

    This has no effect for `byte` units. For `codepoint` units, this applies
    to the number of bytes in the UTF-8 encoding of that codepoint. For
    `grapheme` units, this applies to the number of codepoints in the grapheme
    cluster. For `word` units, this applies to the number of grapheme clusters
    in the word.

  -e, --regex <pattern>
    A regex to apply to each of the units in an atom. If any unit in an atom
    does not match this regex, then the atom is omitted from the output. They
    will still however be counted and used to compute the percent of total
    for all other atoms.

  --skip-binary
    When given, files with a NUL byte will be skipped entirelty. Otherwise,
    frequency distributions will be computed for any kind of data, including
    binary data.

    Note that this doesn't apply to stdin. Frequency distributions are always
    computed for stdin, even if this flag is given and stdin contains a NUL
    byte.
"#;

        let mut config = Config::default();
        let mut parser = lexopt::Parser::from_iter(args);
        while let Some(arg) = parser.next()? {
            match arg {
                Short('h') | Long("help") => {
                    anyhow::bail!(USAGE);
                }
                Short('i') | Long("case-insensitive") => {
                    config.case_insensitive = true;
                }
                Short('o') | Long("overlapping") => {
                    config.overlapping = true;
                }
                Short('l') | Long("length") => {
                    let length = parser.value()?.parse::<usize>()?;
                    anyhow::ensure!(length >= 1, "length must be at least 1");
                    config.length = length;
                }
                Short('u') | Long("unit") => {
                    let val = parser.value()?.parse::<String>()?;
                    config.unit = match &*val {
                        "byte" => Unit::Byte,
                        "codepoint" => Unit::Codepoint,
                        "grapheme" => Unit::Grapheme,
                        "word" => Unit::Word,
                        unk => anyhow::bail!("unrecognized unit {unk:?}"),
                    };
                }
                Short('n') | Long("count") => {
                    let count = parser.value()?.parse::<usize>()?;
                    config.count = if count == 0 { usize::MAX } else { count };
                }
                Short('r') | Long("reverse") => {
                    config.reverse = true;
                }
                Long("min") => {
                    let min = parser.value()?.parse::<usize>()?;
                    config.min = Some(min);
                }
                Long("max") => {
                    let max = parser.value()?.parse::<usize>()?;
                    config.min = Some(max);
                }
                Short('e') | Long("regex") => {
                    let pat = parser.value()?.parse::<String>()?;
                    config.regex = Some(Regex::new(&pat)?);
                }
                Long("skip-binary") => {
                    config.skip_binary = true;
                }
                Value(path) => {
                    config.paths.push(PathBuf::from(path));
                }
                _ => return Err(arg.unexpected().into()),
            }
        }
        if config.paths.is_empty() {
            config.paths.push(PathBuf::from("-"));
        }
        Ok(config)
    }

    fn include_unit(&self, unit: &[u8]) -> bool {
        self.include_unit_range(unit) && self.include_unit_regex(unit)
    }

    fn include_unit_range(&self, unit: &[u8]) -> bool {
        let range = match (self.min, self.max) {
            (None, None) => return true,
            (Some(min), None) => min..=usize::MAX,
            (None, Some(max)) => 0..=max,
            (Some(min), Some(max)) => min..=max,
        };
        let len = match self.unit {
            Unit::Byte => return true,
            Unit::Codepoint => unit.len(),
            Unit::Grapheme => unit.chars().count(),
            Unit::Word => unit.graphemes().count(),
        };
        range.contains(&len)
    }

    fn include_unit_regex(&self, unit: &[u8]) -> bool {
        let Some(re) = self.regex.as_ref() else { return true };
        re.is_match(unit)
    }
}

impl Default for Config {
    fn default() -> Config {
        Config {
            paths: vec![],
            case_insensitive: false,
            overlapping: false,
            length: 1,
            unit: Unit::default(),
            count: 20,
            reverse: false,
            min: None,
            max: None,
            regex: None,
            skip_binary: false,
        }
    }
}

/// The atom units that we support.
#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
enum Unit {
    Byte,
    Codepoint,
    Grapheme,
    #[default]
    Word,
}

/// Reads all of stdin into memory.
fn read_stdin() -> anyhow::Result<Vec<u8>> {
    use std::io::Read;

    let mut data = vec![];
    std::io::stdin()
        .lock()
        .read_to_end(&mut data)
        .context("failed to read from stdin")?;
    Ok(data)
}
