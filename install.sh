#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Install required packages
echo "Installing required packages..."
apt update
apt install -y iptables iptables-persistent

# Create symbolic link for iptables-dds script
# به داخل پوشه مخزن می‌رویم
mkdir /root/dds-tunnel
cd /root/dds-tunnel

# ساخت لینک نمادین با نام dds-tunnel که به tunnel.sh اشاره دارد
ln -s "$(pwd)/tunnel.sh" /usr/local/bin/dds-tunnel
echo "Installation completed. You can now use 'dds-tunnel' command."
# تغییر مجوزهای اجرایی اسکریپت
chmod +x tunnel.sh
sudo bash tunnel.sh

