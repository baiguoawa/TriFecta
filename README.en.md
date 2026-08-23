# TriFecta

> Pick the right candidate by color — a macOS Chinese input method.

TriFecta is a **Rime / Squirrel**-based macOS Chinese input method. It solves a common pain point of the native input method: **selecting candidates far from the home row (7/8/9)** forces you to lean in and read the candidate numbers, then reach for the number keys. TriFecta uses **three-color grouping + the `~` key** so your fingers stay on `~ 1 2 3` and you locate a candidate purely by color.

---

## Why

A native Chinese candidate bar shows 6–9 candidates at once. When the desired candidate is far down the list (especially #7/#8/#9), you have to:
1. Lean closer to read every candidate's number;
2. Look down at the keyboard to find the matching digit key.

TriFecta **splits the candidates into 3 groups**, distinguishes them with **red / yellow / green**, and lets you select with the `~` key:
- Press `~` → candidates 1–3 red, 4–6 yellow, 7–9 green;
- Press `1/2/3` to choose a group → the group's 3 candidates are recolored red/yellow/green **by position**, and the other groups **dim** for focus;
- Press `1/2/3` again to pick the exact candidate (committed).

Your fingers never leave `~ 1 2 3` — no reading numbers, no reaching for 7/8/9.

---

## Features

- **Three-color grouping**: candidates split into 3 groups, red/yellow/green, as high-contrast "liquid-glass" pills matching the panel's native glass look.
- **`~` three-state toggle**:
  1. Blue → press `~` → enter three-color;
  2. A group selected → press `~` → **back to the "choose a group" step** (stay in three-color, so you can change your pick);
  3. On "choose a group" → press `~` → exit back to blue.
- **Precise in-group pick**: after choosing a group, its 3 candidates are colored red/yellow/green by position; other groups dim.
- **Auto-return to blue**: once a character is committed precisely, it returns to blue single-select; if the remaining candidates are high-frequency and in the top 3, just pick directly, otherwise press `~` again.
- **Native look**: horizontal capsule bar, semi-circular ends, translucency/glass background, blue capsule highlight, system-like corner radii & spacing.
- **Punctuation**: common punctuation commits directly (full-width in Chinese, half-width in English/ascii).
- **Nonlinear animation**: clean `easeInEaseOut` state transitions (no flashing on every keystroke).

---

## Install

### Way A: `.dmg` (recommended, provided in GitHub Releases)
Open the `.dmg` → run **安装.command** (enter your password; it installs to `/Library/Input Methods` and auto-registers + builds the Rime schema data).

After installing:
1. **System Settings → Keyboard → Input Sources** → click **“+”** → search **“Squirrel”** (or “鼠鬚管”) → add;
2. Switch to **Squirrel** with **⌃Control + Space** (or the top input menu).

> If macOS Gatekeeper blocks it on first launch: right-click the app → “Open”, or allow it under System Settings → Privacy & Security.

### Way B: build from source (see “Build from source” below)

---

## Usage

| Action | Effect |
|---|---|
| Type pinyin | Blue capsule highlight (native look) |
| Press `~` (left of `1`) | Enter three-color: 1–3 red / 4–6 yellow / 7–9 green |
| Press `1/2/3` | Choose a group: its 3 candidates colored red/yellow/green by position, others dim |
| Press `1/2/3` again | Pick the exact candidate (committed), auto-return to blue |
| `~` (a group selected) | Back to the “choose a group” step |
| `~` (on “choose a group”) | Exit to blue |
| `Shift` | Toggle Chinese ↔ Latin (ascii); Latin uses half-width punctuation |

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
git clone --recursive https://github.com/yourname/TriFecta.git
cd TriFecta

# 2. Use prebuilt librime + Sparkle (skip building librime/Boost)
bash ./action-install.sh

# 3. Build
export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer   # if using beta Xcode
make release
```

> **Note on building:** the bridge header needs librime's *source* headers (e.g. `rime/key_table.h`), which the prebuilt binary package doesn't include. If the build fails with a missing `rime/…h` header, also fetch the [librime](https://github.com/rime/librime) source and copy its `include/` and `src/` into `librime/`. In restricted networks, use `codeload` / `raw.githubusercontent` tarballs for any failing sub-module.

Output: `build/Build/Products/Release/Squirrel.app` (this project keeps the input identifier `im.rime.inputmethod.Squirrel`).

---

## Configuration

Schemas and appearance are configurable via Rime config (`~/Library/Rime`) and the project's `data/`:
- **Three colors**: `sources/SquirrelView.swift` → `groupColors` (red/yellow/green RGB + alpha).
- **Grouping**: candidates N split into 3 groups (`groupSize = ceil(N/3)`).
- **Capsule look**: `data/squirrel.yaml` (`candidate_list_layout: linear`, `font_point`, `line_spacing`, `translucency`, ...).

---

## Distribution

- **Not on the App Store** — distributed via **GitHub Releases** as `.dmg`.
- Signed locally with **ad-hoc** (`codesign --force --deep --sign -`).
- To let others install without a right-click “Open”, use **Apple Developer ID signing + notarization** ($99/year account).

---

## Contributors

TriFecta is built on top of these open-source projects and authors:

- **Rime input engine** — [rime/librime](https://github.com/rime/librime) ([佛振](https://github.com/lotem) et al.)
- **macOS frontend Squirrel** — [rime/squirrel](https://github.com/rime/squirrel) ([Leo Liu](https://github.com/Lekensteyn) et al.)
- **plum (Rime package manager)** — [rime/plum](https://github.com/rime/plum)
- **Sparkle** update framework — [sparkle-project/Sparkle](https://github.com/sparkle-project/Sparkle)
- **Rime schema data** — rime-prelude / rime-luna-pinyin / rime-essay / rime-bopomofo / rime-cangjie / rime-stroke / rime-terra-pinyin / rime-quick / rime-double-pinyin, etc.

The **TriFecta three-color grouping + `~` precise-selection** feature was designed & implemented with the help of **DeepSeek Harness** (an AI coding agent).

## License

- Based on [Rime](https://github.com/rime/librime) / [Squirrel](https://github.com/rime/squirrel), under **GPL-3.0**.
- Input identifier kept as `im.rime.inputmethod.Squirrel`.

---

**TriFecta** — three colors, three picks, one tap to land.
