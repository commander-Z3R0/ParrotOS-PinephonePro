# Debian Conversion Script

## Table of Contents

- [Overview](#overview)
- [How to Use](#how-to-use)
- [Menu Options](#menu-options)
- [Available Editions](#available-editions)
- [Compatibility](#compatibility)
- [Contributions](#contributions)
- [Post installation](#post-installation)
  - [bashrc](#bashrc)
  - [profile](#profile)
  - [/etc/skel](#etc-skel)

## Overview

**Debian Conversion Script** is an installer script for ParrotOS. This project stands as a replacement for the [alternate-install](https://github.com/ParrotSec/alternate-install) which is no longer maintained. It is updated to the latest Parrot release.

## How to Use

Using this script is quite simple. Follow the steps below:

1. **Open a terminal window**
2. **Clone this repository**

   ```bash
   git clone https://gitlab.com/parrotsec/project/debian-conversion-script.git
   cd debian-conversion-script
   sudo chmod +x ./install.sh
   sudo ./install.sh
   ```

## Menu Options

Upon running the script, a menu will appear:

    ========== ParrotOS Editions Installer ==========
    1) Install Core Edition
    2) Install Home Edition
    3) Install Security Edition
    4) Install Hack The Box Edition
    5) Exit
    =================================================

Choose the desired option by typing the corresponding number (e.g., type 1 to install the Core Edition packages).

## Available Editions

- **Core Edition**: Installs the minimal base system without any graphical interface or additional tools. Ideal for advanced users who want to customize their installation.

- **Home Edition**: Installs a user-friendly environment with a complete suite of daily use applications, including office software, multimedia tools, and general utilities.

- **Security Edition**: Installs a comprehensive suite of security tools and utilities for penetration testing, forensics, and vulnerability assessment.

- **Hack The Box Edition**: Installs tools and configurations optimized for use with Hack The Box, a popular online platform for practicing penetration testing and ethical hacking.

## Compatibility

This script has been tested on Debian 12, including virtual machines and Docker containers.

## Contributions

Contributions are welcome! If you encounter any issues or have suggestions for improvements, please open an issue or submit a pull request.

## Post installation

Some configuration files that may contains customization won't be converted by this script and (if wanted) need to be copyied manually.

### bashrc

The parrot version for the default bashrc can be found in **/usr/share/base-files/dot.bashrc**. This file can be copied to the following locations:
- /etc/bash.bashrc
- /etc/skel/.bashrc
- /root/.bashrc

### profile

The parrot version for the default profile can be found in **/usr/share/base-files/dot.profile**. This file can be copied to the following locations:
- /etc/profile
- /etc/skel/.profile
- /root/.profile

### /etc/skel

The configuration files in **/etc/skel** are used to populate every user home
directory upon the user creation. Since the conversion script relies on a pre-installed distribution all the already created users won't have parrot default configurations installed in their home directories. 
To reach a full parrot customization the content of /etc/skel should be copied
on every user home directory, but paying attention to avoid override customization that the user may have done on those files.

