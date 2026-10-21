# UVMaps

Ways a flat image lands on the tipis. Each is a self-contained component with one image
input and one output, instanced inside every scene so a scene owns its own mapping.

| Component | Method |
|---|---|
| `uvmap_ramp.tox` | **Ramp.** The UV map is built from ramp masks — the original approach that shipped with the model. Its generator is `uvgen_ramp` |
| `uvmap_mirror.tox` | **Mirror, animated.** Same mirror method as below, plus an internal `lfo_split` CHOP that drives `crop4.cropbottom` and `crop5.croptop` — LFO 0 = classic 50/50 split, LFO 1 = no crop. Rate, depth and centre are the `Splitrate`, `Splitdepth` and `Splitcentre` parameters on the component, so a scene can animate the mapping itself (its Mirror page drives them). Defaults 0.15 / 0.5 / 0.5 match the old fixed LFO. Used by `vhs`, `microscope`, `render3d` |
| `uvmap_mariokart.tox` | **Mirror, static.** The original mirror method with fixed 50/50 crops. Kept separate from `uvmap_mirror.tox` so the mariokart layer can't inherit the animation. Used by `mariokart` (node renamed to `uv_mariokart` inside that layer) |
| `uvmap_topdown.tox` | **Top-down.** For footage that is already a view of the tipis from above — Blender renders, mostly. Each point of the tipi surface samples the footage at its own footprint position. Its generator is `uvgen_topdown`. Used by `render3d` |

All output 1280x360 — the unrolled tipi strip.

These are **image mappings**: a TOP in, a TOP out, listed in a layer's `Mapping` menu. A
**surface mapping** writes a second UV set onto the mesh instead and hands over a material;
it is SOP + MAT, does not fit this shape, and lives inside the layer that owns it rather than
here. See S18. `render3d/surface_topdown` is the first one.

Templates vs branches: a layer links to a component here with `externaltox` only while it
uses it unchanged. See S19.

## The top-down mapping

The ramp and mirror mappings decide where content lands; this one doesn't decide anything —
the geometry does. It only works for footage shot or rendered looking straight down at the
tipis, which is how the Blender scenes are exported.

`uvgen_topdown` renders the tipi mesh **into its own texture space**: a GLSL material whose
vertex shader puts every vertex at its UV coordinate instead of its world position, and whose
pixel shader writes that point's top-down position as a colour — red is how far across the
footage to sample, green is how far up it. A Remap TOP reads that map and bends the footage
onto the tipis. One render, no per-frame geometry cost; the map only recooks if the model does.

### The two things it needs to know

**The mesh's world bounding box**, in the `bounds` CHOP inside the generator:

| Channel | Value |
|---|---|
| `minx` | -50.324 |
| `rangex` | 215.768 |
| `minz` | -51.100 |
| `rangez` | 106.023 |

**Re-measure `bounds` if the model changes**, or everything slides.

**How the Blender camera was framed**, as four parameters on the component. The camera is
almost never framed exactly on the bounding box — it pulls back a little — and the mapping
has no way to know by how much:

| Parameter | Value | Means |
|---|---|---|
| `Framew` | 1.057 | the render frame is 1.057 bounding-box widths across |
| `Frameh` | 1.059 | and 1.059 bounding-box heights tall |
| `Uoffset` | -0.0125 | frame centre sits 2.9 units right of the box centre |
| `Voffset` | 0.0053 | and 0.6 units off in Z |

In world units that is a 228.1 x 112.3 frame around a 215.8 x 106.0 box. Six percent, and it
was enough to strip the trail off everything but the rim of one tipi.

These were measured, not guessed. The tipi apexes sit at x 0 and x 115.12, both at z 0, and
every base point is exactly 51.1 from its own apex axis — so the two cones are 115.12 apart
and 102.2 across. Max-accumulate the whole clip (every pixel the car ever lit), and the lit
area runs 0.011–0.964 across the frame, with the right-hand loop 0.9108 of the frame tall.
Solve those against the 115.12 separation and the frame comes out 228.1 wide. The check that
it is right: the car's loop radius falls out as 51.13, and the base ring is 51.1 — the car
drives exactly on the rim, which is what the Blender scene does.

If a future render is framed differently, redo that or just open `preview_topdown` and nudge
the four numbers until it matches the source.

### Which way round

Three toggles cover the axis conventions, because Blender's top-down camera and
TouchDesigner's do not agree: `Flipu`, `Flipv` (on by default — Blender looks down its -Z,
TouchDesigner down its +Y) and `Swapuv`. If a render lands mirrored or on its side, one of
these three fixes it; nothing else needs touching.

Two dev previews inside the component put the mapped texture back on the real tipi mesh.
Neither is in the show path, so they cost nothing unless you open them.

| Node | View |
|---|---|
| `preview_render` | From the side. Shows how the trail wraps the cones |
| `preview_topdown` | Straight down, orthographic, framed on the bounding box — the same view Blender rendered from. **This is the calibration tool:** it should look like the source render |

Note the show's own preview (`Render_Engine/preview_cam`) sits *below* the floor looking up,
so it shows the dark insides of the cones with content only on the rims. That is the camera,
not the mapping — judge the mapping on `preview_topdown`.

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
