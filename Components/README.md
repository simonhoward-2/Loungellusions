# Components

One folder per reusable piece. Each holds a `.tox` and a README describing what it looks
like, what it needs, and what drives it (Standard S3).

| Component | Does |
|---|---|
| `Audio/` | One analysis for the show — `low`, `mid`, `high`, `level` |
| `Sources/` | Every named input — media files, live Syphon, the generative `demo` |
| `Demo/` | Animated ramp cluster. The `generative` source |
| `FXTest/` | Six effect lanes with per-lane wet/dry and blending between lanes |
| `PaletteFX/` | Test bench for five Palette-Tools effects, same shape as FXTest |
| `UVMaps/` | The three ways a flat image lands on the tipi: strip, GLSL, hybrid |
| `Layer/` | The channel template: named source, FX, its own mapping, audio |
| `Layers/` | The three built artworks — `mariokart`, `microscope`, `vhs` |

**How they stack in the master:**

```
sources ─ mariokart  ─┐
audio   ─ microscope ─┼─ composition ─ master ─ textureiser_geo ─ render1 ─ camSchnappr ─ projectors
        ─ vhs        ─┘
```

Each layer carries its own UV remap, so the master never decides how content lands on the
tipis — the layer does.

Composition and mastering sit at the top level of the master, where they can be reached
without diving into a component. Everything else is one level down.
