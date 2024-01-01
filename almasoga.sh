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
        # 检测是否存在 wget
        if command -v wget &> /dev/null; then
            echo -e "${green}系统已安装 wget${plain}"
        else
            # 安装 wget
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
        # 检测是否存在 wget
        if command -v wget &> /dev/null; then
            echo -e "${green}系统已安装 wget${plain}"
        else
            # 安装 wget
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

    # 开始安装 soga
    echo -e "${green}/etc/soga 文件夹不存在，开始安装 soga${plain}"
    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)
    if [ $? -eq 0 ]; then
        echo -e "${green}soga 安装成功${plain}"
    else
        echo -e "${red}soga 安装失败${plain}"
        exit 1
    fi
fi

# 安装完成后输出消息
echo -e "${yellow_light}欢迎使用 涩龙 的 soga 配置脚本！${plain}"

# 检测是否存在 /etc/soga 文件夹
if [ -d /etc/soga ]; then
    # 提示用户选择功能
    echo -e "${red}请选择要执行的功能：${plain}"
    echo -e "${green}1. Soga配置${plain}"
    echo -e "${green}2. 解锁配置${plain}"
    echo -e "${green}3. 审计配置${plain}"
    echo -e "${green}4. Soga重装${plain}"

    # 读取用户输入
    read -p "$(echo -e "${yellow}输入编号: ${plain}")" function_number

    # 根据用户输入执行不同的功能
    case $function_number in
        1)
            echo -e "${green}Soga配置${plain}"

            # 提示用户选择操作类型
            read -p "$(echo -e "${yellow}请选择操作类型：${plain} [1. 文件配置 / 2. 修改配置]: ")" config_option

            case $config_option in
                1)
                    echo -e "${green}下载配置文件${plain}"

                    # 进入 /etc/soga 下载 https://github.com/WuYtUgXw/almasoga 的 soga.conf 并替换原来的 soga.conf
                    wget -O /etc/soga/soga.conf https://github.com/WuYtUgXw/almasoga/raw/main/soga.conf
                    if [ $? -eq 0 ]; then
                        echo -e "${green}soga.conf 替换成功${plain}"
                    else
                        echo -e "${red}soga.conf 替换失败${plain}"
                        exit 1
                    fi

                    # 提示输入「编号」，这个编号将在 /etc/soga 的 soga.conf 的 node_id= 后填入
                    read -p "$(echo -e "${yellow}请输入编号：${plain}")" node_id
                    sed -i "s/node_id=/node_id=$node_id/" /etc/soga/soga.conf

                    # 保存并重启 soga 服务
                    systemctl restart soga
                    if [ $? -eq 0 ]; then
                        echo -e "${green}Soga配置已更新并服务已重启${plain}"
                    else
                        echo -e "${red}Soga服务重启失败${plain}"
                        exit 1
                    fi
                    ;;
                2)
                    echo -e "${green}修改配置文件${plain}"

                    # 提示输入「编号」，这个编号将更改 /etc/soga 的 soga.conf 的 node_id=
                    read -p "$(echo -e "${yellow}请输入新的编号：${plain}")" new_node_id
                    sed -i "s/node_id=.*/node_id=$new_node_id/" /etc/soga/soga.conf

                    # 保存并重启 soga 服务
                    systemctl restart soga
                    if [ $? -eq 0 ]; then
                        echo -e "${green}Soga配置已更新并服务已重启${plain}"
                    else
                        echo -e "${red}Soga服务重启失败${plain}"
                        exit 1
                    fi
                    ;;
                *)
                    echo -e "${red}无效的选项${plain}"
                    exit 1
                    ;;
            esac
            ;;
        2)
            echo -e "${green}解锁配置${plain}"
            
            # 提示用户选择解锁配置的类型
            read -p "$(echo -e "${yellow}请选择解锁配置的类型：${plain} [1. DNS解锁 / 2. DNS修改]: ")" unlock_option

            case $unlock_option in
                1)
                    echo -e "${green}DNS解锁${plain}"

                    # 下载 https://github.com/WuYtUgXw/almasoga 的 dns.yml 并替换 /etc/soga 原有的 dns.yml
                    wget -O /etc/soga/dns.yml https://github.com/WuYtUgXw/almasoga/raw/main/dns.yml
                    if [ $? -eq 0 ]; then
                        echo -e "${green}dns.yml 替换成功${plain}"
                    else
                        echo -e "${red}dns.yml 替换失败${plain}"
                        exit 1
                    fi

                    # 提示输入「地区缩写」，例如输入「hk」则将 /etc/soga 的 dns.yml 里的 sin.core 修改为 hkg.core
                    read -p "$(echo -e "${yellow}请输入地区缩写：${plain}")" region_abbr

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
                    echo -e "${green}DNS修改${plain}"

                    # 提示输入「地区缩写」，例如输入「hk」则将 /etc/soga 的 dns.yml 里的 sin.core 修改为 hkg.core
                    read -p "$(echo -e "${yellow}请输入地区缩写：${plain}")" region_abbr

                    replace_rules=""
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

                    # 应用替换规则
                    sed -i "${replace_rules}" /etc/soga/dns.yml

                    echo -e "${green}DNS修改配置已完成${plain}"
                    ;;
                *)
                    echo -e "${red}无效的选项${plain}"
                    exit 1
                    ;;
            esac
            ;;
        3)
            echo -e "${green}审计配置${plain}"
            
            # 提示用户选择操作类型
            read -p "$(echo -e "${yellow}请选择操作类型：${plain} [1. 删除审计 / 2. 增加审计]: ")" audit_option

            case $audit_option in
                1)
                    echo -e "${green}删除审计${plain}"
                    # 删除 /etc/soga/blockList 文件内容
                    echo -n > /etc/soga/blockList
                    if [ $? -eq 0 ]; then
                        echo -e "${green}删除成功${plain}"
                    else
                        echo -e "${red}删除失败${plain}"
                        exit 1
                    fi
                    ;;
                2)
                    echo -e "${green}增加审计${plain}"
                    # 下载 https://github.com/WuYtUgXw/almasoga 的 blockList 并替换 /etc/soga 原有的 blockList
                    wget -O /etc/soga/blockList https://github.com/WuYtUgXw/almasoga/raw/main/blockList
                    if [ $? -eq 0 ]; then
                        echo -e "${green}blockList 替换成功${plain}"
                    else
                        echo -e "${red}blockList 替换失败${plain}"
                        exit 1
                    fi
                    ;;
                *)
                    echo -e "${green}无效的选项${plain}"
                    exit 1
                    ;;
            esac
            ;;
        4)
            echo -e "${green}Soga重装${plain}"
            
            # Prompt for confirmation
            read -p "$(echo -e "${yellow}您确定要重新安装 Soga 吗？ (yes/no): ${plain}")" reinstall_choice

            if [ "$reinstall_choice" == "yes" ] || [ "$reinstall_choice" == "y" ]; then
                echo -e "${yellow_light}正在删除 /etc/soga...${plain}"
                rm -rf /etc/soga

                # Proceed with the installation
                echo -e "${green}/etc/soga 文件夹已删除，开始重新安装 soga${plain}"
                bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)
                if [ $? -eq 0 ]; then
                    echo -e "${green}soga 重新安装成功${plain}"
                else
                    echo -e "${red}soga 安装失败${plain}"
                    exit 1
                fi
            else
                echo -e "${yellow_light}Soga 重装已取消${plain}"
                exit 0
            fi
            ;;
        *)
            echo -e "${green}无效的操作编号${plain}"
            exit 1
            ;;
    esac

    # 脚本执行完毕
    exit 0
fi
