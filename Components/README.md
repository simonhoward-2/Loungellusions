# Components

One folder per reusable piece. Each holds a `.tox` and a README describing what it looks
like, what it needs, and what drives it (Standard S3).

| Component | Does |
|---|---|
| `Audio/` | One analysis for the show — `low`, `mid`, `high`, `level`, `kick` and more |
| `Sources/` | Parked inputs no layer uses yet. Nothing in the show reads it |
| `Demo/` | Animated ramp cluster. The `generative` source |
| `FXTest/` | Six effect lanes with per-lane wet/dry and blending between lanes |
| `PaletteFX/` | Test bench for five Palette-Tools effects, same shape as FXTest |
| `UVMaps/` | The ways a flat image lands on the tipi: ramp, mirror, top-down |
| `Layer/` | The original channel template. Its shape now lives on as the inside of a scene |
| `Layers/` | Inputs, pre-fx, with their own settings. `vhs` / `microscope` switch test or live |
| `Scenes/` | The looks: layers through effects, audio, UV mapping and knob bindings. `template.tox` is the minimum scene |
| `Midi/` | The controller. Publishes four knobs, `tri` `pent` `circ` `sq`, 0 or 1 |
| `Mixer/` | Runs the show: the pool, the clock, two buses and a transition between them |
| `Transitions/` | One `.tox` per transition, A and B in, `Progress` 0 to 1. `fade_black`, `cross` |

**How they stack in the show:**

```
layer_<name> (inputs inside) ─ wired ─────────────┐
                                                   ▼
audio ──────────────────────────────────▶ scene_<name>
midi ─────────────────────────────────▶   in_<layer> → fx → pfx → uv map → out
                                              knobs CHOP at the top, wired by hand
                                                          │
                                     mixer (two buses, transition) / switch2
                                                          │
                                 composition ─ master ─ show_tex ─ Render_Engine ─ projectors
```

The scene owns the mapping, so the show never decides how content lands on the tipis — the
scene does. Layers carry no effects at all.
