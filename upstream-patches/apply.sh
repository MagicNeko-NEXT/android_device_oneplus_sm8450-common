#!/bin/bash
# Xi 2026-10-10
# Applies the changes in upstream-patches/ to the source tree (idempotent: skips what's applied)
#
# Usage (from the source tree root or anywhere, the script finds the root itself):
#     bash device/oneplus/sm8450-common/upstream-patches/apply.sh
#     bash device/oneplus/sm8450-common/upstream-patches/apply.sh --check   # check only, changes no files
#
# Why: these repos are deliberately not forked (the net difference from upstream is about a hundred lines),
# but the changes are required: without the display patch, fingerprint doesn't work.
# Keeping patches in the device tree means running this once after repo sync restores them, without widening the difference from upstream.

set -uo pipefail

CHECK_ONLY=0
[ "${1:-}" = "--check" ] && CHECK_ONLY=1

# ---- find the source root: walk up to the level with build/envsetup.sh ----
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SELF"
while [ "$ROOT" != "/" ] && [ ! -f "$ROOT/build/envsetup.sh" ]; do
  ROOT="$(dirname "$ROOT")"
done
if [ ! -f "$ROOT/build/envsetup.sh" ]; then
  echo "!! Source tree root not found (no build/envsetup.sh above)"
  exit 1
fi
echo "Source tree root: $ROOT"
[ "$CHECK_ONLY" = "1" ] && echo "Mode: --check (read-only, changes no files)"
echo

ok(){   printf '  \033[32m✓\033[0m %s\n' "$*"; }
no(){   printf '  \033[31m✗\033[0m %s\n' "$*"; }
skip(){ printf '  \033[36m=\033[0m %s\n' "$*"; }

failed=0

apply_one() {
  local repo_rel="$1" patch_name="$2" desc="$3"
  local repo="$ROOT/$repo_rel"
  local patch="$SELF/$patch_name"

  echo "== $repo_rel"
  echo "   $desc"

  if [ ! -d "$repo/.git" ]; then
    no "Repo doesn't exist (project not in the source tree?)"
    failed=1; echo; return
  fi
  if [ ! -f "$patch" ]; then
    no "Patch not found: $patch_name"
    failed=1; echo; return
  fi

  cd "$repo" || { no "Can't enter $repo"; failed=1; echo; return; }

  if git apply --check -p1 "$patch" >/dev/null 2>&1; then
    if [ "$CHECK_ONLY" = "1" ]; then
      ok "Can be applied (--check mode, nothing written)"
    else
      git apply -p1 "$patch" && ok "applied" || { no "apply failed"; failed=1; }
    fi
  elif git apply --check --reverse -p1 "$patch" >/dev/null 2>&1; then
    skip "Already applied, skipping"
  else
    no "Neither applicable nor already applied: upstream may have changed, manual check needed"
    echo "      (try first: git -C $repo_rel apply --check -v -p1 $patch)"
    failed=1
  fi
  echo
}

apply_one "hardware/qcom-caf/sm8450/display" \
          "0001-display-sm8450-udfps-hbm-and-sdmext.patch" \
          "Display HAL: UDFPS hbm_enable path + coexisting with other-generation libsdmextension (required for fingerprint)"

apply_one "vendor/lineage" \
          "0002-vendor-lineage-depmod-and-sched-param.patch" \
          "Build system: optional depmod unknown symbol tolerance + sched_param header conflict"

# 2026-10-11: KSM disabled per the owner's instruction, so this patch is disabled (the patch file and ksm.config are both kept;
#            to restore, uncomment the three lines below and add the BoardConfigCommon.mk reference back).
# apply_one "kernel/oneplus/sm8450" \
#           "0003-kernel-sm8450-ksm-fragment.patch" \
#           "Kernel config: enable CONFIG_KSM (samepage merging, works with the device tree's adaptive zram)"

if [ "$failed" = "0" ]; then
  printf '\033[32mAll ready\033[0m\n'
else
  printf '\033[31mSome projects failed, see ✗ above\033[0m\n'
  exit 1
fi
