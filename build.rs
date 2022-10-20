use clap::CommandFactory;

include!("src/cli.rs");

fn main() -> Result<(), std::io::Error> {
    let man = clap_mangen::Man::new(Options::command());
    let mut buffer: Vec<u8> = Default::default();
    man.render(&mut buffer)?;

    std::fs::write("sd.1", buffer)?;

    Ok(())
}
