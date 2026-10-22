# Plan

**Phase: build.** The experimenting is largely done and the work now is making this
production-ready. Simon and Tom alternate as editors, so this document exists to keep one
shared picture of what is decided, what is optional and what is next — standardised enough
that either of us can pick it up cold, loose enough to stay out of the way.

Read sections 7-10 before starting anything. 7 and 8 are measurements and dead ends that cost
real hours; 9 and 10 are the current design.

## Status at a glance

| Area | State |
|---|---|
| First play night | **Done.** Section 2, kept as a record |
| Mapping experiments | **Optional.** Section 3 — a menu to pull from, not a queue |
| Tools installed | **Done.** Section 6 |
| Per-tipi texturing / unwrap | **One unwrap complete.** Section 7. Resolution work still parked |
| 3D pipeline | **In progress.** The current work — Blender renders landed on the tipis |
| Layers, scenes, mixer | **Layers and scenes built 2026-10-21; mixer proof of concept 2026-10-22.** Section 9 — two buses, pool, clock, `fade_black` and `cross`. No panel yet |
| Resolume as the mixer | **Alternative, not chosen.** Section 9A — every scene a clip, cooked on demand |
| Audio reactivity | **Wired per scene.** The analysis comes in at the top of every scene; `vhs` breathes its mirror split and warps on the kick |
| MIDI input | **Built, controller not yet learnt.** Section 10 — four 0/1 knobs, global values, each scene binds them its own way |
| Hand tracking | **Not now.** Parked deliberately, not forgotten |

Sections 1-8 are history and reference. Sections 9 and 10 are what we are building.

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

## 2. Tomorrow night — DONE

*Happened. Kept because the setup order was right and the next time we take this somewhere it
is the same list. Everything below is past tense now.*

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

## 3. The mapping experiments — OPTIONAL

*A menu, not a queue. None of these block anything; pull one when a scene needs a look it
hasn't got. 3.1 and 3.2 have since been overtaken in part — the Texture SOP trick is what the
top-down surface mapping in section 9 uses, and the UV-as-colour measurement asked for in
section 8 now exists. 3.3 is the one still genuinely unexplored, and still the most likely to
produce something nobody has seen.*

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

Rough queue, not a schedule. Status marked per item.

- **Audio reactive — PLANNED.** The analysis exists: `Components/Audio/` publishes eight
  channels and every layer reads them. What is still to come is using it deliberately per
  scene rather than as a wobble on everything. `Audio Device In CHOP` + the `audioAnalysis` palette component gives
  bands and beats immediately. One idea worth keeping as things grow: analyse **once**,
  centrally, and have components read the same channels — otherwise each artwork drifts to
  its own rhythm and the tipis stop looking like one piece. Handy trick for a room full of
  friends: mic input works fine as a stand-in for the FOH line.
- **A second and third test tox**, so the master finally has something to mix between.
  That's Aim 3, and it only gets real once there are two things to crossfade.
- **MIDI on the knobs — PLANNED, not started.** Wants doing alongside the mixer panel in
  section 9, so the same controls exist in hardware and on screen. `MIDI In Map CHOP` onto the promoted custom parameters. Bind to the
  component's parameters rather than to operators inside it, so rebuilding the guts doesn't
  cost the mapping.
- **Hand tracking — NOT NOW.** Parked by choice. Good party trick, no place in an unattended
  show. Via <https://github.com/torinmb/mediapipe-touchdesigner> — free, GPU,
  no install. Pinch controls a parameter. This is the "at station controls" idea from the
  design doc, and it's a good party trick on its own.
- **The 3D pipeline — IN PROGRESS.** This is the current work. Blender animations authored on
  the tipi models, shrinkwrapped, rendered top-down and landed back on the geometry — see
  section 9 and `Components/Layers/README.md`. The original note read: geometry in a rendered scene
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

**Installed — DONE**

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

## 7. Per-tipi texturing and the Blender unwrap

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

## 8. Where this actually landed (2026-08-30) — SUPERSEDED

*Kept as a record of what was tried and measured. The architecture here — three layers, a
composition switch, mastering at the top level — is replaced by section 9. The measurement
notes at the end of this section are still live and still worth reading; the structure above
them is not.*

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

---

## 9. Layers, scenes and the mixer (2026-10-19)

### The short version

- A **layer** is a source, **pre-fx**. General control; a layer is something you set once and
  it affects everything that uses it. It holds its own inputs (files, cameras, streams) and an
  `Active` toggle, and nothing else.
