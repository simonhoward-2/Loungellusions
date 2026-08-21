# Required TouchDesigner versions

Which TouchDesigner build each binary file was last saved with. TouchDesigner opens
older files fine but **never** saves backwards — open a file in a newer build, save it,
and everyone on the older build is locked out.

Generated. Do not hand-edit:

```bash
tools/td-version.sh sync
```

| File | TD build | Saved on |
|---|---|---|
| `Components/FXTest/fxtest.tox` | 2025.32460 | macOS |
| `Components/Layer/layer.tox` | 2025.32460 | macOS |
| `Components/Sources/sources.tox` | 2025.32460 | macOS |
| `Components/UVMaps/uvmap_glsl.tox` | 2025.32460 | macOS |
| `Components/UVMaps/uvmap_hybrid.tox` | 2025.32460 | macOS |
| `Components/UVMaps/uvmap_strip.tox` | 2025.32460 | macOS |
| `Experiments/Light rotation/light_rotation.22.toe` | 2025.32460 | macOS |
| `Experiments/Light rotation/light_rotation.toe` | 2025.32460 | macOS |
| `Experiments/touch-designer-mcp/NewProject.1.toe` | 2025.32460 | macOS |
| `Experiments/touch-designer-mcp/NewProject.toe` | 2025.32460 | macOS |
| `Experiments/touch-designer-mcp/loungellusions_mcp.toe` | 2025.32460 | macOS |
| `Loungellusions_master.toe` | 2020.28110 | Windows |
| `Loungellusions_mcp_2025.toe` | 2025.32460 | macOS |
| `Patches/microscope.1.toe` | 2025.32460 | macOS |
| `Patches/microscope.2.toe` | 2025.32460 | macOS |
| `Patches/microscope.3.toe` | 2025.32460 | macOS |
| `Patches/microscope.4.toe` | 2025.32460 | macOS |
| `Patches/microscope.5.toe` | 2025.32460 | macOS |
| `Patches/microscope.6.toe` | 2025.32460 | macOS |
| `Patches/microscope.toe` | 2025.32460 | macOS |
| `tools/td_backup.tox` | 2025.32460 | macOS |
| `tools/touchdesigner-mcp-td/mcp_webserver_base.tox` | 2025.31550 | macOS |

Read a single file's build:

```bash
tools/td-version.sh read Loungellusions_master.toe
```
