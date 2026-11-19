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

fn dry(args: &[&str]) -> String {
    let out = Command::new(env!("CARGO_BIN_EXE_surya-attended"))
        .arg("--dry-run")
        .args(args)
        .output()
        .unwrap();
    let text =
        String::from_utf8_lossy(&out.stdout).to_string() + &String::from_utf8_lossy(&out.stderr);
    assert!(out.status.success(), "{text}");
    text
}

#[test]
fn until_first_prompt_walks_the_boot_and_the_probes_and_stops_before_the_bite() {
    let text = dry(&["--until", "FIRST_PROMPT"]);
    for s in [
        "the phone answers",
        "way-back.sh is on the phone",
        "boot the pmicwdt kernel once",
        "the pmic watchdog is registered",
        "the way back is in place",
        "stopped before the first prompt",
    ] {
        assert!(text.contains(s), "{s} missing:\n{text}");
    }
    for s in ["arm the apss fuse", "wake in suspend", "standby current"] {
        assert!(
            !text.contains(s),
            "{s} is behind the author's prompt:\n{text}"
        );
    }
}

#[test]
fn the_calls_plus_part_holds_no_bite_no_wake_in_suspend_and_no_unplug() {
    let text = dry(&["--part", "calls-plus"]);
    let order = [
        "way-back.sh is on the phone",
        "the pon reason is read",
        "the step checks hold",
        "the standby script is reachable as root",
        "end on a healthy kernel",
    ];
    let mut at = 0;
    for s in order {
        at += text[at..]
            .find(s)
            .unwrap_or_else(|| panic!("{s} missing or out of order:\n{text}"));
    }
    for s in [
        "boot the pmicwdt kernel once",
        "arm the apss fuse",
        "restarts on a pm8916_wdt kernel",
        "wake in suspend",
        "unplug",
        "standby current",
    ] {
        assert!(
            !text.contains(s),
            "{s} must stay behind the author:\n{text}"
        );
    }
}

#[test]
fn a_part_the_session_has_not_got_is_refused() {
    let out = Command::new(env!("CARGO_BIN_EXE_surya-attended"))
        .args(["--dry-run", "--part", "nope"])
        .output()
        .unwrap();
    assert_eq!(out.status.code(), Some(2));
}
