# Tools

What we drive this repo with. Add tools here as we find them.

## TouchDesigner MCP

Lets agents read and modify the running TD network directly — inspect operators,
set params, build nodes, capture TOP output as an image.

- **Status:** connected and working.
- **Install:** `.mcpb` extension (`touchdesigner-mcp` by 8beeeaaat), installed in Claude
  Desktop. Not configured repo-wide — no `.mcp.json` at root, on purpose.
- **Bridge:** the `mcp_webserver_base` component inside the open `.toe`, HTTP on port 9981.
  It reaches **one running TD instance**, not files on disk.
- **Scope today:** `Experiments/touch-designer-mcp/loungellusions_mcp.toe` only.
- **Gotchas and method:** `.claude/skills/touchdesigner-mcp/SKILL.md` — read it before
  building anything. Silent-failure traps live there.

Rule of thumb: **look before you build.** Read the existing network,
then make the smallest change that shows something.

## TD-Launcher — open a file in the build that made it

<https://github.com/EnviralDesign/TD-Launcher> (MIT)

TouchDesigner never saves backwards. Open a 2020 file in 2025, hit save, and the
2020 machine can't open it again. TD-Launcher reads the build stamped in a `.toe`,
finds that version among the TouchDesigner installs on the machine, and launches it.
If the required build isn't installed it refuses to guess and shows it in red.

Install (macOS, Apple Silicon):

1. Download `TD_Launcher_Installer.arm64.dmg` from the
   [releases page](https://github.com/EnviralDesign/TD-Launcher/releases/latest).
2. Open the DMG, drag **TD Launcher** to **Applications**.
3. First launch is blocked — the app is ad-hoc signed, not notarized. Right-click it
   in Applications, choose **Open**, then **Open** again in the dialog. Once only.
4. File association happens on its own. To make it the default: right-click any `.toe`
   → **Get Info** → **Open with: TD Launcher** → **Change All…**

Install (Windows): run `TD.Launcher.v1.1.0.Setup.exe` from the same release, then set
Windows to open `.toe` files with it.

You can also drag a `.toe` onto the app icon. It only handles `.toe` — a `.tox` gets
loaded by whatever `.toe` pulls it in, so match the master's build.

**Gotcha:** it launches builds that are already installed. It won't fetch a missing one
on macOS — grab that from
[Derivative's archive](https://derivative.ca/download/archive) yourself.

## toeexpand — read the build without opening TouchDesigner

`toeexpand` ships inside every TouchDesigner install
(`/Applications/TouchDesigner <ver>.app/Contents/MacOS/toeexpand`). It unpacks a
`.toe` / `.tox` into a directory whose `.build` file records version, build and OS.

`tools/td-version.sh` wraps it, so nobody has to remember any of that:

```bash
tools/td-version.sh read Loungellusions_master.toe
```

```bash
tools/td-version.sh sync
```

| Command | Does |
|---|---|
| `read <file>` | Print the build one file was saved with. |
| `scan` | Print a row per tracked `.toe` / `.tox`. |
| `sync` | Rewrite `docs/VERSIONS.md` from disk. |
| `check` | Exit non-zero if `docs/VERSIONS.md` is stale. |

It picks the newest installed TouchDesigner automatically; override with
`TOEEXPAND=/path/to/toeexpand`. Expansion happens in a temp directory, because
`toeexpand` dumps its output next to the input file and would otherwise litter the repo.

**Gotcha:** `toeexpand` exits with status 1 even when it succeeds. The script checks for
the `.build` file instead of trusting the exit code.

## Other tools

| Tool | Does | Reach for it when |
|---|---|---|
| | | |

## Skills

- `caveman` — repo default voice, always on.
  Rule files committed: `AGENTS.md` (Claude and most agents) and
  `.github/copilot-instructions.md` (Copilot). Self-contained — no plugin needed.
  `CLAUDE.md` points at `AGENTS.md` rather than repeating the rules.
  Levels: `lite | full | ultra`. Repo default is `full`.

  The caveman plugin's `caveman-init` script also writes Cursor, Windsurf, Cline and
  opencode rule files. We don't use those editors — delete them if the script is re-run.
