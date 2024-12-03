#!/bin/bash
# Server 1 VXLAN Configuration Script with Cleanup Functionality

# Variables
VXLAN_IF="vxlan10"
VXLAN_ID=666
VXLAN_PORT=4789
LOCAL_IP="10.21.21.10"
REMOTE_IPS=("10.21.22.10" "10.21.23.10")
BRIDGE_IF="br-vxlan"
BRIDGE_IP="192.168.100.11/24"

# Function to clean up the configuration
cleanup() {
    echo "Cleaning up VXLAN and bridge configuration..."

    # Bring down the interfaces
    ip link set $VXLAN_IF down 2>/dev/null
    ip link set $BRIDGE_IF down 2>/dev/null

    # Delete the VXLAN interface
    ip link del $VXLAN_IF 2>/dev/null

    # Delete the bridge interface
    ip link del $BRIDGE_IF 2>/dev/null

    echo "Cleanup completed."
}

# Function to configure VXLAN
configure_vxlan() {
    echo "Configuring VXLAN and bridge..."

    # Create VXLAN interface
    ip link add $VXLAN_IF type vxlan id $VXLAN_ID dstport $VXLAN_PORT local $LOCAL_IP nolearning

    # Add static neighbors
    for ip in "${REMOTE_IPS[@]}"; do
        bridge fdb append to 00:00:00:00:00:00 dst $ip dev $VXLAN_IF
    done

    # Add VXLAN to bridge
    ip link add name $BRIDGE_IF type bridge
    ip link set $VXLAN_IF master $BRIDGE_IF

    # Assign IP address to the bridge interface
    ip addr add $BRIDGE_IP dev $BRIDGE_IF

    # Bring up interfaces
    ip link set $VXLAN_IF up
    ip link set $BRIDGE_IF up

    echo "Configuration completed."
}

# Main Script Logic
if [[ $1 == "cleanup" ]]; then
    cleanup
else
    configure_vxlan
fi
