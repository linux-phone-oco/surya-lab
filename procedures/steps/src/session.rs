// SPDX-License-Identifier: MIT OR Apache-2.0
//! The steps' bodies: each reaches the phone only through lpoco (phone() on the runner, `lpoco lab` for the
//! host's side) and returns a Result that stops the run. Nothing here reads like the procedure; main does.

use crate::checks::*;
use lpoco_attended::steps::runs_kernel;
use lpoco_attended::{phone, proc, retry};
use std::path::{Path, PathBuf};
use std::process::Command;

/// the boot entry NAME of the kernel carrying pm8916_wdt (patch 6/6): plain, lpoco refuses a "+"; the release inside it keeps its +
pub const PMICWDT_KERNEL: &str = "calls4";
/// the sysfs name of the PMIC watchdog driver: a hyphen (the module is pm8916_wdt)
const WDT_DRIVER: &str = "pm8916-wdt";
const RUN_ID: &str = "attended";

/// The base this program lives in: every relative path (sleep/way-back.sh, device.toml) is read from here, whatever the cwd.
fn base_root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("../..")
}

fn lab(args: &[&str]) -> Result<String, String> {
    let out = Command::new("lpoco")
        .current_dir(base_root())
        .arg("lab")
        .args(args)
        .output()
        .map_err(|e| format!("lpoco lab {}: {e}", args.join(" ")))?;
    let text = String::from_utf8_lossy(&out.stdout).to_string();
    if out.status.success() {
        Ok(text)
    } else {
        Err(format!(
            "lpoco lab {}: {}{}",
            args.join(" "),
            text,
            String::from_utf8_lossy(&out.stderr)
        ))
    }
}

fn phone_answers() -> Result<(), String> {
    retry(40, 5, || phone().sh("true"))
}

/// What the session reads from `[procedures.surya-attended-session]` of device.toml: read once at the top of main, where
/// `--dry-run` finds a missing key, and handed to the steps.
#[derive(Clone)]
pub struct Facts {
    way_back: String,
    standby: String,
    pon_reason: String,
    /// (path relative to this base, full sha256): the image, the dtb and the modules of the pmicwdt kernel
    kernel_files: [(String, String); 3],
}

impl Facts {
    pub fn from_device() -> Facts {
        let file = |name: &str| (proc(name).text(), proc(&format!("{name}_sha256")).text());
        Facts {
            way_back: proc("way_back").text(),
            standby: proc("standby").text(),
            pon_reason: proc("pon_reason").text(),
            kernel_files: [
                file("calls4_image"),
                file("calls4_dtb"),
                file("calls4_modules"),
            ],
        }
    }

