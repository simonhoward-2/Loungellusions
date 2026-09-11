# FXTest

TD build: 2025.32460

Takes one video input, runs it through six effect lanes, mixes each lane wet/dry against the
dry source, and either switches between lanes or blends across them. One copy of this sits
inside every layer, so any source can wear any treatment.

**Looks like:** whichever lane is selected — mirrored kaleido, soft bloom, hard edge-detect,
noise warp, or brightest-pixel trails.

**Needs:** a TOP on its input. With nothing connected, turn on Test Card for a ramp and text
so there's always something to look at.

**Controls (FX page):**

| Parameter | Does |
|---|---|
| `Test Card` | Swaps the input for an internal ramp + text card |
| `Wet Kaleido` … `Wet HSV` | One per effect, in chain order. 0 = that effect is bypassed |
| `Kaleido Rotate` | Mirror angle |
| `Bloom Size` | Blur radius feeding the bloom |
| `Edge Strength` | Edge-detect gain |
| `Warp Amount` | Displace weight from the animated perlin noise |
| `Trail Decay` | Feedback gain. Higher = longer trails |
| `Trail Zoom` | Per-frame scale of the feedback path. 1.0 = no drift |
| `Hue Cycle` | Hue rotation speed. 0 = static |

**Inside:** `in1` and the test card feed `sw_src -> src`, then each effect hangs off the
previous stage and recombines through its own Cross TOP:

```
src ─ kaleido ─ cross1 ─ bloom ─ cross2 ─ edge ─ cross3 ─ warp ─ cross4 ─ trails ─ cross5 ─ hsv ─ cross6 ─ out1
```

Order is fixed and it matters: edge detecting a bloomed image looks nothing like blooming an
edge-detected one.

The lanes are where the old per-source treatments went. `kaleido` is the mirror that used to
sit on the scroll and skull feeds, `trails` is the feedback loop from the generative chain, and
`hsv` is the hue adjust that used to hang off the gem. Any source can now have any of them.

The trails lane composites with **brightest**, not add. Add diverges: with the source injected
every frame at decay 0.9 the loop settles at ten times source brightness and clips to white
within seconds (measured: 86% of pixels above 0.99). Brightest is bounded by the source, so
the lane stays stable at any decay value.

## Modulation (FXMod page)

Every knob can be driven by the audio bus instead of sitting still. Each has three parameters:

| Parameter | Does |
|---|---|
| `<Knob> Source` | Off / Level / Low / Mid / High / Density / Speed / Noise |
| `<Knob> Sensitivity` | How far the modulation swings the knob, as a fraction of its full range |
| `<Knob> Noise Mix` | 0 = the audio channel drives it cleanly. 1 = that drive is multiplied by the noise LFO |

The maths, per knob:

```
value = base + Sensitivity * range * channel * (1 - NoiseMix + NoiseMix * noise)
```

So Sensitivity sets the depth, and Noise Mix decides how much the LFO chews into it. With
Source off the knob is exactly its base value, so modulation is opt-in per knob.

Worked example: `Bloom Size` base 12, range 40, Source `low`, Sensitivity 0.5. At `low` 0.24
the blur reads 17. Push Noise Mix to 1 with the LFO at 0.35 and it reads 14 instead.
