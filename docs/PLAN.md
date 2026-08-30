# Plan — what to try next

Play-first plan. Experiments at the top, engineering at the bottom where it belongs.
Nothing here is a commitment; if something looks boring on the tipi, drop it.

Immediate goal: **friends over tomorrow night, make things look weird on a surface.**

---

## 1. What's already in the master

`Loungellusions_master.toe` is further along than the docs suggest. Read from the expanded
file, so this is what's actually in there, not what we remember putting there:

**The chain, end to end**

```
6x syphonspoutin + moviefilein sources
  -> feedback / mirror / hsvadj / ramp / chroma  (the look)
  -> Image_wrapping (base COMP)                  (the 2D wrap stage)
  -> null3 -> textureiser_geo                    (texture onto the tipi)
       select1 -> transform1 -> null2            (the tipi geo, from the FBX)
  -> render1 -> comp1
  -> camSchnappr -> blendMask_out -> null5       (projector calibration + blend)
```

**What that means we already have**

- **Mapping works.** `camSchnappr` is in place and configured, with its Auto Blend page
  (Blend, per-channel gamma, luminance) — so the two-projector blend path exists already.
- **The tipi is loaded.** `Teepee2_contUV` FBX COMP feeding a SOP chain
  `select1 -> transform1 -> null2` into `textureiser_geo`. That SOP chain is the interesting
  place — see section 3.
- **Six live input slots.** `syphonspoutin1` through `syphonspoutin6`. Anything that speaks
  Syphon on the Mac is already a source.
- **A 2D wrap stage.** `Image_wrapping` holds crops, ramps, a `layout` and a `remap1` TOP at
  1280x360 — an unrolled-strip texture space, with masks and blends around it.
- **A look chain.** Feedback, mirror, HSV, ramps, chroma key — already wired for playing.

**One gotcha before tomorrow:** the master was last saved with **TD 2020.28110 on Windows**.
You're on 2025.32460 on Mac. Opening and saving bumps it forever (Standard S9/S10). Probably
fine — but don't discover it while friends are watching. Either accept the bump deliberately
and run `tools/td-version.sh sync` after, or work on a copy tomorrow (recommended below).

---

## 2. Tomorrow night

Half an hour of setup, then play. Don't spend the evening in the network editor.

**Before people arrive**

1. Install FunctionStore_tools and Palette-Tools into the user palette
   (`~/Library/Application Support/Derivative/TouchDesigner<ver>/Palette/`), restart TD.
   Details in section 6.
2. `cp Loungellusions_master.toe Experiments/uvplay/uvplay.toe` — **experiment on the copy.**
   `Experiments/` is lawless (Standard S4) and the show file stays untouched while a room
   full of people suggest things. Merge anything good back later, deliberately.
3. Point one projector at any cone-ish thing — rolled paper, a lampshade, an actual tipi if
   one's up. Doesn't need to be right, it needs to be on.
4. Get one live source into a Syphon slot so there's something to react to.

**Then: the test tox**

Make one small `.tox` whose only job is to be swappable — a source, a couple of effects, and
its knobs promoted to the top level (FunctionStore_tools makes that one click). That's the
unit everything else becomes. Don't design it; make it, then look at it.

**Then: run the experiments in section 3 in order.** They're sorted by how fast they pay off.

---

## 3. The mapping experiments

The idea worth chasing: **a cone is very forgiving, and the same footage becomes a different
artwork depending on how it's mapped.** Free variety, no new content. And every style below
is a different answer to "2D thing, 3D surface", which is Aim 1.

The cheap way in: `select1 -> transform1 -> null2` is a SOP chain, and a **Texture SOP**
dropped into it overwrites the geometry's UVs. Change one menu on that SOP and the mapping
style changes. No shader, no rebuild. Then a **Switch SOP** across several Texture SOPs turns
that into a menu — which is the per-artwork configurable option, built in about twenty minutes.

### 3.1 Texture SOP roulette — do this first

Drop a Texture SOP after `transform1`. Cycle its projection type while the projector runs.
That's it. Each type is a different artwork:

| Style | What it should look like | Good for |
|---|---|---|
| **Continuous UV (as-is)** | Wraps the cone seamlessly, verticals stay vertical, squeezes toward the apex | Patterns, texture, anything that should read as the tipi's skin |
| **Front planar** | Flat screen from the front, smearing and stretching around the sides | N64 and CRT — the game stays readable to the crowd standing in front |
| **Top-down** | Radiates from the apex outward, circles become mandalas | Microscope, kaleidoscope, lava lamp. Reads like light pouring down the tent |
| **Cylindrical** | Like the continuous UV but ignoring the taper — deliberately wrong toward the top | Same footage, different stretch. Free second version of everything |
| **Spherical / polar** | Fisheye pull, heavy distortion at the apex | Probably ugly. Try it anyway, ugly is content |

