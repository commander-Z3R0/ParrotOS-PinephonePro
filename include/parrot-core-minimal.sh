#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "[+] Blocking service startup"
cat << 'EOF' > /usr/sbin/policy-rc.d
#!/bin/sh
exit 101
EOF
chmod +x /usr/sbin/policy-rc.d

echo "[+] Installing Parrot keyring"
wget -q https://deb.parrot.sh/parrot/pool/main/p/parrot-archive-keyring/parrot-archive-keyring_2024.12_all.deb
apt-get install -y ./parrot-archive-keyring_2024.12_all.deb

echo "[+] Cleaning duplicate Mobian sources"
rm -f /etc/apt/sources.list.d/mobian.list || true

echo "[+] Adding Parrot repositories (echo)"
cat <<EOF > /etc/apt/sources.list.d/parrot.list
deb https://deb.parrot.sh/parrot echo main contrib non-free non-free-firmware
deb https://deb.parrot.sh/parrot echo-security main contrib non-free non-free-firmware
deb https://deb.parrot.sh/parrot echo-backports main contrib non-free non-free-firmware
EOF

echo "[+] Setting APT pinning (Mobian > Parrot)"

# Mobian manda
cat <<EOF > /etc/apt/preferences.d/00-mobian
Package: *
Pin: origin repo.mobian.org
Pin-Priority: 900
EOF

# Parrot solo tools
cat <<EOF > /etc/apt/preferences.d/10-parrot
Package: parrot-*
Pin: origin deb.parrot.sh
Pin-Priority: 650
EOF

# Bloquear GNOME desktop (clave para Phosh)
cat <<EOF > /etc/apt/preferences.d/99-block-gnome
Package: gnome-*
Pin: *
Pin-Priority: -1
EOF

echo "[+] Updating APT"
apt-get update

echo "[+] Holding sensitive packages"
apt-mark hold apparmor apparmor-profiles apparmor-profiles-extra || true

echo "[+] Installing Parrot tools (no recommends)"
apt-get install -y --no-install-recommends \
  -o Dpkg::Options::=--force-confdef \
  -o Dpkg::Options::=--force-confold \
  parrot-tools-reporting \
  parrot-tools-password \
  parrot-tools-wireless

echo "[+] Fixing dpkg"
dpkg --configure -a || true
apt-get -f install -y || true

echo "[+] Done"
