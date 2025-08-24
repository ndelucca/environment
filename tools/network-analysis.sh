#!/bin/bash

# Network Analysis Script for Debian 13
# Detects and reports all network management tools and configurations

OUTPUT_FILE="/home/ndelucca/environment/network-analysis-report.txt"

echo "=== NETWORK ANALYSIS REPORT ===" > "$OUTPUT_FILE"
echo "Generated on: $(date)" >> "$OUTPUT_FILE"
echo "System: $(uname -a)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Function to add section headers
add_section() {
    echo "" >> "$OUTPUT_FILE"
    echo "===========================================" >> "$OUTPUT_FILE"
    echo "$1" >> "$OUTPUT_FILE"
    echo "===========================================" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
}

# Check if commands exist
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

add_section "NETWORK INTERFACES"
ip addr show >> "$OUTPUT_FILE" 2>&1
echo "" >> "$OUTPUT_FILE"
ip route show >> "$OUTPUT_FILE" 2>&1

add_section "NETWORK MANAGER DETECTION"
echo "NetworkManager service status:" >> "$OUTPUT_FILE"
systemctl status NetworkManager --no-pager >> "$OUTPUT_FILE" 2>&1
echo "" >> "$OUTPUT_FILE"

echo "NetworkManager installed:" >> "$OUTPUT_FILE"
if command_exists nmcli; then
    echo "YES - nmcli found" >> "$OUTPUT_FILE"
    nmcli --version >> "$OUTPUT_FILE" 2>&1
    echo "" >> "$OUTPUT_FILE"
    echo "NetworkManager connections:" >> "$OUTPUT_FILE"
    nmcli connection show >> "$OUTPUT_FILE" 2>&1
    echo "" >> "$OUTPUT_FILE"
    echo "NetworkManager devices:" >> "$OUTPUT_FILE"
    nmcli device status >> "$OUTPUT_FILE" 2>&1
else
    echo "NO - nmcli not found" >> "$OUTPUT_FILE"
fi

add_section "SYSTEMD-NETWORKD DETECTION"
echo "systemd-networkd service status:" >> "$OUTPUT_FILE"
systemctl status systemd-networkd --no-pager >> "$OUTPUT_FILE" 2>&1
echo "" >> "$OUTPUT_FILE"

