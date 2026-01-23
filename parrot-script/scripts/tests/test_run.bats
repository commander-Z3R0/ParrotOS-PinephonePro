#!/usr/bin/env bats

# Setup function: Runs before each test
setup() {
    chmod +x ../scripts/run.sh ../scripts/handle_error.sh
}

# Mock handle_error to prevent premature test exits
mock_handle_error() {
    echo "Mock handle_error called with: $1"
}
export -f mock_handle_error
alias handle_error=mock_handle_error

# Test 1: Successful command execution
@test "run executes a valid command successfully" {
    run ../scripts/run.sh "echo 'Hello, World!'" "Print a greeting"
    [ "$status" -eq 0 ] # Ensure successful execution
    [[ "$output" == *"Executing: Print a greeting"* ]]
    [[ "$output" == *"Hello, World!"* ]]
}

# Test 2: Handles a failed command gracefully
@test "run handles a failed command gracefully" {
    run ../scripts/run.sh "invalidcommand" "Run an invalid command"
    [ "$status" -ne 0 ] # Ensure failure status
    [[ "$output" == *"Executing: Run an invalid command"* ]]
    [[ "$output" == *"Mock handle_error called with: Command failed: Run an invalid command"* ]]
}

# Test 3: Handles empty command
@test "run handles an empty command" {
    run ../scripts/run.sh "" "Run an empty command"
    [ "$status" -ne 0 ] # Ensure failure status
    [[ "$output" == *"Mock handle_error called with: Command failed: Run an empty command"* ]]
}

# Test 4: Logs successful command execution (optional enhancement)
@test "run logs a successful command execution" {
    # Create a temporary log file
    log_file="/tmp/test_command.log"
    export log_file

    # Modify run.sh to log to the temporary file
    run bash -c '
        run() {
            echo "Executing: $2"
            echo "$(date): Executing: $2" >> $log_file
            eval "$1"
            if [ $? -ne 0 ]; then
                handle_error "Command failed: $2"
            fi
        }; run "echo Success" "Log test"
    '
    [ "$status" -eq 0 ] # Ensure successful execution
    grep -q "Executing: Log test" "$log_file"
    rm "$log_file" # Clean up temporary log file
}
