# TriFecta

<p align="center">
  <img src="./icon.png" width="120" alt="TriFecta icon" />
</p>

> **Three colors, three picks, one tap to land.** — a macOS Chinese input method that lets you pick precisely by color.

**🌏 Language:** [**中文**](./README.md) ｜ English

TriFecta is a **Rime / Squirrel**-based macOS Chinese input method. It solves a common pain point of native input methods: **when candidate numbers are far from home row (7/8/9), you have to lean in to read the number, then reach for the digit key**. TriFecta uses **three-color grouping + the `~` key** so your fingers stay on `~ 1 2 3` and you locate a candidate purely by color.

TriFecta also ships **three input modes** (trigger / dwell / slider), a **graphical settings panel**, and can be packaged as a **signed + notarized `.pkg`** that auto-registers the input source on install.

---

## Why

A native Chinese candidate bar shows 6–9 candidates at once. When the desired candidate is far down the list (especially #7/#8/#9), you have to:
1. Lean closer to read every candidate's number;
2. Look down at the keyboard to find the matching digit key.

TriFecta **splits the candidates into 3 groups**, distinguishes them with **red / yellow / green**, and lets you select with the `~` key:
- Press `~` → candidates 1–3 red, 4–6 yellow, 7–9 green;
- Press `1/2/3` to choose a group → that group's 3 candidates are recolored red/yellow/green **by position**, and the other groups **fade away** for focus;
- Press `1/2/3` again to pick the exact candidate (committed).

Your fingers never leave `~ 1 2 3` — no reading numbers, no reaching for 7/8/9.

---

## Features

### Core: three-color grouping + precise selection

- **Three-color grouping**: candidates split into 3 groups, red/yellow/green, as high-contrast "liquid-glass" pills.
- **`~` three-state toggle**:
  1. Blue → press `~` → enter three-color;
  2. A group selected → press `~` → **back to the "choose a group" step** (stay in three-color to change your pick);
  3. On "choose a group" → press `~` → exit back to blue.
- **Precise in-group pick**: after choosing a group, its 3 candidates are colored red/yellow/green by position; **other groups fade away completely** for stronger contrast.
- **Auto-return to blue**: once a character is committed precisely, return to blue single-select; if the remaining candidates are high-frequency top-3, pick directly, otherwise press `~` again.

### Three input modes

| Mode | Behavior |
|---|---|
| **Trigger** | Press the trigger key (default `~`) to open three-color; `1/2/3` pick a group → `1/2/3` pick the candidate |
| **Dwell** | As you type pinyin, **no trigger key needed** — the three-color top menu opens automatically; the first 3 candidates are picked with `1` / `~` / `Tab`, and `2/3` enter the 2nd/3rd group |
| **Slider** | Always shows one group's sub-menu (three colors under candidates 1/2/3); press the trigger key to **slide back one group** (1-3 → 4-6 → 7-9 → page), and `1/2/3` picks the candidate in whichever group is shown; also has a **back key** (default `Tab`) to return to the previous group |

> Switch modes with the **slider in the settings panel** (single thumb — drag to a slot to activate that mode and turn off the others).

### Chinese/English mixing & input comfort

- **`Shift+letter` → uppercase directly**: hold `Shift` and tap a letter to **commit that uppercase letter directly**, without it being treated as an invalid pinyin (no "no candidates" glitch), and without disturbing subsequent Chinese input (temporarily suppresses `Shift`'s CN/EN toggle for a moment).
- **Single/double quote pairing**: in Chinese mode, quotes **alternate left/right** (press once → left quote, press again → right quote, again → left…), no longer stuck on the left half only.

### Graphical settings panel (TriFectaSettings)

A WeChat-style settings window: **left navigation + right panel**, point-and-click tuning instead of hand-editing `~/Library/Rime/*.yaml`. On save it dispatches a distributed notification to **immediately redeploy** (changes take effect instantly). Hand-editing YAML is still fully supported.

It has 6 pages:
- **Input**: simplification/traditional & other input options
- **Appearance**: candidate bar look (font, layout, transparency, colors, …)
- **Interface**: settings window's own look
- **Shortcuts**: three-mode slider + per-mode trigger / back / selection keys
- **Sync**: user data sync
- **About**: version & credits

### Native look & animation

- **Native look**: horizontal capsule bar, semi-circular ends, translucency/glass background, blue capsule highlight, system-like corner radii & spacing.
- **Nonlinear animation**: clean `easeInEaseOut` state transitions (no flashing on every keystroke).

---

## Install

### Way A: `.pkg` (recommended — one step)

> **We recommend the `.pkg`** — it's **signed + notarized**, and **auto-registers the input source / deploys the Rime schema data / enables & selects it** on install. Just double-click.

1. Download & open `TriFecta.pkg`;
2. Follow the wizard and enter your admin password;
3. After install (postinstall runs `--register-input-source` / `--build` / `--enable-input-source` / `--select-input-source`):
   - **Squirrel (鼠鬚管)** appears automatically under **System Settings → Keyboard → Input Sources**;
   - Switch to **Squirrel** with **⌃Control + Space** and type.

> If the input-source list doesn't refresh, **log out and back in** once (HIToolbox cache refresh).

### Way B: `.dmg` (alternative)

> **Do NOT double-click `安装.command` or Squirrel.app** — because the app is ad-hoc signed, macOS shows a "cannot verify… malware" dialog on double-click. Install from the **Terminal** instead.

```bash
# 1) Download this .dmg and open it (mounts to /Volumes/TriFecta)
# 2) Open Terminal and run:
cd /Volumes/TriFecta
sudo bash 安装.command
```

The script automatically: strips the quarantine attribute → copies to `/Library/Input Methods` → registers the input source → builds the Rime schema data → enables and selects it. You only type your password once; you'll see `✔ 安装完成！` on success. (Building schema data takes ~10–60 s; the window may look frozen — that's normal, don't close it.)

If it's still blocked (a `com.apple.quarantine` message), clear it once first:
```bash
xattr -dr com.apple.quarantine /Volumes/TriFecta/安装.command 2>/dev/null
cd /Volumes/TriFecta && sudo bash 安装.command
```

After installing:
1. **System Settings → Keyboard → Input Sources** → click **"+"** → search **"Squirrel"** (or "鼠鬚管") → add;
2. Switch to **Squirrel** with **⌃Control + Space** (or the top input menu).

### Way C: build from source (see "Build from source" below)

---

## Uninstall

Run this in **Terminal** to fully remove it (disable input source → kill the process → delete the app → verify):

```bash
sudo bash -c '
echo ">>> 1. Disable input source"
"/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --disable-input-source 2>/dev/null || echo "  (skipped: nothing to disable)"
echo ">>> 2. Kill Squirrel process"
pkill -9 -f "Squirrel" 2>/dev/null || echo "  (no process)"
sleep 1
echo ">>> 3. Remove installed app"
rm -rf "/Library/Input Methods/Squirrel.app"
echo ">>> 4. Verify"
if [ -d "/Library/Input Methods/Squirrel.app" ]; then echo "  ✘ still present"; else echo "  ✔ removed"; fi
echo ">>> done"
'
```

> To fully clear your usage habits/word dictionary, additionally run `rm -rf ~/Library/Rime`.

---

## Usage

| Action | Effect |
|---|---|
| Type pinyin | Blue capsule highlight (native look) |
| Press `~` (left of `1`) | Enter three-color: 1–3 red / 4–6 yellow / 7–9 green |
| Press `1/2/3` | Choose a group: its 3 candidates colored red/yellow/green by position, **others fade away** |
| Press `1/2/3` again | Pick the exact candidate (committed), auto-return to blue |
| `~` (a group selected) | Back to the "choose a group" step |
| `~` (on "choose a group") | Exit to blue |
| `Shift` (hold) + letter | Commit that **uppercase** letter directly (not treated as pinyin, doesn't disturb Chinese) |
| Single / double quote | Left ↔ right quote alternation |

---

## Build from source

TriFecta is a customization of [rime/squirrel](https://github.com/rime/squirrel) (GPL-3.0).

### Prerequisites
- **Xcode** (14+; macOS 26 beta also works)
- **cmake** (`brew install cmake`, only if building librime from source)
- **Rime / Squirrel source & dependencies**

### Steps
```bash
# 1. Clone (includes librime / plum / Sparkle submodules)
git clone --recursive https://github.com/thesadbee/TriFecta.git
cd TriFecta

# 2. Use prebuilt librime + Sparkle (skip building librime/Boost)
bash ./action-install.sh

# 3. Build
export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer   # if using beta Xcode
make release
```

> **Note on building:** the bridge header needs librime's *source* headers (e.g. `rime/key_table.h`), which the prebuilt binary package doesn't include. If the build fails with a missing `rime/…h` header, also fetch the [librime](https://github.com/rime/librime) source and copy its `include/` and `src/` into `librime/`. In restricted networks, use `codeload` / `raw.githubusercontent` tarballs for any failing sub-module.

Output: `build/Build/Products/Release/Squirrel.app` (this project keeps the input identifier `im.rime.inputmethod.Squirrel`).

### Package as `.pkg`

After building the source you can package a signed + notarized `.pkg` that includes the auto-register/deploy script `scripts/postinstall`:

```bash
# Sign the .app with "Developer ID Application", the .pkg with "Developer ID Installer", then notarize
# See the package/ scripts and the Makefile `package` target
make package
```

---

## Configuration

Schemas and appearance are configurable via Rime config (`~/Library/Rime`), the project's `data/`, **or the settings panel**:
- **Three colors**: `sources/SquirrelView.swift` → `groupColors` (red/yellow/green RGB + alpha).
- **Grouping**: candidates N split into 3 groups (`groupSize = ceil(N/3)`).
- **Modes / trigger / back keys**: settings panel "Shortcuts" page, or `~/Library/Rime/squirrel.yaml` → `group_colors/*`.
- **Capsule look**: `data/squirrel.yaml` (`candidate_list_layout: linear`, `font_point`, `line_spacing`, `translucency`, ...).

---

## Distribution

- **Not on the App Store** — distributed via **GitHub Releases** as a signed + notarized **`.pkg`** (or `.dmg`).
- Sign the `.app` with **Apple Developer ID Application**, the `.pkg` with **Developer ID Installer**, then run **notarization** and `stapler` staple.
- The `.pkg` uses `scripts/postinstall` to **auto-register the input source / deploy the Rime schema data / enable & select it** — users don't have to add it manually.

---

## Contributors

TriFecta is built on top of these open-source projects and authors:

- **Rime input engine** — [rime/librime](https://github.com/rime/librime) ([佛振](https://github.com/lotem) et al.)
- **macOS frontend Squirrel** — [rime/squirrel](https://github.com/rime/squirrel) ([Leo Liu](https://github.com/Lekensteyn) et al.)
- **plum (Rime package manager)** — [rime/plum](https://github.com/rime/plum)
- **Sparkle** update framework — [sparkle-project/Sparkle](https://github.com/sparkle-project/Sparkle)
- **Rime schema data** — rime-prelude / rime-luna-pinyin / rime-essay / rime-bopomofo / rime-cangjie / rime-stroke / rime-terra-pinyin / rime-quick / rime-double-pinyin, etc.

The **TriFecta three-color grouping + `~` precise selection + three modes + settings panel** features were designed & implemented with the help of **DeepSeek Harness** (an AI coding agent).

## License

- Based on [Rime](https://github.com/rime/librime) / [Squirrel](https://github.com/rime/squirrel), under **GPL-3.0**.
- Input identifier kept as `im.rime.inputmethod.Squirrel`.

---

**TriFecta** — three colors, three picks, one tap to land.
