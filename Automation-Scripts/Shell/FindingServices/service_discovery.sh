#!/bin/bash

declare -a DISCOVERY_LIST

# Function to gather service information using systemctl
gather_service_info_systemctl() {
    while read -r line; do
        service_unit="${line%.service*}"
        # Remove all non-alphanumeric characters
        service_unit_clean=$(echo "$service_unit" | tr -dc '[:alnum:]-')
        if [ -z "$service_unit_clean" ]; then
            continue
        fi
        # Check if service name contains a single or multiple backslashes
        if [[ "$service_unit" =~ \\ && ! "$service_unit" =~ \\\\ ]]; then
            continue
        fi
        read -r -a status <<< "$line"
        if [[ "${#status[@]}" -eq 1 && ( "${status[1]}" == "enabled" || "${status[1]}" == "generated" ) ]]; then
            DISCOVERY_LIST+=("{\"{#SERVICE}\":\"$service_unit_clean\"}")
        elif [[ "${#status[@]}" -eq 2 && "${status[1]}" == "enabled" ]]; then
            DISCOVERY_LIST+=("{\"{#SERVICE}\":\"$service_unit_clean\"}")
        fi
    done < <(systemctl list-unit-files 2>/dev/null | awk '{print $1, $2}')
}

# Function to gather service information using chkconfig
gather_service_info_chkconfig() {
    while read -r line; do
        service_unit="${line%%[[:space:]]*}"
        # Remove all non-alphanumeric characters
        service_unit_clean=$(echo "$service_unit" | tr -dc '[:alnum:]-')
        if [ -z "$service_unit_clean" ]; then
            continue
        fi
        DISCOVERY_LIST+=("{\"{#SERVICE}\":\"$service_unit_clean\"}")
    done < <(chkconfig --list | grep ":on")
}

# Check if systemctl command exists
if command -v systemctl >/dev/null 2>&1; then
    gather_service_info_systemctl
elif command -v chkconfig >/dev/null 2>&1; then
    gather_service_info_chkconfig
else
    echo "Neither systemctl nor chkconfig command found. Please provide an alternative method to gather service information."
    exit 1
fi

# Print JSON array with comma-separated items
echo "["
for (( i=0; i<${#DISCOVERY_LIST[@]}; i++ )); do
    # Remove the word "enabled" from the service name
    echo -n "${DISCOVERY_LIST[$i]//enabled/}"
    # Add comma for all items except the last one
    if [ $i -lt $((${#DISCOVERY_LIST[@]}-1)) ]; then
        echo ","
    fi
done
echo "]"  # Close JSON array