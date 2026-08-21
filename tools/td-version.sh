#!/usr/bin/env bash
#
# td-version.sh — read the TouchDesigner build a .toe / .tox file was saved with.
#
# Uses `toeexpand`, the utility shipped inside every TouchDesigner install. It
# expands the binary file into a directory containing a `.build` manifest, which
# records the version, build number and OS of the TouchDesigner that saved it.
#
# Usage:
#   tools/td-version.sh read <file.toe|file.tox>   Print the build of one file.
#   tools/td-version.sh scan                       Print builds of every tracked file.
#   tools/td-version.sh sync                       Rewrite docs/VERSIONS.md from disk.
#   tools/td-version.sh check                      Exit non-zero if VERSIONS.md is stale.
#
# Override the toeexpand binary with TOEEXPAND=/path/to/toeexpand.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSIONS_FILE="$REPO_ROOT/docs/VERSIONS.md"

# Directories we never report on: TouchDesigner's own autosaves and import cache.
EXCLUDES=(-not -path '*/Backup/*' -not -path '*/TDImportCache/*' -not -path '*/.git/*')

die() { echo "td-version: $*" >&2; exit 1; }

# Locate toeexpand. Any installed TouchDesigner can expand files saved by older
# builds, so we take the newest install available.
find_toeexpand() {
  if [[ -n "${TOEEXPAND:-}" ]]; then
    [[ -x "$TOEEXPAND" ]] || die "TOEEXPAND is set but not executable: $TOEEXPAND"
    echo "$TOEEXPAND"
    return
  fi

  local candidate
  candidate="$(ls -d /Applications/TouchDesigner*.app/Contents/MacOS/toeexpand 2>/dev/null | sort -V | tail -1 || true)"
  if [[ -z "$candidate" ]]; then
    candidate="$(ls -d "/c/Program Files/Derivative/TouchDesigner"*/bin/toeexpand.exe 2>/dev/null | sort -V | tail -1 || true)"
  fi

  [[ -n "$candidate" ]] || die "no toeexpand found. Install TouchDesigner, or set TOEEXPAND."
  echo "$candidate"
}

# Print "<build>\t<osname>" for one .toe / .tox file.
#
# toeexpand always writes its output next to the input file, so we copy the file
# into a scratch directory first and expand it there. That keeps the repo clean.
read_build() {
  local file="$1"
  [[ -f "$file" ]] || die "no such file: $file"

  local toeexpand tmp base build_file
  toeexpand="$(find_toeexpand)"
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  base="$(basename "$file")"
  cp "$file" "$tmp/$base"
  # toeexpand exits 1 even when it succeeds, so the expanded manifest is the only
  # reliable success signal.
  ( cd "$tmp" && "$toeexpand" "$base" >/dev/null 2>&1 ) || true

  build_file="$tmp/$base.dir/.build"
  [[ -f "$build_file" ]] || die "toeexpand produced no .build manifest for $file"

  local build osname
  build="$(awk '$1 == "build" { print $2 }' "$build_file")"
  osname="$(awk '$1 == "osname" { print $2 }' "$build_file")"
  printf '%s\t%s\n' "${build:-unknown}" "${osname:-unknown}"
}

# List every tracked .toe / .tox, repo-relative, sorted.
list_files() {
  ( cd "$REPO_ROOT" && find . \( -name '*.toe' -o -name '*.tox' \) "${EXCLUDES[@]}" -print \
    | sed 's|^\./||' | sort )
}

# Print a markdown table row per file.
scan_rows() {
  local file line build osname
  while IFS= read -r file; do
    line="$(read_build "$REPO_ROOT/$file")"
    build="${line%%$'\t'*}"
    osname="${line##*$'\t'}"
    printf '| `%s` | %s | %s |\n' "$file" "$build" "$osname"
  done < <(list_files)
}

# Build the full contents of docs/VERSIONS.md.
render_versions() {
  cat <<'HEADER'
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
HEADER
  scan_rows
  cat <<'FOOTER'

Read a single file's build:

```bash
tools/td-version.sh read Loungellusions_master.toe
```
FOOTER
}

cmd="${1:-}"
case "$cmd" in
  read)
    [[ $# -eq 2 ]] || die "usage: td-version.sh read <file.toe|file.tox>"
    read_build "$2" | awk -F'\t' '{ printf "build %s (saved on %s)\n", $1, $2 }'
    ;;
  scan)
    scan_rows
    ;;
  sync)
    mkdir -p "$(dirname "$VERSIONS_FILE")"
    render_versions > "$VERSIONS_FILE"
    echo "wrote $VERSIONS_FILE"
    ;;
  check)
    if [[ ! -f "$VERSIONS_FILE" ]]; then
      echo "td-version: docs/VERSIONS.md is missing. Run: tools/td-version.sh sync" >&2
      exit 1
    fi
    if ! diff -q <(render_versions) "$VERSIONS_FILE" >/dev/null; then
      echo "td-version: docs/VERSIONS.md is out of date. Run: tools/td-version.sh sync" >&2
      diff <(render_versions) "$VERSIONS_FILE" >&2 || true
      exit 1
    fi
    echo "docs/VERSIONS.md is up to date"
    ;;
  *)
    sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's|^# \{0,1\}||'
    exit 1
    ;;
esac
