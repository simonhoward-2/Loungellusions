# Standards

Living doc. We learn a rule → we write it here. Short entries only.
If a rule needs three paragraphs to explain, it's a bad rule.

Format for every rule: **what**, then **why**. No essays.

---

## S1 — One artwork, one .tox component

**What:** Every finished artwork lives at `Components/<Name>/<name>.tox`.
One folder per artwork. A `.tox` is a real TouchDesigner Component — it drops straight
into any network and carries its own operators, params and custom parameters.

**Why:** `.tox` is TD's native reusable unit. Smaller than a `.toe`, loadable by the master
at runtime, and swappable without touching the show file.

## S2 — Master composes, doesn't contain

**What:** `Loungellusions_master.toe` loads components (Component OPs pointing at the
`.tox` files). It does not hold artwork logic itself. Master is a mixer, not a canvas.

**Why:** Keeps the merge-conflict surface of the one shared binary file as small as possible.

## S3 — Component folder contents

```
Components/<Name>/
  <name>.tox        # the artwork, exported as a Component
  README.md         # 5 lines: what it looks like, what it needs, what controls it
  assets/           # only tiny local assets. Big media -> Drive.
```

Expose the knobs that matter as **custom parameters** on the component's top level.
Master drives those, and nothing reaches inside.

**Why:** An agent (or future Simon) should know what a component does, and how to drive it,
without opening TD.

## S4 — Experiments are lawless

**What:** `Experiments/<name>/` has no rules. Numbered TD increments, `copy` files,
dead ends — all fine. Nothing graduates until it earns it.

**Why:** Rules kill play. Keep the mess quarantined instead of banned.

## S5 — Never commit media

**What:** No video, no renders, no `TDImportCache/`. Media lives in the Drive sibling folder.

**Why:** Repo stays clonable. Git is bad at gigabytes.

## S6 — Binary files are marked binary

**What:** `.toe` / `.tox` are declared `binary` in `.gitattributes`.

**Why:** Stops git's LF normalisation from silently corrupting them.

## S7 — Say what changed inside the .toe

**What:** Commit messages for `.toe` / `.tox` changes describe the *contents* of the change,
not the file. "Added feedback loop to tipi noise" not "update tipi.tox".

**Why:** Binary diffs show nothing. The message is the only record.

## S8 — Pull before you open

**What:** `git pull` before opening any `.toe` / `.tox`. Always.

**Why:** Binary conflict = someone's work gets thrown away. Cheaper to prevent.

## S9 — Every .toe / .tox records its TouchDesigner build

**What:** The build a binary file was saved with lives in `docs/VERSIONS.md`, one row
per file. Never hand-write the table — regenerate it:

```bash
tools/td-version.sh sync
```

Component READMEs state their build too, on one line: `TD build: 2023.12370`.

**Why:** TouchDesigner opens older files and never saves backwards. Save a 2020 file in
2025 and the 2020 machine is locked out, silently, with no error. The build number is
the only thing that says which TouchDesigner to open a file with, and a binary diff
won't tell you.

## S10 — Open .toe files through TD-Launcher

**What:** Launch `.toe` files with TD-Launcher, not by double-clicking into whatever
TouchDesigner opens first. Install and usage in `docs/TOOLS.md`.

**Why:** It reads the required build off the file and opens that version, which makes
S9 self-enforcing at the moment it matters — before the file is open, not after it's
been saved wrong.

## S11 — The version table is enforced at commit

**What:** `tools/hooks/pre-commit` blocks a commit that stages a `.toe` / `.tox` while
`docs/VERSIONS.md` is stale. Turn it on once per clone:

```bash
tools/hooks/install.sh
```

**Why:** A rule nobody checks is a rule nobody follows. This runs locally because
`toeexpand` needs TouchDesigner installed — CI can't do it.

## S12 — Stable filename, timestamped backups

**What:** Each artwork or experiment has exactly one working file with a stable name.
No Save Incremental, no numbered files in the repo.

**First, the preference.** TouchDesigner's `general.inc` preference controls increment-on-save.
It was set to `2`, which is why numbered files appeared in *every* project regardless of which
tox was loaded. Set it to `0`:

```python
ui.preferences['general.inc'] = 0
```

Measured: with `general.inc` at 0, Cmd+S overwrites in place and no numbered file appears.
Everything below is about backups, not about fighting the numbering.

Drop `tools/td_backup.tox` into the project once. It holds an Execute DAT wired to
TouchDesigner's Project Pre Save / Project Post Save callbacks, so **every** save routes
through `tools/td_save.py` — Cmd+S, the File menu, and scripts alike:

- **pre-save** copies the file on disk to `Backup/<name>.<YYYYMMDD-HHMMSS>.toe`
- **post-save** folds any numbered file TD wrote back onto the stable name, then prunes
  `Backup/` to the newest 20

