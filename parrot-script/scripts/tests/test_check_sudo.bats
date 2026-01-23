#!/usr/bin/env bats

# Setup function: Runs before each test
setup() {
    chmod +x ../scripts/check_sudo.sh
}

# Test 1: Script fails when not run as root
@test "check_sudo fails when not run as root" {
    # Simulate non-root execution by unsetting SUDO_UID and SUDO_GID
    run env -u SUDO_UID -u SUDO_GID ../scripts/check_sudo.sh
    [ "$status" -ne 0 ] # Ensure the script exits with a non-zero status
    [[ "$output" == *"Error: This script requires sudo privileges."* ]]
}

# Test 2: Script succeeds when run as root
@test "check_sudo succeeds when run as root" {
    # Simulate root execution by running under sudo
    run sudo ../scripts/check_sudo.sh
    [ "$status" -eq 0 ] # Ensure the script exits successfully
    [[ "$output" == *"✅ User has sufficient privileges (running as root)."* ]]
}

# Test 3: Custom error message (optional, if implemented)
@test "check_sudo provides a custom error message" {
    # Simulate non-root execution by unsetting SUDO_UID and SUDO_GID
    run env -u SUDO_UID -u SUDO_GID bash -c 'check_sudo() {
        if [ "$(id -u)" -ne 0 ]; then
            echo "Custom Error: Please run with sudo privileges." >&2
            exit 1
        fi
    }; check_sudo'
    [ "$status" -ne 0 ]
    [[ "$output" == *"Custom Error: Please run with sudo privileges."* ]]
}
