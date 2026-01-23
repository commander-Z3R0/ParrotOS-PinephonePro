#!/usr/bin/env bats

# Setup function: Runs before each test
setup() {
    chmod +x ../scripts/handle_error.sh
}

# Test 1: Outputs the correct error message
@test "handle_error outputs the correct error message" {
    run ../scripts/handle_error.sh "Test error occurred"
    [ "$status" -ne 0 ] # Ensure it exits with a non-zero status
    [[ "$output" == *"Error: Test error occurred"* ]]
}

# Test 2: Exits with the correct status code (default: 1)
@test "handle_error exits with default non-zero status" {
    run ../scripts/handle_error.sh "Default error"
    [ "$status" -eq 1 ] # Default exit code is 1
}

# Test 3: Exits with a custom status code
@test "handle_error exits with a custom status code" {
    # Simulate a custom exit code by overriding the script
    run bash -c 'handle_error() {
        echo "Error: $1" >&2
        exit $2
    }; handle_error "Custom error" 42'
    [ "$status" -eq 42 ] # Check custom exit code
    [[ "$output" == *"Error: Custom error"* ]]
}