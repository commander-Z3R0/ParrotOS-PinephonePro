#!/bin/bash

source scripts/scripts/run.sh
source scripts/scripts/install_packages.sh


core() {
    local core_packages
    mapfile -t core_packages < config/packages/core.txt

    run "apt update" "Updating package lists"
    install_packages "${core_packages[@]}"
    # run "wget -qO- https://deb.parrotsec.org/parrot/misc/parrotsec.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/parrot-archive-keyring.gpg" "Adding GPG key"
    run "wget https://deb.parrot.sh/parrot/pool/main/p/parrot-archive-keyring/parrot-archive-keyring_2024.12_all.deb" "Unpacking parrot-archive-keyring (2024.12) over (2021.7+parrot2)"
    run "apt install ./parrot-archive-keyring_2024.12_all.deb" "Install new GPG key"
    run "cp config/system/etc/apt/sources.list /etc/apt/sources.list" "Copying sources.list"
    run "cp -r config/system/etc/apt/sources.list.d/* /etc/apt/sources.list.d" "Copying sources.list.d"
    run "cp config/system/etc/apt/listchanges.conf /etc/apt/listchanges.conf" "Copying listchanges.conf"
    run "apt update" "Updating package lists"
    run "cp config/system/etc/os-release /etc/os-release" "Copying os-release"
    run "apt update" "Updating package lists"
    run "apt upgrade -y" "Upgrading packages"
    if [ $(uname -m) == "aarch64" ]; then
        run "apt-mark hold broadcom-sta-dkms" "Blacklisting incompatible package broadcom-sta-dkms"
    fi
    run "apt install -y parrot-core" "Installing parrot-core"

    echo "[!] Core Edition packages installation completed successfully."
}
