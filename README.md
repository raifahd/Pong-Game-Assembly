Pong (COM) — Compact 16-bit x86 VGA demo

**Overview:** Compact two-player Pong in 16-bit x86 assembly (COM, org 0x100).
Uses VGA Mode 13h and BIOS/DOS interrupts for drawing and input. First to **10** wins.

**Controls:** Left = **W/S**, Right = **O/L**. **ESC** = exit, **R** = restart.

**Build:** `nasm -f bin -o pong.com pong_game.asm`
**Run:** `dosbox pong.com` (or any DOS emulator)

**Tweak:** Change constants at the top of `pong_game.asm` (ball/paddle/speed/bounds).

**Notes:** No sound; uses BIOS pixel calls (simple & portable). Requires VGA/DOS.