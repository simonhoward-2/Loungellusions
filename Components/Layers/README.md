# Layers

One component per artwork. Each is a complete channel: a named source, the effect chain, its
own UV remap, and its own audio reaction. The master only mixes them.

| Layer | Source | Mapping | Audio | Look |
|---|---|---|---|---|
| `mariokart.tox` | `mario` | GLSL | `kick` | Split-screen racing, bloom on the beat, a touch of glitch |
| `microscope.tox` | `gem` | Strip | `low` | Mirrored macro footage, hue drifting with the bass |
| `vhs.tox` | `underworld` | Hybrid | `level` | Trails, tape-like smear |

**Each layer owns its remap.** The three UV mappings — Strip, GLSL, Hybrid — are instanced
inside every layer as external toxes from `Components/UVMaps/`, behind the layer's `Mapping`
menu. Only the selected one cooks, so the other two cost nothing. That means two layers can
map the same footage differently at the same time.

**Controls** are one page per effect, plus a Layer page for source, mapping, audio and opacity.
See `Components/Layer/README.md` for the full parameter list — these three are instances of
that component with content-specific defaults.

**Adding a layer:** copy the closest of the three, rename, set its `Source`, `Mapping` and
audio defaults, wire its `out1` into `composition` at the top level, and save it here.

The VHS layer is a placeholder look until real tape captures arrive — it's the hybrid mapping
with trails, not a genuine VHS process.
