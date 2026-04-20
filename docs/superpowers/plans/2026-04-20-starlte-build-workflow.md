# Starlte PBRP Build Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a new GitHub Actions workflow that builds the PBRP recovery image for the Samsung Galaxy S9 (starlte) and automatically publishes a GitHub Release on every successful build.

**Architecture:** A single `build` job on `ubuntu-latest` that mirrors the README build steps — clean disk, install deps, repo sync, clone device tree, build, then release. Triggered by both push and manual dispatch.

**Tech Stack:** GitHub Actions, `repo` tool, Android AOSP build system (PBRP/OmniROM), `softprops/action-gh-release@v2`, `rokibhasansagar/slimhub_actions@main`

---

## File Structure

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `.github/workflows/build-starlte.yml` | Full build + release workflow |

---

### Task 1: Create the workflow skeleton with triggers and env

**Files:**
- Create: `.github/workflows/build-starlte.yml`

- [ ] **Step 1: Create the workflow file with triggers**

Create `.github/workflows/build-starlte.yml` with this exact content:

```yaml
name: Build PBRP for starlte

on:
  push:
    branches:
      - '**'
  workflow_dispatch:
    inputs:
      RELEASE_TAG:
        description: 'Release tag (e.g. v1.0-starlte)'
        required: true
        default: 'v1.0-starlte'

env:
  DEVICE: starlte
  VENDOR: samsung
  MANIFEST_URL: https://github.com/PitchBlackRecoveryProject/manifest_pb.git
  MANIFEST_BRANCH: android-10.0
  DEVICE_TREE_URL: https://github.com/AnCry1596/android_device_starlte-pbrp
  DEVICE_TREE_BRANCH: android-10.0

jobs:
  build:
    name: Build PBRP Recovery
    runs-on: ubuntu-latest
    steps:
      - name: Placeholder
        run: echo "scaffold"
```

- [ ] **Step 2: Verify the file exists**

```bash
ls .github/workflows/build-starlte.yml
```

Expected: file listed with no error.

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/build-starlte.yml
git commit -m "ci: add starlte build workflow skeleton"
```

---

### Task 2: Add disk cleanup and dependency installation steps

**Files:**
- Modify: `.github/workflows/build-starlte.yml`

- [ ] **Step 1: Replace the placeholder step with real steps**

Replace the `steps:` block content in `.github/workflows/build-starlte.yml` with:

```yaml
    steps:
      - name: Clean runner disk space
        uses: rokibhasansagar/slimhub_actions@main

      - name: Install build dependencies
        run: |
          sudo apt-get update -qq
          sudo apt-get install -y --no-install-recommends \
            bc bison build-essential ccache curl flex \
            g++-multilib gcc-multilib git gnupg gperf imagemagick \
            lib32ncurses5-dev lib32readline-dev lib32z1-dev \
            liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev \
            libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lzop \
            pngcrush python3 python-is-python3 \
            schedtool squashfs-tools xsltproc zip zlib1g-dev

      - name: Install repo tool
        run: |
          mkdir -p ~/bin
          curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
          chmod a+x ~/bin/repo
          echo "$HOME/bin" >> $GITHUB_PATH

      - name: Configure git identity
        run: |
          git config --global user.email "ci@github.actions"
          git config --global user.name "GitHub Actions"
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/build-starlte.yml
git commit -m "ci: add disk cleanup and dependency installation steps"
```

---

### Task 3: Add repo init and sync steps

**Files:**
- Modify: `.github/workflows/build-starlte.yml`

- [ ] **Step 1: Append repo init and sync steps after the git config step**

Add these steps after `Configure git identity`:

```yaml
      - name: Initialize repo
        run: |
          mkdir -p ~/android/pbrp
          cd ~/android/pbrp
          repo init \
            -u ${{ env.MANIFEST_URL }} \
            -b ${{ env.MANIFEST_BRANCH }} \
            --depth=1

      - name: Sync repo
        run: |
          cd ~/android/pbrp
          repo sync \
            --no-repo-verify \
            -c \
            --force-sync \
            --no-clone-bundle \
            --no-tags \
            --optimized-fetch \
            --prune \
            -j$(nproc)
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/build-starlte.yml
git commit -m "ci: add repo init and sync steps"
```

---

### Task 4: Add device tree clone and build steps

**Files:**
- Modify: `.github/workflows/build-starlte.yml`

- [ ] **Step 1: Append device tree clone and build steps**

Add these steps after `Sync repo`:

```yaml
      - name: Clone device tree
        run: |
          cd ~/android/pbrp
          git clone \
            ${{ env.DEVICE_TREE_URL }} \
            -b ${{ env.DEVICE_TREE_BRANCH }} \
            device/${{ env.VENDOR }}/${{ env.DEVICE }} \
            --depth=1

      - name: Build PBRP recovery
        run: |
          cd ~/android/pbrp
          source build/envsetup.sh
          lunch omni_${{ env.DEVICE }}-eng
          mka pbrp -j$(nproc)
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/build-starlte.yml
git commit -m "ci: add device tree clone and build steps"
```

---

### Task 5: Add artifact upload and GitHub Release steps

**Files:**
- Modify: `.github/workflows/build-starlte.yml`

- [ ] **Step 1: Append artifact upload and release steps**

Add these steps after `Build PBRP recovery`:

```yaml
      - name: Upload recovery image as artifact
        uses: actions/upload-artifact@v4
        with:
          name: starlte-recovery
          path: ~/android/pbrp/out/target/product/${{ env.DEVICE }}/recovery.img
          if-no-files-found: error

      - name: Set release tag
        id: tag
        run: |
          if [ "${{ github.event_name }}" = "workflow_dispatch" ]; then
            echo "tag=${{ github.event.inputs.RELEASE_TAG }}" >> $GITHUB_OUTPUT
          else
            echo "tag=build-$(echo ${{ github.sha }} | cut -c1-7)" >> $GITHUB_OUTPUT
          fi

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ steps.tag.outputs.tag }}
          name: "PBRP starlte ${{ steps.tag.outputs.tag }}"
          body: |
            PBRP Recovery for Samsung Galaxy S9 (starlte)
            Branch: ${{ env.MANIFEST_BRANCH }}
            Commit: ${{ github.sha }}
          files: ~/android/pbrp/out/target/product/${{ env.DEVICE }}/recovery.img
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

- [ ] **Step 2: Verify the full workflow file looks correct**

```bash
cat .github/workflows/build-starlte.yml
```

Expected: a complete YAML file with all 9 steps, no placeholder content.

- [ ] **Step 3: Validate YAML syntax**

```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/build-starlte.yml'))" && echo "YAML OK"
```

Expected: `YAML OK`

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/build-starlte.yml
git commit -m "ci: add artifact upload and GitHub Release steps"
```

---

## Final Verification

After all tasks:

- [ ] Run `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/build-starlte.yml'))" && echo "YAML OK"` — must print `YAML OK`
- [ ] Push to GitHub and verify the Actions tab shows the new workflow named **"Build PBRP for starlte"**
- [ ] Manually trigger `workflow_dispatch` with tag `v1.0-starlte` and confirm a GitHub Release is created with `recovery.img` attached
