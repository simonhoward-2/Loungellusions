# Loungellusions — Overview

> High-level only. Enough for everyone to *get it*. Structure and composition detail
> lives in the `.toe` files and in `docs/STANDARDS.md`, not here.

## The idea

Loungellusions is projection-mapped visual art for a lounge space — two tipis joined by a
canopy are the primary surface. Live video feeds, generative TouchDesigner patches and
rendered loops get composed, mapped onto the tipi geometry, and projected back onto it.

## The surface

- Primary projection target: **two tipis and the canopy between them**. The canopy is an
  awning that wraps around both cones and links them, so it is a projection surface in its
  own right, not scenery.
- Geometry and UVs live in `Models/Teepee2_master.blend`. The mesh is unwrapped continuously —
  cone, canopy, cone — which is what lets content sweep across the whole structure.
- Each cone unwraps as a **fan**, because a cone unrolls flat into one. That is why the
  mapping components bend rectangular video into fans rather than wrapping it like a cylinder.
- Previews of the mapped result live in Drive under `Demos/`.

## How a piece gets made

1. Idea gets thrown at `Experiments/<name>/` — no rules, just play.
2. If it survives, it becomes a **layer**: `Components/Layers/<name>.tox`. A layer is a whole
   channel — a named source, an effect chain, its own UV mapping, its own audio reaction.
3. `Loungellusions_show.toe` mixes the layers, then hands one image to the mapping and
   projector calibration.

```
sources ─ mariokart  ─┐
audio   ─ microscope ─┼─ composition ─ master ─ show_tex ─ camSchnappr ─ projectors
        ─ vhs        ─┘
```

Two mapping methods are available to any layer: **ramp** (masks built from ramps) and
**mirror** (two arc edges set a focal point per cone, content mirrors or extends outward).

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
