# Transitions

TD build: 2025.32460

How the mixer gets from one scene to the next. Every transition has the same contract:

- two TOP inputs, A then B
- a `Progress` parameter, 0 to 1, on a page called Transition
- one TOP output
- `Active`, `Weight` and `Layers` on the same page, like a scene: the mixer picks the next
  transition from the ones that are `Active` with every named layer on. `render3d` names `render3d`

| Transition | Does |
|---|---|
| `fade_black.tox` | A down to black over the first half, B up from black over the second |
| `cross.tox` | Straight dissolve, A to B |
| `render3d.tox` | The strip dips to black (A out, B in) while the Blender render is drawn over the tipis. Index 2. Runs as long as the render movie (10.42 s), the rest get a random length |
| `uvwipe.tox` | A sweep in UV space: B takes over from A round each cone, starting on the outer back, and the two sweeps meet over the canopy. Index 3. Asked for by `scene_kaleidoscope` |

All run backwards as well as forwards: the mixer's buses flip-flop, so every other transition
goes from B to A with progress running 1 to 0. Write new ones so that works.

In the show they live inside `/project1/mixer` as `tr_fade_black`, `tr_cross`, `tr_render3d` and `tr_uvwipe`, with
`Progress` set by expression from `mixer/state`. Out of the mixer that expression has nothing to
read, so a loaded `.tox` shows an error until its `Progress` is set.

**Adding one** (by hand for now): copy `tr_cross` inside the mixer, change what it does, wire
`bus_a` and `bus_b` into it and its output into the next free input of `transition`. That input
is its number when forcing one in `ctrl`'s `transition` channel, and it joins the pool (`tpool`)
on its own. Its length is random between `fademin` and `fademax`, unless it is `tr_render3d`.
Save it here.

**`render3d` is a dip to black with a second half outside the component.** `tr_render3d` keeps the
contract: A, B, `Progress`, one TOP. Inside it picks A or B at progress 0.5 and dims it by the
`dip` channel of `mixer/state` (1 = black): the strip goes to black under the render, A is gone
before B comes up, and the render plays on black through the middle. `dip` is the same envelope
that drives the overlay (rise over the first `overlayrise`, hold, fall over the last `overlayfall`),
so black and render move together, and it does not depend on the layer: with the layer off
you still get the dip, just no render. If the mixer is not running a transition (the manual
fader) it falls back to the `fade_black` curve. The overlay itself is not in the component, because
it is drawn on the 3D mesh: `Render_Engine/geo_overlay` follows `overlay`. Saved here so the
transition can be dropped in on its own; without the mixer's `state` its `Progress` shows an
error, like the others, and without `geo_overlay` it is a dip to black.

## uvwipe

The transition only this geometry can do. A wipe on a flat screen is a line crossing a
rectangle; this one is a sweep travelling round the cones and across the canopy.

```
in_a ──┐
in_b ──┼─ wipe (GLSL TOP) ── out1
uvgen_sweep ┘            Progress, soft (wipe_ctrl)
```

- `uvgen_sweep` renders the tipi mesh into its own texture space, the way `uvgen_topdown`
  does (a GLSL MAT puts each vertex at its UV; the pixel shader writes a number as colour). The
  number is the **sweep field**, 0 to 1: how late the wipe reaches that point of the surface.
  It is the angle round the cone's apex, from 0 on the side facing away from the other tipi to 1
  facing it, mixed with how far across toward the plane between the tipis (`across`, 0.3). Tipi 2
  is reflected, so both cones sweep the same way and the field is symmetric. The two sweeps meet
  over the canopy, which is reached last.
- `wipe` mixes A into B with it. The soft edge runs the whole field plus its own width, so at
  progress 0 the picture is entirely A and at 1 entirely B (measured: mean abs difference to A at 0
  and to B at 1 both 0.0), with a smooth edge of `soft` (0.3) of the sweep in between.
- It runs backwards because progress is just an offset into the same field: at 1 to 0 B is pulled
  back along the way it came, finishing on the outer backs of the cones. The buses flip-flop, so
  that is every other run.
- `wipe_ctrl` is a constant CHOP: `soft`, `across`, and the measured footprint (`apex1x`
  0, `apex2x` 115.12, `apexz` 0, `baser` 51.1; see `Components/UVMaps/README.md`). The footprint
  is the same numbers as `uvmap_topdown_mirror`.
- `Progress` is `mixer/state` `progress`, like the others. `Active` / `Weight` / `Layers` are
  there too, with no layer (always available).

It works on the strip, so it only reads as a sweep **on the tipis**, not in the monitor's cropped
picture. Take the `Transition` parameter on a scene (`Components/Scenes/README.md`) to ask for it.
It is the same length as any other transition, a random 2 to 8 s.

Next on the list from `docs/PLAN.md` section 9: `blend` (pass through a composite of A and B).
