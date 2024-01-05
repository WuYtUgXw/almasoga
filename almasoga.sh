#!/bin/bash

# 自定义颜色和字体大小
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
yellow_light='\033[2;36m'
plain='\033[0m'

# 检测系统类型
if [ -f /etc/redhat-release ]; then
    # CentOS
    system_type="centos"
elif [ -f /etc/debian_version ]; then
    # Debian
    system_type="debian"
else
    echo -e "${red}不支持的系统类型${plain}"
    exit 1
fi

# 检测是否存在 /etc/soga 文件夹
if [ -d /etc/soga ]; then
    # 脚本已安装 soga，执行以下操作

    # 提示用户选择功能
    echo -e "${yellow}欢迎使用 涩龙 的 soga 配置脚本！${plain}"

    # 循环执行功能
    while true; do
        # 显示功能列表
        echo -e "${red}请选择要执行的功能：${plain}"
        echo -e "${green}1. Soga配置${plain}"
        echo -e "${green}2. 解锁配置${plain}"
        echo -e "${green}3. 审计配置${plain}"
        echo -e "${green}4. Soga重装${plain}"
        echo -e "${green}5. 流媒体测试${plain}"
        echo -e "${green}0. 退出脚本${plain}"

        # 读取用户输入
        read -p "$(echo -e "${yellow}输入编号: ${plain}")" function_number

        # 根据用户输入执行不同的功能
        case $function_number in
            1)
                # Soga配置
                soga_config
                ;;
            2)
                # 解锁配置
                unlock_config
                ;;
            3)
                # 审计配置
                audit_config
                ;;
            4)
                # Soga重装
                soga_reinstall
                ;;
            5)
                # 流媒体测试
                streaming_test
                ;;
            0)
                # 退出脚本
                exit 0
                ;;
            *)
                # 无效的操作编号
                echo -e "${red}无效的操作编号${plain}"
                exit 1
                ;;
        esac
    done
else
    # 脚本未安装 soga，执行以下操作

    # 安装 soga
    install_soga
fi
