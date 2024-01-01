#!/bin/bash

# 自定义颜色和字体大小
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
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
if [ -d /etc/soga ]; then
    # 存在 /etc/soga 文件夹，删除
    echo -e "${yellow}/etc/soga 文件夹已存在，删除后重新安装 soga${plain}"
    rm -rf /etc/soga
fi

# 不存在 /etc/soga 文件夹，开始安装 soga
echo -e "${yellow}/etc/soga 文件夹不存在，开始安装 soga${plain}"
bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)

# 安装完成后输出消息
echo -e "${yellow}欢迎使用 涩龙 的 soga 配置脚本！${plain}"

# 提示用户选择功能
echo -e "\n请选择要执行的功能："
echo -e "${red}1. 功能一${plain}"
echo -e "${red}2. 功能二${plain}"
echo -e "${red}3. 功能三${plain}"

# 读取用户输入
read -p "${yellow}请输入功能编号（1、2、3）: ${plain}" function_number

# 根据用户输入执行不同的功能
case $function_number in
    1)
        echo -e "${red}执行功能一${plain}"
        # 添加功能一的具体操作
        ;;
    2)
        echo -e "${red}执行功能二${plain}"
        # 添加功能二的具体操作
        ;;
    3)
        echo -e "${red}执行功能三${plain}"
        # 添加功能三的具体操作
        ;;
    *)
        echo -e "${red}无效的功能编号${plain}"
        ;;
esac

# 脚本执行完毕
exit 0
