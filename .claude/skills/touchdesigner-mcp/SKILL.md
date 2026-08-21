---
name: touchdesigner-mcp
description: Hard-won gotchas and a working method for driving TouchDesigner through the touchdesigner-mcp server. Load before creating nodes, wiring feedback loops, setting parameters, or opening output windows in TouchDesigner.
---

# Driving TouchDesigner over MCP

Verified against TouchDesigner 099.2025.32460, API Server 1.5.0, MCP Server 2.0.0.

## Connection model

The MCP talks to **one running TouchDesigner instance** over HTTP, not to `.toe` files on disk.

- The bridge is a `mcp_webserver_base` component living *inside* the open `.toe`. Whatever file
  that instance has open is the only network reachable. Other `.toe` files are invisible.
- Default port is 9981, hardcoded in the `.mcpb` extension config.
- To reach a different project, copy `mcp_webserver_base` into it (save it as a `.tox` and drop
  it in). Two instances at once need different ports and separate MCP server entries.
- Check you are connected, and to what, with `get_td_info` plus
  `execute_python_script` running `print(project.name, project.folder)`.

## Method that works

1. **Introspect before setting.** Parameter names are not guessable. Create the node, then
   `print([p.name for p in node.pars()])` and set from that list. Guessed names fail silently
   through some paths.
2. **Batch through `execute_python_script`.** Far fewer round trips than one tool call per node.
   Wrap parameter sets in a try/except that collects failures into a list and prints it, so a
   bad name reports itself instead of aborting the batch.
3. **Measure, don't squint.** `node.numpyArray()` gives real numbers:
   `a.min()`, `a.max()`, `a.mean()`, and `(a > 0.99).mean()` for the clipped fraction. A black
   frame and a broken frame look identical in a screenshot; the array tells them apart.
4. **Then look.** `get_top_image` on the final null TOP. Use it to judge the art, not to debug
   the plumbing.
5. **Check errors explicitly.** `[(c.name, c.errors()) for c in parent.children if c.errors()]`.

## Saving is part of the change

TouchDesigner does **not** autosave. Everything built over MCP lives in memory until saved,
and a crash or a quit loses all of it. So saving is not a separate step you offer at the end —
it closes each unit of work.

**Save when a change is working**, not after every parameter nudge. One save per coherent
result: a chain that renders, a loop that holds steady, a layout that reads. Mid-tuning states
are not worth a save.

Projects carrying `tools/td_backup.tox` handle this themselves — an Execute DAT on the
Project Pre Save / Project Post Save callbacks backs up, folds numbered files onto the stable
name, and prunes. Saving normally is then safe. Repo standard S12.

If the component is absent, save through the helper explicitly:

```python
import sys; sys.path.append('<repo>/tools')
import td_save; td_save.save()
```

**Never call bare `project.save()`.** With no path it increments the filename — `foo.toe`
becomes `foo.1.toe` — and the live project drifts onto the new file. Worse, once `project.name`
is a numbered file, saving to the base path writes **both** files with identical current
content, so the numbered copy preserves nothing. `project.name` keeps the old name until the
file is reopened; that is cosmetic, saves still land correctly.

Overwriting an existing file opens a **modal confirm dialog** when `general.saveprompt` is 1.
TouchDesigner blocks on it and freezes the MCP server with it — the call times out and port
9981 stops answering until a human clicks. Set `ui.preferences['general.saveprompt'] = 0`
before automating saves.

Say what changed inside the file when you report the save — a binary diff tells nobody
anything (repo standard S7). If the save changes which TouchDesigner build wrote the file,
`docs/VERSIONS.md` needs regenerating (S9, `tools/td-version.sh sync`).

## Gotchas

### Feedback TOP needs BOTH the input and the target parameter

Connect the source into the Feedback TOP's input *and* set `par.top` to the target node's name.
With `par.top` blank it outputs pure black and reports **no error at all**. Silent failure —
the whole loop looks wired and produces nothing.

Verify with `numpyArray().max()` on the feedback node; zero means the loop is dead.

### Resolution does not inherit through a feedback loop

Nodes downstream of a feedback cycle fall back to 128x128 even when the source is 1280x720.
Set `outputresolution='custom'` plus `resolutionw`/`resolutionh` on **every** node in the loop.

### Loop gain over unity blows out in seconds

