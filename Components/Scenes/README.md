# Scenes

TD build: 2025.32460

A scene takes one or more layers and makes them into a look: **the effects, the audio
reaction and the UV mapping all belong to the scene.** A layer is just a source (see
`Components/Layers/README.md`), so the same source can be a mirrored kaleidoscope in one scene
and a plain ramp in another.

| Scene | Layers | Mapping | Audio | Look |
|---|---|---|---|---|
| `microscope.tox` | `microscope` | Ramp | `low` | Macro footage, hue drifting with the bass |
| `mariokart.tox` | `mariokart` | Mirror, static (`uv_mariokart`) | `kick` | Split-screen racing, bloom on the beat |
| `vhs.tox` | `vhs` | Mirror, animated | `level`, mirror split on `kick`, beat warp on `kick` × `circ` | Trails and smear, the mirror seam breathing on the beat, melting on the beat when the circle knob is on. Pentagon knob = warp size |
| `render3d.tox` | `render3d` | Top-down surface (S18) | off | Blender renders landed back on the tipis |
| `template.tox` | one, unnamed | Ramp | — | The minimum scene. Copy it to start a new one |

In the show each is `/project1/scene_<name>`, in the **SCENES** box next to the LAYERS box, with
its layers wired into its inputs. Embedded (not `externaltox`), exactly as the old layers were. **The show file is the working copy; these `.tox` files are exports.** Re-save a
scene here after changing it in the show — right-click → Save Component, or
`op('/project1/scene_vhs').save(...)`.

## Inside a scene

```
in_<layer> -> fx -> pfx -> uv_ramp / uv_mirror / ... -> sw_map -> lvl -> out1
```

- `in_<layer>` is an In TOP: the layer wired into the scene from the master level, e.g.
  `layer_vhs` → `scene_vhs/in_vhs` (S20). A scene using two layers has two.
- `fx` and `pfx` are the effect chain from the old layer component, unchanged.
- The UV maps are instanced per scene (S13), so a scene can set its own mapping and animate it.

## Parameters

**Scene page** — what the mixer will read:

| Parameter | Does |
|---|---|
| `Active` | Take this scene out of rotation without touching its layers |
| `Layers` | Space-separated layer names this scene uses |
| `Weight` | How often it comes up when the mixer picks randomly. Default 1 |

**Layer page** — `Mapping`, `Audio Source`, `Audio Sensitivity`, `Noise Multiplier`,
`Opacity`. The page kept its old name so nothing referencing it broke; it is the scene's.

**One page per effect** — Kaleido, Bloom, Edge, Warp, Trails, Hsv, Palette. As before, see
`Components/Layer/README.md`.

**Mirror page** (scenes with `uv_mirror`) — effects on the mapping itself:

| Parameter | Does |
|---|---|
| `Split Rate` | Speed of the mirror split LFO, Hz. 0.15 |
| `Split Depth` | How far the split travels. 0.5 swings it from a 50/50 mirror to no crop |
| `Split Centre` | Where it swings around |
| `Split Audio` | Audio channel that adds to the depth. `off` by default |
| `Split Sens` | How much that channel adds |

Depth is capped at 0.5, so audio only shows when `Split Depth` is below that. `vhs` sits at
0.25 with `kick` adding up to 0.25.

## Knobs and audio (S21)

The knob values and the audio analysis are global. What they do is chosen by hand, per scene.
Every scene has the same four CHOPs **at the top of its network**:

| Node | Does |
|---|---|
| `midi` | Select CHOP of `/project1/midi/knobs` |
| `knobs` | Null. `tri`, `pent`, `circ`, `sq`, 0 or 1 |
| `audio` | Select CHOP of `/project1/audio/analysis` |
| `analysis` | Null. `low` `mid` `high` `level` `density` `speed` `kick` `noise`, 0 to 1 |

The older per-effect audio settings (`Audio Source`, `Warp Audio` and so on) still read
`/project1/audio/analysis` directly; `analysis` is for anything new wired by hand.

Pick off the knob you want where you want it: a Select CHOP on `knobs` into an effect, an
Export, or an expression such as `parent().op('knobs')['circ']` on a scene parameter. Nothing
is bound by default — every scene's look is exactly its own parameters until you wire a knob in.

## vhs: beat warp

The first effect wired by hand from the top-of-scene CHOPs:

