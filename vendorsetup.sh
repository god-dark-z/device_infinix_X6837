#!/bin/bash

RET=0
echo "- Applying fenrir compatiblity patches"
cd system/core
curl https://raw.githubusercontent.com/MillenniumOSS/patches/refs/heads/sixteen/system/core/0001-libfs_avb-Allow-LKs-patched-with-fenrir-to-boot-on-A.patch | git am || {
  RET=1
  git am --abort >/dev/null 2>&1
}
curl https://raw.githubusercontent.com/MillenniumOSS/patches/refs/heads/sixteen/system/core/0002-fastbootd-Always-return-false-for-GetDeviceLockStatu.patch | git am || {
  RET=1
  git am --abort >/dev/null 2>&1
}
cd ../../

if [ $RET -ne 0 ]; then
  echo "ERROR: Patch is not applied! Maybe it's already patched, or you'll have to adapt it to this specific rom source?"
else
  echo "OK: All patched"
fi
