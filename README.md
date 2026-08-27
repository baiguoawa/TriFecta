# TriFecta

<p align="center">
  <img src="./icon.png" width="120" alt="TriFecta icon" />
</p>

> **三色三选，一按即中。** —— 用颜色让你从容三选一的 macOS 中文输入法。

**🌏 Language:** 中文 ｜ [**English**](./README.en.md)

TriFecta 是一款基于 **Rime（Squirrel）** 的 macOS 中文输入法。它解决了原生输入法“**候选字编号靠后（7/8/9）要凑近看编号、还得伸手去够数字键**”的痛点——用**三色分组 + `～` 键精准选字**，让你的手指始终不离 `～ 1 2 3` 四个键，**凭颜色即可定位候选字**。

TriFecta 还提供**三种输入模式**（触发 / 常驻 / 滑块）、**图形化设置面板**，并可打包为**已签名 + 公证的 `.pkg`**（安装后自动完成输入源注册）。

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

### 核心：三色分组 + 精准选字

- **三色分组**：候选字均分为 3 组，红 / 黄 / 绿，高对比度“彩色液态玻璃”观感。
- **`～` 三态切换**：
  1. 蓝色 → 按 `～` → 开启三色；
  2. 已选某组 → 按 `～` → 回到“选组”那一步（不退出三色，便于改选）；
  3. 在“选组”状态 → 按 `～` → 退出三色回到蓝色。
- **组内精准选字**：选中某组后，组内 3 个候选按位置红/黄/绿着色，**其它组完全褪去**（更强的对比聚焦）。
- **选后自动回蓝**：完成一次“精准上字”后自动回到蓝色单点；剩余字若高频在前 1-3 位可直接选，否则再按 `～`。

### 三种输入模式

| 模式 | 行为 |
|---|---|
| **触发模式** | 按触发键（默认 `～`）打开三色选字；`1/2/3` 选组 → 再 `1/2/3` 选字 |
| **常驻模式** | 敲入拼音后**无需触发键**，自动打开三色一级菜单；前 3 个候选可用 `1` / `～` / `Tab` 直接选，`2/3` 进入第 2/3 组 |
| **滑块模式** | 常驻显示某一组的二级菜单（三色显示在 1/2/3 候选下）；按触发键**向后滑动一组**（1-3 → 4-6 → 7-9 → 翻页），滑动到哪组按 `1/2/3` 即选该组对应候选；还提供**回退键**（默认 `Tab`）返回上一组 |

> 三模式通过**设置面板的滑条**一键切换（单滑块拖到某档即激活该模式，其余关闭）。

### 中英混输 / 输入体验

- **中文模式 `Shift+字母` 快速出大写**：按住 `Shift` 敲字母**直接输出对应大写字母**，不进入拼音候选、不产生“非法拼音无候选框”，且不影响后续中文输入（临时屏蔽 `Shift` 的中英切换一小段）。
- **单 / 双引号互补**：中文下单引号 / 双引号**左右交替**（按一次出左引号，再按出右引号，再按回左引号），不再永远只有左半边。

### 图形化设置面板（TriFectaSettings）

微信输入法风格的设置窗口：**左侧导航 + 右侧面板**，鼠标点按调参，替代手改 `~/Library/Rime/*.yaml`。保存后通过分布式通知让输入法**立即重新部署**（配置即时生效）。手改 YAML 的方式完全保留。

设置面板包含 6 页：
- **输入**：简繁、开关等输入相关选项
- **外观**：输入法候选框外观（字体、布局、透明度、颜色等）
- **界面**：设置窗口自身外观
- **快捷键**：三模式切换滑条 + 各模式的触发键 / 回退键 / 选词键自定义
- **同步**：用户数据同步
- **关于**：版本与致谢

### 原生观感与动画

- **原生观感**：横向胶囊候选框、两端半圆、玻璃透明底、蓝色胶囊高亮、圆角/间距贴近系统输入法。
- **非线性动画**：状态切换带干净的 `easeInEaseOut` 过渡（不会每次打字都闪）。

---

## 安装

### 方式 A：`.pkg`（推荐，一步到位）

> **推荐用 `.pkg`** —— 它是**已签名 + 公证**的安装包，安装时**自动完成输入源注册 / Rime 方案部署 / 启用选中**，无需手动添加。双击即可安装。

1. 下载并打开 `TriFecta.pkg`；
2. 按安装向导输入管理员密码；
3. 安装完成后（postinstall 自动执行 `--register-input-source` / `--build` / `--enable-input-source` / `--select-input-source`）：
   - **系统设置 → 键盘 → 输入法** 中 **Squirrel（鼠鬚管）已自动出现**；
   - 用 **⌃Control + 空格** 切换到 Squirrel 即可打字。

> 若安装后系统输入法列表未刷新，**注销重登**一次即可（HIToolbox 缓存刷新）。

### 方式 B：`.dmg`（备选）

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

### 方式 C：源码构建（见下文“从源码构建”）

---

## 卸载

在**终端**运行以下命令即可**干净移除**（禁用输入源 → 杀进程 → 删除 App → 验证）：

