// SPDX-License-Identifier: MIT OR Apache-2.0
//! The whole procedure walked with no phone: --dry-run runs no closure and says every step in order.

use std::process::Command;

#[test]
fn dry_run_walks_every_step_in_order() {
    let out = Command::new(env!("CARGO_BIN_EXE_surya-attended"))
        .arg("--dry-run")
        .output()
        .unwrap();
    let text =
        String::from_utf8_lossy(&out.stdout).to_string() + &String::from_utf8_lossy(&out.stderr);
    assert!(out.status.success(), "{text}");
    let order = [
        "boot the pmicwdt kernel once",
        "the pmic watchdog is registered",
        "arm the apss fuse",
        "the phone restarts on a pm8916_wdt kernel",
        "wake in suspend",
        "standby current",
        "end on a healthy kernel",
    ];
    let mut at = 0;
    for s in order {
        at += text[at..]
            .find(s)
            .unwrap_or_else(|| panic!("{s} missing or out of order:\n{text}"));
    }
}
