#!/bin/bash
#
# SPDX-FileCopyrightText: 2024-2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Applies the fenrir bootloader compatibility patches needed to boot AOSP on an
# LK that spoofs verifiedbootstate=green.
#
# These were previously pulled from MillenniumOSS/patches with "git am". That no
# longer works on lineage-24.0 for three reasons:
#
#   1. libfs_avb moved out of system/core into its own repo. On lineage-23.2 it
#      was system/core/fs_mgr/libfs_avb; on lineage-24.0 the whole fs_mgr/ tree
#      is gone from system/core and lives in system/fs/fs_mgr
#      (LineageOS/android_system_fs_fs_mgr).
#   2. fastbootd's GetDeviceLockStatus() was rewritten upstream. It now reads
#      `!= "orange"` instead of `== "green"`, so the old patch context no longer
#      matches.
#   3. MillenniumOSS/patches only has a "sixteen" branch; there is no
#      "seventeen" equivalent to fetch.
#
# The edits are applied in place and are idempotent, so re-sourcing this file
# (or re-running envsetup.sh) is safe and will not create duplicate hunks.

_fenrir_patch() {
    python3 - "$@" <<'PYEOF'
import sys, os

path, marker = sys.argv[1], sys.argv[2]
old, new = sys.argv[3], sys.argv[4]

if not os.path.isfile(path):
    print("  SKIP  %s (not found)" % path)
    sys.exit(2)

with open(path, 'r', newline='', encoding='utf-8') as f:
    data = f.read()

if marker in data:
    print("  OK    %s (already patched)" % path)
    sys.exit(0)

if old not in data:
    print("  FAIL  %s (expected code not found - upstream changed?)" % path)
    sys.exit(1)

if data.count(old) != 1:
    print("  FAIL  %s (expected code matched %d times, want 1)"
          % (path, data.count(old)))
    sys.exit(1)

with open(path, 'w', newline='', encoding='utf-8') as f:
    f.write(data.replace(old, new))

print("  PATCH %s" % path)
PYEOF
}

_fenrir_apply() {
    local ret=0
    local top="${ANDROID_BUILD_TOP:-$(pwd)}"

    echo "- Applying fenrir compatibility patches for lineage-24.0"

    # 1/3  libfs_avb: treat a spoofed green state as unlocked so AVB does not
    #      fail verification on fenrir-patched LKs.
    _fenrir_patch \
        "${top}/system/fs/fs_mgr/libfs_avb/util.cpp" \
        'verified_boot_state == "green"' \
        '        return verified_boot_state == "orange";' \
        '        return (verified_boot_state == "orange" || verified_boot_state == "green");' \
        || ret=1

    # 2/3  fastbootd: make the lock check compile-time overridable. Gated by
    #      soong_config_set_bool(fastbootd, bypass_lock_state, true) in device.mk.
    _fenrir_patch \
        "${top}/system/core/fastboot/Android.bp" \
        'FASTBOOT_BYPASS_LOCK_STATE' \
        '    cflags: select(soong_config_variable("fastbootd", "zero_packet"), {
        true: ["-DZERO_PACKET"],
        default: [],
    }),
' \
        '    cflags: select(soong_config_variable("fastbootd", "zero_packet"), {
        true: ["-DZERO_PACKET"],
        default: [],
    }),

    cppflags: select(soong_config_variable("fastbootd", "bypass_lock_state"), {
        true: ["-DFASTBOOT_BYPASS_LOCK_STATE"],
        default: [],
    }),
' \
        || ret=1

    # 3/3  fastbootd: fenrir LKs can still flash through bootloader/fastboot, so
    #      always report unlocked when the bypass flag is set.
    _fenrir_patch \
        "${top}/system/core/fastboot/device/utility.cpp" \
        'FASTBOOT_BYPASS_LOCK_STATE' \
        'bool GetDeviceLockStatus() {
    return android::base::GetProperty("ro.boot.verifiedbootstate", "") != "orange";
}' \
        'bool GetDeviceLockStatus() {
#ifdef FASTBOOT_BYPASS_LOCK_STATE
    return false;
#else
    return android::base::GetProperty("ro.boot.verifiedbootstate", "") != "orange";
#endif
}' \
        || ret=1

    if [ $ret -ne 0 ]; then
        echo "ERROR: one or more fenrir patches could not be applied."
        echo "       Inspect the FAIL lines above and rebase them by hand."
    else
        echo "OK: fenrir patches in place"
    fi

    unset -f _fenrir_patch
    unset -f _fenrir_apply
}

_fenrir_apply