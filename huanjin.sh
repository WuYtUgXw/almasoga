#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
WHITE='\033[1;37m'
NC='\033[0m'

function detect_system {
    if [[ -r /etc/os-release ]]; then
        source /etc/os-release
        if [[ $ID == "debian" || $ID == "ubuntu" || $ID == "raspbian" ]]; then
            SYSTEM_TYPE="debian"
        elif [[ $ID == "centos" || $ID == "fedora" || $ID == "rhel" ]]; then
            SYSTEM_TYPE="centos"
        else
            echo -e "${RED}Unsupported system type: $ID${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Unable to read /etc/os-release file, cannot determine system type${NC}"
        exit 1
    fi
}

function main_menu {
    echo -e "${YELLOW}Welcome to the environment configuration script!${NC}"
    echo -e "${YELLOW}1: ${WHITE}wget configuration${NC}"
    echo -e "${YELLOW}2: ${WHITE}Docker configuration${NC}"
    echo -e "${YELLOW}3: ${WHITE}Baota configuration${NC}"
    echo -e "${YELLOW}4: ${WHITE}TCP tuning${NC}"
    echo -e "${YELLOW}5: ${WHITE}Curl configuration${NC}"
    echo -e "${YELLOW}6: ${WHITE}BBR3 configuration${NC}"
    echo -e "${YELLOW}7: ${WHITE}Disable IPv6 network${NC}"
    echo -e "${YELLOW}0: ${WHITE}Exit script${NC}"
}

function wget_menu {
    echo -e "${YELLOW}1: ${WHITE}Install${NC}"
    echo -e "${YELLOW}2: ${WHITE}Uninstall${NC}"
    echo -e "${YELLOW}3: ${WHITE}Return to the main menu${NC}"
}

function docker_menu {
    echo -e "${YELLOW}1: ${WHITE}Install${NC}"
    echo -e "${YELLOW}2: ${WHITE}Uninstall${NC}"
    echo -e "${YELLOW}3: ${WHITE}Return to the main menu${NC}"
}

function bt_menu {
    echo -e "${YELLOW}1: ${WHITE}Install Chinese Baota${NC}"
    echo -e "${YELLOW}2: ${WHITE}Install International Baota${NC}"
    echo -e "${YELLOW}3: ${WHITE}Uninstall Baota${NC}"
    echo -e "${YELLOW}0: ${WHITE}Return to the main menu${NC}"
}

function tcp_tuning_menu {
    echo -e "${YELLOW}1: ${WHITE}Run TCP tuning script${NC}"
    echo -e "${YELLOW}2: ${WHITE}Return to the main menu${NC}"
}

function curl_menu {
    echo -e "${YELLOW}1: ${WHITE}Install${NC}"
    echo -e "${YELLOW}2: ${WHITE}Uninstall${NC}"
    echo -e "${YELLOW}3: ${WHITE}Return to the main menu${NC}"
}

function bbr3_menu {
    echo -e "${YELLOW}1: ${WHITE}Install${NC}"
    echo -e "${YELLOW}2: ${WHITE}Restore${NC}"
    echo -e "${YELLOW}3: ${WHITE}Uninstall${NC}"
    echo -e "${YELLOW}4: ${WHITE}Return to the main menu${NC}"
}

function disable_ipv6_menu {
    echo -e "${YELLOW}1: ${WHITE}Disable IPv6${NC}"
    echo -e "${YELLOW}2: ${WHITE}Enable IPv6${NC}"
    echo -e "${YELLOW}0: ${WHITE}Return to the main menu${NC}"
}

detect_system

while true; do
    main_menu
    read -p "Select a main option (enter the corresponding number): " main_choice

    case $main_choice in
        1)
            while true; do
                wget_menu
                read -p "Select a wget configuration option (enter the corresponding number): " wget_choice
                case $wget_choice in
                    1)
                        if [[ $SYSTEM_TYPE == "debian" ]]; then
                            sudo apt-get update
                            sudo apt-get install -y wget
                        elif [[ $SYSTEM_TYPE == "centos" ]]; then
                            sudo yum install -y wget
                        fi
                        ;;
                    2)
                        if [[ $SYSTEM_TYPE == "debian" ]]; then
                            sudo apt-get remove -y wget
                        elif [[ $SYSTEM_TYPE == "centos" ]]; then
                            sudo yum remove -y wget
                        fi
                        ;;
                    3)
                        break
                        ;;
                    *)
                        echo -e "${RED}Invalid choice${NC}"
                        ;;
                esac
            done
            ;;
        2)
            while true; do
                docker_menu
                read -p "Select a Docker configuration option (enter the corresponding number): " docker_choice
                case $docker_choice in
                    1)
                        if [[ $SYSTEM_TYPE == "debian" ]]; then
                            sudo apt-get update
                            sudo apt-get install -y docker.io
                        elif [[ $SYSTEM_TYPE == "centos" ]]; then
                            sudo yum install -y docker
                        fi
                        ;;
                    2)
                        if [[ $SYSTEM_TYPE == "debian" ]]; then
                            sudo apt-get remove -y docker.io
                        elif [[ $SYSTEM_TYPE == "centos" ]]; then
                            sudo yum remove -y docker
                        fi
                        ;;
                    3)
                        break
                        ;;
                    *)
                        echo -e "${RED}Invalid choice${NC}"
                        ;;
                esac
            done
            ;;
        # ... (rest of your cases)
        0)
            echo -e "${YELLOW}Exiting script.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            ;;
    esac
done
