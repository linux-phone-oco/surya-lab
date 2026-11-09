#!/usr/bin/env python3
"""Which MMIO windows does a patch add, and do any overlap another node?

usage: reg-audit.py DTC BASE.dtb PATCHED.dtb

Checks direct children of the SoC bus (two address and two size cells). Also lists what lives
near 0x03380000 - the aoncc window - and every LPASS-looking window already in the base tree.
"""
import re, subprocess, sys
DTC = sys.argv[1]
def parse(path):
    text = subprocess.run([DTC, "-I", "dtb", "-O", "dts", path], capture_output=True, text=True).stdout
    nodes, stack, buf = {}, [], ""
    for line in text.splitlines():
        s = line.strip()
        if buf or (("=" in s or s.endswith(";")) and not s.endswith("{") and s != "};"):
            buf += " " + s
            if buf.rstrip().endswith(";"):
                m = re.match(r"\s*([^=;\s]+)\s*(?:=\s*(.*?))?;\s*$", buf)
                if m and stack: nodes[stack[-1]][m.group(1)] = m.group(2) or ""
                buf = ""
            continue
        if s.endswith("{"):
            n = s[:-1].strip() or "/"; p = "/" if not stack else stack[-1].rstrip("/") + "/" + n
            stack.append(p); nodes.setdefault(p, {})
        elif s == "};" and stack: stack.pop()
    return nodes
nums = lambda raw: [int(x, 0) for x in re.findall(r"0x[0-9a-fA-F]+|\b\d+\b", raw or "")]
def ranges(nodes):
    out = []
    for p, pr in nodes.items():
        if p.count("/") != 2 or not p.startswith("/soc@0/") or "reg" not in pr: continue   # direct children of the SoC bus: 2 address + 2 size cells
        v = nums(pr["reg"])
        for i in range(0, len(v) - 3, 4):
            a = (v[i] << 32) | v[i + 1]; sz = (v[i + 2] << 32) | v[i + 3]
            out.append((a, a + sz, p.split("/soc@0/")[1], pr.get("status", "").strip('";') or "okay"))
    return sorted(out)
base, patch = ranges(parse(sys.argv[2])), ranges(parse(sys.argv[3]))
bset = {(a, b, n) for a, b, n, _ in base}
added = [r for r in patch if (r[0], r[1], r[2]) not in bset]
print(f"MMIO windows on the SoC bus: base {len(base)}, patched {len(patch)}; added by the patch: {len(added)}")
print("== windows the patch adds ==")
for a, b, n, st in added: print(f"  {a:#012x}-{b-1:#012x}  {n:42} {st}")
print("== overlaps involving an added window ==")
hit = False
for a, b, n, st in added:
    for a2, b2, n2, st2 in patch:
        if n2 != n and a < b2 and a2 < b: print(f"  {n} overlaps {n2}: {a:#x}-{b-1:#x} vs {a2:#x}-{b2-1:#x}"); hit = True
if not hit: print("  (none)")
print("== what else lives within 1 MiB of the aoncc window (0x03380000) in the BASE tree ==")
near = [r for r in base if abs(r[0] - 0x03380000) < 0x100000]
for a, b, n, st in near: print(f"  {a:#012x}-{b-1:#012x}  {n:42} {st}")
if not near: print("  (nothing - the region is empty in the SM7150 tree)")
print("== LPASS-looking windows already in the base tree (0x62xxxxxx and 0x03xxxxxx audio) ==")
for a, b, n, st in base:
    if (0x62000000 <= a < 0x63000000) or re.search(r"lpass|audio|lpi|slim|swr|macro|q6|apr", n): print(f"  {a:#012x}-{b-1:#012x}  {n:42} {st}")
