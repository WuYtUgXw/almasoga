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
    # 提示用户选择是否删除现有的 soga
    read -p "$(echo -e "${red}是否删除现有 soga 并重新安装？${plain}") [1. 跳过安装 / 2. 删除并安装]: " reinstall_option

    case $reinstall_option in
        1)
            echo -e "${yellow}跳过安装 soga${plain}"
            ;;
        2)
            echo -e "${yellow}删除现有 soga 并重新安装${plain}"
            rm -rf /etc/soga
            ;;
        *)
            echo -e "${red}无效的选项，跳过安装 soga${plain}"
            ;;
    esac
fi

# 如果不存在 /etc/soga 文件夹，则开始安装 soga
if [ ! -d /etc/soga ]; then
    echo -e "${yellow}/etc/soga 文件夹不存在，开始安装 soga${plain}"
    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)
    echo -e "${green}soga 安装成功${plain}"
fi

# 安装完成后输出消息
echo -e "${yellow}欢迎使用 Damian 的 soga 配置脚本！${plain}"

# 提示用户选择功能
echo -e "\n请选择要执行的功能："
echo -e "${red}1. 审计配置${plain}"
echo -e "${red}2. 替换为 https://github.com/WuYtUgXw/almasoga 的 blockList${plain}"
echo -e "${red}3. 其他功能${plain}"

# 读取用户输入
read -p "$(echo -e "${yellow}请输入功能编号（1、2、3）: ${plain}")" function_number

# 根据用户输入执行不同的功能
case $function_number in
    1)
        echo -e "${red}审计配置${plain}"
        # 提示用户选择操作类型
        read -p "$(echo -e "${red}请选择操作类型：${plain} [1. 删除审计规则 / 2. 增加审计规则]: ")" audit_option

        case $audit_option in
            1)
                echo -e "${red}删除审计规则${plain}"
                # 删除 /etc/soga/blockList 文件内容
                echo -n > /etc/soga/blockList
                echo -e "${green}删除成功${plain}"
                ;;
            2)
                echo -e "${red}增加审计规则${plain}"
                # 下载 https://github.com/WuYtUgXw/almasoga 的 blockList 并替换 /etc/soga 原有的 blockList
                wget -O /etc/soga/blockList https://github.com/WuYtUgXw/almasoga/raw/main/blockList
                echo -e "${green}blockList 替换成功${plain}"
                ;;
            *)
                echo -e "${red}无效的选项${plain}"
                ;;
        esac
        ;;
    2)
        echo -e "${red}增加审计配置${plain}"
        # 下载 https://github.com/WuYtUgXw/almasoga 的 blockList 并替换 /etc/soga 原有的 blockList
        wget -O /etc/soga/blockList https://github.com/WuYtUgXw/almasoga/raw/main/blockList
        echo -e "${green}blockList 替换成功${plain}"
        ;;
    3)
        echo -e "${red}其他功能，暂未实现${plain}"
        # 添加其他功能的具体操作
        ;;
    *)
        echo -e "${red}无效的操作编号${plain}"
        ;;
esac

# 脚本执行完毕
exit 0
