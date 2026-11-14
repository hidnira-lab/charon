#!/usr/bin/env bash
# Installs the built bundle to /opt/charon-vpn and gives ONLY the
# charon-tunnel helper the capabilities it needs to create the TUN device,
# set routes and rewrite /etc/resolv.conf. The GUI stays unprivileged.
#
#   sudo charon_vpn/linux/install.sh              install / update
#   sudo charon_vpn/linux/install.sh --uninstall  remove
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "run with sudo" >&2
  exit 1
fi

DEST=/opt/charon-vpn
here="$(cd "$(dirname "$0")" && pwd)"

if [ "${1:-}" = "--uninstall" ]; then
  rm -rf "$DEST" /usr/local/bin/charon-vpn /usr/share/applications/charon-vpn.desktop
  echo "Removed. (Autostart entry, if enabled in the app: ~/.config/autostart/charon-vpn.desktop)"
  exit 0
fi

bundle="$(ls -d "$here"/../build/linux/*/release/bundle 2>/dev/null | head -n1 || true)"
if [ -z "$bundle" ] || [ ! -x "$bundle/charon-tunnel" ]; then
  echo "No built bundle (or charon-tunnel missing). Run charon_vpn/linux/build.sh first." >&2
  exit 1
fi

rm -rf "$DEST"
mkdir -p "$DEST"
cp -a "$bundle/." "$DEST/"
cp "$here/../assets/icon/icon_source.png" "$DEST/charon-vpn.png"
chown -R root:root "$DEST"

# Only the helper gets privileges.
setcap cap_net_admin,cap_net_raw,cap_dac_override+ep "$DEST/charon-tunnel"

ln -sf "$DEST/charon_vpn" /usr/local/bin/charon-vpn
cat > /usr/share/applications/charon-vpn.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Charon VPN
Exec=$DEST/charon_vpn
Icon=$DEST/charon-vpn.png
Terminal=false
Categories=Network;
EOF

echo "Installed. Launch 'Charon VPN' from the app menu or run: charon-vpn"
getcap "$DEST/charon-tunnel"
