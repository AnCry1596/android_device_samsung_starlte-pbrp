# Pitch Black Recovery Project for the Samsung Galaxy M20

### How to build ###

# Create dirs
$ mkdir ~/PBRP ; cd ~/PBRP

# Init repo
$ repo init -u git://github.com/PitchBlackRecoveryProject/manifest_pb.git -b android-9.0

# Sync
$ repo sync --no-repo-verify -c --force-sync --no-clone-bundle --no-tags --optimized-fetch --prune -j`nproc`

# Clone m20lte repo
$ git clone hhttps://github.com/PitchBlackRecoveryProject/android_device_m20lte-pbrp -b android-9.0 device/samsung/m20lte

# Build
$ source build/envsetup.sh ; lunch omni_m20lte-eng ; mka pbrp
