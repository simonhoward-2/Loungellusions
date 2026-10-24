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

Both run backwards as well as forwards: the mixer's buses flip-flop, so every other transition
goes from B to A with progress running 1 to 0. Write new ones so that works.

In the show they live inside `/project1/mixer` as `tr_fade_black`, `tr_cross` and `tr_render3d`, with
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

Next on the list from `docs/PLAN.md` section 9: `blend` (pass through a composite of A and B)
and a wipe in UV space that sweeps around the cones.
