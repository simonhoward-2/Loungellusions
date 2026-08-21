# Layer

TD build: 2025.32460

One channel of the show: a named source, through effects, through its own UV mapping, out to
the mix. Three exist in the master (`layer1`, `layer2`, `layer3`); more are copies.

**Looks like:** whatever its source is, wearing whatever effect and mapping it's set to.

**Needs:** `/project1/sources` for the source names, and the three `.tox` files in
`Components/UVMaps/`.

**Controls (Layer page):**

| Parameter | Does |
|---|---|
| `Source` | Which named source to pull from |
| `Mapping` | Strip / GLSL / Hybrid — this layer's UV mapping |
| `FX` | Which effect lane in the nested FX component |
| `FX Wet` | 0 = untouched source, 1 = full effect |
| `Opacity` | Output level into the mix |

**Inside:** `sel_src` -> `fx` -> three `uv_*` components -> `sw_map` -> `lvl` -> `out1`.

The three mappings are nested side by side rather than loaded on demand. TouchDesigner only
cooks what something downstream asks for, so the two unselected mappings sit idle — switching
is instant, with no reload.

`fx` is an embedded copy of `Components/FXTest/fxtest.tox`, so its parameters can carry
expressions back to the layer. Rebuild it from that `.tox` if the effects change.