- A **scene** is a `.tox` that arranges some layers with nodes **and owns the effects, the audio
  reaction and the UV mapping** — including effects on the mapping itself, like the mirror
  split. It names the layers it needs in one space-separated field. It has **no length and no
  transition** — those are the mixer's.
- A scene is **available** when every layer it names is Active. Derived, never stored. Switch a
  layer off and the scenes needing it drop out of rotation on their own.
- The **mixer** owns the show: it finds the available scenes, decides how long each runs, picks
  the next one (in order, or randomly), and runs a transition into it.
- **Transitions are plug-ins.** One `.tox` each, fixed contract. Adding one is dropping a file
  in a folder; the mixer never changes.
- The show runs **unattended**, and is still **drivable by hand**: the same two buses, a panel
  showing what is on, what is next and why a scene is missing, and controls to pause, take and
  enable/disable.
- **Resolume** is wanted for transitions, hands-on mixing and audio-reactive effects — a design
  and rehearsal tool first. It takes two Syphon feeds, A and B, never one per scene. See below.

### The flow

```
Components/Layers/*.tox              Components/Scenes/*.tox
  Active (toggle)                      Layers = "microscope cartrail"
        │                                        │
        └────────────────┬───────────────────────┘
                         ▼
                  mixer / pool  (Script DAT)
          scenes whose every named layer is Active
                         │
                         ▼
                  mixer / clock  (Timer CHOP)
          Scenelength ± Lengthvariance, one shot per scene
                         │ onDone
                         ▼
                  mixer / choose
          Randomness, weights, no-repeat history
                         │
            ┌────────────┴────────────┐
          bus_a                     bus_b
       (current scene)           (next scene)
            └────────────┬────────────┘
                         ▼
                mixer / transition
     switch over Components/Transitions/*.tox, Progress 0..1
                         │
                      master
                         │                     mixer / panel
                     show_tex ───────────┐     now · next · transition · last
                                         │     pool + why each scene is in or out
                                         │     Auto · Play/Pause · Cue · Take · Fader
                                         ▼
                              geo1   uv0: the scene
                                     uv1: 3D overlay, added on top
                                         │
                                  cam1 / cam2
                                         │
                                    projectors
```

Only two scenes cook, whatever the pool size — that is the reason for two buses rather than a
switch over all of them.

---

### Built 2026-10-21

What exists now, in `Loungellusions_show.toe`:

| Where | What |
|---|---|
| `/project1/layer_<name>` | `microscope`, `mariokart`, `vhs`, `render3d`, `cam_41`, `cam_71`. Each holds its own inputs and their settings; `vhs` and `microscope` switch test / camera / stream. `Active` only. Embedded, exported to `Components/Layers/`. **LAYERS** box |
| `/project1/scene_<name>` | One scene per old layer. `in_<layer>` → `fx` → `pfx` → UV maps → `out1`. Embedded; exported to `Components/Scenes/`. **SCENES** box, wired straight into `switch1` / `switch2` |
| `/project1/midi`, `/project1/knobs` | Section 10 |

The scenes are the old layer artworks with the source cut out and replaced by an input from the layer,
so every look is unchanged — measured, mean RGB matches the old layer output. `switch1` now
runs base1, teepee_feedback, microscope, render3d, mariokart, vhs on the `button1` counter
(0–5) as a stand-in for the mixer; `Components/Scenes/README.md` has the table.

`vhs` had gone missing from the show (deleted in 5595d00, a `microscope1` copy in its slot). It
is back as a scene, rebuilt from `Components/Layers/vhs.tox`. `mariokart` had fallen out of
`switch1` when the camera inputs went in; it is back at index 4.

**Scenes are embedded, not `externaltox`.** Same as the layers were. The show is the working
copy and `Components/Scenes/*.tox` are exports — re-save the tox after changing a scene. If two
of us ever edit scenes in the same week, this is the thing to change first.

Not built yet: `Active` does nothing until the mixer reads it, and nothing sets
`allowCooking`. Both are the mixer's job.

### Built 2026-10-22: the mixer, proof of concept

`/project1/mixer`, in a new **MIXER** box between SCENES and COMPOSITION. Composition, master and
the render region moved 1700 px right to make room; the box is deliberately mostly empty, for
the panel and whatever the mixer grows next. `Components/Mixer/README.md` has the detail.

