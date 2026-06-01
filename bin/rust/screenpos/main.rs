/*!
Install:

  cargo install --path ~/bin/rust/screenpos

Usage:

  screenpos <gohead-head> ...
*/

use std::{
    env,
    ffi::{OsStr, OsString},
    path::PathBuf,
    process::{Command, ExitCode, Stdio},
    thread,
    time::Duration,
};

use anyhow::{anyhow, bail, Context};

fn main() -> ExitCode {
    match try_main() {
        Ok(()) => ExitCode::SUCCESS,
        Err(err) => {
            eprintln!("{err:?}");
            ExitCode::FAILURE
        }
    }
}

fn try_main() -> anyhow::Result<()> {
    let args: Vec<OsString> = env::args_os().skip(1).collect();
    if args.iter().any(|arg| arg == "-h" || arg == "--help") {
        usage();
        return Ok(());
    }
    screenpos(args)
}

fn usage() {
    eprintln!("Usage: screenpos <gohead-head> ...");
}

fn screenpos(args: Vec<OsString>) -> anyhow::Result<()> {
    if args.is_empty() {
        usage();
        bail!("missing gohead head name");
    }
    gohead(["set"].into_iter().map(OsString::from).chain(args.clone()))?;
    thread::sleep(Duration::from_secs(1));

    let hostname = command_output0("myhostname")?;
    match hostname.trim() {
        "duff" | "frink" => {
            kill("dzen-workspaces");
            ignore(Command::new("killall").arg("trayer").status());
            spawn_delayed_trayer(&[
                "--widthtype",
                "pixel",
                "--width",
                "150",
                "--heighttype",
                "pixel",
                "--height",
                "40",
                "--edge",
                "bottom",
                "--align",
                "right",
                "--monitor",
                "1",
                "--SetDockType",
                "true",
            ])?;
            spawn_shell(
                "sleep 1 && \
                 \"$HOME/.config/wingo/scripts/dzen-workspaces/dzen-workspaces\" \
                 | dzen2 -dock -xs 3 -h 40 -fn 'Cousine-18' -ta l \
                   -bg '#ffffff' -y 1170",
            )?;
        }
        "nas2" => {
            kill("dzen-workspaces");
            ignore(Command::new("killall").arg("stalonetray").status());
            spawn_shell(
                "stalonetray \
                   --background '#ffffff' \
                   --icon-size 40 --geometry 1x1-0-0 \
                   --grow-gravity SE --icon-gravity SE",
            )?;
            spawn_shell(
                "\"$HOME/.config/wingo/scripts/dzen-workspaces/dzen-workspaces\" \
                 | dzen2 -dock -xs 3 -h 40 -fn 'Cousine-18' -ta l \
                   -bg '#ffffff' -y 1170",
            )?;
        }
        "bart" | "kang" => {
            let head = if args.iter().any(|arg| arg == "laptop") {
                OsString::from("laptop")
            } else {
                first_head(&args)?
            };
            place_head(&head)?;
        }
        "flanders" | "milhouse" | "wiggum" => {
            place_head(&first_head(&args)?)?;
        }
        "otto" => {
            kill("dzen-workspaces");
            ignore(Command::new("killall").arg("trayer").status());
            spawn_delayed_trayer(&[
                "--widthtype",
                "pixel",
                "--width",
                "150",
                "--heighttype",
                "pixel",
                "--height",
                "40",
                "--edge",
                "bottom",
                "--align",
                "right",
                "--SetDockType",
                "true",
            ])?;

            let tv = gohead_output(["query", "tv"])?;
            let head_height = field(&tv, 4)?
                .parse::<i64>()
                .context("failed to parse gohead tv height")?;
            let y = head_height - 40;
            spawn_shell(&format!(
                "sleep 1 && \
                 \"$HOME/.config/wingo/scripts/dzen-workspaces/dzen-workspaces\" \
                 | dzen2 -dock -xs 2 -h 40 -fn 'Cousine-18' -ta l \
                   -bg '#ffffff' -y {y}"
            ))?;
        }
        other => bail!("Unrecognized machine '{other}'."),
    }
    Ok(())
}

fn place_monitor(monitor: String, geom: Geometry) -> anyhow::Result<()> {
    let mut font = "Cousine:size=18";
    let mut height = 40i64;
    match command_output0("myhostname")?.trim() {
        "kang" | "bart" => {
            font = "Cousine:size=25";
            height = 50;
        }
        _ => {}
    }
    let y = geom.height - height + geom.y;

    let tray_width = 350;
    let bat_width = 700;
    let is_laptop = Command::new("is-laptop")
        .stdin(Stdio::null())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .map(|s| s.success())
        .unwrap_or(false);
    let pager_width = if is_laptop {
        geom.width - bat_width - tray_width
    } else {
        geom.width - tray_width
    };

    kill("dzen2");
    kill("dzen-workspaces");
    kill("stalonetray");

    spawn_shell(&format!(
        "\"$HOME/.config/wingo/scripts/dzen-workspaces/dzen-workspaces\" \
         | dzen2 -dock -xs {monitor} -h {height} -fn '{font}' -ta l \
           -bg '#ffffff' -y {y}"
    ))?;

    if is_laptop {
        spawn_shell(&format!(
            "(while true; do laptop-status && sleep 10s; done) \
             | dzen2 -fn '{font}' -bg '#ffffff' \
               -x {} -y {y} -w {bat_width} -h {height}",
            geom.x + pager_width,
        ))?;
    }

    kill("stalonetray");
    spawn(Command::new("my-stalonetray").args([
        "--monitor",
        &monitor,
        "--icon-size",
        &height.to_string(),
    ]))?;
    Ok(())
}

