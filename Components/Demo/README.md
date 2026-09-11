# Demo

TD build: 2025.32460

The animated ramp cluster that used to sprawl across the top-left of the master, packed into
a component. Feeds `sources/generative`.

**Looks like:** slow-moving colour fields — three ramps composited, plus a fourth ramp
transformed and added over the top.

**Needs:** nothing external.

**Inside:** `constant2 -> ramp4 -> transform3` and `ramp1/ramp2/ramp7 -> comp3`, both into
`add2 -> out1`. Ramp palettes live in the companion `*_keys` table DATs, not in the ramp
parameters — edit the table to change the colours.

Runs at 1280x720. The original cluster was 256x256, which was fine when it was a background
wash and soft once it started feeding a mapping.
