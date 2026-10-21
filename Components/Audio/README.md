# Audio

TD build: 2025.32460

One audio analysis for the whole show. Analyse once, publish named channels, let everything
subscribe — so every layer reacts to the same numbers and the tipis stay in step.

**Looks like:** nothing. It's a CHOP, not a picture.

**Needs:** an audio input. Currently `default` (the MacBook microphone). At the festival this
becomes the line out from the FOH desk. `BlackHole 2ch` is also on this machine if you want to
capture system audio instead.

**Analysis engine:** Derivative's own `audioAnalysis` component from the palette
(Tools → audioAnalysis), embedded rather than referenced so the file carries its own copy.
It does the band splitting, kick and snare detection and spectral centroid; this component
wraps it, adds a few extras, and publishes one tidy channel set.

**Publishes** at `/project1/audio/analysis`, all clamped 0–1 so anything downstream can treat
a channel as a normalised fader:

| Channel | From |
|---|---|
| `low` / `mid` / `high` | audioAnalysis band outputs |
| `level` | RMS power of the unfiltered input |
| `density` | audioAnalysis spectral centroid — where the energy sits, not how loud |
| `speed` | Absolute rate of change of `level`. Spikes on transients |
| `kick` | audioAnalysis kick detection, through a Lag CHOP so it reads as a thump with a tail rather than a one-frame spike |
| `noise` | Not audio: a slow simplex LFO, period 4s, so modulation keeps moving when the room goes quiet |

**Controls (Audio page):**

| Parameter | Does |
|---|---|
| `Input Trim` | Gain on the audio **before** analysis. This is the one to reach for when nothing is reacting — the palette component's thresholds need a decent signal to fire at all |
| `Input Gain` | Scales the band and level channels **after** analysis |
| `Smoothing` | Lag on the response. Low is twitchy, high is a slow swell |
| `Density Gain` | Scales `density` only — the spectrum average is tiny before scaling |
| `Speed Gain` | Scales `speed` only |
| `Kick Rise` | Attack on the kick lag. Keep small — this is the thump landing |
| `Kick Fall` | Release. 0.12s reads as a thump; longer becomes a pulse |
| `Kick Threshold (x avg)` | How far above its own recent average the kick band has to jump to count. 1.6 by default; lower fires on more, higher only on the hardest kicks. Adapts to volume — see below |

Output is clamped 0–1, so anything downstream can treat a channel as a normalised fader.

**Inside:** `adev -> aacomp` (the palette component), then channel selects fan out — bands and
level merge and take `Input Gain`, kick goes through `lag_kick`, the spectral centroid is
renamed to `density` — and everything merges before smoothing and clamping into `analysis`.

Referencing it from a component: `op('/project1/audio/analysis')['low'].eval()`. Keep that
path absolute — layers are copied around, and a relative path would break on the first copy.

**Thresholds.** The palette component gates each band with a threshold, and the defaults
(0.1–0.2) assume a healthy signal. They're currently at 0.03–0.12 to catch a quiet room
through the laptop mic. With the FOH line plugged in, raise them again or everything will sit
pinned at 1.

**Two gains stack.** A band's output is `aacomp` band gain (`Lowgain`, `Midgain`, `Highgain`
inside `aacomp`) × this component's `Input Gain`, then clamped. `Input Gain` hits every band
equally, but the bands do not arrive equally — through the laptop mic, low comes in several times
hotter than level, mostly room hum. On 2026-10-21 `Input Gain` was 26.3 in the show (4.0 in the
saved `.tox`) and `Lowgain` 5, so `low` clipped at 1 on hum alone. `Lowgain` is now 0.5, which
puts a quiet room at about 0.25–0.4 and leaves headroom. Fix a pinned band with its own gain in
`aacomp`, not with `Input Gain`, or every other band moves too. `mid` was sitting near 0.9 for the
same reason and has not been touched yet.

**Kick needs a threshold above the floor.** Inside `aacomp`, kick is the RMS of a low-pass band
minus `Kickthresh`, made 0/1 by a Logic CHOP, then fired by a Trigger CHOP on the *rising edge*.
At threshold 0 the signal is always above it, the logic sits at 1, there is never an edge, and
`kick` reads 0 forever — which it did until 2026-10-21. Worse, this component's `Kick Threshold`
was not connected to `aacomp`, so turning it did nothing.

First fix: a fixed threshold of 0.015, picked from quiet music, and `Kick Threshold` wired to
`aacomp`. It lasted until the music got louder: the kick band then sat at 0.05–0.25, always above
0.015, and kick was dead again. **A fixed threshold only works at one volume.**

Now it adapts. `kick_band` (`aacomp/analyze1`) → `kick_avg` (Lag CHOP, about 1 s) → `kick_floor`,
and `aacomp.Kickthresh` = `kick_floor × Kick Threshold`. A kick is the band jumping above its own
recent average, so it keeps working whatever the volume. 1.6 was picked by replaying 15 s of loud
music offline (about 2 crossings a second; 1.5 gave 3, 1.8 under 1), and live it fired 5 clean
onsets in 4.8 s peaking 0.9.
