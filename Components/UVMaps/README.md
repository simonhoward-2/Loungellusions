# UVMaps

TD build: 2025.32460

The three ways a flat image gets onto the tipi. Each is a self-contained component with one
image input and one output, saved so it can be instanced per layer rather than existing once
and being shared.

| Component | Was | What's inside |
|---|---|---|
| `uvmap_strip.tox` | `Image_wrapping` | Crop, layout, ramp masks and a Remap TOP. The original unrolled-strip wrap |
| `uvmap_glsl.tox` | `Image_wrapping1` | GLSL-driven mapping with its own remaps and crops. Aligns Mario Kart |
| `uvmap_hybrid.tox` | `Image_wrapping2` | The strip chain plus the GLSL stage |

All three output 1280x360 — the unrolled tipi strip.

**Second input:** each takes an optional second input, used by the original for a feedback
path from downstream. Layers leave it unconnected.

Which mapping suits which content is the whole experiment. Mario Kart wants `glsl` so the
race stays aligned and readable; round microscope content tends to want `strip`. Change a
layer's `Mapping` menu and watch — the switch only cooks the selected one, so unused mappings
cost nothing.
