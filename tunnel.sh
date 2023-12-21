#!/bin/bash

# ANSI color codes
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RED='\033[1;31m'
RESET='\033[0m'

# ASCII Art for "DailyDigitalSkills"
echo -e "${RED}"
echo "   ____  _             ____             _       _            "
echo "  |  _ \\(_) ___ ___   / ___|_   _ _ __ | |_ ___| |_ ___ _ __ "
echo "  | | | | |/ __/ _ \\ | |  _| | | | '_ \\| __/ _ \\ __/ _ \\ '__|"
echo "  | |_| | | (_|  __/ | |_| | |_| | | | | ||  __/ ||  __/ |   "
echo "  |____/|_|\\___\\___|  \\____|\\__,_|_| |_|\\__\\___|\\__\\___|_|   "
echo -e "${RESET}"

# Display menu and prompt user for input
echo -e "${CYAN}1. Configure iptables for both TCP and UDP"
echo "2. Flush all iptables rules"
echo "3. Exit${RESET}"
read -p "${BLUE}Please select an option: ${RESET}" choice

case $choice in
    1)
        # Get the main server IP address from the user
        read -p "${BLUE}Enter the main server IP address (e.g. 1.1.1.1): ${RESET}" IP

        # Get ports from the user
        read -p "${BLUE}Enter the ports (comma-separated, e.g. 80,443): ${RESET}" PORTS

        # Enable IP forwarding without reboot
        echo -e "${GREEN}Enabling IP forwarding...${RESET}"
        echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/30-ip_forward.conf
        sudo sysctl --system

        # Install required packages
        echo -e "${GREEN}Installing required packages...${RESET}"
        sudo apt install iptables iptables-persistent -y

        # Create MASQUERADE rule for TCP
        sudo iptables -t nat -A POSTROUTING -p tcp --match multiport --dports $PORTS -j MASQUERADE

        # Apply DNAT rule for TCP
        sudo iptables -t nat -A PREROUTING -p tcp --match multiport --dports $PORTS -j DNAT --to-destination $IP

        # Create MASQUERADE rule for UDP
        sudo iptables -t nat -A POSTROUTING -p udp --match multiport --dports $PORTS -j MASQUERADE

        # Apply DNAT rule for UDP
        sudo iptables -t nat -A PREROUTING -p udp --match multiport --dports $PORTS -j DNAT --to-destination $IP

        # Save iptables rules
        echo -e "${GREEN}Saving iptables rules...${RESET}"
        sudo mkdir -p /etc/iptables/
        sudo iptables-save | sudo tee /etc/iptables/rules.v4
        ;;
    2)
        # Flush all iptables rules
        echo -e "${RED}Flushing all iptables rules...${RESET}"
        sudo iptables -F
        sudo iptables -X
        sudo iptables -t nat -F
        sudo iptables -t nat -X
        sudo iptables -t mangle -F
        sudo iptables -t mangle -X
        sudo iptables -P INPUT ACCEPT
        sudo iptables -P FORWARD ACCEPT
        sudo iptables -P OUTPUT ACCEPT

        # Save iptables rules after flushing
        echo -e "${GREEN}Saving iptables rules after flushing...${RESET}"
        sudo iptables-save | sudo tee /etc/iptables/rules.v4

        # Reset ip forwarding status
        echo -e "${GREEN}Resetting IP forwarding status...${RESET}"
        echo "net.ipv4.ip_forward=0" | sudo tee /etc/sysctl.d/30-ip_forward.conf
        sudo sysctl --system
        ;;
    3)  
        echo -e "${CYAN}Exiting...${RESET}"
        exit 0