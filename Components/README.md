# Components

One folder per artwork. Each artwork is a **`.tox`** — a real TouchDesigner Component,
droppable into any network, carrying its own operators and custom parameters.

```
Components/
  Microscope/
    microscope.tox
    README.md
    assets/
  Tipi/
    ...
```

`Loungellusions_master.toe` loads these and composes the show. Master is the mixer;
the art lives here.

**Expose your knobs.** Put the params that matter on the component's top level as custom
parameters. Master drives those. Nothing reaches inside a component.

**State your build.** Every component README opens with the TouchDesigner build the
`.tox` was saved in, on its own line:

```
TD build: 2023.12370
```

Don't guess it, read it:

```bash
tools/td-version.sh read Components/Microscope/microscope.tox
```

Full rules: `docs/STANDARDS.md` (S1-S3, S9).

New component? Copy the shape above, write the 5-line README, go make something weird.
