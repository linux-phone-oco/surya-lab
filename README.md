# surya-lab

The bring-up lab for the Xiaomi POCO X3 NFC (`xiaomi-surya`, SM7150): the tools and experiments
that take it from "boots mainline Linux" to a phone you can use every day - part of
[linux-phone-oco](https://github.com/linux-phone-oco)'s goal of Linux phones as good as Android,
and better. **Audio is the current front; power (staying off, off-mode charging) is next.**
Everything learned here is meant to go upstream.

Everything runs on a lab machine through [lab-agent](https://github.com/creation-guidelines/lab-agent),
so a build or a hardware step is a job, not a copy-pasted command - see its `AGENTS.md`. The tools
are not specific to audio, and most are not specific to this phone.

## dt/ - device-tree audits (no phone needed)

| tool | question it answers |
|---|---|
| `build-dtbs.sh` | build the board DTB at a commit and at its parent, to compare |
| `irq-audit.py` | which GIC interrupts does the patch add, and does any collide? |
| `reg-audit.py` | which MMIO windows does it add, do any overlap, what else is nearby? |
| `disable-node.py` | a DTB with one node disabled: one variable for a hardware bisect |

```sh
dt/build-dtbs.sh ~/Projects/surya-audio/linux . && DTC=/tmp/o-patch/scripts/dtc/dtc
python3 dt/irq-audit.py /tmp/o-patch/scripts/dtc/dtc base.dtb patch.dtb
python3 dt/reg-audit.py /tmp/o-patch/scripts/dtc/dtc base.dtb patch.dtb
DTC=/tmp/o-patch/scripts/dtc/dtc python3 dt/disable-node.py patch.dtb clock-controller@3380000 a1.dtb
```

## Findings so far: audio

The WCD937x patch ([linux-phone-oco/linux#1](https://github.com/linux-phone-oco/linux/pull/1))
hangs the boot with RCU stalls. Audited here: no interrupt collisions, no MMIO overlaps, no new dtc
warnings, voting clocks match SM8250. Prime suspect: the `aoncc` window at `0x03380000`, an
SM8250-pattern address with nothing else near it in the SM7150 tree. Details and the next
hardware test are in the PR comment. Nothing is confirmed on hardware yet.

## The base

A device made from this template has its own open base (tad, `data/`): its queue, tries, measurements, decisions,
research and parts. `make setup` installs tad and `ikb`; `ikb --help` lists what can be recorded, `ikb help RECORD`
how. The standing tables follow [grenudi/ideal-knowledge-base](https://github.com/grenudi/ideal-knowledge-base)
(`idealkb.toml`); the device's own are in `tables.toml`. Fill the device (`ikb device ...`) and declare what is
claimed of each part (`ikb part`: status, evidence, date) - [linux-phone-oco/docs](https://github.com/linux-phone-oco/docs)
pulls `parts` (contract in `devicebase.toml`) and derives the device's support status from them; it types nothing of
its own. The phone's queue is `tad q phone-queue`, its keeper's next item `tad q phone-next`; `lpoco lab gather` files runs
with the `test-run` record.

## Rules

- A tool is not done until it has been run from a fresh clone: the first versions of these each had
  a bug that only running them found (a parser that stopped at the root node; `dtc` killed by
  `| head`).
- Never pipe a tool's output into something that can exit early when the tool must finish writing.

## Tests

The phone checks its own health 120 s after every boot (lpoco lab's suite: the generic checks of
linux-phone-oco/lab-tools, surya's own in `tests/health/`, and the manifest's `[health]`); `lpoco lab
watch` brings every report into `tests/results/DATE-TIME.jsonl` - one line per check, with its
linux-phone-oco/docs component, pass / fail / skip, a detail, and the run (device, time, kernel,
shell) - and files it into the docs' `test_results`, the evidence the support grid's verdicts cite.
`lpoco lab suite run` runs it now. A pass proves a part is there and set up; whether a person hears or
sees it is a witnessed test (a question with buttons on the desktop and the board).

## Provisioning

After a flash, `lpoco lab provision now` installs the packages in `provision/packages.txt` (Firefox,
i2c-tools) over the PC's internet connection: the PC shares it only for the install - forwarding and
a masquerade rule in an nftables table of its own, all undone on exit - so a phone without Wi-Fi
set up still gets them.

## Licence

Data, docs and research: [CC-BY-SA-4.0](LICENSE). Scripts, statements and configuration: MIT OR Apache-2.0, at your option
([`LICENSE-MIT`](LICENSE-MIT), [`LICENSE-APACHE`](LICENSE-APACHE)). Patches to someone else's files keep their licence
(GPL-2.0-only for the kernel, GPL-3.0-or-later for hexagonrpcd) and the UCM profiles keep alsa-ucm-conf's (BSD-3-Clause).
[`REUSE.toml`](REUSE.toml) says it per path, and `bin/licence-check` (`make verify`, CI) keeps every tracked file covered.
