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

## S13 — A layer owns its mapping

**What:** Each layer in `Components/Layers/` carries its own UV mapping components and chooses
between them with its `Mapping` parameter. The master never decides how content lands on the
tipis.

**Why:** Two layers can then map the same footage differently at the same time, and a layer
stays a complete artwork you can drop into any show file. Only the selected mapping cooks, so
the unused one costs nothing.

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

## S16 — Geometry comes from OBJ, not FBX

**What:** Import geometry into TouchDesigner with a File In SOP reading `.obj`. Author in
`Models/Teepee2_master.blend` and export what's needed.

**Why:** TouchDesigner 2025's FBX COMP imports as POPs. Converting that back to a SOP produced
4438 points and **no `uv` attribute at all** — the UVs are simply gone. The same importer left
the original `Teepee2_contUV` FBX COMP broken and reporting "Invalid geometry name"; the show
has been running off geometry baked into a locked `select1` SOP ever since.

OBJ carries one UV set per file, so multiple unwraps mean multiple exports from the one
master `.blend`.
