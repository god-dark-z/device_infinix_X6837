# Infinix HOT 40 Pro (X6837) Device Tree

This repository contains the Android device configuration for the **Infinix HOT 40 Pro**, model **X6837**. It defines the product configuration, board configuration, partition layout, hardware declarations, overlays, init configuration, and other device-specific integration required to build an Android-based operating system for this handset.

## Device information

| Item | Details |
|---|---|
| SoC | MediaTek Helio G99, 6 nm |
| CPU | 2 × Cortex-A76 up to 2.2 GHz; 6 × Cortex-A55 up to 2.0 GHz |
| GPU | Mali-G57 MC2 |
| Memory | 8 GB or 12 GB |
| Storage | 128 GB or 256 GB |
| Original Android release | Android 13 |
| Display | 6.78-inch, 1080 × 2460 |
| Battery | Non-removable 5000 mAh Li-Po |
| Expandable storage | microSDXC |

## Android source-tree location

Place this repository at:

```text
device/infinix/X6837
```

The device tree is intended to be used together with the matching vendor and kernel-image repositories. Product and board configuration should reference the exact branch and component revisions used for the build.

## Branch and upstream

The active integration branch is `lineage-23.2`. This repository is based on [mt6789-transsion-infinix/device_infinix_X6837](https://github.com/mt6789-transsion-infinix/device_infinix_X6837).

## Building

Initialize and synchronize the Android source tree for the target release, place this repository at the path above, add the compatible vendor and kernel components, and then select the X6837 lunch target supplied by the product configuration. The exact lunch target and build commands depend on the Android distribution and manifest in use.

## Contribution guidelines

Keep device-specific changes within this tree and preserve compatibility with the declared Android branch. Changes to partition definitions, sepolicy references, init scripts, overlays, or hardware configuration should include a clear rationale and be tested on the target hardware whenever possible.

## Licensing and proprietary components

Device trees may reference vendor-provided binaries and configuration. Preserve upstream license notices and review the licensing terms of all proprietary components before redistribution.

## Disclaimer

This is a community-maintained project and is not affiliated with or endorsed by Infinix or Transsion.
