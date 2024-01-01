#!/bin/bash

# 自定义颜色
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# 捕获 Ctrl+C 信号
trap ctrl_c INT

function ctrl_c() {
    echo -e "${red}脚本已中断${plain}"
    exit 1
}

# 检测系统类型
if [ -f /etc/redhat-release ]; then
    # CentOS
    echo -e "${green}检测到 CentOS 系统${plain}"
    # 检测是否存在 wget
    if command -v wget &> /dev/null; then
        echo -e "${green}系统已安装 wget${plain}"
    else
        # 安装 wget
        echo -e "${yellow}系统未安装 wget，开始安装${plain}"
        yum install wget -y
        echo -e "${green}wget 安装成功${plain}"
    fi
elif [ -f /etc/debian_version ]; then
    # Debian
    echo -e "${green}检测到 Debian 系统${plain}"
    # 检测是否存在 wget
    if command -v wget &> /dev/null; then
        echo -e "${green}系统已安装 wget${plain}"
    else
        # 安装 wget
        echo -e "${yellow}系统未安装 wget，开始安装${plain}"
        apt-get install wget -y
        echo -e "${green}wget 安装成功${plain}"
    fi
else
    # 未知系统
    echo -e "${red}未检测到 CentOS 或 Debian 系统${plain}"
    exit 1
fi

# 检测是否存在 /etc/soga 文件夹
if [ ! -d /etc/soga ]; then
    # 不存在 /etc/soga 文件夹
    echo -e "${yellow}/etc/soga 文件夹不存在，开始安装 soga${plain}"
    
    # 运行 soga 安装脚本
    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)

    # 安装完成后触发 Ctrl+C 中断脚本
    echo -e "${green}soga 安装完成，脚本将中断${plain}"
    ctrl_c
else
    # 存在 /etc/soga 文件夹
    echo -e "${green}/etc/soga 文件夹已存在${plain}"
    exit 0
fi
