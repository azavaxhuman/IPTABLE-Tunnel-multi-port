#!/bin/bash

# ANSI color codes
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

# ASCII Art for "DailyDigitalSkills"
echo -e "${BLUE}"
echo "-----------------------------------------------------------------------------"
echo "  _____        _ _       _____  _       _ _        _  _____ _    _ _ _     "
echo " |  __ \      (_) |     |  __ \(_)     (_) |      | |/ ____| |  (_) | |    "
echo " | |  | | __ _ _| |_   _| |  | |_  __ _ _| |_ __ _| | (___ | | ___| | |___ "
echo " | |  | |/ _| | | | | | | |  | |/ /    | | | |  | | |  \|  | / / | | / _|"
echo " | |__| | (_| | | | |_| | |__| | | (_| | | || (_| | |____) |   <| | | \__ "
echo " |_____/ \___|_|_|\__, |_____/|_|\__, |_|\__\__,_|_|_____/|_|\_\_|_|_|___/"
echo "                    __/ |          __/ |                                   "
echo "                   |___/          |___/                                    "
echo -e "${RESET}"
echo -e "${RED}"
echo "-----------------------------------------------------------------------------"
echo "------------------------ Youtube : @DailyDigitalSkills ----------------------"
echo "-----------------------------------------------------------------------------"
echo -e "${RESET}"

# Display menu and prompt user for input
echo -e "${CYAN}1. Multi-Port Tunnel(for both TCP and UDP)${RESET}"
echo "                                                "
echo -e "${CYAN}2. Tunnel All Ports (Except for selected ports)${RESET}"
echo "                                                "
echo "${YELLOW}3. Display tables related to the tunnel${RESET}"
echo "                                                "
echo "${YELLOW}4. Flush all iptables rules${RESET}"
echo "                                                "
echo "${BLUE}5. Update${RESET}"
echo "                                                "
echo "${RED}6. Unistall !${RESET}"
echo "                                                "
echo "${RED}7. Exit${RESET}"
echo "                                                "
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
        echo -e "${GREEN}Great ! Multi-Port Tunnel was established${RESET}"
        echo -e "${GREEN}                                                 ${RESET}"
        echo -e "${GREEN}---------------------------------------------------------${RESET}"
        read -p "Back to Main menu? (${GREEN}y${RESET}/${RED}n${RESET}): " answer
        if [ "$answer" == "y" ]; then
        sudo dds-tunnel
        else
        echo "OK"
        echo -e "${CYAN}Exiting...${RESET}"
        exit 0
        fi
        ;;
    2)
        read -p "${BLUE}Enter the Relay server IP (this Server) address (e.g. 1.1.1.1): ${RESET}" RIP
        # Get SSH ports from the user
        # Get the main server IP address from the user
        read -p "${BLUE}Enter the main server IP address (e.g. 2.2.2.2): ${RESET}" IP
        # Get SSH ports from the user
        read -p "${BLUE}Enter the excluded ports (comma-separated, e.g. 22,51): ${RESET}" PORTS
        # Enable IP forwarding without reboot
        echo -e "${GREEN}Enabling IP forwarding...${RESET}"
        echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/30-ip_forward.conf
        sudo sysctl --system

        # Install required packages
        echo -e "${GREEN}Installing required packages...${RESET}"
        sudo apt install iptables iptables-persistent -y

        sudo iptables -t nat -A PREROUTING -p tcp --match multiport --dports $PORTS -j DNAT --to-destination $RIP
        sudo iptables -t nat -A PREROUTING -p udp --match multiport --dports $PORTS -j DNAT --to-destination $RIP
        sudo iptables -t nat -A PREROUTING -p tcp -j DNAT --to-destination $IP
        sudo iptables -t nat -A PREROUTING -p udp -j DNAT --to-destination $IP
        sudo iptables -t nat -A POSTROUTING -j MASQUERADE

        # Save iptables rules
        echo -e "${GREEN}Saving iptables rules...${RESET}"
        sudo mkdir -p /etc/iptables/
        sudo iptables-save | sudo tee /etc/iptables/rules.v4
        echo -e "${GREEN}---------------------------------------------------------${RESET}"
        echo -e "${GREEN}                                                 ${RESET}"
        echo -e "${GREEN}The tunnel was established for all ports except $PORTS ${RESET}"
        echo -e "${GREEN}                                                 ${RESET}"
        echo -e "${GREEN}---------------------------------------------------------${RESET}"
        read -p "Back to Main menu? (${GREEN}y${RESET}/${RED}n${RESET}): " answer
        if [ "$answer" == "y" ]; then
        sudo dds-tunnel
        else
        echo "OK"
        echo -e "${CYAN}Exiting...${RESET}"
        exit 0
        fi
        ;;
     3)
        # Show iptables rules
        echo -e "${RED}Chains and rules related to the nat table${RESET}"
        echo -e "${GREEN}---------------------------------------------------------${RESET}"
        echo -e "${GREEN}                                                 ${RESET}"
        sudo iptables -t nat -L -v --line-numbers
        echo -e "${GREEN}                                                 ${RESET}"
        echo -e "${GREEN}---------------------------------------------------------${RESET}"
        read -p "Back to Main menu? (${GREEN}y${RESET}/${RED}n${RESET}): " answer
        if [ "$answer" == "y" ]; then
        sudo dds-tunnel
        else
        echo "OK"
        echo -e "${CYAN}Exiting...${RESET}"
        exit 0
        fi
        ;;
    4)
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
        echo -e "${GREEN}---------------------------------------------------------${RESET}"
        echo -e "${GREEN}                                                 ${RESET}"
        echo -e "${GREEN}                All tables were reset                    ${RESET}"
        echo -e "${GREEN}                                                 ${RESET}"
        echo -e "${GREEN}---------------------------------------------------------${RESET}"
        read -p "Back to Main menu? (${GREEN}y${RESET}/${RED}n${RESET}): " answer
        if [ "$answer" == "y" ]; then
        sudo dds-tunnel
        else
        echo "OK"
        echo -e "${CYAN}Exiting...${RESET}"
        exit 0
        fi
        

        ;;
            5)
