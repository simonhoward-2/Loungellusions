# PaletteFX

TD build: 2025.32460

Test bench for the Palette-Tools effects. Same shape as `FXTest` — one input, five effects in series, each with its own wet/dry, plus audio reactivity.

**Looks like:** whatever you stack. Bloom glows the highlights; Film, VHS, Glitch and Lines
each break the image in a different, deliberately nasty way.

**Needs:** nothing at runtime. The five effects are **embedded**, not referenced — they were
loaded from the Palette-Tools install and then unhooked from their external paths, so this
`.tox` carries its own copies and works on a machine without Palette-Tools installed.

**Controls (FX page):**

| Parameter | Does |
|---|---|
| `Effect` | Bloom / Film / VHS / Glitch / Lines |
| `Blend Between FX` | Off: `Effect` picks one. On: `FX Mix Position` slides across all five |
| `FX Mix Position` | 0–4, continuous |
| `Wet Bloom` … `Wet Lines` | One per effect, in chain order. 0 = bypassed |
| `Audio Channel` | Off / Level / Low / Mid / High / Density / Speed / Noise |
| `Audio Amount` | 0 = the wet faders rule. 1 = audio drives the wets entirely |
| `Audio Sensitivity` | Gain on the audio side of that blend, 0–3 |
| `Noise Mix` | Multiplies the audio drive by the noise LFO. 0 = clean audio, 1 = fully chewed |

**Audio reactivity:** each effect's wet is
`Wet * (1 - Audio Amount) + Audio Amount * Sensitivity * <channel> * (1 - NoiseMix + NoiseMix * noise)`, reading `/project1/audio/analysis`.
At `Audio Amount` 0 the component behaves exactly as before, so audio is opt-in per instance.

**Source:** <https://github.com/Richard-Burns/Palette-Tools> (the install also carries camera
and point-cloud tools, which are not TOP effects and are not included here).

**To use it in the show:** it's a drop-in replacement for the `fx` component inside a layer —
same input, same output, same style of parameters. Swap it in on one layer and drive it from
that layer's parameters, or add its lanes to `FXTest` if only one or two earn their place.
