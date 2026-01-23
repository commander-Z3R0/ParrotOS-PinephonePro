#!/usr/bin/env bats

# Setup function: Runs before each test
setup() {
    chmod +x ../scripts/install_packages.sh ../scripts/handle_error.sh
}

# Mock handle_error to prevent test interruptions
mock_handle_error() {
    echo "Mock handle_error called with: $1"
}
export -f mock_handle_error
alias handle_error=mock_handle_error

# Mock run function to simulate package installation
mock_run() {
    if [[ "$1" == *"nonexistentpackage"* ]]; then
        return 1 # Simulate failure for nonexistent packages
    fi
    echo "Mock run: $2"
}
export -f mock_run
alias run=mock_run

# Test 1: No packages provided
@test "install_packages fails with no arguments" {
    run ../scripts/install_packages.sh
    [ "$status" -ne 0 ] # Ensure it exits with a non-zero status
    [[ "$output" == *"Mock handle_error called with: No packages specified for installation."* ]]
}

# Test 2: Successful package installation
@test "install_packages installs specified packages" {
    run ../scripts/install_packages.sh curl wget
    [ "$status" -eq 0 ] # Ensure successful execution
    [[ "$output" == *"Mock run: Installing packages: curl wget"* ]]
}

# Test 3: Handles installation failure for nonexistent packages
@test "install_packages handles failed installation gracefully" {
    run ../scripts/install_packages.sh nonexistentpackage
    [ "$status" -ne 0 ] # Ensure it exits with a failure status
    [[ "$output" == *"Mock handle_error called with: Command failed: Installing packages: nonexistentpackage"* ]]
}