```bash
sudo bash -c '
echo ">>> 1. 禁用输入源"
"/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --disable-input-source 2>/dev/null || echo "  (跳过:无可禁用)"
echo ">>> 2. 杀掉 Squirrel 进程"
pkill -9 -f "Squirrel" 2>/dev/null || echo "  (无进程)"
sleep 1
echo ">>> 3. 删除已装 App"
rm -rf "/Library/Input Methods/Squirrel.app"
echo ">>> 4. 验证"
if [ -d "/Library/Input Methods/Squirrel.app" ]; then echo "  ✘ 仍存在"; else echo "  ✔ 已删除"; fi
echo ">>> 完成"
'
```

> 卸载后如需彻底清空使用习惯/词库，可再执行 `rm -rf ~/Library/Rime`。

---

## 使用说明

| 操作 | 效果 |
|---|---|
| 输入拼音 | 蓝色胶囊高亮（原生观感） |
| 按 `～`（数字1左边） | 开启三色分组：1-3红 / 4-6黄 / 7-9绿 |
| 按 `1/2/3` | 选中一组：该组 3 个按位置红/黄/绿，**其它组褪去** |
| 再按 `1/2/3` | 选中组内该字（精准上屏），并自动回蓝色 |
| `～`（已选组时） | 回到“选组”那一步 |
| `～`（选组状态） | 退出三色，回到蓝色 |
| `Shift`（按住）+字母 | 直接输出对应**大写**字母（不进拼音候选，不影响后续中文） |
| 单 / 双引号 | 左引号 ↔ 右引号 左右交替 |

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
git clone --recursive https://github.com/thesadbee/TriFecta.git
cd TriFecta

# 2. 用预编译 librime + Sparkle 快速就绪（跳过编译 librime/Boost）
bash ./action-install.sh

# 3. 构建
export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer   # 若用 beta Xcode
make release
```

> 若在受限网络下 `git clone`/子模块/`plum` 拉取失败，可用 `codeload`/`raw.githubusercontent` 逐个以 tarball 下载替换（工程在多种环境下均可构建）。

产物：`build/Build/Products/Release/Squirrel.app`（本工程仍沿用输入法标识 `im.rime.inputmethod.Squirrel`）。

### 打包为 `.pkg`

源码构建后可打包为已签名 + 公证的 `.pkg`（含自动注册 / 部署脚本 `scripts/postinstall`）：

```bash
# 用 Developer ID Application 签名 app + Developer ID Installer 签名 pkg + 公证
# 详见 package/ 相关脚本与 Makefile package 目标
make package
```

---

## 配置

方案与外观可通过 Rime/主题配置或**设置面板**调整（`~/Library/Rime` 与工程 `data/`）：
- **三色**：`sources/SquirrelView.swift` 中 `groupColors`（红/黄/绿 RGB + alpha）。
- **分组规则**：候选数 N 均分为 3 组（`groupSize = ceil(N/3)`）。
- **三模式 / 触发键 / 回退键**：设置面板「快捷键」页，或 `~/Library/Rime/squirrel.yaml` 的 `group_colors/*`。
- **胶囊外观**：`data/squirrel.yaml`（`candidate_list_layout: linear`、`font_point`、`line_spacing`、`translucency` 等）。

---

## 分发

- **不上架 App Store**，通过 **GitHub Releases** 分发已签名 + 公证的 **`.pkg`**（或 `.dmg`）。
- 工程用 **Apple Developer ID Application** 签名 `.app` + **Developer ID Installer** 签名 `.pkg`，并做 **notarization**（公证）与 `stapler` 装订。
- `.pkg` 安装时通过 `scripts/postinstall` **自动注册输入源 / 部署 Rime 方案数据 / 启用并选中**，用户无需手动添加。

---

## Contributors / 致谢

特别感谢以下开源项目与作者（TriFecta 基于它们构建）：

- **Rime 输入法引擎** —— [rime/librime](https://github.com/rime/librime)（[佛振](https://github.com/lotem) 等）
- **macOS 输入法前端 Squirrel** —— [rime/squirrel](https://github.com/rime/squirrel)（[Leo Liu](https://github.com/Lekensteyn) 等）
- **Rime 方案管理 plum** —— [rime/plum](https://github.com/rime/plum)
- **Sparkle** 自动更新框架 —— [sparkle-project/Sparkle](https://github.com/sparkle-project/Sparkle)
- **Rime 语音方案数据** —— rime-prelude / rime-luna-pinyin / rime-essay / rime-bopomofo / rime-cangjie / rime-stroke / rime-terra-pinyin / rime-quick / rime-double-pinyin 等

**TriFecta 的三色分组 + `～` 精准选字 + 三模式 + 设置面板等功能**由 **DeepSeek Harness**（AI 编程代理）协助设计与实现。

## 许可

- 基于 [Rime](https://github.com/rime/librime) / [Squirrel](https://github.com/rime/squirrel) 定制，遵循 **GPL-3.0**。
- 输入法标识沿用 `im.rime.inputmethod.Squirrel`。

---

**TriFecta** —— 三色三选，一按即中。
