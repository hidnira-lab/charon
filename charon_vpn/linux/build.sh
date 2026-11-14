#!/usr/bin/env bash
# Builds Charon VPN for Linux: fetches xray (pinned like v1), builds the
# charon-tunnel helper, then runs `flutter build linux --release`.
# Run from anywhere: charon_vpn/linux/build.sh
set -euo pipefail
cd "$(dirname "$0")"

XRAY_VERSION="v26.3.27"

mkdir -p bin

if [ ! -x bin/xray ]; then
  case "$(uname -m)" in
    x86_64)  arch="64" ;;
    aarch64) arch="arm64-v8a" ;;
    *) echo "unsupported CPU: $(uname -m)" >&2; exit 1 ;;
  esac
  tmp="$(mktemp -d)"
  curl -fL -o "$tmp/xray.zip" \
    "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-${arch}.zip"
  unzip -o -q "$tmp/xray.zip" xray -d bin
  chmod +x bin/xray
  rm -rf "$tmp"
fi

# Privileged helper that runs tun2proxy (see core/src/tunnel/helper.rs).
(cd ../.. && cargo build --release -p charon-core --bin charon-tunnel)
cp "${CARGO_TARGET_DIR:-../../target}/release/charon-tunnel" bin/charon-tunnel

cd ..
flutter build linux --release
echo
echo "Built. Now run: sudo charon_vpn/linux/install.sh   (from the repo root)"
