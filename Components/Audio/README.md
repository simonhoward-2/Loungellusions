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
| `Kick Threshold` | How hard a transient has to hit to count. Drive it from the room, not from the desk |

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
