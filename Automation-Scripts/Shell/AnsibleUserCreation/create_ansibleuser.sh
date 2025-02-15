#!/bin/bash
####################################################################
# This script is used to install the NDR sensor.
#
# Usage:
#   ./create_ansibleuser.sh
#
# Make sure to run this script with appropriate permissions.
####################################################################

USER="ansibleuser"
PASSWORD="VzDP9pOwFSEV#w1-"
LOGFILE="/var/log/ansibleuser_setup.log"

# Enable logging for entire script
exec > >(tee -a "$LOGFILE") 2>&1

# Detect OS and set the correct sudo group
if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    if [[ "$ID" =~ ^(centos|rhel|fedora)$ ]]; then
        SUDO_GROUP="wheel"
        SSH_SERVICE="sshd"
    elif [[ "$ID" =~ ^(ubuntu|debian)$ ]]; then
        SUDO_GROUP="sudo"
        SSH_SERVICE="ssh"
    else
        echo "Unsupported OS detected. Exiting."
        exit 1
    fi
else
    echo "Could not determine OS. Exiting."
    exit 1
fi

# Create the user with the correct sudo group
if ! id "$USER" &>/dev/null; then
    echo "Creating user: $USER"
    useradd -m -s /bin/bash -G "$SUDO_GROUP" "$USER"
    echo "$USER:$PASSWORD" | chpasswd
    echo "User $USER created."
else
    echo "User $USER already exists."
fi

# Check if sshd_config exists
SSHD_CONFIG="/etc/ssh/sshd_config"
if [ -f "$SSHD_CONFIG" ]; then
    echo "Checking SSH configuration in $SSHD_CONFIG"
    if grep -q "^#PasswordAuthentication" "$SSHD_CONFIG"; then
        sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' "$SSHD_CONFIG"
        SSH_RESTART_REQUIRED=true
    elif grep -q "^PasswordAuthentication no" "$SSHD_CONFIG"; then
        echo "WARNING: PasswordAuthentication is set to 'no'. Manual intervention required."
    fi

    # Restart SSH service
    if [ "$SSH_RESTART_REQUIRED" = true ]; then
        if systemctl list-units --type=service --all | grep -E "\b${SSH_SERVICE}\.service\b" &>/dev/null; then
            echo "Restarting SSH service using systemctl..."
            systemctl restart "$SSH_SERVICE"
        elif command -v service &>/dev/null; then
            echo "Restarting SSH service using service command..."
            service "$SSH_SERVICE" restart
        else
            echo "WARNING: Could not determine how to restart SSH. Manual restart may be required."
        fi
        echo "SSH service restart attempted."
    fi
else
    echo "SSHD configuration file not found. Skipping SSH configuration."
fi
