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
| `Experiments/Light rotation/light_rotation.22.toe` | 2025.32460 | macOS |
| `Experiments/Light rotation/light_rotation.toe` | 2025.32460 | macOS |
| `Experiments/touch-designer-mcp/NewProject.1.toe` | 2025.32460 | macOS |
| `Experiments/touch-designer-mcp/NewProject.toe` | 2025.32460 | macOS |
| `Experiments/touch-designer-mcp/loungellusions_mcp.toe` | 2025.32460 | macOS |
| `Loungellusions_master.toe` | 2020.28110 | Windows |
| `Patches/microscope.1.toe` | 2025.32460 | macOS |
| `Patches/microscope.2.toe` | 2025.32460 | macOS |
| `Patches/microscope.3.toe` | 2025.32460 | macOS |
| `Patches/microscope.4.toe` | 2025.32460 | macOS |
| `Patches/microscope.5.toe` | 2025.32460 | macOS |
| `Patches/microscope.6.toe` | 2025.32460 | macOS |
| `Patches/microscope.toe` | 2025.32460 | macOS |

Read a single file's build:

```bash
tools/td-version.sh read Loungellusions_master.toe
```
