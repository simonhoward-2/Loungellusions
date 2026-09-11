# Archive

Work that isn't in the show any more. Kept because it cost something to learn, not because it
is expected to come back.

| Item | What it was | Why it's here |
|---|---|---|
| `Loungellusions_mcp_2025.toe` | The experiment file the show was built in | Superseded by `Loungellusions_show.toe`. Still holds every mapping experiment, the `legacy` cluster of retired nodes, and the split-geometry render test |
| `Models/Teepee2_rect.obj` | Cylindrical unwrap of the cones | Correct as an unwrap, wrong for the job: a cone is developable, so a rectangular unwrap stretches toward infinity at the apex and Mario Kart came out smeared |
| `Models/Teepee2_rect_trunc.obj` | Same, tip truncated 6% | Fixed the sawtooth gaps the rect unwrap leaves. Still non-isometric, so still worse than the fan |
| `Models/Teepee2_fanpack.obj` | Fan islands stacked, uniform x1.519 | The packing is right (~8x the pixels on paper). Placing the drawn fans into the packed islands overshot by 1.5x and was never solved |
| `Models/Teepee_A.obj`, `Teepee_B.obj` | The mesh split in half, each island filling its own square | The one resolution experiment that worked — ~6.4x more pixels per tipi, verified. Parked because it changes the render path and the canopy gets cut down the middle |
| `Models/Teepee2_dualUV.fbx` | Both UV sets in one FBX | TouchDesigner 2025 imports FBX as POPs and drops the `uv` attribute entirely. OBJ works, FBX doesn't |
| `Components/uvmap_stack.tox` | Stacked mapping for re-laid UVs | Needed a UV layout that never worked. Drawn fans covered 41% of an island needing 68% |
| `Components/uvmap_rect.tox` | The trivial mapping for the rect unwrap | Only useful with `Teepee2_rect.obj`. Worth remembering that it was three nodes — no fan generator needed |

`Models/Teepee2_master.blend` stays in `Models/`, not here: it holds all three UV layers and both
split halves, and it is the source of truth if any of this is revisited.

**The short version of what was learned:** a cone unrolls exactly to a fan, so the fan unwrap
that shipped with the model is the correct one and the GLSL fan generator earns its complexity.
More resolution is available, but only by giving each half its own texture — not by re-laying
UVs into one shared image.