    /// What the session puts on the phone: (file in this base, its place on the phone). The pon reason check is
    /// surya's own and the suite's put does not carry it.
    fn puts(&self) -> [(&'static str, &str); 3] {
        [
            ("sleep/way-back.sh", &self.way_back),
            ("sleep/standby-run.sh", &self.standby),
            ("tests/health/base/pon-reason.sh", &self.pon_reason),
        ]
    }
}

/// Said and passed: the phone already is in the state this step brings about, so it is not done again (no reboot, no put).
fn already(what: &str) -> Result<(), String> {
    println!("  already in state: {what} - nothing to do");
    Ok(())
}

/// Whether the phone runs the calls4 kernel now: false when it cannot be asked (the step then does its work).
fn runs_pmicwdt_kernel() -> bool {
    phone()
        .sh("uname -r 2>/dev/null")
        .is_ok_and(|release| runs_kernel(&release, PMICWDT_KERNEL))
}

/// Whether the file here and the one on the phone have one checksum.
fn on_phone_as_here(local: &str, remote: &str) -> bool {
    let here = Command::new("sha256sum")
        .arg(base_root().join(local))
        .output()
        .map(|o| String::from_utf8_lossy(&o.stdout).to_string())
        .unwrap_or_default();
    let Some(sha) = here.split_whitespace().next() else {
        return false;
    };
    phone()
        .sh(&format!("sha256sum {remote} 2>/dev/null"))
        .is_ok_and(|there| sha_matches(&there, sha))
}

/// Put what is not already on the phone as it is here (way-back.sh, the standby script, the pon reason check).
pub fn put_way_back(f: &Facts) -> Result<(), String> {
    let mut put = 0;
    for (local, remote) in f.puts() {
        if on_phone_as_here(local, remote) {
            continue;
        }
        lab(&["phone", "put", local, remote])?;
        put += 1;
    }
    if put == 0 {
        return already("way-back.sh and its two companions are on the phone, same checksums");
    }
    Ok(())
}

/// The read-probe: the sysfs driver dir (hyphen, as the kernel names it) and the kernel release; this kernel gives the watchdog no sysfs timeout to read.
fn probe_script() -> String {
    format!(
        "echo driver=$([ -d /sys/bus/platform/drivers/{WDT_DRIVER} ] && echo 1 || echo 0); \
         echo kernel=$(uname -r)"
    )
}

/// Every try is spent by a boot: put the entry back (skipped when the kernel already runs) with its one try, from files whose checksums are known.
pub fn install_pmicwdt_kernel(f: &Facts) -> Result<(), String> {
    if runs_pmicwdt_kernel() {
        return already("the phone runs the pmicwdt kernel, so its entry needs no new try");
    }
    let mut paths = Vec::new();
    for (rel, sha) in &f.kernel_files {
        let path = base_root().join(rel).to_string_lossy().to_string();
        verify_sha256(&path, sha)?;
        paths.push(path);
    }
    lab(&[
        "kernel",
        "install",
        PMICWDT_KERNEL,
        &paths[0],
        &paths[1],
        &paths[2],
    ])
    .map(|_| ())
}

fn verify_sha256(path: &str, expected: &str) -> Result<(), String> {
    let out = Command::new("sha256sum")
        .arg(path)
        .output()
        .map_err(|e| format!("sha256sum {path}: {e}"))?;
    let text = String::from_utf8_lossy(&out.stdout);
    if text.starts_with(expected) {
        Ok(())
    } else {
        Err(format!("{path}: sha256 is not {expected}: {text}"))
    }
}

pub fn read_probe() -> Result<(), String> {
    let text = phone().sh(&probe_script())?;
    probe_holds(&parse_probe(&text))
}

pub fn way_back_in_place(f: &Facts) -> Result<(), String> {
    let way_back = &f.way_back;
    phone().root(&format!("sh {way_back} check")).map(|_| ())
}

/// The PON reason and the reset lines of the kernel log, as the phone says them now.
fn pon_text(f: &Facts) -> Result<String, String> {
    let pon_reason = &f.pon_reason;
    phone().root(&format!(
        "sh {pon_reason} 2>&1; dmesg | grep -i -E 'pon|S2_CTL|reset' | tail -20"
    ))
}

/// Arm the fuse and let go; skipped when this boot of the pmicwdt kernel already follows a bite.
pub fn bite(f: &Facts) -> Result<(), String> {
    if runs_pmicwdt_kernel() && pon_text(f).is_ok_and(|pon| bite_seen(&pon)) {
        return already(
            "this boot of the pmicwdt kernel follows a bite, the fuse is not armed again",
        );
    }
    let way_back = &f.way_back;
    phone().root(&format!("sh {way_back} fuse 20")).map(|_| ())
}

pub fn wait_for_restart() -> Result<(), String> {
    std::thread::sleep(std::time::Duration::from_secs(30));
    phone_answers()?;
    read_probe()
}

pub fn pon_reason(f: &Facts) -> Result<(), String> {
    let pon = pon_text(f)?;
    if bite_seen(&pon) {
        Ok(())
    } else {
        Err(format!("no bite in the PON reason: {pon}"))
    }
}

/// calls+ reads the reason the phone has NOW and says it: no bite is asked of it (that is the full session).
pub fn pon_reason_now(f: &Facts) -> Result<(), String> {
    let pon_reason = &f.pon_reason;
    let pon = phone().root(&format!("sh {pon_reason} 2>&1"))?;
    println!("  pon reason now: {}", pon.trim());
    Ok(())
}

/// The standby script is on the phone and readable by root, as the standby run will need it (put there by put_way_back).
pub fn standby_script_reachable(f: &Facts) -> Result<(), String> {
    let standby = &f.standby;
    phone()
        .root(&format!("test -r {standby} && sh -n {standby}"))
        .map(|_| ())
}

pub fn wake_in_suspend(f: &Facts) -> Result<(), String> {
    let way_back = &f.way_back;
    phone()
        .root(&format!("sh {way_back} cycle 10 bt-on stop-sensors"))
        .map(|_| ())
}

/// The phone's own health suite (surya has no tests/automatic/checks.sh: its checks are tests/health, put on the phone by the suite).
pub fn step_checks() -> Result<(), String> {
    lab(&["suite", "run"]).map(|_| ())
}

pub fn start_standby(f: &Facts) -> Result<(), String> {
    let standby = &f.standby;
    phone().root(&format!(
        "systemd-run --unit=standby-{RUN_ID} sh {standby} {RUN_ID} 300 600"
    ))?;
    Ok(())
}

/// Wait out the run (the phone is unplugged meanwhile: devlab retries until the cable is back), then print the mean current.
pub fn read_standby() -> Result<(), String> {
    retry(200, 10, || {
        phone().sh(&format!("[ ! -d /run/systemd/transient/standby-{RUN_ID}.service ] || ! systemctl is-active standby-{RUN_ID}"))
    })?;
    let tsv = phone().sh(&format!("cat /var/tmp/standby-{RUN_ID}/samples.tsv"))?;
    let ma = standby_ma(&tsv).ok_or("no measure-phase samples")?;
    println!("  standby current: {ma:.1} mA");
    Ok(())
}

/// The whole session ends on a pm8916-wdt kernel: probe it, then health, then the lease.
pub fn finish_healthy() -> Result<(), String> {
    read_probe()?;
    finish_on_kept_kernel()
}

/// calls+ keeps its own kernel, which has no pm8916 driver: no probe of it, only health and the lease.
pub fn finish_on_kept_kernel() -> Result<(), String> {
    lab(&["suite", "run"])?;
    lab(&["keeper", "release"]).map(|_| ())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn the_probe_reads_the_hyphenated_sysfs_driver_dir() {
        assert!(probe_script().contains("/sys/bus/platform/drivers/pm8916-wdt "));
    }

    fn device_text() -> String {
        std::fs::read_to_string(base_root().join("device.toml")).unwrap()
    }

    fn facts_from_the_device_file() -> Facts {
        let text = device_text();
        let at = text
            .find("[procedures.surya-attended-session]")
            .expect("device.toml has no [procedures.surya-attended-session]");
        let value = |key: &str| {
            text[at..]
                .lines()
                .find_map(|l| l.strip_prefix(key)?.trim_start().strip_prefix('='))
                .map(|v| v.trim().trim_matches('"').to_string())
                .unwrap_or_else(|| panic!("no {key} in [procedures.surya-attended-session]"))
        };
        let file = |name: &str| (value(name), value(&format!("{name}_sha256")));
        Facts {
            way_back: value("way_back"),
            standby: value("standby"),
            pon_reason: value("pon_reason"),
            kernel_files: [
                file("calls4_image"),
                file("calls4_dtb"),
                file("calls4_modules"),
            ],
        }
    }

    #[test]
    fn every_file_put_on_the_phone_exists_in_the_base() {
        let f = facts_from_the_device_file();
        for (local, remote) in f.puts() {
            assert!(
                base_root().join(local).is_file(),
                "{local} is not in the base"
            );
            assert!(remote.starts_with("/var/tmp/"), "{remote}");
        }
        assert!(f.puts().iter().any(|(_, r)| *r == f.pon_reason));
    }

    #[test]
    fn the_kernel_files_are_named_with_a_full_checksum() {
        for (path, sha) in facts_from_the_device_file().kernel_files {
            assert!(
                path.starts_with("../../") && !path.starts_with('/'),
                "{path}"
            );
            assert!(
                sha.len() == 64 && sha.chars().all(|c| c.is_ascii_hexdigit()),
                "{sha}"
            );
        }
    }

    #[test]
    fn the_device_lists_the_kernel_the_session_boots() {
        let toml = std::fs::read_to_string(base_root().join("device.toml")).unwrap();
        let at = toml
            .find("[kernels]")
            .expect("device.toml has no [kernels]");
        assert!(toml[at..]
            .lines()
            .take(4)
            .any(|l| l.starts_with("test") && l.contains(&format!("\"{PMICWDT_KERNEL}\""))));
    }

    #[test]
    fn entry_name_is_plain_for_lpoco_kernel_try() {
        assert!(
            !PMICWDT_KERNEL.contains('+'),
            "lpoco refuses a NAME with '+'"
        );
    }
}
