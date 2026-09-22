# Device tree for the Infinix HOT 40 Pro (X6837)

## Device specifications

| Basic                   | Spec                                                        |
| ----------------------- | :---------------------------------------------------------- |
| SoC                     | MediaTek Helio G99 (6nm)                                    |
| CPU                     | Octa-core (2x2.2 GHz Cortex-A76 & 6x2.0 GHz Cortex-A55)     |
| GPU                     | Mali-G57 MC2                                                |
| Memory                  | 8GB / 12GB                                                  |
| Shipped Android version | 13                                                          |
| Storage                 | 128GB / 256GB                                               |
| MicroSD                 | MicroSDXC                                                   |
| Battery                 | Non-removable Li-Po 5000 mAh                                |
| Dimensions              | 168.6 x 76.6 x 8.3 mm                                       |
| Display                 | 1080 x 2460 pixels, 6.78 inches                             |
| Rear Camera 1           | 108 MP, f/1.8, (wide), 0.64µm, AF                           |
| Rear Camera 2           | 2 MP, f/2.4, (macro)                                        |
| Rear Camera 3           | QVGA                                                        |
| Front Camera            | 32 MP, f/2.2, (wide)                                        |


## Device Picture

![Infinix HOT 40 Pro](https://fdn2.gsmarena.com/vv/pics/infinix/infinix-hot-40-pro-1.jpg)

## Building for Android 17 (lineage-24.0)

`lineage-24.0` is the LineageOS branch for Android 17. The port of this tree from
`lineage-23.0` (Android 16) consisted of four changes:

1. **`BoardConfig.mk`** – include `device/lineage/sepolicy/libion/sepolicy.mk`
   and add `hardware/mediatek/vintf/mediatek_framework_compatibility_matrix_aidl.xml`
   to `DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE`. `BOARD_VNDK_VERSION` is
   deliberately left unset: `build/make/core/config.mk` clears it on Android 16+.
2. **`device.mk`** – `PRODUCT_ENFORCE_SELINUX_TREBLE_LABELING := false` downgrades
   the Android 17 Treble labeling check to warnings (MTK/Transsion blobs are not
   labeled to that standard); `soong_config_set_bool(libion, legacy_impl, true)`
   selects the legacy ION ABI that MT6789's gralloc needs. `fastbootd` is shipped
   by `vendor/lineage/config/common.mk`, so it is not repeated here.
3. **`rootdir/etc/init/hw/init.mt6789.rc`** – the codec2 service is now restarted
   as `android-hardware-media-c2-hal` (the AIDL name from `hardware/mediatek`
   `aidl/codec2`); the old HIDL `-1-2` suffixed name no longer exists.
4. **`vendorsetup.sh`** – re-applies the fenrir bootloader compatibility patches.
   On Android 17 `libfs_avb` moved from `system/core/fs_mgr/` to its own
   `system/fs/fs_mgr/` repo, so the old `git am` from MillenniumOSS/patches no
   longer applies; the three hunks are now applied in place and are idempotent.

### Repos this tree needs that are not in the LineageOS manifest

Neither `hardware/mediatek` nor `device/mediatek` is synced by the LineageOS
manifest, so they must come from a local manifest or your own fork. The following
are required and have `lineage-24.0` branches:

| Path | Repo | Notes |
| ---- | ---- | ----- |
| `hardware/mediatek` | [LineageOS/android_hardware_mediatek](https://github.com/LineageOS/android_hardware_mediatek) | BoardConfig includes `device/mediatek/sepolicy_vndr/SEPolicy.mk`, so `device/mediatek` is needed too |
| | **or a fork that keeps `aidl/codec2`** | `LineageOS/android_hardware_mediatek@lineage-24.0` dropped `codec2`, but `device.mk` still packages `android.hardware.media.c2-mtk-service` and sets the `android_hardware_mediatek_codec2` soong config. A tree such as [halcyonproject/hardware_mediatek](https://github.com/halcyonproject/hardware_mediatek) carries it. |
| `device/infinix/X6837-kernel` | your kernel repo | must provide `ramdisk/modules.load` and `vendor_dlkm/modules.load` |

### VINTF `target-level` — do not bump it

`configs/vintf/manifest.xml` declares `target-level="7"`. That is the FCM level of
the **vendor image** (Android 13), not of the Android 17 you are compiling. See
the comment at the top of that file before touching it.