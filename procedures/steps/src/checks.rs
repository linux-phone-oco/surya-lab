// SPDX-License-Identifier: MIT OR Apache-2.0
//! What the phone's answers must say: pure functions on text, tested without a phone.

/// What the read-probe script prints, as key=value lines.
#[derive(Debug, PartialEq)]
pub struct Probe {
    pub driver: bool,
    pub kernel: String,
}

pub fn parse_probe(text: &str) -> Probe {
    let get = |k: &str| {
        text.lines()
            .find_map(|l| l.strip_prefix(k).and_then(|v| v.strip_prefix('=')))
            .map(str::trim)
    };
    Probe {
        driver: get("driver") == Some("1"),
        kernel: get("kernel").unwrap_or("").to_string(),
    }
}

/// The driver is registered and the kernel is a pmic-wdt one, never calls+ alone.
pub fn probe_holds(p: &Probe) -> Result<(), String> {
    if !p.driver {
        return Err("pm8916_wdt is not registered".into());
    }
    if p.kernel.is_empty() {
        return Err("no kernel release read".into());
    }
    if !p.kernel.contains("calls4") {
        return Err(format!("not the calls4 kernel: {}", p.kernel));
    }
    Ok(())
}

/// The lines of the PON reason that say the last reset was the PMIC watchdog's (S2 reset) or a hard reset.
pub fn bite_seen(pon: &str) -> bool {
    pon.contains("S2_CTL=0x07")
        || pon.to_lowercase().contains("watchdog")
        || pon.contains("reset_type=hard")
}

/// Standby current: the mean of the measure-phase samples (current_now_uA, column 5), in mA.
pub fn standby_ma(samples_tsv: &str) -> Option<f64> {
    let v: Vec<f64> = samples_tsv
        .lines()
        .filter(|l| l.split('\t').nth(1) == Some("measure"))
        .filter_map(|l| l.split('\t').nth(4)?.parse::<f64>().ok())
        .map(|ua| ua.abs() / 1000.0)
        .collect();
    (!v.is_empty()).then(|| v.iter().sum::<f64>() / v.len() as f64)
}

/// The phone's release (`uname -r`, e.g. `7.1.0-sm7150-calls4+`) names the boot entry `name` as one of its `-` parts, so the
/// running kernel is that entry's build; "calls4" is not matched inside another word.
pub fn release_is_kernel(release: &str, name: &str) -> bool {
    release
        .lines()
        .next()
        .unwrap_or("")
        .trim()
        .split('-')
        .skip(1)
        .any(|part| part.trim_end_matches('+') == name)
}

/// `sha256sum FILE` output (on the phone or here) names exactly this checksum: the file is already as it should be.
pub fn sha_matches(sum_output: &str, expected: &str) -> bool {
    expected.len() == 64 && sum_output.split_whitespace().next() == Some(expected)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn probe_needs_the_driver_and_a_kernel() {
        let ok = parse_probe("driver=1\nkernel=7.0.0-calls4+");
        assert_eq!(probe_holds(&ok), Ok(()));
        assert!(probe_holds(&parse_probe("driver=0\nkernel=x")).is_err());
        assert!(probe_holds(&parse_probe("driver=1\nkernel=")).is_err());
    }

    #[test]
    fn probe_does_not_ask_for_a_timeout_this_kernel_has_no_sysfs_for() {
        assert_eq!(
            probe_holds(&parse_probe("driver=1\nkernel=7.0.0-calls4+")),
            Ok(())
        );
    }

    #[test]
    fn probe_refuses_a_kernel_that_is_not_calls4() {
        assert!(probe_holds(&parse_probe("driver=1\nkernel=6.1-other")).is_err());
    }

    #[test]
    fn bite_is_read_from_pon() {
        assert!(bite_seen("S2_CTL=0x07"));
        assert!(!bite_seen("nothing"));
    }

    #[test]
    fn standby_averages_only_measure_phase() {
        let t = "0\tsettle\tx\t0\t900000\n1\tmeasure\tx\t0\t-30000\n2\tmeasure\tx\t0\t-50000\n";
        assert_eq!(standby_ma(t), Some(40.0));
        assert_eq!(standby_ma("0\tsettle\tx\t0\t1\n"), None);
    }

    #[test]
    fn a_file_is_already_in_place_only_when_the_whole_checksum_matches() {
        let sha = "a".repeat(64);
        assert!(sha_matches(&format!("{sha}  /var/tmp/x\n"), &sha));
        assert!(!sha_matches(
            &format!("{}  /var/tmp/x\n", "b".repeat(64)),
            &sha
        ));
        assert!(!sha_matches("sha256sum: /var/tmp/x: No such file", &sha));
        assert!(!sha_matches("aa  x", "aa"));
    }

    #[test]
    fn the_real_release_names_its_kernel_entry() {
        assert!(release_is_kernel("7.1.0-sm7150-calls4+\n", "calls4"));
        assert!(!release_is_kernel("7.1.0-sm7150-calls+\n", "calls4"));
        assert!(!release_is_kernel("7.1.0-sm7150-notcalls4\n", "calls4"));
        assert!(!release_is_kernel("", "calls4"));
    }
}
