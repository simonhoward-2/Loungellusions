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
| `uvmap_stack.tox` | new | The GLSL mapping with the two panels stacked vertically instead of side by side. **Requires the stacked UV layout** |

The first three output **1280x360**; `uvmap_stack` outputs **1280x720** — the unrolled tipi strip, at the largest a Non-Commercial key
allows (that licence caps every TOP at 1280x1280; ask for 2048 and TouchDesigner silently hands
back 1280).

They used to output 1280x360, and `transform2` squashes content to a third of the canvas
height to sit it in the model's UV band — so each tipi was being textured from roughly 120
rows of pixels. At 1280x1280 that band is about 426 rows instead.

The remaining waste is the UV island itself: two thirds of the canvas is empty because of how
`Teepee2_contUV` is unwrapped. Re-laying those UVs to fill the square, or scaling them with a
Texture SOP, is the next 3x and costs nothing at runtime.

**Each one is now two parts.** The nodes that *generate* the UV displacement map — the GLSL
operator and its DATs, the ramps, crops, resolution references and multiplies — are grouped
into a `uvgen` component inside each mapping. What remains at the top of a mapping is the
signal path itself: `in1 -> remap -> transform -> out1`, seven nodes instead of thirty-odd.
Open `uvgen` to change how the mapping is built; stay outside it to see what it does.

**Second input:** each takes an optional second input, used by the original for a feedback
path from downstream. Layers leave it unconnected.

Which mapping suits which content is the whole experiment. Mario Kart wants `glsl` so the
race stays aligned and readable; round microscope content tends to want `strip`. Change a
layer's `Mapping` menu and watch — the switch only cooks the selected one, so unused mappings
cost nothing.

## The stacked layout

The model ships with both tipis packed across u — island A on the left half, island B on the
right — sharing one narrow band of v (measured: `v 0.041–0.360`). That forces the texture strip
to be 32:9, and with a Non-Commercial licence capping width at 1280, each tipi ends up textured
from roughly **640x115 pixels**.

`uvstack` (a Script SOP at the top level of the master, feeding `null2`) re-lays those UVs:
island A into the bottom half of v, island B into the top, each spanning the full width. The
strip becomes 1280x720 and each tipi gets **1280x360** — twice the width, three times the
height, about **six times the pixels**, all still inside the free licence.

Prims are assigned to a tipi by the x of their centroid, because the two islands overlap
slightly in u and can't be separated by uv alone. The band limits are parameters on the Script
SOP, not constants in the code, so re-measuring a different model is a matter of typing four
numbers.

**These two layouts are mutually exclusive.** UV layout belongs to the geometry, and all three
layers share one SOP chain — so `uvmap_stack` needs `uvstack` active, and the other three maps
need it bypassed. Mixing them in one show means retuning the older maps for stacked UVs.
