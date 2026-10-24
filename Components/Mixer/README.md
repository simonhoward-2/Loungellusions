# Mixer

TD build: 2025.32460

Runs the show. Finds the available scenes, decides how long each runs, picks the next one and
carries the picture into it with a transition. First version, 2026-10-22: a proof of concept of
`docs/PLAN.md` section 9 — two buses, a pool, a clock, two transitions and a monitor.

**Looks like:** the show image. `out1` is 1280x360, the same strip `switch1` used to hand on.

**In the show:** `/project1/mixer`, in the **MIXER** box between SCENES and COMPOSITION. The seven
scenes are wired into its inputs in the old `switch1` order, and `out1` feeds `composition`.

| Input | Scene |
|---|---|
| 0 | `base1` |
| 1 | `teepee_feedback` |
| 2 | `scene_microscope` |
| 3 | `scene_render3d` (`Active` off, see render3d overlay) |
| 4 | `scene_mariokart` |
| 5 | `scene_vhs` |
| 6 | `scene_blend` |

**Publishes** `/project1/mixer/state`: `a` and `b` (the scene index on each bus), `progress`,
`scene` (the one on air), `running`, `clock` (0–1 through this scene), `left` (seconds),
`lvl_a` / `lvl_b` (how much of each bus is in the picture), `tprog` (0–1 through the running
transition), `overlay` (0–1, the render3d overlay level, see below), `dip` (the same envelope without the layer gate: how far `tr_render3d` has taken the strip to black), `tr` (the transition picked: its input on `transition`) and `fade` (its length in seconds). `transition`'s index reads `tr`. `switch2.input` reads
`scene`, so the mesh follows the mixer instead of the old `button1` counter, changing at the
midpoint of a transition. `Render_Engine/geo1.material` is fixed on `constant1`.

**Controls** are nodes inside `mixer`, in the CONTROLS box, not parameters on the COMP:

| Node | Does |
|---|---|
| `btn_auto` | On: the clock runs the show. Off: the fader does |
| `btn_pause` | Hold the scene on air. The clock stops, nothing transitions |
| `btn_next` | Run the transition now, Auto or not |
| `fader` | Manual progress while Auto is off. Picked up only when moved |
| `ctrl` | `scenelength` s (20), `variance` 0–1 (0.2), `randomness` 0 in order / 1 weighted random (0), `fademin` / `fademax` s (2 / 8: a random transition length is drawn between them), `transition` **-1 pick from the pool** / 0 `fade_black` / 1 `cross` / 2 `render3d` to force one, `trrandom` 0 walk the transitions in order / 1 weighted random (1), `overlayrise` / `overlayfall` (0.3 each: the share of a render3d transition spent fading the overlay in and out) |

**Inside:**

```
in_0..in_6 ─┬─ bus_a ─┬─ tr_fade_black ─┐
            └─ bus_b ─┼─ tr_cross ──────┼─ transition ── out1
                      └─ tr_render3d ───┘

sequencer (Execute DAT, every frame) ── bus_state ── state
                                     ── pool, readout
```

**Two buses, flip-flop.** Progress 0 means bus A is on air, 1 means bus B. A transition runs
progress to the other end; when it lands, the bus that just went off air loads the next scene.
Nothing swaps, so the next transition is the same one run backwards. The off-air bus loads a
whole scene length early, which gives feedback scenes time to build up before they are seen.
Only the two selected scenes cook — a Switch TOP cooks just its chosen input.

**The transition pool.** Transitions are picked the way scenes are. Each `tr_` COMP has the same
`Active` / `Weight` / `Layers` as a scene; `tpool` has one row per input of `transition` (available,
or why not, and `onair` / `next` / `ready` / `out`), scanned by the same code as `pool`. A
transition is out when it is switched off or a layer it names is off, so `render3d` drops out of
the pool as `layer render3d off` when its layer is off. When a scene lands, the sequencer picks the
next transition **and its length** together (`tr_index`, `fade` in the mixer's storage, `tr` and
`fade` in `state`) so the monitor shows what is coming. `ctrl` `transition` -1 picks from the pool
(`trrandom` 0 in order, 1 weighted random, never the same one twice running); 0, 1 or 2 forces
that one. A forced one set after the pick wins when the transition begins.

**Length.** `render3d` runs exactly as long as the render movie, so the clip plays once through,
frame 0 at the start and the last frame at the end (250 frames at 24 fps, 10.42 s). Every other
transition draws a random length between `fademin` and `fademax`. The movie length comes from
`layer_render3d/clip_info` (an Info CHOP on the movie): while the movie is loaded during a
render3d transition the sequencer stores frames / rate as `r3d_len`, and the next pick uses that.
A swapped-in clip is therefore used from the transition after the first one that loads it; the
stored fallback is 10.42 s. `fade` is fixed when the transition is picked, not re-read per frame.

