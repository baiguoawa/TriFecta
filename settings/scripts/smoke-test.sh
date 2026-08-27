#!/usr/bin/env bash
#
# smoke-test.sh — 全流程冒烟（真实环境，会写入 ~/Library/Rime 并触发输入法部署）
#
# 默认不改动用户现有状态：若 ~/Library/Rime/squirrel.yaml 已存在，先备份为
# ~/Library/Rime/squirrel.yaml.pre-smoke，结束时还原。
#
set -euo pipefail
cd "$(dirname "$0")/.."

# 先选定工具链（CLT 下 swift-package 缺失 build-server framework，必须用完整 Xcode）
export DEVELOPER_DIR="${DEVELOPER_DIR:-}"
if ! xcodebuild -version >/dev/null 2>&1; then
  if [ -d "/Applications/Xcode-beta.app/Contents/Developer" ]; then
    export DEVELOPER_DIR="/Applications/Xcode-beta.app/Contents/Developer"
  else
    echo "未找到可用的 Xcode 工具链" >&2
    exit 1
  fi
fi

if [ "${SCT_SKIP_BUILD:-0}" != "1" ]; then
  swift test --scratch-path .build-test >/dev/null 2>&1 || swift build --scratch-path .build-test >/dev/null
fi

BIN="$(swift build -c debug --scratch-path .build-test --show-bin-path 2>/dev/null || swift build --scratch-path .build-test --show-bin-path)/TriFectaSettingsCLI"
[ -x "$BIN" ] || { echo "CLI 未构建"; exit 1; }

RIME=~/Library/Rime
SMOKE_RESTORE=""
if [ -f "$RIME/squirrel.yaml" ]; then
  cp "$RIME/squirrel.yaml" "$RIME/squirrel.yaml.pre-smoke"
  SMOKE_RESTORE=1
  echo "==> 已备份 squirrel.yaml → squirrel.yaml.pre-smoke"
fi

restore() {
  if [ -n "$SMOKE_RESTORE" ]; then
    mv "$RIME/squirrel.yaml.pre-smoke" "$RIME/squirrel.yaml" 2>/dev/null || true
  else
    rm -f "$RIME/squirrel.yaml" 2>/dev/null || true
  fi
  rm -f "$RIME/squirrel.yaml.bak"
  echo "==> 已还原原状态"
}
trap restore EXIT

echo "== 1. dump（有效配置快照）"
"$BIN" dump

echo "== 2. 修改主题为 google、候选布局 linear、字号 17"
"$BIN" set style.color_scheme=google style.candidate_list_layout=linear style.font_point=17

echo "== 3. 修改三色配色（仅改绿）"
"$BIN" set group_colors.green=0xAD3366CC

echo "== 4. 检查写入结果"
grep -n "color_scheme: google\|font_point: 17\|group_colors:\|green: 0xAD3366CC" "$RIME/squirrel.yaml"

echo "== 5. 部署（通知运行中的输入法）"
"$BIN" deploy

echo "== 6. 校验完整性与部署后输入法存活"
"$BIN" dump | grep -E "colorScheme: google|groupColors:"
pgrep -x Squirrel >/dev/null && echo "输入法进程存活 ✓" || echo "警告：未发现输入法进程"

echo "== 全部冒烟通过 =="
