<div align="center">
  <img src="./icon.png" width="128" height="128" alt="TriFecta Logo" />
  <h1>TriFecta</h1>
  <p><strong>Three colors, one stroke — a macOS Chinese input method that makes choosing a candidate effortless.</strong></p>

  <p>
    <a href="https://github.com/thesadbee/TriFecta/releases">
      <img src="https://img.shields.io/github/v/release/thesadbee/TriFecta?style=for-the-badge&logo=github" alt="Release" />
    </a>
    <a href="https://github.com/thesadbee/TriFecta/stargazers">
      <img src="https://img.shields.io/github/stars/thesadbee/TriFecta?style=for-the-badge&logo=github&color=ffb800" alt="Stars" />
    </a>
    <a href="https://github.com/thesadbee/TriFecta/releases">
      <img src="https://img.shields.io/github/downloads/thesadbee/TriFecta/total?style=for-the-badge&logo=github" alt="Downloads" />
    </a>
    <a href="LICENSE.txt">
      <img src="https://img.shields.io/badge/License-GPL_3.0-blue.svg?style=for-the-badge" alt="License" />
    </a>
  </p>

  <p>
    <a href="https://github.com/thesadbee/TriFecta/releases/latest">Latest release</a> ｜
    <a href="https://github.com/thesadbee/TriFecta/issues">Report an issue</a> ｜
    <a href="./README.md">中文</a>
  </p>
</div>

---

**TriFecta** is a Chinese input method for macOS built on top of **Rime (Squirrel)**. It solves the pain point of native IMEs where candidate indices (7/8/9) sit far to the right — you have to squint at the numbers and reach for the number keys. With tri-color grouping and the `～` key, your fingers never leave `～ 1 2 3`, so you can locate a candidate by color alone.

