# Sources

TD build: 2025.32460

**Parked inputs.** Since 2026-10-21 each layer holds its own inputs (`Components/Layers/`), so
nothing in the show reads this component. What is left is footage and inputs no layer uses yet,
kept so they are a copy-paste away:

| Name | What |
|---|---|
| `generative` | Output of the nested `demo` component — animated ramps, no file |
| `syphon1`–`syphon6` | Live Syphon inputs. Black until something publishes |
| `moviefilein1` → `kscope_null` | A clip on Tom's Windows machine (`C:/Users/tomha/Downloads/IMG_1908.MOV`). Missing on the Mac |

To use one: copy it into a layer (or into a new `layer_<name>`) and wire it to `out1`.

Moved out on 2026-10-21: every microscope clip (`gem`, `skull`, `underworld`, `scroll`) → the
microscope test player in `layer_microscope`, `mario` → `layer_mariokart`, `car_trail`
→ `layer_render3d`, `cam_41` / `cam_71` → their camera layers, and the whole vhs sample player
→ `layer_vhs`.

Media paths are relative to the `.toe` (`../Loungellusions Media/...`, a symlink into OneDrive).
