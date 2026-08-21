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
