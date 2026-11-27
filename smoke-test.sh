#!/usr/bin/env bash
# QEMU TCG smoke test for a qcow2 cloud image (no KVM required).
# Usage: bash smoke-test.sh <image.qcow2> [timeout-seconds]
set -Eeuo pipefail

usage() {
  echo "Usage: bash $0 <image.qcow2> [timeout-seconds]"
  echo "Starts the image with QEMU TCG and checks serial output for cloud-init or login."
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage >&2
  exit 2
fi

IMAGE=$1
TIMEOUT=${2:-600}
if [[ ! -f "$IMAGE" || ! -r "$IMAGE" ]]; then
  echo "[!] 镜像不存在或不可读：$IMAGE" >&2
  exit 2
fi
if [[ ! "$TIMEOUT" =~ ^[1-9][0-9]*$ ]]; then
  echo "[!] 超时秒数必须是正整数：$TIMEOUT" >&2
  exit 2
fi
if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
  echo "[!] 缺少 qemu-system-x86_64（Debian/Ubuntu: apt install qemu-system-x86）" >&2
  exit 2
fi

CODE=""
VARS_SRC=""
for pair in \
  "/usr/share/OVMF/OVMF_CODE_4M.fd:/usr/share/OVMF/OVMF_VARS_4M.fd" \
  "/usr/share/OVMF/OVMF_CODE.fd:/usr/share/OVMF/OVMF_VARS.fd" \
  "/usr/share/ovmf/OVMF.fd:/usr/share/ovmf/OVMF_VARS.fd"; do
  code=${pair%%:*}
  vars=${pair#*:}
  if [[ -f "$code" && -f "$vars" ]]; then
    CODE=$code
    VARS_SRC=$vars
    break
  fi
done
if [[ -z "$CODE" ]]; then
  echo "[!] 未找到成对的 OVMF CODE/VARS 固件（Debian/Ubuntu: apt install ovmf）" >&2
  exit 2
fi

WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/qcow2-smoke.XXXXXX")
SERIAL_LOG="$WORK_DIR/serial.log"
VARS="$WORK_DIR/OVMF_VARS.fd"
QPID=""
PASSED=0
cleanup() {
  if [[ -n "$QPID" ]]; then
    kill "$QPID" 2>/dev/null || true
    wait "$QPID" 2>/dev/null || true
  fi
  if [[ "$PASSED" -eq 1 ]]; then
    rm -rf "$WORK_DIR"
  else
    echo "日志保留在：$SERIAL_LOG" >&2
  fi
}
trap cleanup EXIT
cp "$VARS_SRC" "$VARS"
: > "$SERIAL_LOG"

echo "镜像：$IMAGE"
echo "OVMF：$CODE"
echo "启动 QEMU TCG，最多等待 ${TIMEOUT}s"
qemu-system-x86_64 \
  -accel tcg -cpu max -smp 2 -m 2048 \
  -drive "if=pflash,format=raw,readonly=on,file=$CODE" \
  -drive "if=pflash,format=raw,file=$VARS" \
  -drive "file=$IMAGE,if=virtio,format=qcow2" \
  -netdev user,id=n0 -device virtio-net-pci,netdev=n0 \
  -display none -serial "file:$SERIAL_LOG" -no-reboot \
  >/dev/null 2>&1 &
QPID=$!

FOUND=0
for ((elapsed=0; elapsed<TIMEOUT; elapsed++)); do
  if grep -qiE 'Cloud-init v|cloud-init.*finished|login:' "$SERIAL_LOG" 2>/dev/null; then
    FOUND=1
    break
  fi
  kill -0 "$QPID" 2>/dev/null || break
  sleep 1
done

echo "--- 串口尾部 ---"
tail -n 40 "$SERIAL_LOG" || true
if [[ "$FOUND" -eq 1 ]]; then
  echo "[+] 冒烟通过：串口检测到 cloud-init 或 login"
  PASSED=1
  exit 0
fi

echo "[!] 冒烟失败：${TIMEOUT}s 内未检测到 cloud-init 或 login" >&2
exit 1
