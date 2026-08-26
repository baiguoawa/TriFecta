#!/usr/bin/env bash
#
# install.sh — 把设置 app 安装进输入法包（WeType 同款"包内嵌设置 app"布局）
#
# 用法：
#   bash scripts/install.sh                # 构建 + 安装（含 sudo 提示）
#   IME=/path/to/Squirrel.app bash scripts/install.sh   # 自定义输入法包
#   SCT_SKIP_BUILD=1 bash scripts/install.sh            # 跳过构建，直接装 dist/
#
# 安装位置：$IME/Contents/MacOS/TriFectaSettings.app（不影响输入法本体签名）
# 卸载：   sudo rm -rf "$IME/Contents/MacOS/TriFectaSettings.app" （用户配置保留）
#
set -euo pipefail
cd "$(dirname "$0")/.."

IME="${IME:-/Library/Input Methods/Squirrel.app}"
[ -d "$IME/Contents" ] || { echo "找不到输入法包：$IME（可用 IME=... 指定）"; exit 1; }

if [ "${SCT_SKIP_BUILD:-0}" != "1" ]; then
  bash scripts/build-app.sh release
fi

SRC="$PWD/dist/TriFectaSettings.app"
[ -d "$SRC" ] || { echo "未找到 $SRC，先运行 bash scripts/build-app.sh"; exit 1; }

DEST="$IME/Contents/MacOS/TriFectaSettings.app"

echo "==> 安装到 $DEST"
sudo rm -rf "$DEST"
sudo mkdir -p "$IME/Contents/MacOS"
sudo cp -R "$SRC" "$DEST"
sudo chown -R root:wheel "$DEST"
sudo xattr -cr "$DEST" 2>/dev/null || true
sudo codesign --force -s - "$DEST"

echo "==> 停止旧设置进程（如有）"
/usr/bin/killall TriFectaSettings 2>/dev/null || true

echo "==> 完成"
echo "输入法菜单「设置...」现在会打开：$DEST"
echo "（无需重启输入法；菜单每次点击都会解析该路径）"
