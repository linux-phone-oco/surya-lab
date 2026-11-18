# surya-lab - notes for agents

**Owner**: `surya-coordinator` - the lane coordinator of the POCO X3 NFC. It queues the lane (tad q phone-next, lane-next), starts the keeper, builder and research launchers and decides what needs no hands; the keeper (`surya-keeper`) holds the phone, the builder and research sessions never touch it.

Principles of linux-phone-oco, cited and never restated ([`tad q principles`](https://github.com/linux-phone-oco/docs) in docs): [as-good-as-android](https://github.com/linux-phone-oco/docs/blob/main/docs/concepts.md#as-good-as-android), [measured-not-claimed](https://github.com/linux-phone-oco/docs/blob/main/docs/concepts.md#measured-not-claimed), [mainline-first](https://github.com/linux-phone-oco/docs/blob/main/docs/concepts.md#mainline-first), [no-manual-steps](https://github.com/linux-phone-oco/docs/blob/main/docs/concepts.md#no-manual-steps), [rust-with-argenv](https://github.com/linux-phone-oco/docs/blob/main/docs/concepts.md#rust-with-argenv).

The device lab for the Xiaomi POCO X3 NFC (surya, Huaxing panel): flashing, provisioning, switching
shells, tests. Everything runs on the lab machine (via lab-agent), never in an agent's own sandbox.

- **Talking to the phone**: always through lpoco lab (linux-phone-oco/lab-tools), which reads this lab's
  `device.toml` - `lpoco lab phone sh` / `lpoco lab phone root` with the commands as a script on standard
  input (no nested quoting), `lpoco lab phone put`, `lpoco lab phone reboot`, or the MCP door `lpoco lab mcp`. It
  holds the phone for each change; the lab's hooks refuse a hand-written ssh to it (`lpoco lab guard`).
- **Secrets** stay on the lab machine, mode 600, never in this repository: `~/.config/surya-lab/`
  (`wifi-ssid`, `wifi-password`).
- **Images**: the stock Sxmo reference is `~/Projects/surya-audio/image-fresh-stock/...img` and its
  device tree's sha256 starts `a43d069d0a49adcd`. Check a device tree's fingerprint before trusting a
  flash: a "reference" image once carried an old WCD test device tree (no sound card).
- **Flashing** (`flash/flash.sh`) bakes in the sound fixes; no depmod from the PC (it made Plasma
  boot-loop). The first boot of a fresh image is slow (it resizes the storage) - not a hang.
- **After a flash**: `lpoco lab provision now` (packages over the PC's connection, then Wi-Fi), then
  `lpoco lab suite put now --runner ...` (lab-tools' README): from then on the phone checks its own health
  120 s after every boot, by the manifest's `[health]` and its own checks in `tests/health/`, and
  `lpoco lab watch` gathers every report into `tests/results/` and the picture by itself.
- **Hardware testing** on Sxmo: the lightest shell, nothing in the way.
- **A script that changes state needs explicit intent**: an argument it cannot run without
  (flash.sh IMAGE, build-dtbs.sh KERNEL_DIR) or a verb (lpoco lab provision now). Run by accident, it must
  print its usage and change nothing. CI checks every script (syntax, shellcheck errors) on each PR.
- **Test kernels**: `lpoco lab kernel install NAME ...` then `lpoco lab kernel try NAME` (linux-phone-oco/lab-tools,
  reading device.toml) - proven live. One try by boot counting
  (proven on surya: the try is counted down on the ESP, and the next boot is stock by itself); a
  stalled initramfs saves its log to the ESP after 5 minutes and reboots (`log NAME` reads it).
  Never `pmos.debug-shell` on an unattended try: it halts the boot until someone continues it.
  WORKAROUND(kept-kernel-with-pmic-wdt): after any PMIC bite, boot only a kernel with pm8916_wdt - stands in for the kept kernel carrying the driver.
  WORKAROUND(surya-adsp-audio-boot-race): restarts the ADSP when the card is missing - stands in for the unread boot race (lab/devlab-audio-heal); if the race is upstream's (the ADSP or the audio services) it goes through the fork-first path.

- **Record as you go** in this device's own base (data/, kept by tad): `ikb --help`, then `ikb help RECORD` - decisions with
  what was rejected, research, the backlog (`ikb backlog`; `ikb backlog-needs` for the phone's queue), the log, and
  the parts (`ikb part`: what is claimed of each part, its evidence and date - docs pulls them and derives the
  device's support status, so type nothing of it there). What helps every device goes to linux-phone-oco/docs. The
  record of the work itself is the commits and pull requests; land with `land` (or `landit`).

<!-- idealkb:begin - kept by grenudi/ideal-knowledge-base at the release idealkb.toml names: change it there -->
## Finding what is known
Ask a query; never read `data/` or `docs/` to answer - they are the database's files and the pages for people.

| To know | Ask |
|---|---|
| how a subject stands, then all that is known of it | `tad q about --subject S` (`--whole true` for every record in full; `tad q about` lists the subjects, and where a summary is due) |
| the work ahead | `tad q next` (`--about S` for one subject) |
| what you may take now, and why the rest may not | `tad q ready --for keeper\|builder\|research` (`--show ready` for the picks only) - the one picking query; a brief names it and carries no picking SQL. An item `--witness person` is skipped ("needs a witness") until a person's go is open: `ikb backlog-go --id ID --until "$(date -Is -d +1hour)"` |
| where something is said | `tad q find --text WORDS` |
| one record whole | `tad q row --id ID` |
| what was recorded lately | `tad q recent` (`--days N`) |
| anything else | `tad statements`: every query and record, with its parameters |

At a task's start ask only about its subject (`about --subject S`, or `next --about S`) and act. Every
answer gives each record by its brief, its one line. Read deeper - `row --id`, `--whole true`, a file past
its first paragraph, another subject, `tad statements` - only when a step needs more. Long answers read best
with `--format csv`.

## Recording
Record with `ikb` (`sh bin/install-ikb.sh` once installs it): `ikb --help` lists the records of this base, one line each; `ikb help RECORD` gives the one you need, its options written from `records/*.sql`. Then `ikb RECORD --option value`: long text from a file or stdin (`--found @-`), the id made from the brief, canon and render done after - never SQL, never by hand. Each record names what it is about (`--about`) and, for a decision or a research, its brief (the record in one line; the title is the brief of the rest), then land. A change to a row no record covers (a status, a wait, a field of a decision, a source taken away): `ikb set TABLE --key K --field NAME=VALUE`, `ikb remove TABLE --key K` - checked, never `tad sql`. Where `tad q about` says a summary is due for a subject you recorded into, renew it: `ikb summary --about S --says ...` - how it stands now, naming the records that carry it.
A thing there are many of with one shape is a row; prose read once in order is a file (README, this entry,
a brief), and a file opens with its own brief: its first paragraph says what it holds. Research is both: its finding a row, its own material - notes, excerpts, measurements - a dated
folder the row names (`--material auto` makes `research/ABOUT/DATE/`); redone, a new row `--supersedes` the old.
Work headed to others (a patch, finding, correction or question for a project, list, wiki, standard, person or another base) is an upstream item: `tad q upstream` shows where each stands; record with `ikb upstream-item --from-work ID`. A patch carried in a fork until its upstream has it names the fork (`--carried-in FORK-ID/BRANCH`; the fork is an upstream of its own: `ikb upstream --fork-of ORIGINAL`); `tad q carried` says which to keep and which to drop at the next rebase. Its tag column - UPSTREAM, FROMGIT, FROMLIST, OURS - is how far the patch has travelled, read off the item's state; the fork's commit subjects carry it as `FROMLIST(item-id): subject` (`bin/check-fork-tags.sh BASE REPO RANGE` finds one that disagrees). A workaround standing in for an upstream fault is marked `WORKAROUND(item-id)` in place and its place goes in the item's `--local-ref`; it ends when the item lands. Move an item on as the replies come (`ikb upstream-state --state accepted --reviewed-by "Name"`), never leave it as it was sent.
A decision never edited when it changes: a new one `--supersedes` it whole or `--amends` it in part, says who it binds (`--scope`) and the backlog item that carries it out (`--tracked-by`); `tad q decided` reads where each stands - superseded, in work, carried out, untracked - from that work.
<!-- idealkb:end -->
