# Loungellusions — Overview

> High-level only. Enough for everyone to *get it*. Structure and composition detail
> lives in the `.toe` files and in `docs/STANDARDS.md`, not here.

## The idea

Loungellusions is projection-mapped visual art for a lounge space — the tipi sas the
primary surface. Live video feeds, generative TouchDesigner patches and rendered
loops get composed into 3d space that is 3d mapped to the tipi surface.

## The surface

- Primary projection target: **tipis** (geometry in `Models/Teepee2_contUV.fbx`,
  continuous UV so content can wrap without seams).
- Previews of the mapped result live in Drive under `Demos/`.

## How a piece gets made

1. Idea gets thrown at `Experiments/<name>/` — no rules, just play.
2. If it survives, it gets exported to `Components/<Name>/<name>.tox` as a reusable Component.
3. `Loungellusions_master.toe` loads those `.tox` files and composes the show.

## Media (lives in Google Drive, not git)

Sibling folder to this repo: `../Loungellusions Media`

| Folder | Holds |
|---|---|
| `Samples/` | Prerecorded visual content |
| `Renders/` | Prerendered TOP material |
| `Demos/` | Rendered tipi previews |
| `Content/` | One folder per category |

Reference from a `.toe` with a relative path, e.g.
`"..\Loungellusions Media\Samples\n64\mario_1.mov"`

## Reference links

<!-- Drop the Google Drive links + any reference material here. Keep it to a table:
     name, what it is, why it matters. Don't paste the content itself. -->

| Link | What | Why it matters |
|---|---|---|
| | | |

## Aims

1. Multiple 2D -> 3D UV mapping techniques
2. Direct 3D object manipulation projected onto surface
3. Master mixer to allow for different layering and mixing between components
4. Allow for a network of TD patches for linked components/standalone patches
5. Allow for MIDI control directly into components
6. Allow for MIDI control of master interface / mixing
