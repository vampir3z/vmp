#!/bin/bash

# Update package list
apt update

# Ask if this is the "iran" or "kharej" server
read -p "Is this the \"iran\" or \"kharej\" server? (1/2): " server_type

# Check the server type
if [[ $server_type == 1 ]]; then
  # Ask for local and remote IP addresses
  read -p "Enter local IP address: " local_ip
  read -p "Enter remote IP address: " remote_ip

  # Edit netplan configuration file for "iran" server
  cat << EOM > /etc/netplan/pdtun.yaml
network:
  version: 2
  tunnels:
    tunel01:
      mode: sit
      local: "$local_ip"
      remote: "$remote_ip"
      addresses:
        - 2001:db8:212::1/64
      mtu: 1500
EOM
else
  # Ask for local and remote IP addresses
  read -p "Enter local IP address: " local_ip
  read -p "Enter remote IP address: " remote_ip

  # Edit netplan configuration file for "kharej" server
  cat << EOM > /etc/netplan/pdtun.yaml
network:
  version: 2
  tunnels:
    tunel01:
      mode: sit
      local: "$local_ip"
      remote: "$remote_ip"
      addresses:
        - 2001:db8:212::2/64
      mtu: 1500
EOM
fi

# Apply netplan configuration
sudo netplan apply

# Edit systemd network configuration file
cat << EOM > /etc/systemd/network/tun0.network
[Network]
Address=2001:db8:212::1/64
Gateway=2001:db8:212::25
EOM

# Restart systemd-networkd
sudo systemctl restart systemd-networkd

# Clear and save command history
history -c && history -w

# Reboot the server
sudo reboot