The project is a customized fork of [rime/squirrel](https://github.com/rime/squirrel) (GPL-3.0), shipped as a signed and notarized `.pkg` that automatically registers the input source after installation.

## Highlights

- **Tri-color grouping, precise selection**: candidates are split into 3 groups (red / yellow / green). Press `～` to open tri-color, `1/2/3` to pick a group, then `1/2/3` again to pick the candidate. Other groups fade away for focus, and it automatically returns to blue after selection.
- **Three input modes**: Trigger (open tri-color with `～`), Persistent (no trigger key needed — the tri-color menu opens automatically; the first 3 candidates are selectable with `1` / `～` / `Tab`), Slider (a second-level menu stays visible; the trigger key slides one group forward, with a back key). Switch modes with a single slider in the settings panel.
- **Graphical settings panel**: WeChat IME style — left navigation + right panels, mouse-driven tuning that replaces hand-editing `~/Library/Rime/*.yaml`. Saving triggers an immediate redeploy via distributed notifications. Manual YAML editing is fully preserved.
- **Mixed Chinese/English input**: `Shift` + letter outputs the uppercase letter directly, without entering pinyin candidates or disturbing later Chinese input; single/double quotes alternate left and right instead of always showing the left half.
- **Native look & feel**: horizontal capsule candidate bar, translucent glass background, clean `easeInEaseOut` transitions between states — no flicker with every keystroke.

## Download & Install

Get the package that fits your setup from [GitHub Releases](https://github.com/thesadbee/TriFecta/releases/latest).

| Method | Who it's for | Notes |
| --- | --- | --- |
| **`.pkg`** (recommended) | Regular users | Signed + notarized, double-click to install, auto-registers the input source / deploys the Rime schema / enables & selects it |
| **`.dmg`** | Backup / manual install | One-line terminal install; the script strips quarantine and registers everything |
| **Build from source** | Developers | `make release` / `make package`, see below |

**Method A: `.pkg` (recommended)**

1. Download and open `TriFecta.pkg`;
2. Follow the installer wizard and enter your admin password;
3. After installation, **Squirrel (鼠鬚管) appears automatically** under System Settings → Keyboard → Input Sources. Switch to Squirrel with `⌃Control + Space` and start typing.

> If the input source list doesn't refresh after installation, log out and back in once (HIToolbox cache refresh).

<details>
<summary><b>Method B: `.dmg` step-by-step</b></summary>
<br>

> Note: do NOT double-click `安装.command` or Squirrel.app — the app is ad-hoc signed, and macOS will block it on double-click.

Download the dmg and double-click to open it (mounted at /Volumes/TriFecta), then open Terminal and paste:

```bash
cd /Volumes/TriFecta
sudo bash 安装.command
```

The script will: strip quarantine → copy to `/Library/Input Methods` → register the input source → build the Rime schema data → enable and select. You only enter your login password once; you're done when you see `✔ 安装完成！`. (Building the schema data takes about 10–60 seconds — the window may look frozen, that's normal, don't close it.)

If it's still blocked (with a `com.apple.quarantine` message), clear it once manually before running:

```bash
xattr -dr com.apple.quarantine /Volumes/TriFecta/安装.command 2>/dev/null
cd /Volumes/TriFecta && sudo bash 安装.command
```

After installation: System Settings → Keyboard → Input Sources → click “+” → search “Squirrel” (or “鼠鬚管”) → Add, then switch to Squirrel with `⌃Control + Space`.

</details>

<details>
<summary><b>Uninstall</b></summary>
<br>

Run the following in Terminal for a clean removal:

```bash
sudo bash -c '
echo ">>> 1. Disable input source"
"/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --disable-input-source 2>/dev/null || echo "  (skipped: nothing to disable)"
echo ">>> 2. Kill Squirrel processes"
pkill -9 -f "Squirrel" 2>/dev/null || echo "  (no processes)"
sleep 1
echo ">>> 3. Remove installed app"
rm -rf "/Library/Input Methods/Squirrel.app"
echo ">>> 4. Verify"
if [ -d "/Library/Input Methods/Squirrel.app" ]; then echo "  ✘ still exists"; else echo "  ✔ removed"; fi
echo ">>> Done"
'
```

To fully clear your usage habits / dictionary after uninstalling, also run `rm -rf ~/Library/Rime`.

</details>

## Build from Source

TriFecta is a customized [rime/squirrel](https://github.com/rime/squirrel) (GPL-3.0) fork.

- Requirements: **Xcode** (14+, macOS 26 beta works too), **cmake** (`brew install cmake`, only if compiling librime manually), **Rime / Squirrel sources and dependencies**

```bash
# 1. Clone the repo (includes librime / plum / Sparkle submodules)
git clone --recursive https://github.com/thesadbee/TriFecta.git
cd TriFecta

# 2. Use the prebuilt librime + Sparkle to get ready fast (skips building librime/Boost)
bash ./action-install.sh

# 3. Build
export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer   # if using beta Xcode
make release
```

> If `git clone`/submodules/`plum` fail on a restricted network, download each one as a tarball via `codeload`/`raw.githubusercontent` and replace them (the project builds in a variety of environments).

Output: `build/Build/Products/Release/Squirrel.app` (the project still uses the bundle ID `im.rime.inputmethod.Squirrel`).

To package a signed + notarized `.pkg` (including the auto-register / deploy script `scripts/postinstall`):

```bash
# Sign the app with Developer ID Application, sign the pkg with Developer ID Installer, notarize
# See package/ scripts and the Makefile package target
make package
```

## Configuration

Schemas and appearance can be tuned via Rime/theme config or the settings panel (`~/Library/Rime` and the project's `data/`):

- **Tri-color palette**: `groupColors` in `sources/SquirrelView.swift` (red/yellow/green RGB + alpha).
- **Grouping rule**: N candidates are split evenly into 3 groups (`groupSize = ceil(N/3)`).
- **Modes / trigger key / back key**: the Shortcuts page in the settings panel, or `group_colors/*` in `~/Library/Rime/squirrel.yaml`.
- **Capsule appearance**: `data/squirrel.yaml` (`candidate_list_layout: linear`, `font_point`, `line_spacing`, `translucency`, etc.).

## Contributing

TriFecta grows with community feedback. If you find a bug or have a feature idea, open an [Issue](https://github.com/thesadbee/TriFecta/issues) or a Pull Request. The project is a customized fork of [Rime](https://github.com/rime/librime) / [Squirrel](https://github.com/rime/squirrel) and is licensed under **GPL-3.0**.

---

Special thanks to: [rime/librime](https://github.com/rime/librime) ([佛振](https://github.com/lotem) et al.), [rime/squirrel](https://github.com/rime/squirrel) ([Leo Liu](https://github.com/Lekensteyn) et al.), [rime/plum](https://github.com/rime/plum), [sparkle-project/Sparkle](https://github.com/sparkle-project/Sparkle), and the Rime schema data projects: rime-prelude, rime-luna-pinyin, rime-essay, rime-bopomofo, rime-cangjie, rime-stroke, rime-terra-pinyin, rime-quick, rime-double-pinyin and others.

TriFecta's tri-color grouping + `～` precise selection + three modes + settings panel were designed and implemented with the help of **DeepSeek Harness** (an AI coding agent).