fn first_head(args: &[OsString]) -> anyhow::Result<OsString> {
    args.first().cloned().ok_or_else(|| anyhow!("missing gohead head name"))
}

fn place_head(head_name: &OsStr) -> anyhow::Result<()> {
    let query =
        gohead_output([OsString::from("query"), head_name.to_os_string()])?;
    let geom = geometry_from_query(&query)?;
    let head_num = head_num(head_name)?;
    place_monitor(head_num, geom)
}

fn head_num(head_name: &OsStr) -> anyhow::Result<String> {
    let tabs = gohead_output(["tabs"])?;
    let needle = head_name.to_string_lossy();
    for line in tabs.lines() {
        let mut fields = line.split('\t');
        let Some(num) = fields.next() else { continue };
        let name = fields.next().unwrap_or("");
        if format!("{num}\t{name}").contains(needle.as_ref()) {
            return Ok(num.to_string());
        }
    }
    bail!("could not find head number for '{}'", needle)
}

#[derive(Debug)]
struct Geometry {
    x: i64,
    y: i64,
    width: i64,
    height: i64,
}

fn geometry_from_query(query: &str) -> anyhow::Result<Geometry> {
    let fields: Vec<&str> = query.trim().split('\t').collect();
    if fields.len() < 5 {
        bail!("unexpected gohead query output: {query:?}");
    }
    Ok(Geometry {
        x: fields[1].parse().context("failed to parse x")?,
        y: fields[2].parse().context("failed to parse y")?,
        width: fields[3].parse().context("failed to parse width")?,
        height: fields[4].parse().context("failed to parse height")?,
    })
}

fn field(output: &str, one_based: usize) -> anyhow::Result<&str> {
    output
        .trim()
        .split('\t')
        .nth(one_based - 1)
        .ok_or_else(|| anyhow!("missing field {one_based} in {output:?}"))
}

fn gohead<I, S>(args: I) -> anyhow::Result<()>
where
    I: IntoIterator<Item = S>,
    S: AsRef<OsStr>,
{
    let status = Command::new(gohead_path())
        .args(args)
        .status()
        .context("failed to run gohead")?;
    if !status.success() {
        bail!("gohead failed with {status}");
    }
    Ok(())
}

fn gohead_output<I, S>(args: I) -> anyhow::Result<String>
where
    I: IntoIterator<Item = S>,
    S: AsRef<OsStr>,
{
    let output = Command::new(gohead_path())
        .args(args)
        .output()
        .context("failed to run gohead")?;
    if !output.status.success() {
        bail!("gohead failed with {}", output.status);
    }
    Ok(String::from_utf8_lossy(&output.stdout).into_owned())
}

fn gohead_path() -> OsString {
    let mut path = home();
    path.push(".gox11/bin/gohead");
    if path.is_file() {
        return path.into_os_string();
    }
    OsString::from("gohead")
}

fn command_output<I, S>(program: &str, args: I) -> anyhow::Result<String>
where
    I: IntoIterator<Item = S>,
    S: AsRef<OsStr>,
{
    let output = Command::new(program)
        .args(args)
        .output()
        .with_context(|| format!("failed to run '{program}'"))?;
    if !output.status.success() {
        bail!("{program} failed with {}", output.status);
    }
    Ok(String::from_utf8_lossy(&output.stdout).into_owned())
}

fn command_output0(program: &str) -> anyhow::Result<String> {
    command_output(program, Vec::<OsString>::new())
}

fn kill(process: &str) {
    ignore(Command::new("my-killall").arg(process).status());
}

fn ignore<T, E>(_result: Result<T, E>) {}

fn spawn_delayed_trayer(args: &[&str]) -> anyhow::Result<()> {
    let command = format!("sleep 1 && exec trayer {}", shell_words(args));
    spawn_shell(&command)
}

fn shell_words(args: &[&str]) -> String {
    args.iter()
        .map(|arg| format!("'{}'", arg.replace('\'', r"'\''")))
        .collect::<Vec<_>>()
        .join(" ")
}

fn spawn_shell(command: &str) -> anyhow::Result<()> {
    let mut cmd = Command::new("sh");
    cmd.arg("-c")
        .arg(command)
        .env("PATH", shell_path())
        .stdin(Stdio::null())
        .stdout(Stdio::null());
    spawn(&mut cmd)
}

fn spawn(command: &mut Command) -> anyhow::Result<()> {
    command.spawn().context("failed to spawn command")?;
    Ok(())
}

fn shell_path() -> OsString {
    let mut gox11 = home();
    gox11.push(".gox11/bin");
    let mut path = gox11.into_os_string();
    path.push(":");
    path.push(env::var_os("PATH").unwrap_or_default());
    path
}

fn home() -> PathBuf {
    env::var_os("HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from("/"))
}
