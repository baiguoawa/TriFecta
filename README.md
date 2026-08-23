# TriFecta

> 三连中 —— 用颜色让你从容三选一的 macOS 中文输入法。

**🌏 Language:** 中文 ｜ [**English**](./README.en.md)

TriFecta 是一个基于 **Rime（Squirrel）** 的 macOS 中文输入法，针对原生输入法“**取远号候选字要凑近看编号、还要伸手去够 7/8/9**”的痛点，用**三色分组 + `～` 键精准选字**来解决：手指始终不离 `～ 1 2 3` 四个键，凭颜色即可定位候选字。

---

## 为什么做

原生中文输入法候选框一次显示 6~9 个字，候选字编号靠后（尤其 7/8/9）时：
1. 得把脸凑近屏幕看清每个字的编号；
2. 得低头找键盘上对应的数字键。

TriFecta 把候选字**均分成 3 组**，用**红 / 黄 / 绿**三色区分，并让你用 `～` 键进入“三色分组选字”：
- `～` 开启 → 候选 1-3 红、4-6 黄、7-9 绿；
- 按 `1/2/3` 选中一组 → 组内候选再按位置标成红/黄/绿，**其它组变暗**聚焦；
- 再按 `1/2/3` 选中组内那个字（精准上屏）。

全程手指只在 `～ 1 2 3` 上，不用看编号、不用摸 7/8/9。

---

## 功能特性

- **三色分组**：候选字均分为 3 组，红/黄/绿，高对比度“彩色液态玻璃”观感（与原生 Liquid Glass 背景一致）。
- **`～` 三态切换**：
  1. 蓝色 → 按 `～` → 开启三色；
  2. 已选某组 → 按 `～` → **回到“选组”那一步**（不退出三色，便于改选）；
  3. 在“选组”状态 → 按 `～` → 退出三色回蓝色。
- **组内精准选字**：选中某组后，组内 3 个候选按位置红/黄/绿着色，其它组变暗。
- **选后自动回蓝**：完成一次“精准上字”后自动回到蓝色单点；剩余字若高频在前 1-3 位可直接选，否则再按 `～`。
- **原生观感**：横向胶囊候选框、两端半圆、玻璃透明底、蓝色胶囊高亮、圆角/间距贴近系统输入法。
- **标点**：中文下常用标点全角直接上屏，英文（Shift 切西文）下半角。
- **非线性动画**：状态切换带干净的 `easeInEaseOut` 过渡（不会每次打字都闪）。

---

## 安装

### 方式 A：`.dmg`（推荐）

> **注意：不要双击 `安装.command` 或 Squirrel.app** —— 因为 App 是 ad-hoc 签名，macOS 会在你双击时弹「无法验证是否含恶意软件」拦截。请在**终端**用一行命令安装。

```bash
# 1) 下载本 dmg，双击打开（挂载到 /Volumes/TriFecta）
# 2) 打开 终端（Terminal），粘贴运行：
cd /Volumes/TriFecta
sudo bash 安装.command
```

脚本会自动：剥离隔离属性 → 复制到 `/Library/Input Methods` → 注册输入源 → 构建 Rime 方案数据 → 启用并选中。全程只需输一次登录密码，看到 `✔ 安装完成！` 即成功。（构建方案数据约 10~60 秒，窗口看似卡住是正常的，别关。）

若仍被拦（提示 `com.apple.quarantine`），先手动清一次再运行：
```bash
xattr -dr com.apple.quarantine /Volumes/TriFecta/安装.command 2>/dev/null
cd /Volumes/TriFecta && sudo bash 安装.command
```

安装后：
1. **系统设置 → 键盘 → 输入法** → 点 **“+”** → 搜索 **“Squirrel”**（或“鼠鬚管”）→ 添加；
2. 用 **⌃Control + 空格**（或顶部输入法菜单）切到 **Squirrel**。

### 方式 B：源码构建（见下文“从源码构建”）

---

## 使用说明

