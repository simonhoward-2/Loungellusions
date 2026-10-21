# Layers

TD build: 2025.32460

A layer is an **input, pre-fx**: the operators that bring a picture in, with their settings
(file, device, URL, playback). Effects, audio reaction and UV mapping belong to the scene — see
`Components/Scenes/README.md`.

| Layer | Inputs | Notes |
|---|---|---|
| `microscope.tox` | `micro` (test) · `camera` · `stream` | `input` switch picks one. The test input is the microscope sample player |
| `vhs.tox` | `vhs` (test) · `camera` · `stream` | `input` switch picks one. The test input is the tape sample player |
| `mariokart.tox` | `mario` | Movie file |
| `render3d.tox` | `car_trail` | Movie file, a Blender render |
| `cam_41.tox` | `cam_41` | RTSP `192.168.1.41:554/stream1`. Feeds `teepee_feedback` |
| `cam_71.tox` | `cam_71` | RTSP `192.168.1.71:554/stream2`. Feeds `base1` |

**Parameters:** `Active` only. Off takes the layer out of the show; the mixer will read it.

## Test or live: the `input` switch

`microscope` and `vhs` carry three inputs into a Switch TOP named `input`:

| `input` index | Input | Set it up on |
|---|---|---|
| 0 | test footage — the sample player | nothing; it finds the clips itself |
| 1 | `camera` — Video Device In: the USB microscope, or the capture card from the VCR | its device menu |
| 2 | `stream` — Video Stream In: RTSP / SRT / HLS | its `url` |

Change the index on the switch itself, inside the layer. Only the selected input cooks, so an
unplugged camera costs nothing while the test footage is on. Both default to 0.

## The test players

`vhs` and `microscope` each have one, built the same way. In `layer_vhs` the nodes are `vhs_*`,
in `layer_microscope` they are `micro_*`:

| Node | Does |
|---|---|
| `*_samples` | Lists every movie in its folder, in name order: `Samples/vhs` (8 clips) or `Samples/microscope` (11) |
| `vhs` / `micro` | Movie File In playing the current clip. Holds on the last frame |
| `*_advance` | Steps to the next clip when the current one ends. Wraps, so it plays forever |
| `*_advance_btn` | ADVANCE button: step on now |
| `*_now` | Which clip is playing, e.g. `2/11  micro_dwarf.mov` |

Drop a new clip in the folder and it joins the rotation next time `*_samples` cooks.

The tape player came from `sources`; the microscope one is a copy of it, replacing the single
`gem` clip, so all eleven microscope clips are in rotation. Until
2026-10-21 the vhs layer was showing `underworld`, a microscope clip, as a placeholder; it plays
the real tape samples now.

## In the show (S20)

Each layer sits at the master level as `/project1/layer_<name>`, in the **LAYERS** box, wired
into every scene that uses it. Inside a scene it arrives on an In TOP named `in_<layer>`.

Layers are **embedded**, like scenes: the show is the working copy and these `.tox` files are
exports. They were `externaltox` while they held nothing but a Select TOP; now that camera URLs
and devices live in them, an `externaltox` reload would throw away whatever was set in the
show. Re-save the `.tox` after changing a layer.

**Adding a layer:** copy the closest `layer_<name>` in the LAYERS box, rename it, swap its
input for yours, and wire it into the scenes that want it.

## History

Before 2026-10-21 these files held whole artworks — source, `fx`, `pfx`, UV maps — and lived
at the top of the show as `/project1/microscope` and so on. Those artworks are now the scenes.
The old full versions are in git history if a scene ever needs to be rebuilt from one.

The `vhs` artwork went missing from the show in commit 5595d00: the node was deleted and a
copy of `microscope` (`microscope1`) landed in its slot. The scene was rebuilt from this
folder's `vhs.tox`, which still held it. Its UV maps carried absolute OneDrive paths from an
older machine; they are relative now.