echo "systemd-networkd configuration files:" >> "$OUTPUT_FILE"
if [ -d "/etc/systemd/network" ]; then
    ls -la /etc/systemd/network/ >> "$OUTPUT_FILE" 2>&1
    echo "" >> "$OUTPUT_FILE"
    for file in /etc/systemd/network/*; do
        if [ -f "$file" ]; then
            echo "--- Content of $file ---" >> "$OUTPUT_FILE"
            cat "$file" >> "$OUTPUT_FILE" 2>&1
            echo "" >> "$OUTPUT_FILE"
        fi
    done
else
    echo "/etc/systemd/network directory does not exist" >> "$OUTPUT_FILE"
fi

add_section "IFUPDOWN DETECTION"
echo "ifupdown configuration:" >> "$OUTPUT_FILE"
if [ -f "/etc/network/interfaces" ]; then
    echo "--- /etc/network/interfaces ---" >> "$OUTPUT_FILE"
    cat /etc/network/interfaces >> "$OUTPUT_FILE" 2>&1
    echo "" >> "$OUTPUT_FILE"
else
    echo "/etc/network/interfaces not found" >> "$OUTPUT_FILE"
fi

if [ -d "/etc/network/interfaces.d" ]; then
    echo "--- /etc/network/interfaces.d contents ---" >> "$OUTPUT_FILE"
    ls -la /etc/network/interfaces.d/ >> "$OUTPUT_FILE" 2>&1
    for file in /etc/network/interfaces.d/*; do
        if [ -f "$file" ]; then
            echo "--- Content of $file ---" >> "$OUTPUT_FILE"
            cat "$file" >> "$OUTPUT_FILE" 2>&1
            echo "" >> "$OUTPUT_FILE"
        fi
    done
else
    echo "/etc/network/interfaces.d directory does not exist" >> "$OUTPUT_FILE"
fi

echo "networking service status:" >> "$OUTPUT_FILE"
systemctl status networking --no-pager >> "$OUTPUT_FILE" 2>&1

add_section "DNS RESOLUTION"
echo "systemd-resolved status:" >> "$OUTPUT_FILE"
systemctl status systemd-resolved --no-pager >> "$OUTPUT_FILE" 2>&1
echo "" >> "$OUTPUT_FILE"

echo "resolvectl status:" >> "$OUTPUT_FILE"
if command_exists resolvectl; then
    resolvectl status >> "$OUTPUT_FILE" 2>&1
else
    echo "resolvectl not found" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

echo "--- /etc/resolv.conf ---" >> "$OUTPUT_FILE"
if [ -f "/etc/resolv.conf" ]; then
    ls -la /etc/resolv.conf >> "$OUTPUT_FILE" 2>&1
    echo "Content:" >> "$OUTPUT_FILE"
    cat /etc/resolv.conf >> "$OUTPUT_FILE" 2>&1
else
    echo "/etc/resolv.conf not found" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

echo "--- /etc/nsswitch.conf (hosts line) ---" >> "$OUTPUT_FILE"
grep "^hosts:" /etc/nsswitch.conf >> "$OUTPUT_FILE" 2>&1

add_section "DHCP CLIENT DETECTION"
echo "DHCP client processes:" >> "$OUTPUT_FILE"
ps aux | grep -E "(dhcp|dhclient)" | grep -v grep >> "$OUTPUT_FILE" 2>&1
echo "" >> "$OUTPUT_FILE"

for dhcp_client in dhclient dhcpcd pump udhcpc; do
    echo "Checking for $dhcp_client:" >> "$OUTPUT_FILE"
    if command_exists "$dhcp_client"; then
        echo "  Found: $(which $dhcp_client)" >> "$OUTPUT_FILE"
        systemctl status "$dhcp_client" --no-pager >> "$OUTPUT_FILE" 2>&1 || echo "  No systemd service for $dhcp_client" >> "$OUTPUT_FILE"
    else
        echo "  Not found" >> "$OUTPUT_FILE"
    fi
    echo "" >> "$OUTPUT_FILE"
done

add_section "WIRELESS TOOLS"
echo "Wireless interfaces:" >> "$OUTPUT_FILE"
if command_exists iwconfig; then
    iwconfig >> "$OUTPUT_FILE" 2>&1
else
    echo "iwconfig not found" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

if command_exists iw; then
    echo "iw dev:" >> "$OUTPUT_FILE"
    iw dev >> "$OUTPUT_FILE" 2>&1
else
    echo "iw not found" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

echo "wpa_supplicant status:" >> "$OUTPUT_FILE"
systemctl status wpa_supplicant --no-pager >> "$OUTPUT_FILE" 2>&1
echo "" >> "$OUTPUT_FILE"

if [ -f "/etc/wpa_supplicant/wpa_supplicant.conf" ]; then
    echo "wpa_supplicant configuration exists" >> "$OUTPUT_FILE"
else
    echo "wpa_supplicant configuration not found" >> "$OUTPUT_FILE"
fi

add_section "INSTALLED NETWORK PACKAGES"
echo "Network-related packages:" >> "$OUTPUT_FILE"
dpkg -l | grep -E "(network-manager|ifupdown|systemd|wpasupplicant|dhcp)" >> "$OUTPUT_FILE" 2>&1

add_section "ACTIVE NETWORK SERVICES"
echo "All active network-related services:" >> "$OUTPUT_FILE"
systemctl list-units --type=service --state=active | grep -E "(network|dhcp|wpa|resolv)" >> "$OUTPUT_FILE" 2>&1

add_section "FIREWALL STATUS"
echo "UFW status:" >> "$OUTPUT_FILE"
if command_exists ufw; then
    ufw status >> "$OUTPUT_FILE" 2>&1
else
    echo "UFW not installed" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

echo "iptables rules:" >> "$OUTPUT_FILE"
iptables -L -n >> "$OUTPUT_FILE" 2>&1
echo "" >> "$OUTPUT_FILE"

echo "ip6tables rules:" >> "$OUTPUT_FILE"
ip6tables -L -n >> "$OUTPUT_FILE" 2>&1

add_section "NETWORK STATISTICS"
echo "Network connections:" >> "$OUTPUT_FILE"
ss -tuln >> "$OUTPUT_FILE" 2>&1
echo "" >> "$OUTPUT_FILE"

echo "Network interface statistics:" >> "$OUTPUT_FILE"
cat /proc/net/dev >> "$OUTPUT_FILE" 2>&1

echo "" >> "$OUTPUT_FILE"
echo "=== ANALYSIS COMPLETE ===" >> "$OUTPUT_FILE"
echo "Report saved to: $OUTPUT_FILE" >> "$OUTPUT_FILE"

echo "Network analysis complete! Report saved to: $OUTPUT_FILE"