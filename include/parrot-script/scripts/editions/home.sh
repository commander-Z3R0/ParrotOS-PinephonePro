#!/bin/bash

source scripts/install_packages.sh

home() {
    local home_packages
    mapfile -t home_packages < config/packages/home.txt

    install_packages "${home_packages[@]}"
    echo "[!] Home Edition packages installation completed successfully."
}
