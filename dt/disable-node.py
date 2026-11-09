#!/usr/bin/env python3
"""Make a variant of a DTB with one node disabled - a one-variable change for a hardware bisect.

usage: disable-node.py IN.dtb NODE OUT.dtb      NODE as decompiled, e.g. clock-controller@3380000
env:   DTC  the dtc to use (default: dtc on PATH)

Decompiles, sets `status = "disabled";` in exactly that node, recompiles. dtc's warnings are
collected, never piped into something that can close early and kill it before it writes OUT.
"""
import os, subprocess, sys

def main(src, node, dst):
    dtc = os.environ.get("DTC", "dtc")
    text = subprocess.run([dtc, "-I", "dtb", "-O", "dts", src], capture_output=True, text=True, check=True).stdout
    lines = text.split("\n")
    starts = [n for n, l in enumerate(lines) if l.strip() == f"{node} {{"]
    if len(starts) != 1:
        sys.exit(f"{node}: found {len(starts)} times in {src}, need exactly 1")
    i = starts[0]
    indent = lines[i][: len(lines[i]) - len(lines[i].lstrip())]
    j = next(n for n in range(i + 1, len(lines)) if lines[n] == indent + "};")
    own = [n for n in range(i + 1, j) if lines[n].startswith(indent + "\t") and not lines[n].startswith(indent + "\t\t")]
    status = [n for n in own if lines[n].strip().startswith("status")]
    if status:
        lines[status[0]] = f'{indent}\tstatus = "disabled";'
    else:
        lines.insert(j, f'{indent}\tstatus = "disabled";')
    tmp = dst + ".dts"
    open(tmp, "w").write("\n".join(lines))
    done = subprocess.run([dtc, "-I", "dts", "-O", "dtb", "-o", dst, tmp], capture_output=True, text=True)
    os.remove(tmp)
    if done.returncode != 0 or not os.path.getsize(dst):
        sys.exit("dtc failed:\n" + done.stderr[-800:])
    print(f"{dst}: {node} disabled ({os.path.getsize(dst)} bytes)")

if len(sys.argv) != 4:
    sys.exit(__doc__)
main(*sys.argv[1:])
