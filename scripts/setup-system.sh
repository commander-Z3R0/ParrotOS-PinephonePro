#!/bin/sh

# Setup hostname
echo "$1" > /etc/hostname

# Change plymouth default theme
plymouth-set-default-theme mobian

# systemd-firstboot requires user input, which isn't possible
# on mobile devices
systemctl mask systemd-firstboot.service
