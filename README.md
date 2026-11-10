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

## Rules

- A tool is not done until it has been run from a fresh clone: the first versions of these each had
  a bug that only running them found (a parser that stopped at the root node; `dtc` killed by
  `| head`).
- Never pipe a tool's output into something that can exit early when the tool must finish writing.

## Tests

`tests/run.sh` runs the automatic checks on the phone over SSH - read-only, nothing to hear or
touch - and keeps the results as `tests/results/DATE-TIME.jsonl`: one line per check, with its
linux-phone-oco/docs component, pass / fail / skip, a detail, and the run (device, time, kernel,
shell). `tests/to-docs.sh RESULTS` files them into the docs as the `test_results` table, the evidence
the support grid's verdicts cite. A pass proves a part is there and set up; whether a person hears
or sees it is a witnessed test (a question with buttons on the desktop and the board).
