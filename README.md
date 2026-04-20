# Pitch Black Recovery Project for the Samsung Galaxy M20

### How to build ###

# Create dirs
$ mkdir ~/PBRP ; cd ~/PBRP

# Init repo
$ repo init -u git://github.com/PitchBlackRecoveryProject/manifest_pb.git -b android-10.0

# Sync
$ repo sync --no-repo-verify -c --force-sync --no-clone-bundle --no-tags --optimized-fetch --prune -j`nproc`

# Clone starlte repo
$ git clone hhttps://github.com/AnCry1596/android_device_starlte-pbrp -b android-9.0 device/samsung/starlte

# Build
$ source build/envsetup.sh ; lunch omni_starlte-eng ; mka pbrp
