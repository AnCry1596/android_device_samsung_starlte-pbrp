# PBRP device tree for Samsung S9 aka starlte

## Kernel source 
Available at https://github.com/corsicanu/android_kernel_samsung_universal9810

## How to build
This was tested and it's fully compatible with a minimal PBRP-based manifest.
1. Set up the build environment following the PBRP build instructions for your chosen manifest.
2. In the root folder of cloned repo you need to clone the device tree:
```bash
git clone -b android-9.0 https://github.com/PitchBlackRecoveryProject/android_device_samsung_starlte.git device/samsung/starlte
```
3. To build:
```bash
export ALLOW_MISSING_DEPENDENCIES=true && . build/envsetup.sh && lunch pbrp_starlte-eng && mka recoveryimage -j128
```