| 操作 | 效果 |
|---|---|
| 输入拼音 | 蓝色胶囊高亮（原生观感） |
| 按 `～`（数字1左边） | 开启三色分组：1-3红 / 4-6黄 / 7-9绿 |
| 按 `1/2/3` | 选中一组：该组 3 个按位置红/黄/绿，其它组变暗 |
| 再按 `1/2/3` | 选中组内该字（精准上屏），并自动回蓝色 |
| `～`（已选组时） | 回到“选组”那一步 |
| `～`（选组状态） | 退出三色，回到蓝色 |
| `Shift`（轻按） | 中文 ↔ 西文（ascii）切换 |
| `Shift`（按住） | 临时大写，松开自动回中文（不卡英文态） |

---

## 从源码构建

TriFecta 基于 [rime/squirrel](https://github.com/rime/squirrel)（GPL-3.0）定制。

### 环境
- **Xcode**（14+，macOS 26 beta 亦可）
- **cmake**（`brew install cmake`，若手动编译 librime）
- **Rime / Squirrel 源码与依赖**

### 步骤
```bash
# 1. 拉取仓库（含 librime / plum / Sparkle 子模块）
git clone --recursive https://github.com/yourname/TriFecta.git
cd TriFecta

# 2. 用预编译 librime + Sparkle 快速就绪（跳过编译 librime/Boost）
bash ./action-install.sh

# 3. 构建
export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer   # 若用 beta Xcode
make release
```

> 若在受限网络下 `git clone`/子模块/`plum` 拉取失败，可用 `codeload`/`raw.githubusercontent` 逐个以 tarball 下载替换（工程在多种环境下均可构建）。

产物：`build/Build/Products/Release/Squirrel.app`（本工程仍沿用输入法标识 `im.rime.inputmethod.Squirrel`）。

---

## 配置

方案与外观可通过 Rime/主题配置调整（`~/Library/Rime` 与工程 `data/`）：
- **三色**：`sources/SquirrelView.swift` 中 `groupColors`（红/黄/绿 RGB + alpha）。
- **分组规则**：候选数 N 均分为 3 组（`groupSize = ceil(N/3)`）。
- **胶囊外观**：`data/squirrel.yaml`（`candidate_list_layout: linear`、`font_point`、`line_spacing`、`translucency` 等）。

---

## 分发

- **不上架 App Store**，通过 **GitHub Releases** 分发 `.dmg`。
- 本工程本地用 **ad-hoc 签名**（`codesign --force --deep --sign -`）。
- 若要让他人无需右键“打开”即可安装，需 **Apple Developer ID 签名 + notarization**（$99/年账号）。

---

## Contributors / 致谢

特别感谢以下开源项目与作者（TriFecta 基于它们构建）：

- **Rime 输入法引擎** —— [rime/librime](https://github.com/rime/librime)（[佛振](https://github.com/lotem) 等）
- **macOS 输入法前端 Squirrel** —— [rime/squirrel](https://github.com/rime/squirrel)（[Leo Liu](https://github.com/Lekensteyn) 等）
- **Rime 方案管理 plum** —— [rime/plum](https://github.com/rime/plum)
- **Sparkle** 自动更新框架 —— [sparkle-project/Sparkle](https://github.com/sparkle-project/Sparkle)
- **Rime 语音方案数据** —— rime-prelude / rime-luna-pinyin / rime-essay / rime-bopomofo / rime-cangjie / rime-stroke / rime-terra-pinyin / rime-quick / rime-double-pinyin 等

**TriFecta 的三色分组 + `～` 精准选字功能**由 **DeepSeek Harness**（AI 编程代理）协助设计与实现。

## 许可

- 基于 [Rime](https://github.com/rime/librime) / [Squirrel](https://github.com/rime/squirrel) 定制，遵循 **GPL-3.0**。
- 输入法标识沿用 `im.rime.inputmethod.Squirrel`。

---

**TriFecta** —— 三色三选，一按即中。
