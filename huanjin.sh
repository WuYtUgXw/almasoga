#!/bin/bash

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# 获取系统类型
function detect_system {
    if [[ -r /etc/os-release ]]; then
        source /etc/os-release
        if [[ $ID == "debian" || $ID == "ubuntu" || $ID == "raspbian" ]]; then
            SYSTEM_TYPE="debian"
        elif [[ $ID == "centos" || $ID == "fedora" || $ID == "rhel" ]]; then
            SYSTEM_TYPE="centos"
        else
            echo -e "${RED}不支持的系统类型: $ID${NC}"
            exit 1
        fi
    else
        echo -e "${RED}无法读取 /etc/os-release 文件，无法确定系统类型${NC}"
        exit 1
    fi
}

# 一级选项
function main_menu {
    echo -e "${YELLOW}欢迎使用环境配置脚本！${NC}"
    echo -e "${YELLOW}1: ${WHITE}wget配置${NC}"
    echo -e "${YELLOW}2: ${WHITE}Docker配置${NC}"
    echo -e "${YELLOW}3: ${WHITE}宝塔配置${NC}"
    echo -e "${YELLOW}4: ${WHITE}TCP调优${NC}"
    echo -e "${YELLOW}5: ${WHITE}Curl配置${NC}"
    echo -e "${YELLOW}6: ${WHITE}BBR3配置${NC}"
    echo -e "${YELLOW}0: ${WHITE}退出脚本${NC}"
}

# 二级选项 wget 配置
function wget_menu {
    echo -e "${YELLOW}1: ${WHITE}安装${NC}"
    echo -e "${YELLOW}2: ${WHITE}卸载${NC}"
    echo -e "${YELLOW}3: ${WHITE}返回上级菜单${NC}"
}

# 二级选项 Docker 配置
function docker_menu {
    echo -e "${YELLOW}1: ${WHITE}安装${NC}"
    echo -e "${YELLOW}2: ${WHITE}卸载${NC}"
    echo -e "${YELLOW}3: ${WHITE}返回上级菜单${NC}"
}

# 二级选项 宝塔配置
function bt_menu {
    echo -e "${YELLOW}1: ${WHITE}安装中文宝塔${NC}"
    echo -e "${YELLOW}2: ${WHITE}安装国际宝塔${NC}"
    echo -e "${YELLOW}0: ${WHITE}返回上级菜单${NC}"
}

# 二级选项 TCP调优
function tcp_tuning_menu {
    echo -e "${YELLOW}1: ${WHITE}运行 TCP调优脚本${NC}"
    echo -e "${YELLOW}2: ${WHITE}返回上级菜单${NC}"
}

# 二级选项 Curl 配置
function curl_menu {
    echo -e "${YELLOW}1: ${WHITE}安装${NC}"
    echo -e "${YELLOW}2: ${WHITE}卸载${NC}"
    echo -e "${YELLOW}3: ${WHITE}返回上级菜单${NC}"
}

# 二级选项 BBR3配置
function bbr3_menu {
    echo -e "${YELLOW}1: ${WHITE}安装${NC}"
    echo -e "${YELLOW}2: ${WHITE}还原${NC}"
    echo -e "${YELLOW}3: ${WHITE}卸载${NC}"
    echo -e "${YELLOW}4: ${WHITE}返回上级菜单${NC}"
}

# 获取系统类型
detect_system

