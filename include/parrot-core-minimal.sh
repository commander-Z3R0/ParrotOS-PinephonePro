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

echo "[+] Adding repositories"

# Parrot repositories (release 'echo')
cat <<EOF > /etc/apt/sources.list.d/parrot.list
deb https://deb.parrot.sh/parrot echo main contrib non-free non-free-firmware
deb https://deb.parrot.sh/parrot echo-security main contrib non-free non-free-firmware
deb https://deb.parrot.sh/parrot echo-backports main contrib non-free non-free-firmware
EOF

# Mobian repository (assume already in sources.list.d/mobian.list)
cat <<EOF > /etc/apt/sources.list.d/mobian.list
deb https://repo.mobian.org forky main
EOF

echo "[+] Setting APT pinning"
# Parrot: priority 700
cat <<EOF > /etc/apt/preferences.d/99-parrot
Package: *
Pin: origin deb.parrot.sh
Pin-Priority: 700
EOF

# Mobian: priority 600
cat <<EOF > /etc/apt/preferences.d/99-mobian
Package: *
Pin: origin repo.mobian.org
Pin-Priority: 600
EOF

echo "[+] Installing Parrot core"
apt-get update
apt-mark hold apparmor apparmor-profiles apparmor-profiles-extra || true
apt-get install -y parrot-core || true

echo "[+] Fixing dpkg"
dpkg --configure -a || true
apt-get -f install -y || true

echo "[+] Done"
