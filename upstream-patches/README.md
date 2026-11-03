# upstream-patches: local changes that must be applied to upstream repos

These repos are **deliberately not forked** (the net difference from upstream is only about a hundred lines, not worth maintaining a repo for).
But the changes themselves are required; in particular, **without the display patch, fingerprint doesn't work**.
So they are kept here as patches: apply them after rebuilding the source tree, which keeps the changes without widening the difference from upstream.

## 0001-display-sm8450-udfps-hbm-and-sdmext.patch

**Target repo**: `hardware/qcom-caf/sm8450/display`
**Upstream baseline**: `lineage-23.2-caf-sm8450` of `LineageOS/android_hardware_qcom_display`
(this patch's diff baseline is commit `222878b`)
**Net difference**: 14 files, +153 / -14

It has three parts:

1. **Connect the UDFPS hbm_enable path** (`OPLUS_FINGERPRINT_MASK`)
   The device tree has always set `soong_config_set_bool(qtidisplay,oplus_udfps,true)`,
   but `Android.bp` has no matching `soong_config_variables`, so that code is **silently compiled out**.
   This adds the variable and cflags, and makes `HWDeviceDRM::SetupAtomic()` scan layer names and set
   `OPLUS_OFP_PROPERTY_*` bits as needed, sent to the kernel through the DRM connector property `hbm_enable`.
   Without this: `pressed_icon_status` never reaches `ON_WR_PTR`, `waitUiready` times out,
   and fingerprint enrollment always ends with `errno=15001` (= 10108 FP_ERR_FINGERUP_TOO_FAST).

2. **Layer name matching uses keywords only**, instead of copying sm8550's literals.
   sm8550's `"SurfaceView[UdfpsControllerOverlay](BLAST)"` is an Android 14 era
   name; in this A16 tree the measured buffer name is
   `VRI[SurfaceView[UdfpsControllerOverlay]]#N(BLAST Consumer)N`, so a copied literal would never match.

3. **Three essentials for coexisting with prebuilt blobs from a different generation**
   - `display_base`: `SetColorTransform` returns `kErrorNone` when there is no color manager.
     This device's `libsnapdragoncolor-manager.so` is from a different generation than the source and SIGSEGVs on load, so
     `color_manager.cpp` deliberately skips STC. If this returned `kErrorNotSupported` as-is,
     composer would permanently set `color_tranform_failed_`, and
     `PreValidateDisplay()` would call `MarkLayersForClientComposition()` every frame:
     **the entire display stack is forced back to 100% GPU composition**.
   - `comp_manager`: `IsDisplayHWAvailable()` doesn't touch the blob's vtable and simply does `return true`.
     That slot is the last one in the interface in `resource_interface.h`, and the other-generation blob's vtable is one slot shorter than ours,
     so calling it means `pc=0`. Its only use is `enable_null_display_`, and this device always has a panel.
   - `hw_device_drm`: the probe is narrowed to "log only when the mask changes", to avoid log spam every frame.

**How to apply** (from the source tree root):
```
cd hardware/qcom-caf/sm8450/display
git apply -p1 <path-to>/0001-display-sm8450-udfps-hbm-and-sdmext.patch
```

**Verification** (after flashing, nothing left to guesswork):
```
adb shell dumpsys SurfaceFlinger | grep usesDeviceComposition    # should be true
adb logcat -d | grep "ofp-mask"                                  # should toggle 0x1 <-> 0x3 on press
adb shell dmesg | grep HBM_ENABLE                                # should show HBM_ENABLE:3
adb shell 'cat /sys/kernel/oplus_display/fp_state'
```

## 0002-vendor-lineage-depmod-and-sched-param.patch

**Target repo**: `vendor/lineage`
**Upstream baseline**: `16.0` of `crdroidandroid/android_vendor_lineage`
**Net difference**: 2 files, +33 / -3

- `build/tasks/kernel.mk`: depmod unknown symbol and `BOOT_KERNEL_MODULES`
  missing checks are now controlled by `BOARD_KERNEL_MODULES_LOAD_ALLOW_MISSING`.
  The device tree list uses old module names while gki-modules has renamed them, and missing old names make
  depmod fail to find symbols and break the dependency chain.
- `tools/clean_headers.sh`: handles the sched_param header conflict.

**How to apply** (from the source tree root):
```
cd vendor/lineage
git apply -p1 <path-to>/0002-vendor-lineage-depmod-and-sched-param.patch
```

## 0003-kernel-sm8450-ksm-fragment.patch

**Target repo**: `kernel/oneplus/sm8450`
**Upstream baseline**: `lineage-ovaltine-dev/android_kernel_oneplus_sm8450` (diff baseline `cfcbf0579b5f`)
**Net difference**: 1 file (new), +10

- Adds `arch/arm64/configs/vendor/oplus/ksm.config`, containing only one line, `CONFIG_KSM=y`.
  KSM appears in neither `gki_defconfig` nor any vendor fragment, so `make gki_defconfig`
  leaves it at the kernel default `n` (the resulting `.config` has `# CONFIG_KSM is not set`),
  so the whole `/sys/kernel/mm/ksm` directory is absent and it can't be enabled at runtime.
  The device tree's `TARGET_KERNEL_CONFIG` already appends it to the end of the list to override the default.

**How to apply** (from the source tree root):
```
cd kernel/oneplus/sm8450
git apply -p1 <path-to>/0003-kernel-sm8450-ksm-fragment.patch
```

**Companion changes** (all in the device tree, committed with this repo, no patch needed):

- `BoardConfigCommon.mk`: `TARGET_KERNEL_CONFIG` appends `vendor/oplus/ksm.config`
- `init/init.kernel.post_boot-cape.sh`: adds `configure_memory_extension()`,
  enabling these adaptively based on physical memory:
  - zram = `min(RAM x 50%, 6GB)`, minimum 1GB, lz4 algorithm (16G model → 6144MB)
  - KSM: memory ≤6GB scans often (200 pages / 20ms), >6GB gently (100 pages / 50ms), with zero-page merging enabled

  This device's `chip_family=0x82` takes the cape branch, and the stock cape script **has no zram section**
  (only the taro version has `configure_zram_parameters`), which is exactly why zram was never enabled.
- `sepolicy/ksm.te` + `sepolicy/genfs_contexts`: give `/sys/kernel/mm/ksm`
  a dedicated `sysfs_ksm` label and allow `vendor_qti_init_shell` to write it.
  The default label is generic `sysfs`, on which that domain has read-only access. Without this,
  the script's writes to `pages_to_scan` / `use_zero_pages` / `run` are silently blocked by SELinux.

**Verification** (after flashing):
```
adb shell ls -Z /sys/kernel/mm/ksm/run   # should be u:object_r:sysfs_ksm:s0
adb shell cat /sys/kernel/mm/ksm/run     # should be 1
adb shell cat /proc/swaps                # should list /dev/block/zram0 (6144MB on this device)
```

> **Flashing note**: after changing SELinux policy you **must flash `odm` as well**. The policy loaded at runtime is
> `/odm/etc/selinux/precompiled_sepolicy`, which doesn't check the vendor hash,
> so flashing only vendor has no effect (hit this in testing on 2026-10-11).

## Maintenance convention

When changing these repos, **re-export the patch right after** (overwriting the file of the same name in this directory),
otherwise this directory slowly drifts from the actual tree:

```
git -C hardware/qcom-caf/sm8450/display diff <upstream baseline>..HEAD -- . ':(exclude)*.before-*' \
  > device/oneplus/sm8450-common/upstream-patches/0001-display-sm8450-udfps-hbm-and-sdmext.patch
git -C vendor/lineage diff <upstream baseline>..HEAD -- . ':(exclude)*.before-*' \
  > device/oneplus/sm8450-common/upstream-patches/0002-vendor-lineage-depmod-and-sched-param.patch
```

> Note: the display repo once had a mistakenly committed backup file,
> `sdm/libs/core/comp_manager.cpp.before-t17-hwavail` (954 lines), cleaned up on 2026-10-10.
> The export command keeps `:(exclude)*.before-*` so that stray commits like that don't end up in the patch.

---

## One-step apply (idempotent)

After rebuilding the source tree or running `repo sync`, run this once:

```
bash device/oneplus/sm8450-common/upstream-patches/apply.sh
```

- It finds the source tree root by walking up (looks for `build/envsetup.sh`);
- **Idempotent**: skips what's already applied and never applies twice;
- If upstream code has changed so that neither state matches, it reports that clearly and asks for a manual check rather than forcing the patch;
- To check without changing files: `apply.sh --check`.

Measured state on this machine:

```
$ bash device/oneplus/sm8450-common/upstream-patches/apply.sh --check
```
```
