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
| `Loungellusions_show.toe` | **The show file.** Sources, layers, mix, mapping, projector calibration. |
| `Loungellusions_master.toe` | The original 2020 file. Superseded, kept for reference. |
| `Components/` | One folder per reusable piece, each a `.tox`. See `Components/README.md`. |
| `Components/Layers/` | Inputs, pre-fx, each holding its own files / cameras / streams. `vhs` and `microscope` switch test or live. |
| `Components/Scenes/` | The built artworks: layers through effects, audio and UV mapping. |
| `Components/Midi/` | The MIDI controller. Four global knob values; each scene wires the ones it wants by hand. |
| `Experiments/` | Scratch. One folder per experiment. No rules here on purpose. |
| `Patches/` | Older standalone patches (pre-Components). Migrate as we touch them. |
| `Models/` | `Teepee2_master.blend` is the source of truth for geometry and UVs; `.fbx` / `.obj` are exports. |
| `Archive/` | Experiments that didn't make the show, with a README saying why. |
| `Backup/` | TD autosaves. Don't work in here. |
| `docs/` | Overview, standards, tools. Start at `docs/OVERVIEW.md`. |
| `tools/` | Repo scripts. `td-version.sh` reads TD build numbers; `hooks/` holds the git hooks. |

Media lives **outside** the repo in OneDrive, reached by the `../Loungellusions Media`
symlink. Reference it with relative paths from the `.toe`. Never copy it in, never commit it.

## Read before doing

- `docs/OVERVIEW.md` — what the project *is*, artistically. Read before making art choices.
- `docs/STANDARDS.md` — how we keep files tidy. Living doc; add to it when we learn.
- `docs/TOOLS.md` — the MCP + tool kit, incl. TouchDesigner MCP and TD-Launcher.
- `docs/PLAN.md` — the build plan. Status at the top; sections 7-10 are the live ones.
- `docs/VERSIONS.md` — which TouchDesigner build each `.toe` / `.tox` needs. Generated.

## Hard rules

- **Read `docs/PLAN.md` before starting anything.** Every session, before the first edit —
  not when a question comes up. It records what was decided, what was measured, and what was
  tried and archived. Sections 7-10 in particular. Work started without it repeats dead ends
  that are already written down, or rebuilds something that already exists under another name.
- **Pull from main before working.** `.toe` / `.tox` are binary — merge conflicts are fatal.
- Never commit a `.toe` / `.tox` without saying what changed inside it. Binary diff tells nobody nothing.
- **Every `.toe` / `.tox` has a documented TD build.** Touch a binary file, then run
  `tools/td-version.sh sync` and commit `docs/VERSIONS.md` with it. Standards S9-S11.
- **Open `.toe` files with TD-Launcher**, not the first TouchDesigner that grabs them.
  TD saves forward only — the wrong build silently locks everyone else out.
- Don't touch `Backup/`. That's TD's turf.
- Don't commit media, renders, or `TDImportCache/`.
