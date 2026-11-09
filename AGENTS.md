# AGENTS.md

Tooling for the surya audio work. Conventions:

- Run builds and anything hardware-adjacent on the lab machine with `lab-agent submit --wait`
  (see its AGENTS.md); do not compile kernels in a throwaway sandbox.
- Findings that matter go on the kernel PR or in `linux-phone-oco/docs`, not only in a chat.
- State what was measured and what was only inferred. "Built and ready" means the file exists and
  was checked, not that the command ran.
- Scripts here are tested by running them from a fresh clone before they are committed.
