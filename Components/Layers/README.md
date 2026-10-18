# Layers

One component per artwork. Each is a complete channel: a named source, the effect chain, its
own UV remap, and its own audio reaction. The master only mixes them.

| Layer | Source | Mapping | Audio | Look |
|---|---|---|---|---|
| `mariokart.tox` | `mario` | GLSL | `kick` | Split-screen racing, bloom on the beat, a touch of glitch |
| `microscope.tox` | `gem` | Strip | `low` | Mirrored macro footage, hue drifting with the bass |
| `vhs.tox` | `underworld` | Hybrid | `level` | Trails, tape-like smear |
| `render3d.tox` | `car_trail` | Top-down | off | Blender renders of the tipi surface, landed back on the tipis |

**Each layer owns its remap.** The UV mappings are instanced inside every layer as external
toxes from `Components/UVMaps/`, behind the layer's `Mapping` menu. Only the selected one
cooks, so the others cost nothing. That means two layers can map the same footage differently
at the same time.

**Controls** are one page per effect, plus a Layer page for source, mapping, audio and opacity.
See `Components/Layer/README.md` for the full parameter list — these three are instances of
that component with content-specific defaults.

**Adding a layer:** copy the closest of the three, rename, set its `Source`, `Mapping` and
audio defaults, wire its `out1` into `composition` at the top level, and save it here.

The VHS layer is a placeholder look until real tape captures arrive — it's the hybrid mapping
with trails, not a genuine VHS process.

## render3d

The channel for Blender work. The animation is authored on the tipi models in
`Models/Teepee2_master.blend`, shrinkwrapped onto the tipi surface, then rendered from a
camera looking straight down and exported to `../Loungellusions Media/Renders/`. The
`topdown` mapping puts it back where it came from. Scenes in their own right, and the
transitions between the other scenes.

Its node in the show file is `/project1/render3d`, input 3 of `switch1` — the scene
selector `button1` drives (`count1` now counts 0-3, not 0-2).

### It is a surface layer (S18)

This one does not hand the show an image. `surface_topdown` inside it publishes two things:

- **a mesh** on the layer's `out_geo` SOP output — the show's own 31-point mesh with a second
  UV set written into layer 1 by a Texture SOP projecting through `cam_blender`, an
  orthographic stand-in for the Blender render camera. Layer 0 is untouched, so the same mesh
  still serves the image layers.
- **a material**, `mat_surface`, a Constant MAT reading `colormapcoord uv1` with the layer's
  full-resolution image — 1280x630 straight off `fx`, not the 1280x360 show strip.

`switch2` input 3 takes the mesh, `Render_Engine/geo1.material` takes the material, both on
the scene index. One render pass, the same calibrated cameras, no compositing.

`lvl_master` carries `Masterlevel * Masterfade` because this path never passes through
`master`. Without it the blackout would not cover this scene.

The `topdown` entry in the `Mapping` menu still works and still produces the strip — it is
the fallback, and the thing to compare against. `preview_showpath` shows what the show path
is actually wearing; `uv_topdown/preview_topdown` is the calibration view.

Every effect is dry by default and `Audiosrc` is off, because a Blender render arrives
finished: the car already leaves its own trail, so the layer's trails on top of that just
smear it. Turn them up as a deliberate choice, not a starting point.

It was copied from `vhs`, and two things came with it:

- `test_src` is the vhs sample cycler. Left in place, not wired. The layer reads `sel_src`.
- Its `fx` chain had the trails feedback branch stuck at 1280x720 while the rest of the
  chain followed the source, so a 2.03:1 render was refit into 16:9 and the mapping sampled
  the wrong pixels. Every node in that chain now takes its resolution from `src` by
  expression. Resolution does not inherit through a feedback loop — see the MCP skill notes.
