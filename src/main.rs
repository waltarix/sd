mod cli;
mod error;
mod input;
mod replacer;
mod utils;

use crate::error::{Error, Result};
use crate::input::{App, Source};
use crate::replacer::Replacer;

use crate::cli::Options;
use clap::{CommandFactory, Parser};
use clap_complete::generate;

fn main() -> Result<()> {
    let options = Options::parse();

    if let Some(shell) = options.completion {
        generate(shell, &mut Options::command(), "sd", &mut std::io::stdout());
        return Ok(());
    }

    let source = if options.recursive {
        Source::recursive()?
    } else if !options.files.is_empty() {
        Source::Files(options.files)
    } else {
        Source::Stdin
    };

    App::new(
        source,
        Replacer::new(
            options.find,
            options.replace_with,
            options.literal_mode,
            options.flags,
            options.replacements,
        )?,
    )
    .run(options.preview)?;

    Ok(())
}
