// SPDX-License-Identifier: MIT OR Apache-2.0
//! surya's attended session, one command: `cargo run --release -p surya-attended` (from lab/attended).
//! `--dry-run` walks every step and prompt and touches nothing; `--log FILE` keeps the log; `--help` says the rest.
//! Decision 2026-11-19-attended-only-when-one-command-away. After a bite the next boot is a pm8916_wdt kernel,
//! never calls+; the run ends on one, healthy, with the lease released.

mod checks;
mod session;

use lpoco_attended::prelude::*;
use session::*;

fn main() {
    let _run = procedure("surya attended session", "xiaomi-surya");

    step("the phone answers", wait_for_phone);
    step("way-back.sh is on the phone", put_way_back);
    step("boot the pmicwdt kernel once", boot_pmicwdt_kernel);
    check("the pmic watchdog is registered", read_probe);
    check("the way back is in place", way_back_in_place);

    ask_author(
        "keep the cable in, hands off the phone; it will reset by itself in about 30 s / \
         the screen goes dark and the phone restarts on its own; if it does not return in 3 min hold power 15 s",
    );
    step("arm the apss fuse and let the pmic watchdog bite", bite);
    step(
        "the phone restarts on a pm8916_wdt kernel",
        wait_for_restart,
    );
    check("the pon reason says a bite", pon_reason);

    step("wake in suspend", wake_in_suspend);
    check("the step checks hold", step_checks);

    ask_author(
        "unplug the cable when told, leave the phone alone for the run / \
         the standby current figure prints at the end; plug the cable back in then",
    );
    step("standby current", standby_current);

    step("end on a healthy kernel, lease released", finish_healthy);
}
