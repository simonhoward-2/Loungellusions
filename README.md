# Loungellusions 🔥

Projection-mapped visual art in TouchDesigner. Tipis are the canvas.

**ALWAYS pull from main before working.** `.toe` files are binary — conflicts eat work. Check in often, do not leave changes (especially master) unfinished as we cannot merge.

## Start here

- [`docs/OVERVIEW.md`](docs/OVERVIEW.md) — what the project is
- [`docs/STANDARDS.md`](docs/STANDARDS.md) — how we keep it tidy
- [`docs/TOOLS.md`](docs/TOOLS.md) — the MCP + tool kit
- [`CLAUDE.md`](CLAUDE.md) — how agents work in here

To get started, read tools page to ensure patch is opened in correct version.

## Layout

Two folders, sitting at the same level. Use relative paths in TD files to media
e.g. `video_file_in = "..\Loungellusions Media\Samples\n64\mario_1.mov"`

### Loungellusions (this repo)
- `Loungellusions_master.toe` — the show; loads and mixes the `.tox` components
- `Components/` — one folder per artwork, each a `.tox`
- `Experiments/` — one folder per experiment, no rules
- `Patches/` — standalone patches for linked (network) visual elements
- `Models/` — projection geometry
- `Backup/` — TD autosaves, don't work in here

### Loungellusions Media (Google Drive)
- `Samples/` — prerecorded visual content
- `Renders/` — prerendered top material
- `Demos/` — rendered tipi previews
- `Content/` — one folder per category
