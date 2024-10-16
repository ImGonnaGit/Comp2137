#!/bin/bash 

# Get system information and store in variables
HOSTNAME=$(hostname)
OS=$(lsb_release -d | cut -f2)
UPTIME=$(uptime -p)
CPU=$(lscpu | grep "Model name" | cut -d: -f2 | xargs)
RAM=$(free -h | grep Mem | awk '{print $2}')
DISK=$(lsblk -d -o NAME,SIZE,MODEL | grep -v loop)
IP=$(hostname -I | cut -d' ' -f1)
GATEWAY=$(ip route | grep default | awk '{print $3}')
DNS=$(systemd-resolve --status | grep 'DNS Servers' -A1 | tail -n1 | xargs)

# Display the report
echo ""
echo "System Report geenerated by $USER, $(date)"
echo ""
echo "System Information"
echo "----"
echo "Hostname: $HOSTNAME"
echo "OS: $OS"
echo "Uptime: $UPTIME"
echo ""
echo "Hardware Information"
echo "----"
echo "CPU: $CPU"
echo "RAM: $RAM"
echo "Disk(s):"
echo "$DISK"
echo ""
echo "Network Information"
echo "----"
echo "Host IP Address: $IP"
echo "Gateway IP: $GATEWAY"
echo "DNS Server: $DNS"
echo ""
echo "System Status"
echo "----"
echo "Users Logged In: $(who | awk '{print $1}' | sort | uniq | xargs)"
echo "Disk Space: $(df -h --output=source,avail / | tail -1)"
echo "Process Count: $(ps aux | wc -l)"
echo "Load Averages: $(uptime | awk -F'load average:' '{ print $2 }' | xargs)"
echo "Memory Usage: $(free -h | grep Mem | awk '{print $3 " used out of " $2}')"
echo "UFW RULES:"
echo "$UFW_RULES"
echo ""

