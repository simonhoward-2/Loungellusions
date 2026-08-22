# Layer

TD build: 2025.32460

One channel of the show: a named source, through effects, through its own UV mapping, out to
the mix. Three exist in the master (`layer1`, `layer2`, `layer3`); more are copies.

**Looks like:** whatever its source is, wearing whatever effect and mapping it's set to.

**Needs:** `/project1/sources` for the source names, and the three `.tox` files in
`Components/UVMaps/`.

**Controls.** Parameters are split into one page per effect, so a layer is tuned without
opening `fx` or `pfx` at all.

**Layer page** — `Source`, `Mapping`, `Audio Source`, `Audio Sensitivity`, `Noise Multiplier`,
`Opacity`. The audio trio here is the layer default.

**One page per effect** — Kaleido, Bloom, Edge, Warp, Trails, Hsv — each carrying:

| Parameter | Does |
|---|---|
| `Wet` | Wet/dry for that effect in the serial chain |
| its knob(s) | Rotate, Size, Strength, Amount, Decay + Zoom, Cycle |
| `Audio Source` | `Follow Layer` by default, or pin this one effect to its own channel |
| `Sensitivity` | Multiplies the layer sensitivity for this effect only, 0–2 |
| `Noise Mix` | Multiplies the layer noise multiplier for this effect only, 0–2 |

**Palette page** (layer1 and layer2) — the five palette wets plus the same audio trio.

Every wet is multiplied by its matching global on the master's **FXMaster** page, so
`/project1` can pull one effect down across all layers at once without touching their
individual settings.

**Inside:** `sel_src` -> `fx` -> `pfx` -> three `uv_*` components -> `sw_map` -> `lvl` -> `out1`.

`pfx` is the Palette-Tools stage and carries the audio reactivity. It sits after `fx`, so the
built-in lanes shape the image first and the palette effects treat the result.

The three mappings are nested side by side rather than loaded on demand. TouchDesigner only
cooks what something downstream asks for, so the two unselected mappings sit idle — switching
is instant, with no reload.

`fx` is an embedded copy of `Components/FXTest/fxtest.tox`, so its parameters can carry
expressions back to the layer. Rebuild it from that `.tox` if the effects change.

## Audio reactivity

Three parameters at the layer drive both effect stages, so a layer reacts as one thing rather
than as eleven separately-tuned effects.

`Audio Source` on the Layer page sets the default channel. Each effect page can override it
with its own `Audio Source`, or leave it on `Follow Layer`. `Audio Sensitivity` sets the depth
for the whole layer and each effect scales it further with its own `Sensitivity`; the same
applies to `Noise Multiplier` and each effect's `Noise Mix`.

The full depth for any one knob is `layer sensitivity × built-in weight × effect sensitivity`.

Each fx knob carries a fixed weight on top of the layer sensitivity, so a single fader doesn't
swing everything equally hard:

| Knob | Weight |
|---|---|
| Kaleido Rotate, Bloom Size | 1.0 |
| Edge Strength, Warp Amount | 0.6 |
| Hue Cycle | 0.5 |
| Trail Decay | 0.3 |
| Trail Zoom | 0.2 |

Trail Decay and Trail Zoom are deliberately low — they sit inside a feedback loop, where a
swing that reads as lively on a blur reads as a blowout.

The layer drives the nested parameters by expression, so any single knob can still be
overridden by typing a constant into it inside `fx` or `pfx`. Sensitivity at 0 means every
knob sits at its base value and the palette wets are purely manual.
