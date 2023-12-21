#!/bin/bash

# نمایش منو و درخواست ورودی از کاربر
echo "1. Configure iptables for both TCP and UDP"
echo "2. Flush all iptables rules"
echo "3. Exit"
read -p "Please select an option: " choice

case $choice in
    1)
        # دریافت آدرس IP از کاربر
        read -p 'Enter the main server IP address (e.g. 1.1.1.1): ' IP

        # دریافت پورت‌ها از کاربر
        read -p 'Enter the ports (comma-separated, e.g. 80,443): ' PORTS

        # فعال‌سازی IP forwarding بدون نیاز به ریبوت
        echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/30-ip_forward.conf
        sudo sysctl --system

        # نصب بسته‌های مورد نیاز
        sudo apt install iptables iptables-persistent -y

        # ایجاد قانون MASQUERADE برای TCP
        sudo iptables -t nat -A POSTROUTING -p tcp --match multiport --dports $PORTS -j MASQUERADE

        # اعمال تغییر مسیردهی (DNAT) برای TCP
        sudo iptables -t nat -A PREROUTING -p tcp --match multiport --dports $PORTS -j DNAT --to-destination $IP

        # ایجاد قانون MASQUERADE برای UDP
        sudo iptables -t nat -A POSTROUTING -p udp --match multiport --dports $PORTS -j MASQUERADE

        # اعمال تغییر مسیردهی (DNAT) برای UDP
        sudo iptables -t nat -A PREROUTING -p udp --match multiport --dports $PORTS -j DNAT --to-destination $IP

        # ذخیره قوانین iptables
        sudo mkdir -p /etc/iptables/
        sudo iptables-save | sudo tee /etc/iptables/rules.v4
        ;;
    2)
        # حذف تمام قوانین iptables
        sudo iptables -F
        sudo iptables -X
        sudo iptables -t nat -F
        sudo iptables -t nat -X
        sudo iptables -t mangle -F
        sudo iptables -t mangle -X
        sudo iptables -P INPUT ACCEPT
        sudo iptables -P FORWARD ACCEPT
        sudo iptables -P OUTPUT ACCEPT

        # ذخیره کردن قوانین iptables پس از حذف
        sudo iptables-save | sudo tee /etc/iptables/rules.v4

        # بازنشانی وضعیت ip forwarding
        echo "net.ipv4.ip_forward=0" | sudo tee /etc/sysctl.d/30-ip_forward.conf
        sudo sysctl --system
        ;;
    3)  
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid option"
        ;;
esac