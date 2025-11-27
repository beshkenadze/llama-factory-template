#!/bin/bash
# Syncthing auto-configuration script
# Configures Syncthing with remote device and folders via ENV variables

SYNCTHING_CONFIG_DIR="${SYNCTHING_CONFIG_DIR:-$HOME/.config/syncthing}"
SYNCTHING_API_KEY="${SYNCTHING_API_KEY:-$(head -c 32 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 32)}"
SYNCTHING_GUI_ADDRESS="${SYNCTHING_GUI_ADDRESS:-0.0.0.0:8384}"

# Wait for Syncthing to generate initial config
wait_for_syncthing() {
    local max_wait=30
    local waited=0
    while [ ! -f "$SYNCTHING_CONFIG_DIR/config.xml" ] && [ $waited -lt $max_wait ]; do
        sleep 1
        waited=$((waited + 1))
    done
    if [ ! -f "$SYNCTHING_CONFIG_DIR/config.xml" ]; then
        echo "ERROR: Syncthing config not found after ${max_wait}s"
        return 1
    fi
}

# Get local device ID
get_local_device_id() {
    syncthing --device-id 2>/dev/null
}

# Add remote device via REST API
add_remote_device() {
    local device_id="$1"
    local device_name="$2"

    curl -s -X POST \
        -H "X-API-Key: $SYNCTHING_API_KEY" \
        -H "Content-Type: application/json" \
        "http://127.0.0.1:8384/rest/config/devices" \
        -d "{
            \"deviceID\": \"$device_id\",
            \"name\": \"$device_name\",
            \"addresses\": [\"dynamic\"],
            \"autoAcceptFolders\": false,
            \"introducedBy\": \"\"
        }" 2>/dev/null
}

# Add folder via REST API
add_folder() {
    local folder_id="$1"
    local folder_path="$2"
    local folder_type="$3"
    local device_id="$4"

    mkdir -p "$folder_path"

    curl -s -X POST \
        -H "X-API-Key: $SYNCTHING_API_KEY" \
        -H "Content-Type: application/json" \
        "http://127.0.0.1:8384/rest/config/folders" \
        -d "{
            \"id\": \"$folder_id\",
            \"label\": \"$folder_id\",
            \"path\": \"$folder_path\",
            \"type\": \"$folder_type\",
            \"devices\": [
                {\"deviceID\": \"$(get_local_device_id)\"},
                {\"deviceID\": \"$device_id\"}
            ],
            \"rescanIntervalS\": 60,
            \"fsWatcherEnabled\": true,
            \"fsWatcherDelayS\": 10
        }" 2>/dev/null
}

# Wait for Syncthing API to be ready
wait_for_api() {
    local max_wait=30
    local waited=0
    while ! curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:8384/rest/system/status" 2>/dev/null | grep -q "200\|403"; do
        sleep 1
        waited=$((waited + 1))
        if [ $waited -ge $max_wait ]; then
            echo "ERROR: Syncthing API not ready after ${max_wait}s"
            return 1
        fi
    done
}

# Main configuration
configure_syncthing() {
    echo "=== Syncthing Auto-Configuration ==="

    # Check if remote device is configured
    if [ -z "$SYNCTHING_REMOTE_DEVICE_ID" ]; then
        echo "SYNCTHING_REMOTE_DEVICE_ID not set, skipping auto-config"
        echo "Local Device ID: $(get_local_device_id)"
        return 0
    fi

    echo "Waiting for Syncthing API..."
    wait_for_api || return 1

    # Add remote device
    echo "Adding remote device: ${SYNCTHING_REMOTE_DEVICE_NAME:-remote}"
    add_remote_device "$SYNCTHING_REMOTE_DEVICE_ID" "${SYNCTHING_REMOTE_DEVICE_NAME:-remote}"

    # Configure models folder (receive only)
    if [ -n "$SYNCTHING_MODELS_PATH" ]; then
        echo "Adding models folder: $SYNCTHING_MODELS_PATH (${SYNCTHING_MODELS_TYPE:-receiveonly})"
        add_folder \
            "${SYNCTHING_MODELS_FOLDER_ID:-models}" \
            "$SYNCTHING_MODELS_PATH" \
            "${SYNCTHING_MODELS_TYPE:-receiveonly}" \
            "$SYNCTHING_REMOTE_DEVICE_ID"
    fi

    # Configure outputs folder (send only)
    if [ -n "$SYNCTHING_OUTPUTS_PATH" ]; then
        echo "Adding outputs folder: $SYNCTHING_OUTPUTS_PATH (${SYNCTHING_OUTPUTS_TYPE:-sendonly})"
        add_folder \
            "${SYNCTHING_OUTPUTS_FOLDER_ID:-outputs}" \
            "$SYNCTHING_OUTPUTS_PATH" \
            "${SYNCTHING_OUTPUTS_TYPE:-sendonly}" \
            "$SYNCTHING_REMOTE_DEVICE_ID"
    fi

    echo ""
    echo "=== Syncthing Configuration Complete ==="
    echo "Local Device ID: $(get_local_device_id)"
    echo "Remote Device: $SYNCTHING_REMOTE_DEVICE_ID"
    [ -n "$SYNCTHING_MODELS_PATH" ] && echo "Models: $SYNCTHING_MODELS_PATH (${SYNCTHING_MODELS_TYPE:-receiveonly})"
    [ -n "$SYNCTHING_OUTPUTS_PATH" ] && echo "Outputs: $SYNCTHING_OUTPUTS_PATH (${SYNCTHING_OUTPUTS_TYPE:-sendonly})"
    echo ""
    echo "NOTE: Accept this device on your NAS to start syncing"
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    configure_syncthing
fi
