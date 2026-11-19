#!/usr/bin/env rust-script
//! surya attended session: pmicwdt boot and probe, with(&facts, bite), wake-in-suspend, step checks, standby current.
//! `lpoco-attended run attended-session --dry-run` walks every step and prompt and touches nothing; `--log FILE` keeps the log.
//! Decision 2026-11-19-attended-only-when-one-command-away. After a bite the next boot is a pm8916_wdt kernel,
//! never calls+; the run ends on one, healthy, with the lease released.
//! The keeper runs what is not risky without the author: `--until FIRST_PROMPT` (the boot of the pmicwdt kernel
//! and the probes, stopping at the first prompt) and `--part calls-plus` (the checks that need neither the bite
//! nor the cable). Only the with(&facts, bite), the restart after it, wake in suspend and the unplug wait for the author.
//! A rerun does not repeat what is done: `--from STEP` resumes at a step (the printed `--until` stop names it); a step whose
//! state already holds is skipped and said: the pmicwdt kernel already running (no install, no boot), the three files already on
//! the phone with the same checksums, a bite already read in this boot's PON reason. The physical prompts are filed in
//! ~/.cache/lpoco-attended/xiaomi-surya/prompt and answered by writing `ok` to the `answer` file beside it (or on the terminal).
//!
//! ```cargo
//! [dependencies]
//! lpoco-attended = { git = "https://github.com/linux-phone-oco/lab-tools", tag = "lpoco-attended-v0.34.1" }
//! surya-steps = { path = "steps" }
//! ```
// SPDX-License-Identifier: MIT OR Apache-2.0

use lpoco_attended::prelude::*;
use lpoco_attended::steps::{boot_once, wait_for_phone};
use surya_steps::session::*;

/// A step that needs the session's facts, which a step closure cannot read from the manifest itself.
fn with(facts: &Facts, run: fn(&Facts) -> Result<(), String>) -> impl FnOnce() -> Result<(), String> {
    let facts = facts.clone();
    move || run(&facts)
}

fn main() {
    let _run = procedure("surya attended session", "xiaomi-surya");
    let facts = Facts::from_device();
    match part().as_deref() {
        None => whole_session(facts),
        Some("calls-plus") => calls_plus(facts),
        Some(other) => unknown_part(other, &["calls-plus"]),
    }
}

fn whole_session(facts: Facts) {
    run_step(wait_for_phone(40, 5));
    step("way-back.sh is on the phone", with(&facts, put_way_back));
    step(
        "install the pmicwdt kernel with its one try",
        with(&facts, install_pmicwdt_kernel),
    );
    run_step(boot_once(PMICWDT_KERNEL));
    run_step(wait_for_phone(40, 5));
    check("the pmic watchdog is registered", read_probe);
    check("the way back is in place", with(&facts, way_back_in_place));

    confirm("the cable stays in, hands off the phone: it will restart by itself in about 30 s; not back in 3 min, hold power 15 s / ready");
    step("arm the apss fuse and let the pmic watchdog bite", with(&facts, bite));
    look_for("the screen going dark and the phone restarting on its own");
    step(
        "the phone restarts on a pm8916_wdt kernel",
        wait_for_restart,
    );
    check("the pon reason says a bite", with(&facts, pon_reason));

    step("wake in suspend", with(&facts, wake_in_suspend));
    check("the step checks hold", step_checks);

    step("start the standby current run", with(&facts, start_standby));
    unplug_usb("the host no longer lists the phone; leave the phone alone for the run");
    replug_usb("the host lists the phone again, when the run is over (about 15 min)");
    step("the standby current", read_standby);

    step("end on a healthy kernel, lease released", finish_healthy);
}

/// What needs no calls4, no bite and no author, on the kept kernel.
fn calls_plus(facts: Facts) {
    run_step(wait_for_phone(40, 5));
    step("way-back.sh is on the phone", with(&facts, put_way_back));
    check("the pon reason is read", with(&facts, pon_reason_now));
    check("the step checks hold", step_checks);
    check(
        "the standby script is reachable as root",
        with(&facts, standby_script_reachable),
    );
    step(
        "end on the kept kernel, lease released",
        finish_on_kept_kernel,
    );
}
