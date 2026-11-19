// SPDX-License-Identifier: MIT OR Apache-2.0
//! The steps' bodies: each reaches the phone only through lpoco (phone() on the runner, `lpoco lab` for the
//! host's side) and returns a Result that stops the run. Nothing here reads like the procedure; main does.

use crate::checks::*;
use lpoco_attended::{phone, retry};
use std::process::Command;

const WAY_BACK: &str = "/var/tmp/way-back.sh";
const STANDBY: &str = "/var/tmp/standby-run.sh";
/// the boot entry NAME of the kernel carrying pm8916_wdt (patch 6/6): plain, lpoco refuses a "+"; the release inside it keeps its +
const PMICWDT_KERNEL: &str = "calls4";
const PON_REASON: &str = "/var/tmp/pon-reason.sh";
/// the sysfs name of the PMIC watchdog driver: a hyphen (the module is pm8916_wdt)
const WDT_DRIVER: &str = "pm8916-wdt";
const RUN_ID: &str = "attended";

fn lab(args: &[&str]) -> Result<String, String> {
    let out = Command::new("lpoco")
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

pub fn wait_for_phone() -> Result<(), String> {
    retry(40, 5, || phone().sh("true"))
}

/// What the session puts on the phone: (file in this base, its place on the phone). The pon reason check is surya's
/// own and the suite's put does not carry it.
const PUTS: [(&str, &str); 3] = [
    ("sleep/way-back.sh", WAY_BACK),
    ("sleep/standby-run.sh", STANDBY),
    ("tests/health/base/pon-reason.sh", PON_REASON),
];

pub fn put_way_back() -> Result<(), String> {
    for (local, remote) in PUTS {
        lab(&["phone", "put", local, remote])?;
    }
    Ok(())
}

/// The read-probe: the sysfs driver dir (hyphen, as the kernel names it), the watchdog's timeout, the kernel release.
fn probe_script() -> String {
    format!(
        "echo driver=$([ -d /sys/bus/platform/drivers/{WDT_DRIVER} ] && echo 1 || echo 0); \
         for w in /sys/class/watchdog/*; do grep -q PM8916 $w/identity 2>/dev/null && echo timeout=$(cat $w/timeout); done; \
         echo kernel=$(uname -r)"
    )
}

pub fn boot_pmicwdt_kernel() -> Result<(), String> {
    lab(&["kernel", "try", PMICWDT_KERNEL])?;
    wait_for_phone()
}

pub fn read_probe() -> Result<(), String> {
    let text = phone().sh(&probe_script())?;
    probe_holds(&parse_probe(&text))
}

pub fn way_back_in_place() -> Result<(), String> {
    phone().root(&format!("sh {WAY_BACK} check")).map(|_| ())
}

pub fn bite() -> Result<(), String> {
    phone().root(&format!("sh {WAY_BACK} fuse 20")).map(|_| ())
}

pub fn wait_for_restart() -> Result<(), String> {
    std::thread::sleep(std::time::Duration::from_secs(30));
    wait_for_phone()?;
    read_probe()
}

pub fn pon_reason() -> Result<(), String> {
    let pon = phone().root(&format!(
        "sh {PON_REASON} 2>&1; dmesg | grep -i -E 'pon|S2_CTL|reset' | tail -20"
    ))?;
    if bite_seen(&pon) {
        Ok(())
    } else {
        Err(format!("no bite in the PON reason: {pon}"))
    }
}

/// calls+ reads the reason the phone has NOW and says it: no bite is asked of it (that is the full session).
pub fn pon_reason_now() -> Result<(), String> {
    let pon = phone().root(&format!("sh {PON_REASON} 2>&1"))?;
    println!("  pon reason now: {}", pon.trim());
    Ok(())
}

/// The standby script is on the phone and readable by root, as the standby run will need it (put there by put_way_back).
pub fn standby_script_reachable() -> Result<(), String> {
    phone()
        .root(&format!("test -r {STANDBY} && sh -n {STANDBY}"))
        .map(|_| ())
}

pub fn wake_in_suspend() -> Result<(), String> {
    phone()
        .root(&format!("sh {WAY_BACK} cycle 10 bt-on stop-sensors"))
        .map(|_| ())
}

pub fn step_checks() -> Result<(), String> {
    lab(&["health"]).map(|_| ())
}

pub fn standby_current() -> Result<(), String> {
    phone().root(&format!(
        "systemd-run --unit=standby-{RUN_ID} sh {STANDBY} {RUN_ID} 300 600"
    ))?;
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
    lab(&["health"])?;
    lab(&["keeper", "release"]).map(|_| ())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn the_probe_reads_the_hyphenated_sysfs_driver_dir() {
        assert!(probe_script().contains("/sys/bus/platform/drivers/pm8916-wdt "));
    }

    #[test]
    fn every_file_put_on_the_phone_exists_in_the_base() {
        let base = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("../..");
        for (local, _) in PUTS {
            assert!(base.join(local).is_file(), "{local} is not in the base");
        }
        assert!(PUTS.iter().any(|(_, remote)| *remote == PON_REASON));
    }

    #[test]
    fn entry_name_is_plain_for_lpoco_kernel_try() {
        assert!(
            !PMICWDT_KERNEL.contains('+'),
            "lpoco refuses a NAME with '+'"
        );
    }
}
