# Loungellusions 🔥

Visual art project in TouchDesigner. Projection illusions for a tipi / lounge space.

This is a **play repo**, not a work repo. Treat it that way.

## Vibe rules (read first)

- **Caveman by default.** Follow the voice rules in `AGENTS.md` for every reply, unless the
  user says "stop caveman" / "normal mode". Short words. Big energy. No lofty waffle.
  Those rules are self-contained, so they work without the caveman plugin installed.
- **Make, then talk.** This is a visual medium. Build the thing, show the thing,
  discuss after. Don't write a 5-paragraph plan for a noise TOP.
- **Play beats polish.** Weird ideas welcome. Broken experiments are content, not failures.
- **Small moves.** Nudge a param, look at it, nudge again. Don't architect.
- Caveman voice is for *talk*. Facts, paths, node names and params stay exact.

## What's here

| Where | What |
|---|---|
| `Loungellusions_master.toe` | The main show file. Loads and mixes the `.tox` components. |
| `Components/` | One folder per artwork, each a `.tox`. See `Components/README.md`. |
| `Experiments/` | Scratch. One folder per experiment. No rules here on purpose. |
| `Patches/` | Older standalone patches (pre-Components). Migrate as we touch them. |
| `Models/` | Geometry (`.fbx`) for projection surfaces. |
| `Backup/` | TD autosaves. Don't work in here. |
| `docs/` | Overview, standards, tools. Start at `docs/OVERVIEW.md`. |
| `tools/` | Repo scripts. `td-version.sh` reads TD build numbers; `hooks/` holds the git hooks. |

Media lives **outside** the repo in Google Drive (`../Loungellusions Media`).
Reference it with relative paths from the `.toe`. Never commit media.

## Read before doing

- `docs/OVERVIEW.md` — what the project *is*, artistically. Read before making art choices.
- `docs/STANDARDS.md` — how we keep files tidy. Living doc; add to it when we learn.
- `docs/TOOLS.md` — the MCP + tool kit, incl. TouchDesigner MCP and TD-Launcher.
- `docs/PLAN.md` — build plan: tools, repo methodology, mapping, audio, video transport, show night.
- `docs/VERSIONS.md` — which TouchDesigner build each `.toe` / `.tox` needs. Generated.

## Hard rules

- **Pull from main before working.** `.toe` / `.tox` are binary — merge conflicts are fatal.
- Never commit a `.toe` / `.tox` without saying what changed inside it. Binary diff tells nobody nothing.
- **Every `.toe` / `.tox` has a documented TD build.** Touch a binary file, then run
  `tools/td-version.sh sync` and commit `docs/VERSIONS.md` with it. Standards S9-S11.
- **Open `.toe` files with TD-Launcher**, not the first TouchDesigner that grabs them.
  TD saves forward only — the wrong build silently locks everyone else out.
- Don't touch `Backup/`. That's TD's turf.
- Don't commit media, renders, or `TDImportCache/`.
