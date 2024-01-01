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
if [ -d /etc/soga ]; then
    # 存在 /etc/soga 文件夹，删除
    echo -e "${yellow}/etc/soga 文件夹已存在，删除后重新安装 soga${plain}"
    rm -rf /etc/soga
fi

# 不存在 /etc/soga 文件夹，开始安装 soga
echo -e "${yellow}/etc/soga 文件夹不存在，开始安装 soga${plain}"
bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)

# 安装完成后输出消息
echo -e "${green}soga 安装完成${plain}"

# 显示欢迎消息
echo -e "\n欢迎使用 Damian 的 soga 配置脚本！"

# 提示用户选择功能
echo -e "\n请选择要执行的功能："
echo -e "1. 功能一"
echo -e "2. 功能二"
echo -e "3. 功能三"

# 读取用户输入
read -p "请输入功能编号（1、2、3）: " function_number

# 根据用户输入执行不同的功能
case $function_number in
    1)
        echo -e "执行功能一"
        # 添加功能一的具体操作
        ;;
    2)
        echo -e "执行功能二"
        # 添加功能二的具体操作
        ;;
    3)
        echo -e "执行功能三"
        # 添加功能三的具体操作
        ;;
    *)
        echo -e "${red}无效的功能编号${plain}"
        ;;
esac

# 脚本执行完毕
exit 0
