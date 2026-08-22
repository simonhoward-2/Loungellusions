# Sources

TD build: 2025.32460

Every input the show can draw on, named for what it is. Self-contained — the media nodes
live inside this component now, not scattered across the top level.

**Looks like:** nothing on its own. It's the shelf, not the artwork.

**Needs:** the Drive media folder as a sibling of the repo (`../Loungellusions Media`).

| Name | What |
|---|---|
| `mario` | `Samples/n64/mario_1.mov` |
| `skull` | `Samples/microscope/micro_skull.mov` |
| `gem` | `Samples/microscope/micro_gem.mov` |
| `underworld` | `Samples/microscope/micro_underworld.mov` |
| `scroll` | `Samples/microscope/micro_assorted_scroll.mov` |
| `generative` | Output of the nested `demo` component — animated ramps, no file |
| `syphon1`–`syphon6` | Live Syphon inputs. Black until something publishes |

Sources are **raw**. The mirror, hue-shift and feedback treatments that used to hang off
individual sources now live in the shared FX component instead, so any source can have any
of them. See `Components/FXTest/README.md`.

Layers pick a source by name, building the path `/project1/sources/<name>`. Renaming an
entry breaks any layer pointing at it — add names rather than renaming.
