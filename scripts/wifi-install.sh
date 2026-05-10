#!/usr/bin/env bash
# 同 WiFi 下打包 + 装机到手机（不用数据线）。
#
# 前置一次性配对：
#   1. 手机：设置 → 开发者选项 → 无线调试 → 开启
#   2. 手机：点「使用配对码配对设备」，记下显示的 IP:port + 配对码（6 位）
#   3. 电脑：adb pair <IP>:<配对port>  → 提示后输入配对码
#   4. 配对完成后，回到无线调试主页，记下「IP 地址和端口」（这是连接端口，不是配对端口）
#
# 用法：
#   ./scripts/wifi-install.sh <IP>:<port>          # 用上次的 build 装
#   ./scripts/wifi-install.sh <IP>:<port> --build  # 先打包再装
#   ./scripts/wifi-install.sh --reuse              # 用 ~/.gooddad-wifi-target 里上次的目标
#
# 例：
#   ./scripts/wifi-install.sh 192.168.1.100:43209 --build

set -euo pipefail

CONFIG_FILE="$HOME/.gooddad-wifi-target"
BUILD=0
TARGET=""

for arg in "$@"; do
  case "$arg" in
    --build) BUILD=1 ;;
    --reuse) TARGET="$(cat "$CONFIG_FILE" 2>/dev/null || true)" ;;
    *:*) TARGET="$arg" ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "用法: $0 <IP>:<port> [--build]"
  echo "  或: $0 --reuse"
  echo
  echo "上次目标: $(cat "$CONFIG_FILE" 2>/dev/null || echo '<无>')"
  exit 1
fi

echo "▶ 连接 $TARGET"
adb connect "$TARGET"

# 等设备 online
for i in 1 2 3 4 5; do
  if adb -s "$TARGET" get-state 2>/dev/null | grep -q device; then
    break
  fi
  echo "  等设备 online ($i/5)…"
  sleep 1
done

if ! adb -s "$TARGET" get-state 2>/dev/null | grep -q device; then
  echo "✗ 没连上 $TARGET。检查："
  echo "  - 手机和电脑是不是同一 WiFi"
  echo "  - 无线调试是否开启"
  echo "  - 是否做过 adb pair（一次性）"
  exit 1
fi

# 记下成功目标
echo "$TARGET" > "$CONFIG_FILE"

if [[ $BUILD -eq 1 ]]; then
  echo "▶ 打 debug APK"
  flutter build apk --debug
fi

APK="build/app/outputs/flutter-apk/app-debug.apk"
if [[ ! -f "$APK" ]]; then
  echo "✗ 没找到 $APK，加 --build 重新打"
  exit 1
fi

echo "▶ 装到 $TARGET"
adb -s "$TARGET" install -r "$APK"

echo "▶ 重启 app"
adb -s "$TARGET" shell am force-stop com.xdd.good.dad
adb -s "$TARGET" shell am start -n com.xdd.good.dad/.MainActivity

PID="$(adb -s "$TARGET" shell pidof com.xdd.good.dad)"
echo "✓ 完成 · pid=$PID · 抓日志：adb -s $TARGET logcat --pid=$PID -v time"
