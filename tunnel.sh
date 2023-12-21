#!/bin/bash

# ANSI color codes
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

# ASCII Art for "DailyDigitalSkills"
echo -e "${RED}"
echo "-----------------------------------------------------------------------------"
echo "  _____        _ _       _____  _       _ _        _  _____ _    _ _ _     "
echo " |  __ \      (_) |     |  __ \(_)     (_) |      | |/ ____| |  (_) | |    "
echo " | |  | | __ _ _| |_   _| |  | |_  __ _ _| |_ __ _| | (___ | | ___| | |___ "
echo " | |  | |/ _ | | | | | | |  | | |/ _ | | __/ _\ | | |___ \| |/ / | | / __|"
echo " | |__| | (_| | | | |_| | |__| | | (_| | | || (_| | |____) |   <| | | \__ "
echo " |_____/ \___|_|_|\__, |_____/|_|\__, |_|\__\__,_|_|_____/|_|\_\_|_|_|___/"
echo "                    __/ |          __/ |                                   "
echo "                   |___/          |___/                                    "
echo "-----------------------------------------------------------------------------"
echo "------------------------ Youtube : @DailyDigitalSkills "------------------------
echo "-----------------------------------------------------------------------------"

echo -e "${RESET}"

# Display menu and prompt user for input
echo -e "${CYAN}1. Configure iptables for both TCP and UDP"
echo "2. Flush all iptables rules"
echo "3. Exit${RESET}"
read -p "${GREEN}Please select an option: ${RESET}" choice

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
        echo -e "${GREEN}---------------------------------------------------------${RESET}"
        echo -e "${GREEN}                                                 ${RESET}"
        echo -e "${GREEN}Great ! Tunnel was established${RESET}"
        echo -e "${GREEN}                                                 ${RESET}"
        echo -e "${GREEN}---------------------------------------------------------${RESET}"
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
        ;;
    *)
        echo -e "${RED}Invalid option${RESET}"
        ;;
esac