| Built | How |
|---|---|
| Two buses | `bus_a` / `bus_b`, Switch TOPs over the six scene inputs. Only the selected scenes cook |
| Flip-flop | Progress 0 = A on air, 1 = B. A transition runs to the other end, then the off-air bus loads the next scene. Nothing swaps |
| Pool | `pool` DAT, rebuilt every frame from `Active` and `Layers`, with the reason a scene is out. `Active` now does something |
| Clock | `scenelength` ± `variance` per scene, in the `sequencer` Execute DAT |
| Chooser | `randomness` 0 walks the pool in order, 1 picks weighted by `Weight`, never the scene on air |
| Transitions | `tr_fade_black` and `tr_cross`, to the contract below, picked by `ctrl` `transition`. Exported to `Components/Transitions/` |
| By hand | `btn_auto`, `btn_pause`, `btn_next`, `fader` — nodes in the mixer network, not parameters |
| Readouts | `readout` DAT: now, next, time left, transition, progress, last. For the panel, when it exists |

`switch2` and `geo1.material` read `mixer/state` `scene` instead of the `button1` counter.
`switch1` / `button1` are still wired to the scenes but feed nothing — a fallback while this is
new. Delete them once the mixer has had a night.

Measured: `fade_black` at progress 0.25 / 0.5 / 0.75 gave half of A / black / half of B; `cross`
at 0.5 gave exactly the mean of the two buses. Auto ran several scenes through on its own, and
switching `layer_vhs` off dropped `scene_vhs` from the pool as `layer vhs off`.

