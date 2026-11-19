// SPDX-License-Identifier: MIT OR Apache-2.0
//! surya's own steps for the procedures in `procedures/`: what only this phone needs (the pmicwdt kernel, the
//! bite, the standby current). Whatever a second device would need too lives in lpoco-attended's step library.
//! Nothing here reads like a procedure; the procedure file does.

pub mod checks;
pub mod session;