Nothing to remember at save time. To save from a script or over MCP, `td_save.save()` does
the same thing explicitly; the callbacks are idempotent so the two are safe together.

`Backup/` is gitignored. Git commits are the history of record; `Backup/` is the local
"open the last one next to this one" net that git can't give you cheaply for binaries.

**Why:** TD's numbered files look like version history and are not. Measured: saving over
`loungellusions_mcp.toe` while the project was named `loungellusions_mcp.1.toe` wrote **both**
files with identical current content — the numbered copy preserved nothing. The post-save hook
promotes before it deletes, because a numbered file TD just wrote holds the newest work and
deleting it blind would throw the save away.

Timestamps beat a rotating `.1 -> .2 -> .3` cascade: nothing gets renamed on save, so a crash
mid-rotation can't scramble the set, the newest always sorts last, and at ~90KB a copy there is
no size problem worth solving.

**Known cosmetic wart:** `project.name` keeps climbing (`.1`, `.2`, ...) because TouchDesigner
only re-reads it when a file is opened. Harmless — the stable file on disk is always correct.

## S13 — A scene owns its mapping

**What:** Each scene in `Components/Scenes/` carries its own UV mapping components and chooses
between them with its `Mapping` parameter, after its effects. Layers carry no mapping and no
effects. The master never decides how content lands on the tipis.

**Why:** Two scenes can then map the same source differently at the same time, effects are
applied in the flat image before it is bent onto the cones, and a scene can animate its own
mapping (the mirror split) without that reaching any other scene. Only the selected mapping
cooks, so the unused one costs nothing.

*Until 2026-10-21 this read "a layer owns its mapping". Layers became pre-fx sources and the
mapping moved up with the effects.*

## S14 — Name operators for what they do

**What:** No `uvgen`, `null3`, `textureiser_geo`. Names say the job: `uvgen_ramp`,
`uvgen_compose_left`, `show_tex`, `tipi_geo`, `preview_geo`, `projector_out`.

**Why:** We lost time to `uvgen` meaning two different things in two components, and to
`uvmap_hybrid` sounding like a blend when it was one method per tipi. A name that describes
the method is the cheapest documentation there is.

## S15 — Annotate the network, comment the nodes

**What:** Top-level networks are divided into labelled `annotateCOMP` regions, and any node
whose role isn't obvious carries a `.comment`.

**Why:** Some connections are made by parameter, not by wire — camSchnappr reads `tipi_geo`
and `show_tex` by path, and every layer reads the audio bus the same way. Those links are
invisible on the canvas, so they have to be written down where they'd otherwise be missed.

**Gotcha:** annotate boxes carry the nodes inside them. Deleting or resizing a box can drag
its contents — three nodes drifted that way, one by 375 pixels. Re-check positions after
editing boxes.

**Leave room for the text.** A box's title and body sit at its top, and a node placed there
covers them. Keep the band above the topmost node clear, and size it from the text, not by eye:

```
header = 30 (title) + lines × 20 + 30 (margin)
lines  ≈ characters × 7.5 / (box width − 20)      # body font 14, word-wrapped
```

So a 250-wide box with a 100-character body needs about 140 px above its first node. Short body
text and wider boxes both shrink it. The numbers are an estimate: check by eye in the network
editor after placing, and grow the box upward if the text is still covered.

**Leave room to grow.** Where a column of nodes is a list that will get longer — layers,
scenes — space the rows well apart (400 px in the LAYERS and SCENES boxes) so a new one drops
in between two existing ones without shuffling everything else.

## S16 — Geometry comes from OBJ, not FBX

**What:** Import geometry into TouchDesigner with a File In SOP reading `.obj`. Author in
`Models/Teepee2_master.blend` and export what's needed.

**Why:** TouchDesigner 2025's FBX COMP imports as POPs. Converting that back to a SOP produced
4438 points and **no `uv` attribute at all** — the UVs are simply gone. The same importer left
the original `Teepee2_contUV` FBX COMP broken and reporting "Invalid geometry name"; the show
has been running off geometry baked into a locked `select1` SOP ever since.

OBJ carries one UV set per file, so multiple unwraps mean multiple exports from the one
master `.blend`.

## S17 — Every CHOP shows its graph on the tile

**What:** Every CHOP has its node-tile viewer on so its current values / waveform read at a
glance. One flag:

- `chop.viewer = True`

CHOP viewers are cheap — the CHOP is cooking anyway, the tile just draws its samples. This
does **not** apply to TOPs, SOPs, or COMPs; forcing tile display on those triggers extra work
(a `baseCOMP` with `.display = True` has to render its internal `opviewer` TOP; a TOP tile
draws pixels). Leave those alone unless a specific stage benefits from a live thumbnail — set
it per-node then, not as a blanket rule.

