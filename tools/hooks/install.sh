#!/usr/bin/env bash
#
# Point git at tools/hooks/ so the repo's hooks are version controlled.

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
git config core.hooksPath tools/hooks
echo "core.hooksPath -> tools/hooks"
