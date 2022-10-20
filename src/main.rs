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
use clap_complete::{generate, Shell};

fn main() -> Result<()> {
    let options = Options::parse();

    if let Some(shell) = options.completion {
        return print_completion(shell);
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

fn print_completion(shell: Shell) -> Result<()> {
    let mut buf = Vec::new();
    generate(shell, &mut Options::command(), "sd", &mut buf);

    let completion = std::str::from_utf8(buf.as_slice()).unwrap();

    match shell {
        Shell::Zsh => {
            let re = regex::Regex::new("(::(?:find|replace_with|files)) -- .+:").unwrap();
            println!("{}", re.replace_all(completion, "${1}:"))
        }
        _ => println!("{}", completion),
    }

    Ok(())
}