**The render3d overlay.** `render3d` is not a scene in rotation; it is a transition (index 2 of
`transition`, picked from the pool like any other). The strip goes A to B through `tr_render3d`, a dip to black, and the
Blender render is drawn **over** the tipis by `Render_Engine/geo_overlay` while it runs, and the
strip underneath fades to black for it (A out, then B in, `tr_render3d` is a dip). The
sequencer publishes the level as `state` `overlay` (and, as `dip`, how black the strip is): 0 outside a render3d transition, then a
smoothstep up over the first `overlayrise` of it, 1 through the middle, and down over the last
`overlayfall`. It follows the transition picked when the run starts, so changing `ctrl` mid-fade cannot snap it
off, and it is 0 when `layer_render3d` is switched off, so that layer's button is the master switch
for the overlay: the strip still crosses, no render. Only a running transition draws it; a manual
fader move does not.

At the start of every render3d transition the sequencer stores `r3d_t0` (the movie's index
reads it, so the clip starts from its first frame) and pulses the reset on the scene's trail
feedback (`scene_render3d/fx/t_fb`), so each run starts clean. It also turns `allowCooking`
on for `layer_render3d` and `scene_render3d` and off again when the transition lands: idle, the
movie is unloaded and neither cooks (measured 0 cooks over 359 frames; with the layer left cooking
the movie decoded every frame, 347 of 356).

**The pool.** `pool` has one row per input: available, or why not — `off by hand` (the scene's
`Active`), `layer vhs off` (a layer it names is off) or `no layer x` (it names a layer that does
not exist). The camera scenes (`base1`, `teepee_feedback`) have `Layers` only, so they follow their camera layer;
a scene with neither `Active` nor `Layers` always counts as available.
A scene that goes unavailable while on air finishes its run; it is just not picked again.

`readout` holds now, next, time left, transition, fade time, progress, last, mode and paused. A render3d transition reads `render3d` in it.

**The monitor.** `monitor` is a Container COMP, 1280x950, and `/project1/mixer_monitor` (an
annotate box in the MIXER box with its OP viewer on and **interactive**) shows it on the main
network — clickable there. An OP Viewer TOP was used first and cannot take clicks. Top to bottom:

| Part | Shows |
|---|---|
| Header | AUTO / MANUAL, PAUSED, the last scene, and the **PLAY / PAUSE / NEXT** buttons |
| NOW / NEXT | Name and a live thumbnail of each bus, green for on air, amber for cued |
| Clock bar | How far through this scene, and seconds to the next transition |
| Transition bar | Which transition (the next one while idle), its length, how far through it is while it runs, and `overlay 0.80` while the render3d overlay is up |
| OUT | The mixed output |
| History | `lvl_a`, `lvl_b` and `overlay` over the last two minutes — each transition is two lines crossing, and a render3d one has a third that rises and falls across them |
| Pool | One cell per scene: green on air, amber next, grey ready, red out with the reason |
| Transition pool | A second row, one cell per transition, same colours; the picked one shows its length (`next  6.7 s`) |

The pictures are cropped to the band the tipi UVs actually use, v 0 to 0.37 of the strip
(`band_now`, `band_next`, `band_out`), and stretched to fit, so they read about twice as tall as
the real proportions. Everything reads `state`, `readout` and `pool` by expression through
`parent.Mixer`; nothing in the monitor computes.

The buttons are Text COMPs; `button_exec` (a Panel Execute DAT on their `lselect`) drives the
mixer's own controls, so the two sets of buttons never disagree. **Play** turns `btn_auto` on and
`btn_pause` off. **Pause** turns `btn_pause` on. **Next** stores `next_request` on the mixer and the
sequencer runs the transition on its next frame — it works while paused too, and stays paused
after. Play lights green while the clock runs, Pause amber while paused, Next amber while a
transition runs. It only cooks while something is looking at it.
`mixer_history`, `mixer_readout`, `mixer_pool` and `mixer_tpool` sit next to it on the main network as plain
tiles. There is one pool cell per mixer input, built by script; a new scene needs its cell added
(the cells are `monitor/pool_<n>`, 170 px wide at seven).

**Adding a scene:** wire it into the next free mixer input, add `in_<n>` inside (named so it
sorts after the others — In TOPs order alphabetically), wire `in_<n>` into input `n` of `bus_a`
and `bus_b`, give `switch2` a mesh at the same index (`tipi_geo` for an image scene), and add a pool cell to `monitor`.

Fade time used to be one `ctrl` value, `fadetime`. It is gone: every transition now has a length of its own.

**Not built yet:** Auto and the fader on the monitor (they are still only in the CONTROLS box), `allowCooking` on inactive layers, a fallback scene for an empty
pool (it holds the scene on air instead), `Cue` (choosing B by hand), and `cycle` / `random`
transition modes (the pool pick replaced them).

The show file is the working copy; this `.tox` is an export. Re-save it after changing the mixer
in the show.