Feedback brightness multiplied by any upscale is a gain term. At `brightness1` 0.99 with an
`sx`/`sy` of 1.012 the frame clipped to pure white almost immediately. 0.94 held a steady state.
Tune by watching `decay.numpyArray().mean()` settle, then pulse `resetpulse` on the Feedback TOP
after each change so you are not reading a transient.

### Script-created nodes all land at 0,0

`parent.create()` does not lay out. Every node stacks in one pile until you set `nodeX`/`nodeY`.
Nodes are 130x90, so 200px horizontal and 180px vertical spacing reads cleanly. Put a feedback
return path on the row below the main chain, flowing right-to-left, so the cycle is visible.

### Ramp TOP colours live in a companion table DAT

The `color1`..`color4` parameters are not the palette. The Ramp TOP reads a table DAT named by
its `dat` parameter (`<name>_keys`), with columns `pos, r, g, b, a`. Create that DAT and append
rows. Editing the table changes the palette live.

### Sparse noise costs about six times what perlin does

The Noise TOP's `sparse` type is in a different price bracket from the rest. Measured on the
warp chain of the audio-reactive network, everything else held at 59.8 fps:

| Noise feeding the Displace TOP | Real fps |
|---|---|
| sparse, 814x612 | 10.7 |
| sparse, 256x192 | 49.8 |
| simplex3d, 814x612 | 59.2 |
| perlin3d, 814x612 | 59.4 |

The Displace TOP it feeds is free — bypassing only the noise put the chain straight back to
59.7. Reach for `perlin3d` or `simplex3d` first and treat `sparse` as a deliberate expense.

Swapping the type changes how hard the displacement hits: perlin's gradients are much wider
than sparse's, so the displace weight that read as a nice liquid warp under sparse dissolved
the frame into marble soup under perlin. Retune the weight after any noise-type change.

## Measuring performance

**A TOP only cooks when something displays it.** With no viewer open on the chain, the whole
thing idles and every frame-rate reading comes back a clean 60 — including a chain that
actually runs at 10 fps the moment it is on screen. Worse, `absTime.frame` advances at
`cookRate` whether or not TouchDesigner manages to render, so frames-per-second computed from
it is always just `cookRate` and tells you nothing. Both readings look healthy while the
patch is unusable.

Force the cooking and count real frames instead. An Execute DAT with **Frame Start** on:

```python
def onFrameStart(frame):
	pr = op('/project1')
	pr.store('ffcount', pr.fetch('ffcount', 0) + 1)
	pr.op('fx_out').cook(force=True)
	return
```

Then, in two separate MCP calls a good ten seconds apart — one to reset and stamp, one to
read:

```python
# call 1
op('/project1').store('ffcount', 0)
op('/project1').store('t0', time.time())
# call 2
p = op('/project1')
print(round(p.fetch('ffcount') / (time.time() - p.fetch('t0')), 1))
```

Sanity-check the metric against a chain you know is cheap before trusting a bad number, and
delete the Execute DAT afterwards — it forces cooking that would otherwise not happen.

Two things that do **not** work for this:

- `OP.cookTime` / `cpuCookTime` are stale unless the Performance Monitor is running, and
  `gpuCookTime` reads 0.0. The large values sitting on nodes are one-off costs from shader
  compiles and resolution changes, not per-frame cost.
- Raising `cookRate` to find headroom measures nothing, because the TOPs keep cooking at
  viewer rate while the timeline runs away.

### Nothing cooks at all while the timeline is paused

`op('/project1').time.play` being False stops frame advance dead. Audio analysis reads zero,
movies sit on one frame, and none of it reports an error — it looks exactly like a broken
network. Check it first when live values are all zero.

Related: never `time.sleep()` inside `execute_python_script` to watch a value change. The
script blocks TouchDesigner's cook thread, so no frames advance and every sample comes back
identical. Sample across separate MCP calls instead, or read a Trail CHOP's `numpyArray()`.

## Reference build

`Experiments/touch-designer-mcp/loungellusions_mcp.toe` holds two networks built entirely over
MCP. Read it before building another.

- A feedback spiral — noise seed, damped injection, add-composite feedback loop with rotate and
  scale, ramp-lookup palette, bloom, and a `windowCOMP` output.
- An audio-reactive effects rig, unlinked from the spiral — Audio Analysis component into five
  control nulls, four effect chains with Cross TOP wet/dry, palette knob widgets, and seven
  blend modes. Its `fx_notes` DAT documents the node names and the tuning parameters.
