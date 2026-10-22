# Transitions

TD build: 2025.32460

How the mixer gets from one scene to the next. Every transition has the same contract:

- two TOP inputs, A then B
- a `Progress` parameter, 0 to 1, on a page called Transition
- one TOP output

| Transition | Does |
|---|---|
| `fade_black.tox` | A down to black over the first half, B up from black over the second |
| `cross.tox` | Straight dissolve, A to B |

Both run backwards as well as forwards: the mixer's buses flip-flop, so every other transition
goes from B to A with progress running 1 to 0. Write new ones so that works.

In the show they live inside `/project1/mixer` as `tr_fade_black` and `tr_cross`, with
`Progress` set by expression from `mixer/state`. Out of the mixer that expression has nothing to
read, so a loaded `.tox` shows an error until its `Progress` is set.

**Adding one** (by hand for now — the menu is not built from this folder yet): copy `tr_cross`
inside the mixer, change what it does, wire `bus_a` and `bus_b` into it and its output into the
next free input of `transition`. Its number in `ctrl`'s `transition` channel is that input.
Save it here.

Next on the list from `docs/PLAN.md` section 9: `blend` (pass through a composite of A and B)
and a wipe in UV space that sweeps around the cones.
