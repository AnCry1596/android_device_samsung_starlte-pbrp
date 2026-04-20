# Starlte PBRP Build Workflow Design

**Date:** 2026-04-20  
**Topic:** New GitHub Actions workflow to build PBRP recovery for Samsung Galaxy S9 (starlte)

## Overview

A new workflow file `.github/workflows/build-starlte.yml` that builds the PBRP recovery image for the starlte device and automatically creates a GitHub Release on every successful build.

## Triggers

- `push` — fires on every push to any branch
- `workflow_dispatch` — manual trigger with one input:
  - `RELEASE_TAG` (string, required) — the tag to use for the GitHub Release (e.g. `v1.0-starlte`)

## Job: `build`

Runs on `ubuntu-latest`.

### Steps

1. **Clean runner** — `rokibhasansagar/slimhub_actions@main` to free disk space before syncing AOSP sources
2. **Install dependencies** — `apt-get` packages: `git`, `repo`, `openjdk-11-jdk`, `ccache`, and standard Android build tools (`bc`, `bison`, `flex`, `g++`, `gcc`, `gnupg`, `gperf`, `libxml2-utils`, `make`, `pngcrush`, `schedtool`, `squashfs-tools`, `xsltproc`, `zip`, `zlib1g-dev`, `liblz4-tool`, `libncurses5-dev`, `libsdl1.2-dev`, `libssl-dev`, `libwxgtk3.0-gtk3-dev`, `libxml2`, `python3`, `python-is-python3`)
3. **Configure git** — set `user.email` and `user.name` (from env or hardcoded safe defaults)
4. **repo init** — `repo init -u https://github.com/PitchBlackRecoveryProject/manifest_pb.git -b android-10.0 --depth=1`
5. **repo sync** — `repo sync --no-repo-verify -c --force-sync --no-clone-bundle --no-tags --optimized-fetch --prune -j$(nproc)`
6. **Clone device tree** — `git clone https://github.com/AnCry1596/android_device_starlte-pbrp -b android-10.0 device/samsung/starlte --depth=1`
7. **Build** — `source build/envsetup.sh && lunch omni_starlte-eng && mka pbrp -j$(nproc)`
8. **Upload artifact** — upload `out/target/product/starlte/recovery.img` as a GitHub Actions artifact named `starlte-recovery`
9. **Create GitHub Release** — `softprops/action-gh-release@v2` attaches `recovery.img`; tag comes from `RELEASE_TAG` input (workflow_dispatch) or auto-generated `build-<short SHA>` for push triggers

## Secrets

- `GITHUB_TOKEN` — built-in, no user configuration needed

## Out of Scope

- Telegram notifications
- SourceForge upload
- ccache persistence across runs (can be added later)
