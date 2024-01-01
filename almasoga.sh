#!/bin/bash

# 自定义颜色
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

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
fi

if [ -f /etc/debian_version ]; then
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
fi

# 检测是否存在 /etc/soga 文件夹
if [ ! -d /etc/soga ]; then
    # 不存在 /etc/soga 文件夹
    echo -e "${yellow}/etc/soga 文件夹不存在，开始安装 soga${plain}"
    
    # 运行 soga 安装脚本
    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)

    # 安装完成后输出消息
    echo -e "${green}soga 安装完成${plain}"
else
    # 存在 /etc/soga 文件夹
    echo -e "${green}/etc/soga 文件夹已存在，跳过 soga 安装${plain}"
fi

# 脚本执行完毕
exit 0
