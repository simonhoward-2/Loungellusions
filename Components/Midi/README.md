# Midi

TD build: 2025.32460

The controller. Owns the device and the CC table and publishes four knobs, named by the shape
printed on them. Nothing else in the show talks to a MIDI In CHOP.

**Looks like:** nothing. A CHOP.

**Publishes** `/project1/midi/knobs`: `tri`, `pent`, `circ`, `sq`, always present, always 0 to 1.

**Needs:** the controller mapped as **device id 1** in Dialogs → MIDI Device Mapper. That
mapping is per machine, not in the file. Without it `midi_in` warns "Could not open the MIDI
interface" and the knobs sit at their defaults — the show keeps running.

**Inside:**

```
midi_map (table) ─┐
midi_in ──────── read_knobs (Script CHOP) ── knobs (null)
panel_tri/pent/circ/sq ── panel_in ──┘
```

**On-screen knobs.** `/project1/control_panel` has four sliders, `knob_tri`, `knob_pent`,
`knob_circ`, `knob_sq`, next to the master parameters. They drive the same four knobs as the
hardware. **Whichever moved last wins**: turn the hardware and it takes over, drag a slider and
that takes over, so the two never fight. The same `snap` applies, so a slider past halfway is on.
`panel_*` Select CHOPs read each slider's `out1`; `panel_in` merges them into `read_knobs`'s
second input.

`midi_map` is the **only** place a CC number is written down:

| Column | Does |
|---|---|
| `shape` | Channel name published |
| `cc` / `chan` | Where it arrives. `midi_in` builds its CC list from this column |
| `invert` | 1 flips it. Toy controllers are often wired backwards |
| `snap` | 1 = the knob reads **0 or 1 only**. On for all four: these knobs are switches, not faders |
| `default` | Value with no controller, or before the knob is first touched. Also a quick way to test a knob with nothing plugged in |

The CC numbers (70–73) are placeholders until the controller is learnt. Re-learn or swap the
controller and this table is the whole change.

The values are global. What a knob **does** is each scene's choice, wired by hand. Every scene
brings the values in with a `midi` Select CHOP and a `knobs` null at the top of its network —
see `Components/Scenes/README.md`.
