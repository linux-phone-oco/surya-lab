# dt - device-tree audits, no phone needed

Build a board's DTB at a commit and its parent, and compare: interrupts added and colliding (`irq-audit.py`),
MMIO windows overlapping (`reg-audit.py`), one node disabled for a hardware bisect (`disable-node.py`).
