# Mixer

TD build: 2025.32460

Runs the show. Finds the available scenes, decides how long each runs, picks the next one and
carries the picture into it with a transition. First version, 2026-10-22: a proof of concept of
`docs/PLAN.md` section 9 — two buses, a pool, a clock and two transitions. No panel yet.

**Looks like:** the show image. `out1` is 1280x360, the same strip `switch1` used to hand on.

**In the show:** `/project1/mixer`, in the **MIXER** box between SCENES and COMPOSITION. The six
scenes are wired into its inputs in the old `switch1` order, and `out1` feeds `composition`.

| Input | Scene |
|---|---|
| 0 | `base1` |
| 1 | `teepee_feedback` |
| 2 | `scene_microscope` |
| 3 | `scene_render3d` |
| 4 | `scene_mariokart` |
| 5 | `scene_vhs` |

**Publishes** `/project1/mixer/state`: `a` and `b` (the scene index on each bus), `progress`,
`scene` (the one on air) and `running`. `switch2.input` and `Render_Engine/geo1.material` read
`scene`, so the mesh and the render3d material follow the mixer instead of the old `button1`
counter. They change at the midpoint of a transition — black, in `fade_black`; a visible snap,
in `cross`, when one side is the render3d surface scene.

**Controls** are nodes inside `mixer`, in the CONTROLS box, not parameters on the COMP:

| Node | Does |
|---|---|
| `btn_auto` | On: the clock runs the show. Off: the fader does |
| `btn_pause` | Hold the scene on air. The clock stops, nothing transitions |
| `btn_next` | Run the transition now, Auto or not |
| `fader` | Manual progress while Auto is off. Picked up only when moved |
| `ctrl` | `scenelength` s (20), `variance` 0–1 (0.2), `randomness` 0 in order / 1 weighted random (0), `fadetime` s (4), `transition` 0 `fade_black` / 1 `cross` |

**Inside:**

```
in_0..in_5 ─┬─ bus_a ─┬─ tr_fade_black ─┐
            └─ bus_b ─┴─ tr_cross ──────┴─ transition ── out1

sequencer (Execute DAT, every frame) ── bus_state ── state
                                     ── pool, readout
```

**Two buses, flip-flop.** Progress 0 means bus A is on air, 1 means bus B. A transition runs
progress to the other end; when it lands, the bus that just went off air loads the next scene.
Nothing swaps, so the next transition is the same one run backwards. The off-air bus loads a
whole scene length early, which gives feedback scenes time to build up before they are seen.
Only the two selected scenes cook — a Switch TOP cooks just its chosen input.

**The pool.** `pool` has one row per input: available, or why not — `off by hand` (the scene's
`Active`), `layer vhs off` (a layer it names is off) or `no layer x` (it names a layer that does
not exist). The camera scenes have no `Active` or `Layers` and always count as available.
A scene that goes unavailable while on air finishes its run; it is just not picked again.

`readout` holds now, next, time left, transition, fade time, progress, last, mode and paused —
what the panel will show when it is built.

**Not built yet:** the panel, `allowCooking` on inactive layers, a fallback scene for an empty
pool (it holds the scene on air instead), `Cue` (choosing B by hand), and `cycle` / `random`
transition modes.

The show file is the working copy; this `.tox` is an export. Re-save it after changing the mixer
in the show.
