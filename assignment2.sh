#!/bin/bash

echo "----------"
echo "Configuring Server"
echo "----------"

# Status Check
check_status() {
    if [ $? -ne 0 ]; then
        echo "[ERROR] $1 failed. Exiting script."
        exit 1
    fi
}

# Step.1  Check Network
echo "Checking network settings"

grep -q "192.168.16.21/24" /etc/netplan/*.yaml
if [ $? -ne 0 ]; then
    echo "Updating networ to 192.168.16.21/24"
    sed -i 's/address: .*/address: 192.168.16.21\/24/' /etc/netplan/*.yaml
    netplan apply
    check_status "Network configuration is updating"
else
    echo "Network is already configured."
fi

# Step.2  Update hosts
echo "Updating /etc/hosts"

grep -q "192.168.16.21 server1" /etc/hosts
if [ $? -ne 0 ]; then
    echo "Adding 192.168.16.21 server1 to /etc/hosts"
    sed -i '/server1/d' /etc/hosts
    echo "192.168.16.21 server1" >> /etc/hosts
    check_status "Updating /etc/hosts"
else
    echo "/etc/hosts is already configured."
fi

#Step.3 Apache2/Squid
echo "Checking if Apache2 and Squid are installed"

dpkg -l | grep apache2
if [ $? -ne 0 ]; then
    echo "Installing Apache2"
    apt-get install -y apache2
    check_status "Apache2 installation"
else
    echo "Apache2 is already installed."
fi

dpkg -l | grep squid
if [ $? -ne 0 ]; then
    echo "Installing Squid"
    apt-get install -y squid
    check_status "Squid installation"
else
    echo "Squid is already installed"
fi

# Step.4 User accounts + set up keys
echo "User accounts creation"

users=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")

for user in "${users[@]}"; do
    id "$user" &>/dev/null
    if [ $? -ne 0 ]; then
        echo "Creating user $user"
        useradd -m -s /bin/bash "$user"
        check_status "Creating user $user"
    else
        echo "User $user already exists."
    fi

    if [ ! -d "/home/$user/.ssh" ]; then
        mkdir -m 700 "/home/$user/.ssh"
        check_status "Creating SSH direct for $user"
    fi

    if ! grep -q "ssh-rsa" "/home/$user/.ssh/authorized_keys"; then
        echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAt3y4mjlDUL0hoyXhnkZl5eBYzFExhbIv4I9TbQsODtjlCFiMMTAHevVjsejvqFjzicv9zL1q9kA2X8l5tF9VBrFvObkAL9HjJktV9FY4fJ7eXLgD1i87E3jsKN7fPbbvNSVtjp5vj2SgGp1nlzY1tkL6MEmvCzxfmOckmfmd3HGpfkVtziF0hHzmA==" >> "/home/$user/.ssh/authorized_keys"
        echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm" >> "/home/$user/.ssh/authorized_keys"
        check_status "Adding SSH keys"
    else
        echo "SSH keys are already present"
    fi

    chmod 600 "/home/$user/.ssh/authorized_keys"
    chown -R "$user:$user" "/home/$user/.ssh"

# Step 4.5 Add dennis to sudo
    if [ "$user" == "dennis" ]; then
        usermod -aG sudo "$user"
        check_status "Adding $user to sudo group"
        echo "$user added to sudo group."
    fi
done

echo "Server is configured"