Expect two of these to look great, two to look broken and one to be a surprise. Note which,
in the experiment's README, while you remember.

### 3.2 Make it a switch

Several Texture SOPs in parallel, one Switch SOP, one custom parameter driving the switch.
Now the mapping style is a knob — assignable per artwork, changeable live, and eventually
MIDI-mappable like anything else.

Stretch version: cross-dissolve between two mapping styles instead of hard-switching. Cheapest
route is the existing `remap1` TOP in `Image_wrapping` — a remap is driven by a *map image*, so
two map images cross-dissolved gives a morph between mapping styles. The in-between states are
where the good accidents live.

### 3.3 The moving projector — the one that isn't just a menu

Everything above is static once set. This one moves, which is why it's the most likely to
produce something nobody's seen:

- **Virtual projector.** Project the texture from an arbitrary point in space rather than
  along an axis. Park that point where the crowd stands and the image looks correctly flat
  *only from there* — real anamorphic illusion, which is the whole "Loungellusions" premise.
  Then animate the point: the texture sweeps across the tipi like a searchlight.
- **World-space volume.** Derive UVs from 3D position in a moving texture volume, so the tipi
  becomes a window into something drifting past it. This is the microscope brief's "moving
  through a miniature world", except the world moves and the tent stays still.

These need a small GLSL MAT (UVs from world position, matrix from a Camera COMP) rather than
a Texture SOP. An evening's work, not a weekend's — but do 3.1 and 3.2 first, since they cost
nothing and one of them might be enough.

### 3.4 Test card, not noise

One piece of discipline, because it saves hours: audition mappings with a **numbered grid or
strong horizon line**, not generative noise. Noise hides stretch, seams and flips until the
moment you put real footage through it. Ten seconds of grid first, then play.

---

## 4. What to try after that

Rough queue, not a schedule. Pull whatever's most fun.

- **Audio reactive.** `Audio Device In CHOP` + the `audioAnalysis` palette component gives
  bands and beats immediately. One idea worth keeping as things grow: analyse **once**,
  centrally, and have components read the same channels — otherwise each artwork drifts to
  its own rhythm and the tipis stop looking like one piece. Handy trick for a room full of
  friends: mic input works fine as a stand-in for the FOH line.
- **A second and third test tox**, so the master finally has something to mix between.
  That's Aim 3, and it only gets real once there are two things to crossfade.
- **MIDI on the knobs.** `MIDI In Map CHOP` onto the promoted custom parameters. Bind to the
  component's parameters rather than to operators inside it, so rebuilding the guts doesn't
  cost the mapping.
- **Hand tracking** via <https://github.com/torinmb/mediapipe-touchdesigner> — free, GPU,
  no install. Pinch controls a parameter. This is the "at station controls" idea from the
  design doc, and it's a good party trick on its own.
- **The 3D pipeline**, when there's 3D content to justify it: geometry in a rendered scene
  with the tipi as the projection surface, rather than a flat source mapped onto it. Harry's
  bugs and critters, and the "looking glass / snow globe" tipi-cam idea.

---

## 5. Later, when it starts hurting

None of this is worth doing yet. Each item has a trigger — do it when the trigger fires,
not before.

