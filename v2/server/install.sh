#!/usr/bin/env bash
# Charon server installer.
#
# Sets up Xray with VLESS + Reality on a fresh Ubuntu LTS server and prints the
# vless:// link (and a QR code) to paste into Charon. Read it before you run it:
# it runs as root and changes your server.
#
# What it does, in order:
#   1. installs curl, openssl and qrencode, and applies pending updates
#   2. installs Xray with the official installer (pinned below, checked by SHA-256)
#   3. creates a user id, a Reality key pair and a short id on this server
#   4. picks a cover site for Reality (you type one, or it tries a short list)
#   5. writes /usr/local/etc/xray/config.json and checks it with Xray
#   6. starts Xray, opens port 443 in ufw if ufw is on
#   7. prints the link and saves it to /root/charon-link.txt
#
# Usage:  bash install.sh [--reinstall] [--cover-site DOMAIN] [--address IP_OR_NAME]
#   --reinstall         replace an existing setup (old links stop working; the old
#                       config is kept as a .bak file)
#   --cover-site DOMAIN use this cover site instead of asking
#   --address ADDRESS   the address to put in the link, when the server cannot
#                       see its own public IP
#
# Step by step guide (also the manual way, if this script stops):
#   https://charon.hidnira.studio/en/start/installing-xray/
#
# Licence: GPL 3.0, the same as the rest of Charon.

set -euo pipefail

XRAY_VERSION="v26.10.31"
INSTALLER_COMMIT="9d3ad49a3294d4c1d042f1fb6a16360b4d1befd1"
INSTALLER_SHA256="91fd40e9b6f222b5819f3ba91f0bfb4bb8c4d425a7c0ffe9d8b155d25ed79609"
INSTALLER_URL="https://raw.githubusercontent.com/XTLS/Xray-install/${INSTALLER_COMMIT}/install-release.sh"
CONFIG="/usr/local/etc/xray/config.json"
LINK_FILE="/root/charon-link.txt"
PORT=443
FALLBACK_SITES=(www.microsoft.com www.apple.com www.amazon.com dl.google.com)
GUIDE="https://charon.hidnira.studio/en/start/installing-xray/"

step=0
total=7

say() { printf '\n[%s/%s] %s\n' "$step" "$total" "$1"; }
next() { step=$((step + 1)); say "$1"; }
die() {
  if [[ $step -eq 0 ]]; then
    printf '\nSTOPPED before changing anything: %s\n' "$1" >&2
  else
    printf '\nSTOPPED at step %s: %s\n' "$step" "$1" >&2
    printf 'Nothing after this step was changed. The manual way in the guide picks up from here:\n  %s\n' "$GUIDE" >&2
  fi
  exit 1
}

