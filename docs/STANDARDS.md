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

---

## Migration backlog

- `Patches/microscope*.toe` → export as `Components/Microscope/microscope.tox`
- `Experiments/Light rotation/` → still cooking, leave it
