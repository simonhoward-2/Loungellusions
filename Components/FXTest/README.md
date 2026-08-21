# FXTest

TD build: 2025.32460

Test bench component. Takes one video input, runs it through five effect lanes, mixes each
lane wet/dry against the dry source, and switches between them. Built as the first swappable
unit for the master mixer — the thing everything else gets modelled on.

**Looks like:** whichever lane is selected — mirrored kaleido, soft bloom, hard edge-detect,
noise warp, or brightest-pixel trails.

**Needs:** a TOP on its input. With nothing connected, turn on Test Card for a ramp and text
so there's always something to look at.

**Controls (FX page):**

| Parameter | Does |
|---|---|
| `Effect` | Which lane reaches the output: Kaleido / Bloom / Edge / Warp / Trails |
| `Test Card` | Swaps the input for an internal ramp + text card |
| `Wet Kaleido` ... `Wet Trails` | Per-lane wet/dry. 0 = dry source, 1 = full effect |
| `Kaleido Rotate` | Mirror angle |
| `Bloom Size` | Blur radius feeding the bloom |
| `Edge Strength` | Edge-detect gain |
| `Warp Amount` | Displace weight from the animated perlin noise |
| `Trail Decay` | Feedback gain. Higher = longer trails |
| `Trail Zoom` | Per-frame scale of the feedback path. 1.0 = no drift |

**Inside:** `in1` and the test card feed `sw_src` -> `src`. Each lane hangs off `src` and
recombines through its own Cross TOP, so the wet/dry is per lane. `sw_fx` picks one and `out1`
publishes it.

The trails lane composites with **brightest**, not add. Add diverges: with the source injected
every frame at decay 0.9 the loop settles at ten times source brightness and clips to white
within seconds (measured: 86% of pixels above 0.99). Brightest is bounded by the source, so
the lane stays stable at any decay value.