reinstall=0
cover_site=""
address=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --reinstall) reinstall=1 ;;
    --cover-site|--address)
      [[ $# -ge 2 && -n "$2" ]] || die "$1 needs a value, for example: $1 example.com"
      if [[ "$1" == --cover-site ]]; then cover_site="$2"; else address="$2"; fi
      shift ;;
    -h|--help) sed -n '2,27p' "$0"; exit 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

# --- checks before touching anything ---------------------------------------

[[ ${EUID} -eq 0 ]] || die "run this as root (log in as root, or put sudo in front)"
# shellcheck source=/dev/null
[[ -r /etc/os-release ]] && . /etc/os-release
[[ "${ID:-}" == "ubuntu" ]] || die "this script is made for Ubuntu LTS; this server runs ${PRETTY_NAME:-an unknown system}"
command -v systemctl >/dev/null || die "systemd is missing; this does not look like a normal Ubuntu server"

if [[ -s "$CONFIG" && "$(tr -d '[:space:]' <"$CONFIG")" != "{}" && $reinstall -eq 0 ]]; then
  die "Xray is already set up here. Your link is in ${LINK_FILE} (show it with: cat ${LINK_FILE}).
To make a new setup anyway, run again with --reinstall. Every device using the old link will need the new one."
fi

if ss -ltnpH "sport = :${PORT}" 2>/dev/null | grep -v '"xray"' | grep -q .; then
  die "another program already listens on port ${PORT}: $(ss -ltnpH "sport = :${PORT}" | head -1)"
fi

valid_name() { [[ "$1" =~ ^[A-Za-z0-9.-]+$ && "$1" == *.* && "$1" != *..* ]]; }

# TLS 1.3 and HTTP/2 are what Reality needs from a cover site.
site_ok() {
  [[ "$(curl --tlsv1.3 --http2 -sS -o /dev/null -w '%{http_version}' --max-time 10 "https://$1/" 2>/dev/null)" == "2" ]]
}

# Reads an answer from the terminal; with no terminal (a pipe, a provider's run script) it answers "".
ask() {
  local reply=""
  if { : </dev/tty; } 2>/dev/null; then read -r -p "$1" reply </dev/tty || true; fi
  printf '%s' "$reply"
}

# --- 1. packages -------------------------------------------------------------

next "Installing tools and pending updates (this can take a few minutes)"
export DEBIAN_FRONTEND=noninteractive
apt-get update -q || die "apt-get update failed; check the server's internet connection"
apt-get -y -q -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold upgrade \
  || die "installing updates failed"
apt-get install -y -q curl openssl qrencode ca-certificates || die "installing curl, openssl and qrencode failed"

# --- 2. Xray -------------------------------------------------------------------

next "Installing Xray ${XRAY_VERSION} with the official installer"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "$INSTALLER_URL" -o "$tmp/install-release.sh" || die "could not download the Xray installer from GitHub"
echo "${INSTALLER_SHA256}  $tmp/install-release.sh" | sha256sum -c --quiet - \
  || die "the Xray installer did not match its expected SHA-256, so it was not run"
bash "$tmp/install-release.sh" install --version "$XRAY_VERSION" || die "the Xray installer failed"
[[ "$(xray version)" == "Xray ${XRAY_VERSION#v} "* ]] || die "Xray ${XRAY_VERSION} is not the version now installed"

# --- 3. keys -------------------------------------------------------------------

next "Creating your user id, keys and short id"
uuid="$(xray uuid)"
keys="$(xray x25519)"
private_key="$(awk -F': ' '/^PrivateKey:/ {print $2}' <<<"$keys")"
public_key="$(awk -F': ' '/^Password \(PublicKey\):/ {print $2}' <<<"$keys")"
short_id="$(openssl rand -hex 8)"
[[ -n "$uuid" && -n "$private_key" && -n "$public_key" && -n "$short_id" ]] \
  || die "could not read the keys Xray created"

# --- 4. cover site ---------------------------------------------------------------

next "Choosing a cover site"
if [[ -n "$cover_site" ]]; then
  valid_name "$cover_site" || die "\"$cover_site\" is not a domain name"
  site_ok "$cover_site" || die "$cover_site does not answer with TLS 1.3 and HTTP/2 from this server"
else
  echo "Reality makes your connection look like a visit to a real website."
  echo "Best: a site hosted near this server, not a famous brand. Type it without https://"
  echo "Or press Enter and the script tries a few large sites (they work, but are easier to spot)."
  while [[ -z "$cover_site" ]]; do
    typed="$(ask 'Cover site: ')"
    typed="${typed#https://}"; typed="${typed#http://}"; typed="${typed%%/*}"
    if [[ -z "$typed" ]]; then
      for s in "${FALLBACK_SITES[@]}"; do
        echo "  trying $s ..."
        if site_ok "$s"; then cover_site="$s"; break; fi
      done
      [[ -n "$cover_site" ]] || die "none of the fallback sites answered with TLS 1.3 and HTTP/2"
    elif ! valid_name "$typed"; then
      echo "  \"$typed\" is not a domain name, try again"
    elif site_ok "$typed"; then
      cover_site="$typed"
    else
      echo "  $typed does not answer with TLS 1.3 and HTTP/2 from this server, try another (or press Enter)"
    fi
  done
fi
echo "Cover site: $cover_site"

# --- 5. config -------------------------------------------------------------------

next "Writing and checking the Xray settings"
if [[ -z "$address" ]]; then
  address="$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for (i = 1; i < NF; i++) if ($i == "src") print $(i + 1)}')"
  if [[ -z "$address" || "$address" =~ ^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.|100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\.) ]]; then
    echo "This server cannot see its own public IP (it sees ${address:-none})."
    address="$(ask "Type the server's public IP from your provider's page: ")"
    [[ -n "$address" ]] || die "no address given"
  fi
fi

if [[ -s "$CONFIG" && "$(tr -d '[:space:]' <"$CONFIG")" != "{}" ]]; then
  backup="${CONFIG}.bak-$(date +%Y%m%d-%H%M%S)"
  cp -p "$CONFIG" "$backup"
  echo "Old settings kept in $backup"
fi

cat >"$tmp/config.json" <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [{
    "port": ${PORT},
    "protocol": "vless",
    "settings": {
      "clients": [{ "id": "${uuid}", "flow": "xtls-rprx-vision" }],
      "decryption": "none"
    },
    "streamSettings": {
      "network": "tcp",
      "security": "reality",
      "realitySettings": {
        "show": false,
        "dest": "${cover_site}:443",
        "xver": 0,
        "serverNames": ["${cover_site}"],
        "privateKey": "${private_key}",
        "shortIds": ["${short_id}"]
      }
    },
    "sniffing": { "enabled": true, "destOverride": ["http", "tls", "quic"] }
  }],
  "outbounds": [
    { "protocol": "freedom", "tag": "direct", "settings": { "domainStrategy": "UseIPv4" } },
    { "protocol": "blackhole", "tag": "block" }
  ],
  "routing": {
    "rules": [{ "type": "field", "ip": ["geoip:private"], "outboundTag": "block" }]
  }
}
EOF
# The official installer runs Xray as the user "xray" and gives the config to root:xray, mode 640.
install -m 640 -o root -g xray "$tmp/config.json" "$CONFIG"
xray run -test -config "$CONFIG" >/dev/null || die "Xray rejected the new settings"

# --- 6. start ----------------------------------------------------------------------

next "Starting Xray"
systemctl enable xray >/dev/null 2>&1
systemctl restart xray
sleep 2
systemctl is-active --quiet xray || die "Xray did not stay running; see: journalctl -u xray -n 30"
if command -v ufw >/dev/null && ufw status | grep -q '^Status: active'; then
  ufw allow "${PORT}/tcp" >/dev/null
  echo "Opened port ${PORT} in ufw."
fi

# --- 7. link -----------------------------------------------------------------------

next "Your link"
host="$address"
[[ "$host" == *:* ]] && host="[$host]"
link="vless://${uuid}@${host}:${PORT}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${cover_site}&fp=chrome&pbk=${public_key}&sid=${short_id}&type=tcp#my-server"
(umask 077 && printf '%s\n' "$link" >"$LINK_FILE")

echo
echo "$link"
echo
qrencode -t ANSIUTF8 "$link"
cat <<EOF

Done. Paste the link above into Charon, or scan the QR code with your phone.
  * Treat it like a password: anyone with it can use this server.
  * It is saved in ${LINK_FILE}; show it again with: cat ${LINK_FILE}
  * If your provider has its own firewall (security group), allow TCP port ${PORT} there too.
EOF
