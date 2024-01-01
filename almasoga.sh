#!/bin/bash

# 自定义颜色和字体大小
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
yellow_light='\033[0;33m'
plain='\033[0m'

# 检测系统类型
if [ -f /etc/redhat-release ]; then
    # CentOS
    echo -e "${yellow}检测到 CentOS 系统${plain}"
    # 检测是否存在 wget
    if command -v wget &> /dev/null; then
        echo -e "${yellow}系统已安装 wget${plain}"
    else
        # 安装 wget
        echo -e "${yellow_light}系统未安装 wget，开始安装${plain}"
        yum install wget -y
        echo -e "${yellow}wget 安装成功${plain}"
    fi
fi

if [ -f /etc/debian_version ]; then
    # Debian
    echo -e "${yellow}检测到 Debian 系统${plain}"
    # 检测是否存在 wget
    if command -v wget &> /dev/null; then
        echo -e "${yellow}系统已安装 wget${plain}"
    else
        # 安装 wget
        echo -e "${yellow_light}系统未安装 wget，开始安装${plain}"
        apt-get install wget -y
        echo -e "${yellow}wget 安装成功${plain}"
    fi
fi

# 检测是否存在 /etc/soga 文件夹
if [ -d /etc/soga ]; then
    # 提示用户选择是否删除现有的 soga
    read -p "$(echo -e "${yellow}是否删除现有 soga 并重新安装？${plain}") [1. 跳过安装 / 2. 删除并安装]: " reinstall_option

    case $reinstall_option in
        1)
            echo -e "${yellow}跳过安装 soga${plain}"
            ;;
        2)
            echo -e "${yellow}删除现有 soga 并重新安装${plain}"
            rm -rf /etc/soga
            ;;
        *)
            echo -e "${yellow_light}无效的选项，跳过安装 soga${plain}"
            ;;
    esac
fi

# 如果不存在 /etc/soga 文件夹，则开始安装 soga
if [ ! -d /etc/soga ]; then
    echo -e "${yellow_light}/etc/soga 文件夹不存在，开始安装 soga${plain}"
    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)
    echo -e "${yellow}soga 安装成功${plain}"
fi

# 安装完成后输出消息
echo -e "${yellow}欢迎使用 Damian 的 soga 配置脚本！${plain}"

# 提示用户选择功能
echo -e "${yellow}请选择要执行的功能：${plain}"
echo -e "${yellow_light}1. Soga配置${plain}"
echo -e "${yellow_light}2. 解锁配置${plain}"
echo -e "${yellow_light}3. 审计配置${plain}"

# 读取用户输入
read -p "$(echo -e "${yellow}输入编号: ${plain}")" function_number

# 根据用户输入执行不同的功能
case $function_number in
    1)
        echo -e "${yellow_light}Soga配置${plain}"
        # Soga配置的具体操作
        ;;
    2)
        echo -e "${yellow_light}解锁配置${plain}"
        # 下载 https://github.com/WuYtUgXw/almasoga 的配置文件并替换 /etc/soga 原有的配置
        wget -O /etc/soga/soga.conf https://github.com/WuYtUgXw/almasoga/raw/main/soga.conf
        echo -e "${yellow_light}解锁配置替换成功${plain}"
        ;;
    3)
        echo -e "${yellow_light}审计配置${plain}"
        # 提示用户选择操作类型
        read -p "$(echo -e "${yellow_light}请选择操作类型：${plain} [1. 删除审计 / 2. 增加审计]: ")" audit_option

        case $audit_option in
            1)
                echo -e "${yellow_light}删除审计${plain}"
                # 删除 /etc/soga/blockList 文件内容
                echo -n > /etc/soga/blockList
                echo -e "${yellow_light}删除成功${plain}"
                ;;
            2)
                echo -e "${yellow_light}增加审计${plain}"
                # 下载 https://github.com/WuYtUgXw/almasoga 的 blockList 并替换 /etc/soga 原有的 blockList
                wget -O /etc/soga/blockList https://github.com/WuYtUgXw/almasoga/raw/main/blockList
                echo -e "${yellow_light}blockList 替换成功${plain}"
                ;;
            *)
                echo -e "${yellow_light}无效的选项${plain}"
                ;;
        esac
        ;;
    *)
        echo -e "${yellow_light}无效的操作编号${plain}"
        ;;
esac

# 脚本执行完毕
exit 0
