"""Save a TouchDesigner project the way this repo wants it saved.

Repo standard S12: one stable filename per artwork, timestamped copies in Backup/,
never TD's Save Incremental.

Two ways in, same behaviour:

1. Automatic. `tools/td_backup.tox` holds an Execute DAT wired to TouchDesigner's
   Project Pre Save / Project Post Save callbacks, so every save goes through here
   - Cmd+S, the File menu, or a script. Drop the .tox into a project once.

2. Explicit, from a Textport or over MCP:

       import sys; sys.path.append('<repo>/tools')
       import td_save; td_save.save()

Backup/ is gitignored. Git commits are the history of record (standard S7).
"""

import os
import re
import shutil
import time

INCREMENT = re.compile(r"^(?P<stem>.+?)\.(?P<num>\d+)$")
KEEP = 20


def _project():
    try:
        from td import project
        return project
    except Exception:
        raise RuntimeError("td_save only runs inside TouchDesigner")


def stable_stem(filename):
    """'foo.12.toe' -> 'foo'   |   'foo.toe' -> 'foo'"""
    base = os.path.splitext(filename)[0]
    m = INCREMENT.match(base)
    return m.group("stem") if m else base


def _paths(folder=None, name=None):
    proj = _project()
    folder = folder or proj.folder
    stem = stable_stem(name or proj.name)
    return folder, stem, os.path.join(folder, stem + ".toe")


def _numbered(folder, stem):
    """Numbered siblings of the stable file, newest first."""
    out = []
    for entry in os.listdir(folder):
        if not entry.endswith(".toe") or entry == stem + ".toe":
            continue
        base = os.path.splitext(entry)[0]
        if stable_stem(entry) == stem and INCREMENT.match(base):
            out.append(entry)
    return sorted(out, key=lambda e: os.path.getmtime(os.path.join(folder, e)), reverse=True)


def backup_existing(folder=None, name=None):
    """Copy the file currently on disk into Backup/ before anything overwrites it."""
    folder, stem, target = _paths(folder, name)
    if not os.path.exists(target):
        return None
    backup_dir = os.path.join(folder, "Backup")
    os.makedirs(backup_dir, exist_ok=True)
    made = os.path.join(backup_dir, "%s.%s.toe" % (stem, time.strftime("%Y%m%d-%H%M%S")))
    shutil.copy2(target, made)
    return made


def collapse_increments(folder=None, name=None):
    """Fold TD's numbered files back onto the stable filename.

    If TouchDesigner wrote the save to a numbered file (it does this whenever
    project.name carries a number), that file holds the newest work - promote it
    onto the stable name BEFORE deleting anything, or the save is lost.
    """
    folder, stem, target = _paths(folder, name)
    nums = _numbered(folder, stem)
    if not nums:
        return [], False

    newest = os.path.join(folder, nums[0])
    promoted = False
    if not os.path.exists(target) or os.path.getmtime(newest) > os.path.getmtime(target):
        shutil.copy2(newest, target)
        promoted = True

    for entry in nums:
        os.remove(os.path.join(folder, entry))
    return nums, promoted


def prune(folder=None, name=None, keep=KEEP):
    """Keep the newest `keep` backups for this stem. keep=0 keeps everything."""
    folder, stem, _ = _paths(folder, name)
    backup_dir = os.path.join(folder, "Backup")
    if not keep or not os.path.isdir(backup_dir):
        return []
    copies = sorted(
        (e for e in os.listdir(backup_dir)
         if e.startswith(stem + ".") and e.endswith(".toe")),
        reverse=True,
    )
    dropped = copies[keep:]
    for e in dropped:
        os.remove(os.path.join(backup_dir, e))
    return dropped


# --- Execute DAT callbacks (automatic path) -------------------------------

def on_pre_save():
    made = backup_existing()
    return os.path.basename(made) if made else None


def on_post_save(keep=KEEP):
    collapsed, promoted = collapse_increments()
    pruned = prune(keep=keep)
    return collapsed, promoted, pruned


# --- explicit path --------------------------------------------------------

def save(keep=KEEP, folder=None, name=None, verbose=True):
    """Back up, save to the stable path, tidy up. Safe to call with the hooks
    installed - the pre/post callbacks are idempotent."""
    proj = _project()
    folder, stem, target = _paths(folder, name)

    made = backup_existing(folder, name)
    proj.save(target)
    collapsed, promoted = collapse_increments(folder, name)
    pruned = prune(folder, name, keep)

    if verbose:
        print("saved   :", target)
        print("backup  :", os.path.basename(made) if made else "(first save, none)")
        print("removed :", collapsed or "none", "(promoted)" if promoted else "")
        print("pruned  :", pruned or "none")
    return target
