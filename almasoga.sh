#!/bin/bash

# 自定义颜色和字体大小
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
yellow_light='\033[2;36m'
plain='\033[0m'

# 检测是否存在 /etc/soga 文件夹
if [ -d /etc/soga ]; then 
    echo -e "${green}/etc/soga 文件夹已存在，跳过安装 soga${plain}"
else
    # 检测系统类型
    if [ -f /etc/redhat-release ]; then
        # CentOS
        echo -e "${yellow}检测到 CentOS 系统${plain}"
        if command -v wget &> /dev/null; then
            echo -e "${green}系统已安装 wget${plain}"
        else
            echo -e "${green}系统未安装 wget，开始安装${plain}"
            yum install wget -y
            if [ $? -eq 0 ]; then
                echo -e "${green}wget 安装成功${plain}"
            else
                echo -e "${red}wget 安装失败${plain}"
                exit 1
            fi
        fi
    elif [ -f /etc/debian_version ]; then
        # Debian
        echo -e "${yellow}检测到 Debian 系统${plain}"
        if command -v wget &> /dev/null; then
            echo -e "${green}系统已安装 wget${plain}"
        else
            echo -e "${green}系统未安装 wget，开始安装${plain}"
            apt-get install wget -y
            if [ $? -eq 0 ]; then
                echo -e "${green}wget 安装成功${plain}"
            else
                echo -e "${red}wget 安装失败${plain}"
                exit 1
            fi
        fi
    else
        echo -e "${red}不支持的系统类型${plain}"
        exit 1
    fi

    echo -e "${green}/etc/soga 文件夹不存在，开始安装 soga${plain}"
    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)
    if [ $? -eq 0 ]; then
        echo -e "${green}soga 安装成功${plain}"
    else
        echo -e "${red}soga 安装失败${plain}"
        exit 1
    fi
fi

# 脚本执行完毕
while true; do
    echo -e "${yellow_light}欢迎使用 涩龙 的 soga 配置脚本！${plain}"

    if [ -d /etc/soga ]; then
        echo -e "${red}请选择要执行的功能：${plain}"
        echo -e "${green}1. Soga配置${plain}"
        echo -e "${green}2. 解锁配置${plain}"
        echo -e "${green}3. 审计配置${plain}"
        echo -e "${green}4. Soga重装${plain}"
        echo -e "${green}5. 流媒体测试${plain}"
        echo -e "${green}6. 设置中国时区 UTC+8${plain}"
        echo -e "${green}0. 退出脚本${plain}"

        read -p "$(echo -e "${yellow}输入编号: ${plain}")" function_number

        case $function_number in
            1)
                echo -e "${green}Soga配置${plain}"
                # 省略详细代码（如需详细内容可参考原始脚本）
                ;;
            2)
                echo -e "${green}解锁配置${plain}"
                # 省略详细代码（如需详细内容可参考原始脚本）
                ;;
            3)
                echo -e "${green}审计配置${plain}"
                # 省略详细代码（如需详细内容可参考原始脚本）
                ;;
            4)
                echo -e "${green}Soga重装${plain}"
                read -p "$(echo -e "${yellow}您确定要重新安装 Soga 吗？ (yes/no): ${plain}")" reinstall_choice
                if [ "$reinstall_choice" == "yes" ] || [ "$reinstall_choice" == "y" ]; then
                    rm -rf /etc/soga
                    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)
                    if [ $? -eq 0 ]; then
                        echo -e "${green}soga 重新安装成功${plain}"
                    else
                        echo -e "${red}soga 安装失败${plain}"
                        exit 1
                    fi
                else
                    echo -e "${yellow_light}Soga 重装已取消${plain}"
                fi
                ;;
            5)
                echo -e "${green}流媒体测试${plain}"
                bash <(curl -L -s https://raw.githubusercontent.com/WuYtUgXw/almasoga/main/stream.sh)
                ;;
            6)
                echo -e "${green}设置中国时区 UTC+8${plain}"

                current_timezone=$(timedatectl | grep "Time zone" | awk '{print $3}')
                echo -e "${yellow}当前时区: ${green}$current_timezone${plain}"

                timedatectl set-timezone Asia/Shanghai
                if [ $? -eq 0 ]; then
                    echo -e "${green}时区已成功设置为中国时区 UTC+8${plain}"
                else
                    echo -e "${red}时区设置失败，请检查权限或环境${plain}"
                    exit 1
                fi

                new_timezone=$(timedatectl | grep "Time zone" | awk '{print $3}')
                echo -e "${yellow}新时区: ${green}$new_timezone${plain}"
                ;;
            0)
                echo -e "${yellow_light}退出脚本${plain}"
                exit 0
                ;;
            *)
                echo -e "${red}无效的操作编号${plain}"
                ;;
        esac
    fi
done