```
analysis ── beat_kick (kick, renamed warp) ──┐
                                             beat_mul (multiply, gain 1) ── beat_warp ──▶ Wetwarp
knobs ───── beat_sens (circ) ────────────────┘
```

The circle knob is the sensitivity: at 0 there is no beat warp, at 1 every kick crossfades the
warp lane in, and the kick's lag tail lets it melt back out. `Wetwarp` on the Warp page reads
`0.0 + op('beat_warp')['warp']` — edit the `0.0` for a resting warp, `beat_mul`'s gain to
scale the whole effect, `beat_sens`'s channel to move it to another knob.

**Warp size** is the pentagon knob: `size_knob` (pent) → `size_range` (Math CHOP, 0–1 to
0.12–0.45) → `warp_size` → `Warpamt` on the Warp page. Knob off is the old 0.12; on is a heavy
0.45 melt. Edit `size_range`'s `torange` to taste. **Size only shows while the beat warp is in** — circle
knob on and a kick landing — because `Wetwarp` is the beat; with no beat the warp lane is mixed out.

Seen on real music on 2026-10-21: a kick of 0.69 took `Wetwarp` to 0.69 with the circle knob on,
and with the pentagon on as well the frame melted hard on each beat.

## Making a new scene

Copy `scene_template` (its own SCENE TEMPLATE box, above SCENES) and paste it into a gap in
the SCENES box. Rows are 400 px apart, with each layer level with its scene in the LAYERS box,
so a new scene and its layer drop in between two existing rows. It is the minimum:

```
in_layer -> uv_ramp -> lvl -> out1
midi -> knobs                      (at the top)
```

1. Rename it `scene_<name>`, and `in_layer` to `in_<layer>`.
2. Wire the layer in from the LAYERS box. Set `Layers` on the Scene page to match.
3. Put effects between `in_<layer>` and the mapping, or copy `fx` / `pfx` from another scene.
   Swap `uv_ramp` for another mapping from `Components/UVMaps/` if wanted.
4. Wire in the knobs you want from `knobs` — see Knobs above.
5. Wire `out1` into `switch1` (and a mesh into `switch2`, S18), and save it here as `<name>.tox`.

`template.tox` in this folder is the same component.

## Tom's camera scenes

`base1` and `teepee_feedback` are scenes too: a camera layer in, the tipi mesh selected inside
(`sel_geo`, a Select SOP of `/project1/tipi_geo`), and both a TOP and a SOP out. The geometry
select used to sit at the master level, wired in; it lives inside now so the only thing wired
into a scene is its layers. They have the knob CHOPs at the top like every other scene.

## Wiring in the show

Scenes wire straight into `switch1` (image) and `switch2` (mesh). Until the mixer exists,
both pick by the `button1` counter:

| Index | `switch1` | `switch2` |
|---|---|---|
| 0 | `base1` (camera `cam_71`) | `base1/out4` |
| 1 | `teepee_feedback` (camera `cam_41`) | `teepee_feedback/out2` |
| 2 | `scene_microscope` | `tipi_geo` |
| 3 | `scene_render3d` | `scene_render3d/out_geo` |
| 4 | `scene_mariokart` | `tipi_geo` |
| 5 | `scene_vhs` | `tipi_geo` |

`Render_Engine/geo1.material` switches to `scene_render3d/surface_topdown/mat_surface` on
index 3 only.

## render3d

The scene for Blender work. The animation is authored on the tipi models in
`Models/Teepee2_master.blend`, shrinkwrapped onto the tipi surface, then rendered from a camera
looking straight down and exported to `../Loungellusions Media/Renders/`. The `topdown` mapping
puts it back where it came from.

It is a **surface scene** (S18). `surface_topdown` inside it publishes a mesh on `out_geo` —
the show mesh with a second UV set in layer 1 — and a material, `mat_surface`, reading
`colormapcoord uv1` at full resolution, 1280x630 straight off `fx`.

`lvl_master` carries `Masterlevel * Masterfade` because this path never passes through
`master`. Without it the blackout would not cover this scene.

Its effect wets used to be typed straight onto `fx` (edge 0.241, warp 0.145, trails 0.338),
which left the scene's own pages at 0 and doing nothing. They are on the scene pages now, with
the same values, so the look is unchanged and the pages work.

Every node in its `fx` chain takes its resolution from `src` by expression. Resolution does
not inherit through a feedback loop — see the MCP skill notes.
