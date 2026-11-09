#!/usr/bin/env python3
"""Which GIC interrupts does a patch add, and does any collide?

usage: irq-audit.py DTC BASE.dtb PATCHED.dtb      (DTC: the kernel build's scripts/dtc/dtc)

Decompiles both DTBs, resolves each node's interrupt parent (interrupt-parent is inherited from
the root), and reports SPIs shared by more than one node that only the patched tree has.
"""
import re, subprocess, sys, collections
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
            name = s[:-1].strip() or "/"
            p = "/" if not stack else (stack[-1].rstrip("/") + "/" + name)
            stack.append(p); nodes.setdefault(p, {})
        elif s == "};" and stack: stack.pop()
    return nodes
nums = lambda raw: [int(x, 0) for x in re.findall(r"0x[0-9a-fA-F]+|\b\d+\b", raw or "")]
def spis(nodes):
    ph = {nums(pr["phandle"])[0]: p for p, pr in nodes.items() if "phandle" in pr}
    def ctrl(p):
        q = p
        while True:
            pr = nodes.get(q, {})
            if "interrupt-parent" in pr: return ph.get(nums(pr["interrupt-parent"])[0])
            if q in ("/", ""): return None
            q = q.rsplit("/", 1)[0] or "/"
    out = collections.defaultdict(set); with_irq = 0
    for p, pr in nodes.items():
        if "interrupts" not in pr: continue
        with_irq += 1
        c = ctrl(p)
        if not c or "arm,gic" not in nodes[c].get("compatible", ""): continue
        v = nums(pr["interrupts"])
        for i in range(0, len(v) - 2, 3):
            if v[i] == 0: out[v[i + 1]].add(p)      # type 0 = SPI
    return out, len(nodes), with_irq
(base, nb, ib), (patch, np_, ip) = spis(parse(sys.argv[2])), spis(parse(sys.argv[3]))
print(f"nodes: base {nb}, patched {np_} | nodes with interrupts: base {ib}, patched {ip}")
print(f"GIC SPIs in use: base {len(base)}, patched {len(patch)}")
coll = lambda m: {n: sorted(ps) for n, ps in m.items() if len(ps) > 1}
cb, cp = coll(base), coll(patch)
print(f"SPIs shared by more than one node: base {len(cb)}, patched {len(cp)}")
new = {n: ps for n, ps in cp.items() if cb.get(n) != ps}
print("== shared SPIs that only the patch introduces ==")
for n, ps in sorted(new.items()): print(f"  SPI {n}: " + "  |  ".join(x.split('/soc@0/')[-1] for x in ps))
if not new: print("  (none)")
print("== SPIs used by nodes the patch adds ==")
for n in sorted(patch):
    added = sorted(p for p in patch[n] if p not in base.get(n, set()))
    if added: print(f"  SPI {n}: " + ", ".join(a.split('/soc@0/')[-1] for a in added) + ("   <-- SHARED with " + ", ".join(sorted(x.split('/soc@0/')[-1] for x in patch[n] if x not in added)) if len(patch[n]) > len(added) else ""))
