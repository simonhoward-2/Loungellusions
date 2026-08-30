# UVMaps

Two ways a flat image lands on the tipis. Each is a self-contained component with one image
input and one output, instanced inside every layer so a layer owns its own mapping.

| Component | Method |
|---|---|
| `uvmap_ramp.tox` | **Ramp.** The UV map is built from ramp masks — the original approach that shipped with the model. Its generator is `uvgen_ramp` |
| `uvmap_mirror.tox` | **Mirror.** Two arc edges set a focal point on each cone; content mirrors or extends outward from there. Its generators are `uvgen_compose_left` and `uvgen_compose_right`, one per tipi |

Both output 1280x360 — the unrolled tipi strip.

## Why the mirror mapping has two generators

The two tipis face the camera at different angles, so each needs its own focal arc. The arcs
are `const0value` / `const1value` on the `constant1` CHOP inside each generator, in degrees:

| Generator | Tipi | Arc |
|---|---|---|
| `uvgen_compose_left` | Left in camera view | 200–310 |
| `uvgen_compose_right` | Right in camera view | 50–160 |

The arc decides which slice of the cone receives the image; everything outside it is where the
mirroring happens. Move the arc and the seam moves with it — put it behind the tipi and the
crowd never sees it.

A shader inside each generator measures the angle around a centre point and maps that arc onto
the source image. That is why these are cone-shaped fans rather than rectangles: a cone unrolls
flat into a fan, so a fan is the mapping that adds no distortion.

## Dropped

`uvmap_hybrid.tox` was the ramp mapping on one tipi and the mirror mapping on the other —
a mongrel rather than a third method. Archived. If you ever want the two tipis mapped by
different methods, do it with two layers rather than one component that hides the mismatch.
