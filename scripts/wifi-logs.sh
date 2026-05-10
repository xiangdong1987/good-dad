#!/usr/bin/env bash
# 自动重连的 wifi logcat：adb 进程意外死了就重连重试。
# 用法：./scripts/wifi-logs.sh [<IP:port>]
#   不带参数会用 ~/.gooddad-wifi-target

set -uo pipefail

TARGET="${1:-$(cat "$HOME/.gooddad-wifi-target" 2>/dev/null || true)}"
if [[ -z "$TARGET" ]]; then
  echo "用法: $0 <IP>:<port>"
  exit 1
fi

LOG_FILE="/tmp/good-dad-logs/app.log"
mkdir -p "$(dirname "$LOG_FILE")"
: > "$LOG_FILE"

while true; do
  # 确保连接还在
  if ! adb -s "$TARGET" get-state 2>/dev/null | grep -q device; then
    adb connect "$TARGET" >/dev/null 2>&1 || true
    sleep 1
    continue
  fi
  PID="$(adb -s "$TARGET" shell pidof com.xdd.good.dad 2>/dev/null | tr -d '\r')"
  if [[ -z "$PID" ]]; then
    sleep 2
    continue
  fi
  echo "[wifi-logs] tailing pid=$PID @ $(date '+%H:%M:%S')" >> "$LOG_FILE"
  adb -s "$TARGET" logcat --pid="$PID" -v time >> "$LOG_FILE" 2>&1
  echo "[wifi-logs] disconnected, retrying @ $(date '+%H:%M:%S')" >> "$LOG_FILE"
  sleep 1
done