Departures from the design below, all for simplicity: controls are nodes in the network rather
than parameters on the COMP (Simon's standing preference); transitions are embedded in the mixer
and added by wiring, not loaded from the folder listing; no `Cue`, no `cycle` / `random`
transition modes, no fallback scene (an empty pool holds the scene on air), and nothing sets
`allowCooking` yet. The mesh and material switch at the transition midpoint, which `fade_black`
hides and `cross` does not.

### Layers

Live in `Components/Layers/`, one `.tox` each. A layer is a source and nothing more:

- **`Active`** toggle. Off means the layer is out of the show.
- When off, the mixer sets `.allowCooking = False` on it, so an inactive layer costs nothing.
  This is the real lever — a bypassed-but-cooking layer still burns GPU.
- **Its own inputs**, with their settings. `/project1/sources` is parked; nothing reads it.

Effects, audio and mapping are the scene's (S13).

### Scenes

New folder, `Components/Scenes/`, one `.tox` each. A scene is where the blending between layers
is wired with nodes — composites, crosses, masks, whatever the look needs. That is why scenes
are components and not table rows: the arrangement is a patch, not a parameter.

Each scene carries:

| Parameter | What |
|---|---|
| `Active` | Take this scene out of rotation by hand, without touching its layers |
| `Layers` | Space-separated layer names, e.g. `microscope mariokart cartrail`. Any number |
| `Weight` | How often it comes up when the mixer is picking randomly. Default 1 |

No length. No transition. No fade. A scene does not know how long it will be on screen or what
comes before or after it, and should not be written as though it does.

**More than two layers is allowed.** The cost is real but bounded: a bus cooks the layers its
scene names, so the worst case is the two heaviest scenes running at once during a transition.
Worth watching rather than forbidding — if a five-layer scene drops frames, that is the scene's
problem to solve, not a rule.

**A scene naming a layer that does not exist is an error, not an empty slot.** The mixer reports
it rather than quietly dropping the scene, because a typo that silently removes a scene from the
rotation is invisible until the night.

### How layers wire into scenes

**Revised 2026-10-21: layers are wired, not instanced (S20).** Layer and scene COMPs both sit at
the top of the show in their own boxes; a layer's output is wired into each scene that uses it,
and one layer can feed several scenes.

The first version of this section gave every scene its own instance of each layer, inheriting
parameters from a token by expression, so two scenes could hold different settings for one layer
through a crossfade. That mattered while layers carried effects. Now a layer is only a source,
so there is nothing for two scenes to disagree about — and instancing hid the wiring inside the
scenes, which is the thing you most want to see. A scene that wants a different source wires a
different layer; everything else it wants different is already its own.

The cost goes down too: a layer feeding two scenes during a transition cooks once.

### Availability

```
available(scene) = scene.Active and all(layer.Active for layer in scene.Layers)
```

Two gates. A scene can be switched off directly, or fall out because something it needs did.
The panel shows which, because "disabled" and "its layer is disabled" are different problems
and look identical from the outside.

Computed by a Script DAT scanning both folders. It is the whole dependency mechanism and there
is nothing to keep in sync by hand — which is the point of inferring it from the UI rather than
maintaining a table.

**If a layer is switched off while its scene is playing, the scene finishes.** It leaves the pool
afterwards. Cutting mid-scene on a parameter change is worse to watch than four more seconds of
something you have just decided you do not want.

**If the pool is empty**, the mixer runs a fallback scene that names no layers. Black, or the
generative source. Unattended shows need a defined answer to "everything is off" that is not a
dead projector.

### The mixer

One COMP. Its parameters are the show's controls:

| Parameter | What |
|---|---|
| `Scenelength` | Base seconds per scene |
| `Lengthvariance` | 0–1. How much each scene's length wanders either side of the base |
| `Randomness` | 0 walks the pool in order, 1 picks weighted-random, between is the odds of jumping |
| `Fadetime` | Transition duration |
| `Transitionmode` | Which transition, or `cycle`, or `random` |
| `Auto` | Sequencer drives the buses. Off hands them to you |
| `Play` / `Pause` | Pause holds the current scene indefinitely — the clock stops, nothing transitions. It does not stop cooking |
| `Next` | Pulse to advance now, using the loaded transition and fade |
| `Cue` | Load a chosen scene into B without taking it |
| `Take` | Run the transition into B now |
| `Fader` | Manual progress 0 to 1. Overrides the clock while `Auto` is off |

Changing `Scenelength` mid-show retimes from the current scene onward rather than jumping — the
clock is a one-shot per scene, so the new value simply applies to the next one.

### Driving it by hand

Two drivers, one engine. With `Auto` on, the clock and the chooser fill bus B and run the
transition. With `Auto` off, you do: cue a scene into B, move the fader or hit take. Nothing
else changes — the same buses, the same transitions, the same pool. That matters more than it
sounds, because it means the manual path cannot drift out of sync with the automatic one;
there is only one path.

`Pause` is deliberately not `Auto` off. Pause means *stay on this scene* — the clock stops and
no transition fires, but the sequencer is still in charge and will carry on from where it was.
Use pause to hold something that is working; use `Auto` off to take over.

### The panel

A Container COMP in `Components/Mixer/`, hosted by the existing `control_panel`, for a Perform
Mode window. Everything it shows comes from one Table DAT the mixer writes — the UI reads, it
never computes. One place to look when the panel and the output disagree.

**Readouts**

| Shows | Why it earns its space |
|---|---|
| **Now** | Current scene, and how long is left on it |
| **Next** | What is cued, and whether the chooser picked it or a human did |
| **Transition** | Which one is loaded, and the fade time it will use |
| **Progress** | Transition progress while one is running, so a long cross is visibly a cross and not a freeze |
| **Last** | The scene just left, so a good accident can be got back to |
| **Pool** | Every scene, marked available / off by hand / off because of a layer — **and which layer** |

That last column is the one that saves an evening. A derived pool means scenes can vanish from
rotation for a reason that is three nodes away, and the failure is silent: the show simply stops
showing something. Naming the blocking layer turns a mystery into a glance.

**Live controls**: `Auto`, `Play` / `Pause`, `Cue`, `Take`, `Fader`, `Next`, plus a toggle per
scene and per layer. The per-layer toggles are the ones that change the shape of the show —
switching off `vhs` should visibly grey out every scene that named it.

Worth building the panel **before** the sequencer. It is the only way to see whether the pool
logic is right, and it turns the mixer from something you debug in the network editor into
something you debug by looking at it.

### Transitions

`Components/Transitions/`, one `.tox` each, all to the same contract:

- two TOP inputs, `A` and `B`
- one `Progress` parameter, 0 to 1
- one TOP output

The mixer switches between them, so only the selected transition cooks and **adding a transition
is dropping a file in the folder** — no mixer edit, no menu to extend by hand if the menu is built
from the folder listing.

First one to build, and the default:

- **`fade_black`** — A down to black over the first half, B up from black over the second.

Obvious ones after that: `cross` (a straight dissolve), `blend` (composite A and B with a mode —
add, screen, difference — and pass through it, A → blended → B), and eventually a wipe driven in
UV space, which on this geometry reads as a sweep travelling around the cones and across the
canopy rather than a line crossing a rectangle. That last one is the one worth the effort; it is
the only transition on the list that could not be done on a flat screen.

### Resolume: the mixing surface, not the scene store

What Resolume is actually wanted for: **transitions, hands-on mixing that reads at a glance, and
audio-reactive effects on the mixed image.** Not storing scenes. That changes the shape of the
integration, and makes it much cheaper than it first looked.

**Two feeds out, one back.**

```
TouchDesigner                         Resolume                    TouchDesigner
  bus_a ── Syphon ──┐
                    ├──  crossfade · transitions · FX  ── Syphon ──  map · calibrate · project
  bus_b ── Syphon ──┘                                                 + uv1 overlay added here
```

Because the mixer already runs two buses, TD publishes exactly **two** Syphon feeds, not one per
scene. The cooking question answers itself: two scenes cook, same as before, and the size of the
scene bank is irrelevant.

| Stays in TouchDesigner | Moves to Resolume |
|---|---|
| Layers, scenes, the pool and why a scene is unavailable | The crossfader and the transition library |
| Scene choice, weighting, randomness | Effects, and audio reactivity on the mixed image |
| MIDI knob values and their bindings | The visual mixing surface |
| Geometry, UV sets, camSchnappr, the overlay | |

Section 9's transition subsystem then does not need building, and the panel shrinks to the pool
and the readouts — Resolume shows now and next far better than a Text COMP will.

**One feed per scene does not work, for the record.** A Syphon Out TOP cooks every frame whether
or not a client is attached, because TD cannot see who is listening. N scenes as N clips means N
scenes cooking — the inverse of what the two-bus design buys. It can be fixed by having Resolume
send OSC on clip-connect and TD deactivate the unused outputs, but that is a control channel
built to tell TD something its own mixer knew a frame earlier.

**What it costs**

- Two Syphon hops, out and back. A few frames. Imperceptible for audio-coupled effects.
- A second application in an **unattended** show's failure path. This is the real objection and
  it has not gone away.
- Mixing happens in strip space, so the **uv1 overlay cannot take part**. It has to composite
  after the return — which works, it is additive and scene-independent, but it means the sharp
  path and the mixed path are not the same path.
- Timing. Resolume's auto-pilot cycles a deck; it knows nothing about layer availability or the
  pool. So either TD decides when to transition and tells Resolume over OSC, or Resolume runs the
  clock and TD follows it. If TD is sending the progress value anyway, TD may as well run the
  cross.

**Where that lands.** Resolume earns its place wherever **someone is driving** — designing
scenes, rehearsing, finding a look by hand with a crossfader and a bank of effects. That is a
genuinely better tool than anything we would write, and what it finds can be baked back into TD
as scene settings.

It earns much less on a night when nobody is driving, which is the night we are building for. So:
**a design and rehearsal tool first, and a show tool only if the unattended path is proven to
survive it.** Prove TD alone end to end, then decide whether Resolume rides along.

**The line not to cross:** letting Resolume do the projection mapping. That replaces camSchnappr
and makes the uv1 surface path impossible, because Resolume has no model of the tipis. The sharp
path exists *because* TouchDesigner knows the geometry.

Section 9A sketches the other way round: Resolume as the whole mixer, with every scene as a clip.

### What this replaces

`switch1`, `composition`, `blend_mix` and the `button1` / `count1` / `null3` scene counter all
go or get rewired. `switch2` currently reads that same counter for geometry and would take the
mixer's scene channel instead.

`blend_mix` is worth reading before deleting — it is a built blender wired to nothing, with a
feature-versus-microscope switch and three composite modes. It is the ancestor of this section.

### Open questions this does not settle

- **Resolution.** Section 7's per-tipi split is still parked in `Archive/`. Section 8 asked for a
  UV-coordinates-as-colour measurement before trying again — that now exists, as
  `render3d/uv_topdown/uvgen_topdown`, built for the top-down mapping. The measurement section 7
  wanted is available; the decision it was meant to inform is still open.
- **`Masterfade` does nothing.** `master.opacity` only scales alpha and `Render_Engine/constant1`
  has blending off, so the alpha is discarded. Measured: identical RGB at fade 1.0 and 0.25. The
  blackout has never dimmed the projectors. One-line fix, not yet applied, because it changes
  what the projectors do.
- **The canopy.** The mesh is cone A + canopy + cone B, and the unwrap runs continuously across
  all three. Scenes may eventually want to address the canopy separately; nothing here does.
- **`Uvset` is a fossil.** `/project1` carries `Uvset` (`fan` / `rect` / `recttrunc` / `fanpack`)
  and `Rendermode` (`single` / `split`) as custom parameters. Nothing reads either, and the OBJs
  section 7 specified — `Models/Teepee2_fan.obj`, `Models/Teepee2_rect.obj` — are not in the repo.

---

## 9A. Alternative: Resolume as the mixer (2026-10-21)

A hypothetical, written down so it can be compared rather than re-argued. **Not decided.**
Section 9 is still the plan. The Resolume subsection in 9 keeps TD as the mixer and sends Resolume
two feeds; this goes the whole way.

### The short version

- **Every scene publishes its own Syphon feed**, and every scene is a clip in Resolume.
- **Resolume owns the mix**: layers, crossfader, transitions, effects, audio reactivity on the
  mixed image, MIDI mapping of its own parameters, and auto-pilot for unattended running.
- **TouchDesigner becomes a scene server plus the projection pipeline**: layers, scenes, the
  return feed, geometry, camSchnappr, the uv1 overlay.
- **A scene cooks only while Resolume has its clip connected.** Resolume reports it; TD switches
  cooking. This is what makes one feed per scene affordable — section 9 ruled it out without it.

### The flow

```
TouchDesigner                            Resolume                       TouchDesigner
  scene_a ── Syphon "LL_scene_a" ──┐
  scene_b ── Syphon "LL_scene_b" ──┼── clips in layers / decks    ── Syphon ── geo1 uv0
  scene_c ── Syphon "LL_scene_c" ──┘   mix · transitions · FX                  + uv1 overlay
     ▲                                 audio analysis · MIDI map               cam1 / cam2
     │                                          │
     └──── clip connected / disconnected ◄──────┘
           (WebSocket API, or OSC)
```

### Demand-driven cooking

- Each scene gets a Syphon Spout Out named for it, `LL_<scene>`, placed **outside** the scene COMP.
  The server then stays advertised whether or not the scene cooks, so Resolume never loses the
  source.
- The scene COMP defaults to `allowCooking = False`. A stopped scene costs close to nothing;
  Syphon re-serves its last frame, which nobody sees because the clip is not connected.
- TD learns which clips are connected and sets `allowCooking` to match. Two ways in:
  - **Resolume's WebSocket API, via a WebSocket DAT.** Subscribe to each clip's `connected`
    parameter by clip id. TD can find the clips by name or source, so the deck can be rearranged
    freely. Preferred.
  - **OSC out from Resolume, via an OSC In DAT.** Simpler, but addresses are by position
    (`/composition/layers/N/clips/M/...`), so moving a clip in the deck silently breaks the mapping.
- **The cooking budget is the number of connected clips**: one per Resolume layer with a clip on,
  plus both clips during a clip transition. Section 9's two-bus bound becomes a ceiling set by
  how many Resolume layers are in use — the operator's choice rather than the design's.
- Treat Resolume's preview state as "cook" as well as connected. That gives a scene a head start
  before it goes on screen (see cold start, below).

### Building it out

Resolume Arena / Avenue 7 has a **REST API and a WebSocket API** (Preferences → Web Server,
port 8080 by default). Between them they can add and remove layers and columns, list available
sources (`GET /sources`), load media or a source into a clip slot
(`POST /composition/layers/{l}/clips/{c}/open`, with a `source:///video/<display name>` URI),
manage effects, and subscribe to parameter changes.

So the deck can be **generated, not hand-built.** A script in TD lists `Components/Scenes/`,
opens each scene's Syphon source into a clip slot and names the clip after the scene. Rerun it
when a scene is added. A Web Client DAT can make those calls; nothing else needs installing. The
Resolume composition (`.avc`) is then a build product rather than something to keep in step by
hand.

A TD Syphon server appears in `GET /sources` as `TouchDesigner - <sendername>`, so a scene whose
Syphon Out is named `LL_scene_a` opens with `source:///video/TouchDesigner%20-%20LL_scene_a`.
Measured 2026-10-21, see below.

**MCP.** Resolume ships an **official** one with Arena since 7.26:
`/Applications/Resolume Arena/mcp/resolume_arena_mcp_server.mcpb`, a Claude Desktop extension
that drives the same web server (load sources, effects, layers, columns, groups). It needs the web
server enabled. Community servers also exist (`drohi-r/resolume-mcp`, `Tortillaguy/resolume-mcp`)
but the official one comes first. Either way it is for building and designing — **never a show
dependency.** None installed yet.

### Tested 2026-10-21

`Experiments/resolume-arena-test/` holds the test: `arena_test.toe` (three scenes, each with a
Syphon Out, plus the WebSocket link) and `arena_test.avc` (the Arena composition with the three
Syphon clips in layer 1). It ran as a **second TouchDesigner instance** with its MCP bridge on
port **9982**, so the show file on 9981 was never touched. Arena 7.27.1.

**The cooking loop works.** `arena_link` is a WebSocket DAT on `ws://127.0.0.1/api/v1`, port
8080. On connect, Arena sends the whole composition; the callback finds every clip whose source
names `LL_scene_<tag>`, subscribes to its `connected` parameter by id, and sets the scene COMP's
`allowCooking` from it. `arena_state` shows the result. Measured with `out1.totalCooks`:

| Arena | scene_a | scene_b | scene_c |
|---|---|---|---|
| Clips loaded, none connected | frozen | frozen | frozen |
| Connect clip 1 | cooking | frozen | frozen |
| Connect clip 2, same layer | frozen | cooking | frozen |
| `disconnect-all` | frozen | frozen | frozen |

Frozen means zero cooks across about 190 frames. With its scene off, the **Syphon Out stops
cooking too** — it re-serves its last frame and costs nothing.

**Gotchas found:**

- `POST /composition/new` and `POST /composition/open` do their job but never finish the HTTP
  reply. Always pass a timeout (`curl -m`).
- After `/composition/new`, every clip `open` failed with "the requested clip is not found".
  Saving and reopening the composition through `/composition/open` fixed it.
- The Syphon sources took a little while to show up in `/sources` after TD started publishing.
- Clip thumbnails from the REST API show a generic Syphon icon, not the picture, so the API
  cannot confirm the image arrived. Check by eye, or route Arena's output back over Syphon.
- The MCP bridge's port is an expression on a custom parameter. In a freshly assembled `.toe` it
  evaluated before it was ready and bound to port 1, so the test file hardcodes 9982.

- A Syphon clip comes in at its own size. The 1280x720 scenes sat small inside Arena's default
  1920x1080 composition. Match the composition to the scene size, or set the clip to fill.

**The picture arrives.** Checked by eye: scene A showed live in Arena's Composition Monitor, its
frame counter running.

**Not yet measured:** cold start, meaning how long a scene takes to look right after its clip
connects.

### Who owns what

| Stays in TouchDesigner | Moves to Resolume | Goes away |
|---|---|---|
| Layers and their instancing inside scenes | Mixing, crossfader, layer stacking | `mixer / clock`, `mixer / choose` |
| Scenes, one Syphon feed each | The transition library | `Components/Transitions/` |
| The cooking switch | Effects, audio reactivity on the mix | The panel |
| Scene-internal knobs (section 10) | MIDI mapping of Resolume's own parameters | The pool, unless rebuilt (below) |
| Return feed, geometry, camSchnappr, uv1 | Auto-pilot | |

### What it costs

1. **Cold start.** A clip connects, and TD starts cooking the scene a frame or more later.
   Feedback and particle scenes begin from empty, so there are a few stale or black frames and
   then a visible "bloom". A fade-in transition covers the black, not the bloom. Cooking on the
   preview state helps when someone is driving; auto-pilot does not preview.
2. **The pool goes.** Resolume knows nothing about a layer's `Active` or a scene's availability.
   A scene whose layer is off plays black, and auto-pilot will pick it. TD could push clip
   bypass back over the same WebSocket, but that is the pool rebuilt across two apps.
3. **MIDI splits.** Resolume maps the knobs for its own parameters; scene internals
   (`tri` / `pent` / `circ` / `sq`) stay in TD. macOS lets both apps open the controller at
   once, so that part is fine. But `Globalknobs` scoping needs to know the scene on screen, and TD
   no longer decides that — it has to read it from Resolume.
4. **Audio reactivity in two places.** Resolume reacts on the mixed strip; anything a TD layer
   does with audio inside a scene stays in TD.
5. **Unchanged from section 9's Resolume costs:** a second app in an unattended show's failure
   path, the uv1 overlay outside the mix, two Syphon hops. And the same line not to cross —
   mapping stays in TD.

### Against section 9

Gains Resolume's surface, transitions, effects library, audio analysis and MIDI learn, and drops
most of section 9's build. Loses the availability pool, TD knowing what is on screen, and a
single-app unattended show.

If it is worth pursuing, the test is small: three scenes, the WebSocket cooking loop, and a
measurement of cold start on the heaviest one. That answers whether demand-driven cooking holds
up before either design is built.

---

## 10. MIDI and global inputs (2026-10-21)

### The short version

- One component owns every physical input. Everything else **references** it.
- Knobs are named for **what they are on the controller** — `tri`, `pent`, `circ`, `sq`. They
  read **0 or 1 only**.
- The knob **values** are global: one value per knob, the same in every scene.
- What a knob **does** is each scene's choice, wired by hand from a `knobs` CHOP at the top of
  every scene. Scoping a value to the scene on screen (`Globalknobs` off) waits for the mixer.
- CC numbers appear in **one table**, nowhere else.
- With no controller plugged in, the channels still exist and still have values. A show that
  runs itself cannot have a missing USB device take a layer with it.

### The controller

A toy MIDI controller, four knobs, marked with shapes:

| Channel | Knob |
|---|---|
| `tri` | Triangle |
| `pent` | Pentagon |
| `circ` | Circle |
| `sq` | Square |

Named by shape deliberately. "The circle knob" is something either of us can say out loud
standing at the tipi; `cc74` is not. The shape is also the only thing printed on the hardware,
so the name and the thing agree.

### Revised 2026-10-21, and built

Two things changed once the real controller was in hand, and they simplify everything below:

- **The knobs read 0 or 1 only.** They are switches, not faders. So there is no position to
  pick up, no delta to take, and no relative mode — the whole of the old "go relative when
  scoped" design is gone.
- **The value is global, the job is the scene's.** One `circ` value for the whole show, read
  by every scene; what `circ` does is wired by hand in each scene (S21).
  (A first build on 2026-10-21 made the job global too — one effect per knob show-wide. Wrong
  call, reverted the same evening.)

### The component

`Components/Midi/`, at `/project1/midi`, publishing `/project1/midi/knobs` with the four shape
channels, always present, 0 or 1.

```
midi_map (Table DAT)        shape  cc  chan  invert  snap  default
      │                     tri    70  1     0       1     0
      ▼                     ...
midi_in (MIDI In CHOP) ── read_knobs (Script CHOP) ── knobs (null)
```

The four knobs are also on screen: sliders in `/project1/control_panel`, merged into the same
channels. Whichever was moved last wins, hardware or screen.

The table is the **only** place a CC number is written down. `snap` 1 rounds a knob to 0 or 1,
`default` is the value with nothing plugged in. CC 70–73 are placeholders until the controller
is learnt, and the device has to be mapped as id 1 in Dialogs → MIDI Device Mapper on each
machine.

### What each knob does: per scene, by hand

The knob values are global (`/project1/midi/knobs`). What they do is chosen by hand, per
scene. Every scene has the same two CHOPs **at the top of its network**:

| Node | Does |
|---|---|
| `midi` | Select CHOP of `/project1/midi/knobs` |
| `knobs` | Null. `tri`, `pent`, `circ`, `sq`, 0 or 1 |

Pick off the knob you want where you want it: a Select CHOP on `knobs` into an effect, an
Export, or an expression such as `parent().op('knobs')['circ']` on a scene parameter. Nothing
is bound by default — every scene's look is exactly its own parameters until you wire a knob in.

A `knob_map` table with a binding script was built first (2026-10-21) and removed the same
evening: it worked, but a table that writes expressions is more to understand than the
expressions themselves. No scene has knobs wired yet.

### Scoping to one scene — not built

`Globalknobs` off ("this knob only touches the scene on screen") stays in the design but is not
built: it needs the mixer to say which scene is on screen. With 0/1 knobs it would be a gate —
the knob reaches only the live scene — rather than the relative-delta scheme this section used
to describe.

### Still to decide

- **More than four controls.** A shift or page button doubles the knobs and halves the clarity.
  Four that always mean what the panel says beats eight that need remembering.
- **Where MIDI sits relative to audio reactivity.** Both modulate the same parameters. A knob
  setting the *depth* of an audio reaction is usually better than a knob and a reaction fighting
  over one value.
