#!/bin/bash

LOG_FILE="/var/log/conversion_status.log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

is_docker_container() {
    if [ -f /.dockerenv ]; then
        return 0
    fi
    
    if [ -f /proc/1/cgroup ]; then
        if grep -q docker /proc/1/cgroup 2>/dev/null; then
            return 0
        fi
        if grep -q containerd /proc/1/cgroup 2>/dev/null; then
            return 0
        fi
    fi
    
    if [ -f /proc/self/mountinfo ]; then
        if grep -q "docker" /proc/self/mountinfo 2>/dev/null; then
            return 0
        fi
    fi
    
    if [ -f /proc/1/comm ]; then
        local init_process=$(cat /proc/1/comm 2>/dev/null)
        # https://docs.docker.com/reference/cli/docker/container/run/#init
        if [ "$init_process" = "docker-init" ] || [ "$init_process" = "tini" ]; then
            return 0
        fi
    fi
    
    return 1
}

IS_DOCKER=false
if is_docker_container; then
    IS_DOCKER=true
    log "Running in Docker container"
else
    log "Running on host system"
fi

source scripts/run.sh
source scripts/editions/core.sh
source scripts/editions/home.sh
source scripts/editions/security.sh
source scripts/editions/htb.sh

check_system() {
    log "Performing system checks..."
    
    # Simple check if running Debian
    if ! grep -q "Debian" /etc/os-release; then
        log "ERROR: This script requires Debian"
        return 1
    fi
    
    if [ "$IS_DOCKER" = false ]; then
        local required_space=15000 # 15GB in MB
        local available_space=$(df -m / | awk 'NR==2 {print $4}')
        
        if [ "$available_space" -lt "$required_space" ]; then
            log "ERROR: Insufficient disk space. Required: 15 GB, Available: ${available_space}MB"
            return 1
        fi
    else
        log "Docker environment detected - skipping disk space check"
    fi
    
    log "System checks passed successfully"
    return 0
}

display_menu() {
    clear
    echo "╔════════════════════════════════════════════╗"
    echo "║          Debian Conversion Script          ║"
    if [ "$IS_DOCKER" = true ]; then
        echo "║              [DOCKER MODE]                 ║"
    fi
    echo "╠════════════════════════════════════════════╣"
    echo "║ 1) Install Core Edition                    ║"
    echo "║    Minimal installation for server use     ║"
    echo "║ 2) Install Home Edition                    ║"
    echo "║    Full desktop environment for daily use  ║"
    echo "║ 3) Install Security Edition                ║"
    echo "║    Tools for security testing and auditing ║"
    echo "║ 4) Install Hack The Box Edition            ║"
    echo "║    Customized environment for HTB labs     ║"
    echo "║ 5) Exit                                    ║"
    echo "╚════════════════════════════════════════════╝"
}

install_edition() {
    local edition=$1
    log "Starting installation of $edition"
    
    if ! check_system; then
        log "System checks failed. Installation aborted."
        return 1
    fi
    
    log "Updating package lists..."
    apt-get update
    
    case $edition in
        "core") core ;;
        "home") 
            if [ "$IS_DOCKER" = true ]; then
                log "WARNING: Home edition in Docker may have limited functionality"
            fi
            core && home 
            ;;
        "security") core && security ;;
        "htb") core && htb ;;
        *) log "Invalid edition selected"; return 1 ;;
    esac
    
    log "Installation of $edition edition completed successfully!"
}

touch "$LOG_FILE"
log "Installation script started..."

while true; do
    display_menu
    read -p "Enter the option number: " option
    case $option in
        1) install_edition "core" ;;
        2) install_edition "home" ;;
        3) install_edition "security" ;;
        4) install_edition "htb" ;;
        5) log "Exiting installation script..."; exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
    
    read -p "Press Enter to continue..."
done