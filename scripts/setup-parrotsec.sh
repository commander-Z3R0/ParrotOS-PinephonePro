#!/bin/bash

# ==========================
# Helpers
# ==========================

check_sudo() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Error: This script requires sudo privileges. Please run it with sudo." >&2
        exit 1
    fi
}

handle_error() {
    echo "Error: $1" >&2
    exit 1
}

run() {
    echo "Executing: $2"
    eval "$1"
    if [ $? -ne 0 ]; then
        handle_error "Command failed: $2"
    fi
}

install_packages() {
    if [ $# -eq 0 ]; then
        handle_error "No packages specified for installation."
    fi
    run "apt install -y $*" "Installing packages: $*"
}

# ==========================
# Core setup
# ==========================

core() {
    local script_dir
    script_dir="$(dirname "$0")"

    local core_packages
    mapfile -t core_packages < "$script_dir/config/packages/core.txt"

    run "apt update" "Updating package lists"
    install_packages "${core_packages[@]}"

    # run "wget -qO- https://deb.parrotsec.org/parrot/misc/parrotsec.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/parrot-archive-keyring.gpg" "Adding GPG key"
    run "wget https://deb.parrot.sh/parrot/pool/main/p/parrot-archive-keyring/parrot-archive-keyring_2024.12_all.deb" "Unpacking parrot-archive-keyring (2024.12)"
    run "apt install ./parrot-archive-keyring_2024.12_all.deb -y" "Install new GPG key"

    run "cp $script_dir/config/system/etc/apt/sources.list /etc/apt/sources.list" "Copying sources.list"
    run "cp -r $script_dir/config/system/etc/apt/sources.list.d/* /etc/apt/sources.list.d" "Copying sources.list.d"
    run "cp $script_dir/config/system/etc/apt/listchanges.conf /etc/apt/listchanges.conf" "Copying listchanges.conf"
    run "apt update" "Updating package lists"
    run "cp $script_dir/config/system/etc/os-release /etc/os-release" "Copying os-release"
    run "apt update" "Updating package lists"
    run "apt upgrade -y" "Upgrading packages"

    if [ "$(uname -m)" == "aarch64" ]; then
        run "apt-mark hold broadcom-sta-dkms" "Blacklisting incompatible package broadcom-sta-dkms"
    fi

    run "apt install -y parrot-core" "Installing parrot-core"

    echo "[!] Core Edition packages installation completed successfully."
}

# ==========================
# Entry point
# ==========================
check_sudo
core
