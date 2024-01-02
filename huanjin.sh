#!/bin/bash

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# 一级选项
function main_menu {
    echo -e "${YELLOW}欢迎使用环境配置脚本！${NC}"
    echo -e "${YELLOW}1: ${WHITE}wget配置${NC}"
    echo -e "${YELLOW}2: ${WHITE}Docker配置${NC}"
    echo -e "${YELLOW}3: ${WHITE}MySQL配置${NC}"
    echo -e "${YELLOW}4: ${WHITE}TCP调优${NC}"
    echo -e "${YELLOW}5: ${WHITE}Curl配置${NC}"
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

# 二级选项 MySQL 配置
function mysql_menu {
    echo -e "${YELLOW}1: ${WHITE}安装${NC}"
    echo -e "${YELLOW}2: ${WHITE}卸载${NC}"
    echo -e "${YELLOW}3: ${WHITE}返回上级菜单${NC}"
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
                        sudo apt-get update
                        sudo apt-get install -y wget
                        ;;
                    2)
                        # 卸载 wget
                        sudo apt-get remove -y wget
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
                        sudo apt-get update
                        sudo apt-get install -y docker.io
                        ;;
                    2)
                        # 卸载 Docker
                        sudo apt-get remove -y docker.io
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
                mysql_menu
                read -p "请选择 MySQL 配置选项 (输入对应数字): " mysql_choice
                case $mysql_choice in
                    1)
                        # 安装 MySQL
                        sudo apt-get update
                        sudo apt-get install -y mysql-server
                        ;;
                    2)
                        # 卸载 MySQL
                        sudo apt-get remove -y mysql-server
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
                        sudo apt-get update
                        sudo apt-get install -y curl
                        ;;
                    2)
                        # 卸载 Curl
                        sudo apt-get remove -y curl
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
