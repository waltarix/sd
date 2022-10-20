use clap::{builder::PossibleValue, Parser};
use clap_complete::Shell;

#[derive(Debug, Parser)]
#[command(version, about, long_about = "An intuitive find & replace CLI")]
pub struct Options {
    /// Output result into stdout and do not modify files.
    #[arg(short = 'p', long = "preview")]
    pub preview: bool,

    /// Treat expressions as non-regex strings.
    #[arg(short = 's', long = "string-mode")]
    pub literal_mode: bool,

    /// Recursively replace files
    #[arg(short = 'r')]
    pub recursive: bool,

    /// Limit the number of replacements
    #[arg(short = 'n')]
    pub replacements: Option<usize>,

    /// Regex flags. May be combined (like `-f mc`).
    #[arg(
        short = 'f',
        long = "flags",
        value_parser([
            PossibleValue::new("c").help("case-sensitive"),
            PossibleValue::new("e").help("disable multi-line matching"),
            PossibleValue::new("i").help("case-insensitive"),
            PossibleValue::new("m").help("multi-line matching"),
            PossibleValue::new("s").help("make `.` match newlines"),
            PossibleValue::new("w").help("match full words only"),
        ]),
    )]
    pub flags: Option<String>,

    /// Generate shell completion script for the specified shell
    #[arg(
        long = "completion",
        value_name = "shell",
        value_parser = clap::value_parser!(Shell),
        conflicts_with_all = ["find", "replace_with"],
    )]
    pub completion: Option<Shell>,

    /// The regexp or string (if -s) to search for.
    #[arg(
        required_unless_present = "completion",
        default_value = "",
        hide_default_value = true
    )]
    pub find: String,

    /// What to replace each match with. Unless in string mode, you may use captured values like $1, $2, etc.
    #[arg(
        required_unless_present = "completion",
        default_value = "",
        hide_default_value = true
    )]
    pub replace_with: String,

    /// The path to file(s). This is optional - sd can also read from STDIN.
    /// {n}Note: sd modifies files in-place by default. See documentation for examples.
    pub files: Vec<std::path::PathBuf>,
}