#Update
        echo -e "${RED}Updating...${RESET}"
        REPO_NAME="IPTABLE-Tunnel-multi-port"

        # مسیری که می‌خواهید مخزن در آن clone شود
        INSTALL_PATH="/root/dds-tunnel"

        # مسیری که مخزن در آن clone شده است
        CLONE_PATH="$INSTALL_PATH"

        # اگر مخزن قبلاً clone نشده باشد، آن را clone کنید
        if [ ! -d "$CLONE_PATH" ]; then
    git clone "https://github.com/azavaxhuman/$REPO_NAME.git" "$CLONE_PATH"
    else
    # اگر مخزن قبلاً clone شده باشد، آن را به‌روزرسانی کنید
    cd "$CLONE_PATH" || exit
    git pull origin main
    fi
    echo -e "${GREEN}Done...${RESET}"
    sudo dds-tunnel

        ;;
    6)

    #Unistall
    read -p "Are You Sure to Unistall DDS-Tunnel? (${GREEN}yes${RESET}/${RED}no${RESET}): " answer


    if [ "$answer" == "yes" ]; then
    # اگر جواب yes بود، دستورات مورد نظر را اجرا کن
    echo "Oh ! Ok , No problem!"
    sudo unlink /usr/local/bin/dds-tunnel
    sudo rm -rf /root/dds-tunnel/
    # اینجا دستورات مورد نظر را قرار دهید
    else
    # اگر جواب yes نبود، پیام مناسب را نمایش بده
    echo "OK"
    sudo dds-tunnel
    fi
        ;;
    7)  
        echo -e "${CYAN}Exiting...${RESET}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option${RESET}"
        ;;
esac
