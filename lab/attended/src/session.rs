// SPDX-License-Identifier: MIT OR Apache-2.0
//! The steps' bodies: each reaches the phone only through lpoco (phone() on the runner, `lpoco lab` for the
//! host's side) and returns a Result that stops the run. Nothing here reads like the procedure; main does.

use crate::checks::*;
use lpoco_attended::{phone, retry};
use std::process::Command;

const WAY_BACK: &str = "/var/tmp/way-back.sh";
const STANDBY: &str = "/var/tmp/standby-run.sh";
/// the kernel entry carrying pm8916_wdt (patch 6/6); lane rule: after a bite never calls+
const PMICWDT_KERNEL: &str = "calls4+";
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

pub fn put_way_back() -> Result<(), String> {
    lab(&["phone", "put", "sleep/way-back.sh", WAY_BACK])?;
    lab(&["phone", "put", "sleep/standby-run.sh", STANDBY])?;
    Ok(())
}

pub fn boot_pmicwdt_kernel() -> Result<(), String> {
    lab(&["kernel", "try", PMICWDT_KERNEL])?;
    wait_for_phone()
}

pub fn read_probe() -> Result<(), String> {
    let text = phone().sh(
        "echo driver=$([ -d /sys/bus/platform/drivers/pm8916_wdt ] && echo 1 || echo 0); \
         for w in /sys/class/watchdog/*; do grep -q PM8916 $w/identity 2>/dev/null && echo timeout=$(cat $w/timeout); done; \
         echo kernel=$(uname -r)",
    )?;
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
    let pon = phone().root("sh /usr/lib/lpoco-health/pon-reason.sh 2>&1; dmesg | grep -i -E 'pon|S2_CTL|reset' | tail -20")?;
    if bite_seen(&pon) {
        Ok(())
    } else {
        Err(format!("no bite in the PON reason: {pon}"))
    }
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

pub fn finish_healthy() -> Result<(), String> {
    read_probe()?;
    lab(&["health"])?;
    lab(&["keeper", "release"]).map(|_| ())
}