**Why:** CHOPs drive everything — audio bus, LFOs, math on parameters. When something looks
wrong the first question is always "is that value what I think it is". A live graph on the
tile answers it without opening the node.

**Apply:** When creating a CHOP over MCP, `chop.viewer = True` in the same script. When
touching an existing CHOP whose tile is blank, flip it.

## S18 — Two kinds of scene: image and surface

**What:** A scene delivers its content to the show in one of two ways, and says which in its
README row. (Written when layers held the mapping; since 2026-10-21 the scene does.)

- An **image scene** remaps its content into the model's UV layer 0 and hands over one TOP.
  It flows `switch1` → `composition` → `master` → `show_tex` → `Render_Engine/geo1`, wearing
  `constant1`. Ramp and mirror mappings work this way. Three of the four scenes are this.
- A **surface scene** hands over a *mesh and a material* instead. It writes its own unwrap
  into **UV layer 1** of the show mesh, publishes that mesh on a SOP output, and supplies the
  material to wear with it. `switch2` picks the mesh on the scene index, `geo1.material`
  picks the material on the same index. The `render3d` scene is the only one so far.

Both go through the same `geo1` and the same calibrated cameras, so there is one render pass
either way and projector calibration is untouched.

**Why:** The show strip is 1280x360 and the model UVs occupy v 0.041–0.360 of it — about
1280x115 pixels for both tipis, against a cone whose slant is 85 world units. Content that is
already in the tipis' own space, like a Blender render, loses most of itself going through
that bottleneck. A surface scene skips it and samples the source at full resolution.

**Two traps, both load-bearing:**

- `switch2`'s inputs are **sequential** while its index is the **scene number**. It used to
  have two inputs and survive scenes 2 and 3 by clamping. Adding a mesh at the end means
  every scene below it needs a real input or it will grab the wrong mesh. Six scenes, six
  inputs (2026-10-21).
- A surface layer **never passes through `master`**, so `Masterlevel` and `Masterfade` do not
  reach it. `scene_render3d/surface_topdown/lvl_master` re-applies both by expression. Any future
  surface layer needs the same node or the blackout will not cover it.

## S19 — UV components are templates; a layer that diverges branches

**What:** `Components/UVMaps/` holds the generic methods. A layer links to one with
`externaltox` **only while it uses it unchanged**. The moment a layer needs its own version,
either clear `externaltox` so the component embeds in that layer's own `.tox`, or save a
named branch `uvmap_<method>_<layer>.tox`. The layer's README row records which.

**Why:** This already happened once without a rule. `uvmap_mariokart.tox` exists only so the
mariokart layer cannot inherit `uvmap_mirror`'s `lfo_split` animation — a fork made to stop a
change leaking, with nothing written down to say so. Animating a shared mapping should never
be able to reach another artwork by accident.

A surface mapping is SOP + MAT, not TOP in / TOP out, so it does not fit the UVMaps shape and
is not listed in a layer's `Mapping` menu. It lives inside the layer that owns it.

## S20 — A layer is wired into its scenes, at the master level

**What:** Every layer and every scene sits at the top of the show, `/project1/layer_<name>` and
`/project1/scene_<name>`, in their own annotated boxes. A layer's output is **wired** into the
input of each scene that uses it; inside the scene an In TOP named `in_<layer>` picks it up. One
layer can feed several scenes.

A layer holds its own inputs and their settings — files, devices, stream URLs. Layers and
scenes are both **embedded** in the show; the `.tox` files in `Components/` are exports.

**Why:** the wiring is the documentation — open `/project1` and you can see which source feeds
which look. Sharing is safe because a layer is pre-fx: it has no settings a scene would want
different. A scene that wants a different input wires a different layer.

*Superseded design (2026-10-19 to 10-21): each scene held its own instance of the layer, with
parameters inherited from a token by expression. That existed to keep per-layer effect settings
apart during a crossfade; once effects moved to the scene there was nothing left to keep apart,
and the instances hid the wiring.*

## S21 — Knob values are global; each scene picks them off by hand

**What:** The four knob values live in one place, `/project1/midi/knobs`. Every scene brings them
in the same way — a `midi` Select CHOP and a `knobs` null at the top of the scene network, with
`audio` / `analysis` beside them for the audio bus — and
then wires whichever knob it wants into whichever effect it wants: a Select CHOP, an Export, or
an expression. CC numbers stay in `midi_map` only.

**Why:** the knob means something different in each look, and the simplest record of what it
does is the wire or expression itself. A binding table on top of that was tried (2026-10-21) and
dropped the same evening as more machinery than the job needs.