| Thing | Do it when | What it buys |
|---|---|---|
| **Externalise components** — `.tox` on disk, Python as `.py` next to it, Text DAT tagged `EXT` | Two people want to work the same weekend, or an agent needs to read component logic | Real git diffs, no binary merge fear. Tools: [save-external](https://github.com/raganmd/touchdesigner-save-external), [tox-exporter](https://github.com/JohnENoonan/touch-tox-exporter), [td-style.guide](https://td-style.guide/docs/SM-guide/external-tox-files) |
| **Video transport decision — NDI vs USB** | Before spending money on the USB expansion card and extenders in the design doc | TD tends to hit a ceiling around two simultaneous USB webcams. NDI over the ethernet we're already running scales past that. Keep a capture card for the N64 — latency is visible when punters watch their own race |
| **Engine COMP isolation** | The first time one crashed input takes the whole show down | Each camera chain in its own process |
| **Perform Mode + pre-flight checklist** | Festival week | Nothing to drag, nothing to break, and a laminated list for whoever is nearest at dusk |
| **Content fallbacks** | Festival week | A dead input drops to a loop from `Renders/` instead of to black. Black reads as broken; a slow loop reads as "between pieces" |
| **Mapping style as a documented contract** | Once there are 3+ components and the switch from 3.2 exists | Artworks output flat, the mapping stage maps. Keeps calibration in one place instead of inside every component |

---

## 6. Tools

**Install tomorrow, before friends arrive**

- **[FunctionStore_tools](https://github.com/function-store/FunctionStore_tools)** — free.
  Promote a parameter to the parent in one click, place operators with your own defaults,
  swap operator positions. The parameter promotion is the bit you'll use constantly building
  test toxes.
- **[Palette-Tools](https://github.com/Richard-Burns/Palette-Tools)** — free. Bloom, glitch,
  camera and text components. Instant effects vocabulary to throw at the tipi.

Both install the same way: drop into
`~/Library/Application Support/Derivative/TouchDesigner<ver>/Palette/`, restart TD, and they
appear in the palette for every project.

**Free and worth having when the moment comes**

- [mediapipe-touchdesigner](https://github.com/torinmb/mediapipe-touchdesigner) — face, hand,
  pose tracking. Mac and PC, GPU, no install.
- [awesome-touchdesigner](https://github.com/monkeymonk/awesome-touchdesigner) — curated index.
  Look here before searching blind.

**Already in the kit:** TD-Launcher, `toeexpand` + `tools/td-version.sh`, TouchDesigner MCP,
`tools/td_backup.tox`. All documented in `docs/TOOLS.md`.

**Reference for the mapping work:** [camSchnappr docs](https://docs.derivative.ca/Palette:camSchnappr),
[Derivative's projection mapping guide](https://docs.derivative.ca/Projection_Mapping).

---

## 6. Per-tipi texturing and the Blender unwrap

Decided 2026-08-28, after measuring that the packed-strip approach caps each tipi at 640x115
pixels and that re-laying UVs in TouchDesigner distorts the islands (the drawn fan covered 41%
of an island needing 68%).

### Why one texture per tipi beats one packed strip

| | Packed strip (now) | Stacked strip | One texture each |
|---|---|---|---|
| Pixels per tipi | 640 x 115 | 1280 x 360 | 1280 x 720 |
| Effects per tipi | shared | shared | independent |
| Packing stage | layout + fan generator | layout + fan generator | none |

Separate textures are not just more pixels — they remove the reason the `uvgen` GLSL machinery
exists. The fan generator, the arcs, the ramp masks and the crops are all there to bend a
rectangular video into a fan-shaped UV island and to pack two of them into one image. Give each
tipi its own rectangular unwrap and all of that goes away, replaced by a Transform TOP.

They also unlock what the packed strip can't do: a different source, different effects and a
different audio channel per tipi. Two tipis showing two players' Mario Kart views with their own
treatments, rather than one image split in half.

### Blender checklist

1. Import `Models/Teepee2_contUV.fbx`. Keep the original file — export to a new name.
2. Separate into **three** objects (Edit Mode, `P`): `Tipi_A`, `Canopy`, `Tipi_B`. The canopy
   between the cones is a projection surface like the others — see the UV zones below.
3. Per cone: mark a seam from apex to base **up the back**, away from the crowd. The seam is
   where content wraps around and meets itself — it wants to be where nobody stands.
4. Unwrap each cone so its island is a **rectangle**: u runs around the cone, v from base to
   apex. Cylinder projection, or Follow Active Quads on a ring of faces.
5. Scale each island to fill 0..1 in its own UV space. Each object gets the whole square —
   no packing, no shared canvas.
6. Note which direction u runs and where u=0 lands, so the front of the tipi is known in TD
   without guessing.
7. Export FBX to `Models/`, transforms applied, scale 1.

### What changes in TouchDesigner

- Two Geometry COMPs, one per cone, each with its own Phong MAT and its own `colormap`.
- `render1` already takes a list in its geometry parameter, so both render into one image and
  the projector path is unchanged.
- `camSchnappr` keeps pointing at the merged mesh (`Geosop` is `/project1/null2`) — calibration
  needs the whole shape, not the split.
- `uvmap_*` components collapse. Sweeping content around a tipi becomes a `tx` offset on a
  Transform TOP, which is also how the animated searchlight effect gets built.
- Layers need a target: either one layer stack per tipi, or a `Target` parameter (A / B / Both)
  on each layer.

### The three surfaces, measured

Read off the current model, so the Blender work starts from fact rather than assumption:

| Surface | Prims | u range | v range | Height (y) |
|---|---|---|---|---|
| `coneA` | 10 | 0.000–0.421 | 0.041–0.352 | 0–68216 |
| `canopy` | 17 | 0.273–0.725 | 0.041–0.360 | 8424–20468 |
| `coneB` | 10 | 0.578–0.999 | 0.041–0.352 | 0–68216 |

This is what `contUV` in the filename means: the unwrap runs **continuously** left to right —
cone A, then the canopy, then cone B — and the ranges deliberately overlap where the canopy
meets each cone. One image flows across the whole structure, which is what makes a sweep from
one tipi across the canopy to the other tipi work at all.

That continuity is the thing to protect. Splitting into per-surface textures buys resolution
and independent effects, but the sweep then has to be reconstructed from three coordinated
offsets rather than coming for free. If each object's unwrap keeps u running in the same
direction, the offsets are just the u ranges above, recorded as constants — so both are
achievable, but it has to be a deliberate decision in Blender, not an accident of unwrapping.

### Cost

Two texture chains instead of one is roughly double the GPU work for the mapping stage. That
stage is cheap compared to the effects, and unselected mappings don't cook, but it is worth
watching once both tipis run live content.

### Blender master file and the two unwraps (2026-08-30)

`Models/Teepee2_master.blend` is the single source of truth for geometry and UVs. One mesh
(32 verts, 37 polys), two UV layers:

| Layer | What | Island shape |
|---|---|---|
| `UVMap` | The original unwrap that shipped with the FBX | Two cone **fans** joined by the canopy, sitting in the bottom third of the square |
| `UVRect` | Cylindrical unwrap authored in Blender | Three full-width bands: coneA `v 0–0.38`, canopy `v 0.39–0.61`, coneB `v 0.62–1.0` |

Export both to OBJ rather than FBX — `Models/Teepee2_fan.obj` and `Models/Teepee2_rect.obj`.
OBJ carries one UV set per file, which is why there are two, and TouchDesigner's File In SOP
reads them cleanly. The FBX route was abandoned: in 2025 the FBX COMP imports as POPs, and the
converted geometry arrived with no `uv` attribute at all.

In the master, `/project1/uvset` is a Switch SOP between the two, driven by the **UV Set**
parameter on `/project1`. Whichever is selected feeds `textureiser_geo`. The two meshes occupy
the same world space (the OBJs are scaled x1000 by `xf_rect` to match the baked FBX units), so
switching changes only how texture lands, never where the geometry sits.

**UV Set and a layer's Mapping have to agree.** Strip, GLSL, Hybrid and Stack all expect `fan`;
Rect expects `rect`. Nothing enforces it yet.

`camSchnappr` still calibrates against `null2`, the fan geometry. That is fine — the two meshes
are the same shape and calibration only cares about shape — but it is worth knowing if the
fan path is ever removed.

---

## 7. Where this actually landed (2026-08-30)

**Built and in the show file** (`Loungellusions_show.toe`):

- Three layers — `mariokart`, `microscope`, `vhs` — each owning source, effects, audio and mapping
- Two mapping methods, `ramp` and `mirror`, with the mirror arcs tuned per tipi (left 200-310, right 50-160)
- One audio analysis publishing eight channels, reaching both effect stages in every layer
- Composition and mastering at the top level, annotated regions, commented nodes

**Tried and archived** — see `Archive/README.md` for the full account:

| Attempt | Result |
|---|---|
| Raise texture resolutions | Broke the mapping. Aspect ratio, not resolution, was the constraint |
| Re-lay UVs in TouchDesigner (stack) | Drawn fans covered 41% of an island needing 68% |
| Cylindrical unwrap in Blender (rect) | Works, but a cone is developable — a rect unwrap smears toward the apex |
| Same with a truncated tip | Fixes the sawtooth gaps, still non-isometric |
| Fan islands packed uniformly | Packing correct (~8x on paper), placing the drawn fans overshot by 1.5x |
| **Split the mesh in half, one texture each** | **Worked — ~6.4x more pixels per tipi, verified** |

**The resolution question is still open.** Today each tipi is textured from roughly 705 x 115
pixels. The split-halves route reached ~1267 x 410 and is the only approach that improved
anything without breaking alignment, but it changes the render path and cuts the canopy down
the middle. It is parked in `Archive/`, not abandoned.

**The measurement to build first, next time:** render the geometry with a shader that outputs
UV coordinates as colour. That reads back exactly which texel each surface point samples, and
would have caught all four failures above in minutes rather than hours. Coverage ratio between
drawn content and island area is the pass/fail number — 1.0 is correct, 0.6 and 1.5 are the
two failures we measured.
