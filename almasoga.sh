#!/bin/bash

# Custom colors and font size
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
yellow_light='\033[2;36m'
blink='\033[5m'
plain='\033[0m'

# Check if /etc/soga folder exists
if [ -d /etc/soga ]; then 
    echo -e "${green}/etc/soga 文件夹已存在，跳过安装 soga${plain}"
else
    # Check the system type
    if [ -f /etc/redhat-release ]; then
        # CentOS
        echo -e "${yellow}检测到 CentOS 系统${plain}"
        # Check if wget is installed
        if command -v wget &> /dev/null; then
            echo -e "${green}系统已安装 wget${plain}"
        else
            # Install wget
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
        # Check if wget is installed
        if command -v wget &> /dev/null; then
            echo -e "${green}系统已安装 wget${plain}"
        else
            # Install wget
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

    # Start installing soga
    echo -e "${green}/etc/soga 文件夹不存在，开始安装 soga${plain}"
    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)
    if [ $? -eq 0 ]; then
        echo -e "${green}soga 安装成功${plain}"
    else
        echo -e "${red}soga 安装失败${plain}"
        exit 1
    fi
fi

# Script execution complete
while true; do
    # After installation, display a welcome message
    echo -e "${yellow_light}${blink}欢迎使用 涩龙 的 soga 配置脚本！${plain}"

    # Check if /etc/soga folder exists
    if [ -d /etc/soga ]; then
        # Prompt the user to choose a function
        echo -e "${red}${blink}请选择要执行的功能：${plain}"
        echo -e "${green}${blink}1. Soga配置${plain}"
        echo -e "${green}${blink}2. 解锁配置${plain}"
        echo -e "${green}${blink}3. 审计配置${plain}"
        echo -e "${green}${blink}4. Soga重装${plain}"
        echo -e "${green}${blink}5. 流媒体测试${plain}"
        echo -e "${green}${blink}0. 退出脚本${plain}"

        # Read user input
        read -p "$(echo -e "${yellow}${blink}输入编号: ${plain}")" function_number

        # Execute different functions based on user input
        case $function_number in
            1)
                echo -e "${green}${blink}Soga配置${plain}"

                # Prompt the user to choose the type of operation
                read -p "$(echo -e "${yellow}${blink}请选择操作类型：${plain} [1. 文件配置 / 2. 修改配置]: ")" config_option

                case $config_option in
                    1)
                        echo -e "${green}${blink}下载配置文件${plain}"

                        # Enter /etc/soga, download https://github.com/WuYtUgXw/almasoga's soga.conf and replace the original soga.conf
                        wget -O /etc/soga/soga.conf https://github.com/WuYtUgXw/almasoga/raw/main/soga.conf
                        if [ $? -eq 0 ]; then
                            echo -e "${green}soga.conf 替换成功${plain}"
                        else
                            echo -e "${red}soga.conf 替换失败${plain}"
                            exit 1
                        fi

                        # Prompt for "node_id", which will be filled in after "node_id=" in /etc/soga/soga.conf
                        read -p "$(echo -e "${yellow}${blink}请输入编号：${plain}")" node_id
                        sed -i "s/node_id=/node_id=$node_id/" /etc/soga/soga.conf

                        # Save and restart the soga service
                        systemctl restart soga
                        if [ $? -eq 0 ]; then
                            echo -e "${green}Soga配置已更新并服务已重启${plain}"
                        else
                            echo -e "${red}Soga服务重启失败${plain}"
                            exit 1
                        fi
                        ;;
                    2)
                        echo -e "${green}${blink}修改配置文件${plain}"

                        # Prompt for "node_id", which will change /etc/soga/soga.conf's node_id=
                        read -p "$(echo -e "${yellow}${blink}请输入新的编号：${plain}")" new_node_id
                        sed -i "s/node_id=.*/node_id=$new_node_id/" /etc/soga/soga.conf

                        # Save and restart the soga service
                        systemctl restart soga
                        if [ $? -eq 0 ]; then
                            echo -e "${green}Soga配置已更新并服务已重启${plain}"
                        else
                            echo -e "${red}Soga服务重启失败${plain}"
                            exit 1
                        fi
                        ;;
                    *)
                        echo -e "${red}${blink}无效的选项${plain}"
                        exit 1
                        ;;
                esac
                ;;
            2)
                echo -e "${green}${blink}解锁配置${plain}"
                
                # Prompt the user to choose the type of unlocking configuration
                read -p "$(echo -e "${yellow}${blink}请选择解锁配置的类型：${plain} [1. DNS解锁 / 2. DNS修改]: ")" unlock_option

                case $unlock_option in
                    1)
                        echo -e "${green}${blink}DNS解锁${plain}"

                        # Download https://github.com/WuYtUgXw/almasoga's dns.yml and replace /etc/soga's original dns.yml
                        wget -O /etc/soga/dns.yml https://github.com/WuYtUgXw/almasoga/raw/main/dns.yml
                        if [ $? -eq 0 ]; then
                            echo -e "${green}dns.yml 替换成功${plain}"
                        else
                            echo -e "${red}dns.yml 替换失败${plain}"
                            exit 1
                        fi

                        # Prompt for "region abbreviation", e.g., entering "hk" will modify /etc/soga's dns.yml from sin.core to hkg.core
                        read -p "$(echo -e "${yellow}${blink}请输入地区缩写：${plain}")" region_abbr

                        case $region_abbr in
                            hk)
                                sed -i "s/sin.core/hkg.core/" /etc/soga/dns.yml
                                ;;
                            sg)
                                sed -i "s/sin.core/sin.core/" /etc/soga/dns.yml
                                ;;
                            jp)
                                sed -i "s/sin.core/nrt.core/" /etc/soga/dns.yml
                                ;;
                            us)
                                sed -i "s/sin.core/lax.core/" /etc/soga/dns.yml
                                ;;
                            *)
                                echo -e "${red}无效的地区缩写${plain}"
                                exit 1
                                ;;
                        esac

                        echo -e "${green}DNS解锁配置已完成${plain}"
                        ;;
                    2)
                        echo -e "${green}${blink}DNS修改${plain}"

                        # Prompt for "region abbreviation", e.g., entering "hk" will modify /etc/soga's dns.yml from sin.core to hkg.core
                        read -p "$(echo -e "${yellow}${blink}请输入地区缩写：${plain}")" region_abbr

                        case $region_abbr in
                            hk)
                                replace_rules="s/sin.core/hkg.core/;s/hkg.core/hkg.core/;s/nrt.core/hkg.core/;s/lax.core/hkg.core/;"
                                ;;
                            sg)
                                replace_rules="s/sin.core/sin.core/;s/hkg.core/sin.core/;s/nrt.core/sin.core/;s/lax.core/sin.core/;"
                                ;;
                            jp)
                                replace_rules="s/sin.core/nrt.core/;s/hkg.core/nrt.core/;s/nrt.core/nrt.core/;s/lax.core/nrt.core/;"
                                ;;
                            us)
                                replace_rules="s/sin.core/lax.core/;s/hkg.core/lax.core/;s/nrt.core/lax.core/;s/lax.core/lax.core/;"
                                ;;
                            *)
                                echo -e "${red}无效的地区缩写: $region_abbr${plain}"
                                exit 1
                                ;;
                        esac

                        # Apply replacement rules
                        sed -i "${replace_rules}" /etc/soga/dns.yml

                        echo -e "${green}DNS修改配置已完成${plain}"
                        ;;
                    *)
                        echo -e "${red}${blink}无效的选项${plain}"
                        exit 1
                        ;;
                esac
                ;;
            3)
                echo -e "${green}${blink}审计配置${plain}"
                
                # Prompt the user to choose the type of operation
                read -p "$(echo -e "${yellow}${blink}请选择操作类型：${plain} [1. 删除审计 / 2. 增加审计]: ")" audit_option

                case $audit_option in
                    1)
                        echo -e "${green}${blink}删除审计${plain}"
                        # Clear /etc/soga/blockList file content
                        echo -n > /etc/soga/blockList
                        if [ $? -eq 0 ]; then
                            echo -e "${green}删除成功${plain}"
                        else
                            echo -e "${red}删除失败${plain}"
                            exit 1
                        fi
                        ;;
                    2)
                        echo -e "${green}${blink}增加审计${plain}"
                        # Download https://github.com/WuYtUgXw/almasoga's blockList and replace /etc/soga's original blockList
                        wget -O /etc/soga/blockList https://github.com/WuYtUgXw/almasoga/raw/main/blockList
                        if [ $? -eq 0 ]; then
                            echo -e "${green}blockList 替换成功${plain}"
                        else
                            echo -e "${red}blockList 替换失败${plain}"
                            exit 1
                        fi
                        ;;
                    *)
                        echo -e "${green}${blink}无效的选项${plain}"
                        exit 1
                        ;;
                esac
                ;;
            4)
                echo -e "${green}${blink}Soga重装${plain}"
                
                # Prompt for confirmation
                read -p "$(echo -e "${yellow}${blink}您确定要重新安装 Soga 吗？ (yes/no): ${plain}")" reinstall_choice

                if [ "$reinstall_choice" == "yes" ] || [ "$reinstall_choice" == "y" ]; then
                    echo -e "${yellow_light}${blink}正在删除 /etc/soga...${plain}"
                    rm -rf /etc/soga

                    # Proceed with the installation
                    echo -e "${green}${blink}/etc/soga 文件夹已删除，开始重新安装 soga${plain}"
                    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)
                    if [ $? -eq 0 ]; then
                        echo -e "${green}soga 重新安装成功${plain}"
                    else
                        echo -e "${red}soga 安装失败${plain}"
                        exit 1
                    fi
                else
                    echo -e "${yellow_light}${blink}Soga 重装已取消${plain}"
                    exit 0
                fi
                ;;
            5)
                echo -e "${green}${blink}流媒体测试${plain}"
                bash <(curl -L -s https://raw.githubusercontent.com/WuYtUgXw/almasoga/main/stream.sh)
                ;;
            0)
                echo -e "${yellow_light}${blink}退出脚本${plain}"
                exit 0
                ;;
            *)
                echo -e "${green}${blink}无效的操作编号${plain}"
                exit 1
                ;;
        esac
    fi
done