while true; do
    main_menu
    read -p "请选择一级选项 (输入对应数字): " main_choice

    case $main_choice in
        1)
            while true; do
                wget_menu
                read -p "请选择 wget 配置选项 (输入对应数字): " wget_choice
                case $wget_choice in
                    1)
                        # 安装 wget
                        if [[ $SYSTEM_TYPE == "debian" ]]; then
                            sudo apt-get update
                            sudo apt-get install -y wget
                        elif [[ $SYSTEM_TYPE == "centos" ]]; then
                            sudo yum install -y wget
                        fi
                        ;;
                    2)
                        # 卸载 wget
                        if [[ $SYSTEM_TYPE == "debian" ]]; then
                            sudo apt-get remove -y wget
                        elif [[ $SYSTEM_TYPE == "centos" ]]; then
                            sudo yum remove -y wget
                        fi
                        ;;
                    3)
                        # 返回上级菜单
                        break
                        ;;
                    *)
                        echo -e "${RED}无效的选择${NC}"
                        ;;
                esac
            done
            ;;
        2)
            while true; do
                docker_menu
                read -p "请选择 Docker 配置选项 (输入对应数字): " docker_choice
                case $docker_choice in
                    1)
                        # 安装 Docker
                        if [[ $SYSTEM_TYPE == "debian" ]]; then
                            sudo apt-get update
                            sudo apt-get install -y docker.io
                        elif [[ $SYSTEM_TYPE == "centos" ]]; then
                            sudo yum install -y docker
                        fi
                        ;;
                    2)
                        # 卸载 Docker
                        if [[ $SYSTEM_TYPE == "debian" ]]; then
                            sudo apt-get remove -y docker.io
                        elif [[ $SYSTEM_TYPE == "centos" ]]; then
                            sudo yum remove -y docker
                        fi
                        ;;
                    3)
                        # 返回上级菜单
                        break
                        ;;
                    *)
                        echo -e "${RED}无效的选择${NC}"
                        ;;
                esac
            done
            ;;
        3)
            while true; do
                bt_menu
                read -p "请选择宝塔配置选项 (输入对应数字): " bt_choice
                case $bt_choice in
                    1)
                        # 安装中文宝塔
                        if [[ $SYSTEM_TYPE == "debian" ]]; then
                            sudo apt-get install -y wget && wget -O install.sh https://download.bt.cn/install/install_6.0.sh && sh install.sh ed8484bec
                        elif [[ $SYSTEM_TYPE == "centos" ]]; then
                            sudo yum install -y wget && wget -O install.sh https://download.bt.cn/install/install_6.0.sh && sh install.sh ed8484bec
                        fi
                        ;;
                    2)
                        # 安装国际宝塔
                        if [[ $SYSTEM_TYPE == "debian" ]]; then
                            sudo apt-get install -y wget && wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh && bash install.sh aapanel
                        elif [[ $SYSTEM_TYPE == "centos" ]]; then
                            sudo yum install -y wget && wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh && bash install.sh aapanel
                        fi
                        ;;
                    0)
                        # 返回上级菜单
                        break
                        ;;
                    *)
                        echo -e "${RED}无效的选择${NC}"
                        ;;
                esac
            done
            ;;
        4)
            while true; do
                tcp_tuning_menu
                read -p "请选择 TCP调优 配置选项 (输入对应数字): " tcp_choice
                case $tcp_choice in
                    1)
                        # 运行 TCP调优脚本
                        wget http://sh.nekoneko.cloud/tools.sh -O tools.sh && bash tools.sh
                        ;;
                    2)
                        # 返回上级菜单
                        break
                        ;;
                    *)
                        echo -e "${RED}无效的选择${NC}"
                        ;;
                esac
            done
            ;;
        5)
            while true; do
                curl_menu
                read -p "请选择 Curl 配置选项 (输入对应数字): " curl_choice
                case $curl_choice in
                    1)
                        # 安装 Curl
                        if [[ $SYSTEM_TYPE == "debian" ]]; then
                            sudo apt-get update
                            sudo apt-get install -y curl
                        elif [[ $SYSTEM_TYPE == "centos" ]]; then
                            sudo yum install -y curl
                        fi
                        ;;
                    2)
                        # 卸载 Curl
                        if [[ $SYSTEM_TYPE == "debian" ]]; then
                            sudo apt-get remove -y curl
                        elif [[ $SYSTEM_TYPE == "centos" ]]; then
                            sudo yum remove -y curl
                        fi
                        ;;
                    3)
                        # 返回上级菜单
                        break
                        ;;
                    *)
                        echo -e "${RED}无效的选择${NC}"
                        ;;
                esac
            done
            ;;
        6)
            while true; do
                bbr3_menu
                read -p "请选择 BBR3 配置选项 (输入对应数字): " bbr3_choice
                case $bbr3_choice in
                    1)
                        # 安装 BBR3
                        backup_bbr
                        bash <(curl -sSL https://raw.githubusercontent.com/WuYtUgXw/almasoga/main/bbr3.sh)
                        ;;
                    2)
                        # 还原 BBR
                        restore_bbr
                        ;;
                    3)
                        # 卸载 BBR
                        uninstall_bbr
                        ;;
                    4)
                        # 返回上级菜单
                        break
                        ;;
                    *)
                        echo -e "${RED}无效的选择${NC}"
                        ;;
                esac
            done
            ;;
        0)
            # 退出脚本
            echo -e "${GREEN}脚本执行完成${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}无效的选择${NC}"
            ;;
    esac
done

# 备份BBR
function backup_bbr {
    if [[ $SYSTEM_TYPE == "debian" ]]; then
        sudo cp /usr/lib/modules/$(uname -r)/kernel/net/ipv4/tcp_bbr/bbr.ko /usr/lib/modules/$(uname -r)/kernel/net/ipv4/tcp_bbr/bbr.ko.bak
    elif [[ $SYSTEM_TYPE == "centos" ]]; then
        sudo cp /lib/modules/$(uname -r)/kernel/net/ipv4/tcp_bbr/bbr.ko /lib/modules/$(uname -r)/kernel/net/ipv4/tcp_bbr/bbr.ko.bak
    fi
}

# 还原BBR
function restore_bbr {
    if [[ $SYSTEM_TYPE == "debian" ]]; then
        sudo cp /usr/lib/modules/$(uname -r)/kernel/net/ipv4/tcp_bbr/bbr.ko.bak /usr/lib/modules/$(uname -r)/kernel/net/ipv4/tcp_bbr/bbr.ko
    elif [[ $SYSTEM_TYPE == "centos" ]]; then
        sudo cp /lib/modules/$(uname -r)/kernel/net/ipv4/tcp_bbr/bbr.ko.bak /lib/modules/$(uname -r)/kernel/net/ipv4/tcp_bbr/bbr.ko
    fi
}

# 卸载BBR
function uninstall_bbr {
    if [[ $SYSTEM_TYPE == "debian" ]]; then
        sudo rm -f /usr/lib/modules/$(uname -r)/kernel/net/ipv4/tcp_bbr/bbr.ko
    elif [[ $SYSTEM_TYPE == "centos" ]]; then
        sudo rm -f /lib/modules/$(uname -r)/kernel/net/ipv4/tcp_bbr/bbr.ko
    fi
}
