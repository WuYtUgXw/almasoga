#!/bin/bash

# 自定义颜色和字体大小
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
yellow_light='\033[2;36m'
plain='\033[0m'

# 将系统时区更改为 UTC+8
echo -e "${yellow}正在检查系统时区...${plain}"
current_timezone=$(timedatectl | grep "Time zone" | awk '{print $3}')
if [ "$current_timezone" != "Asia/Shanghai" ]; then
    echo -e "${yellow}当前时区为 $current_timezone，正在更改为中国时区（Asia/Shanghai）...${plain}"
    timedatectl set-timezone Asia/Shanghai
    if [ $? -eq 0 ]; then
        echo -e "${green}系统时区已更改为中国时区（Asia/Shanghai）${plain}"
    else
        echo -e "${red}时区更改失败，请手动检查${plain}"
        exit 1
    fi
else
    echo -e "${green}系统时区已是中国时区（Asia/Shanghai），无需更改${plain}"
fi

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

# 脚本执行完毕
while true; do
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
        echo -e "${green}5. 流媒体测试${plain}"
        echo -e "${green}0. 退出脚本${plain}"

        # 读取用户输入
        read -p "$(echo -e "${yellow}输入编号: ${plain}")" function_number

        # 根据用户输入执行不同的功能
        case $function_number in
            1)
                echo -e "${green}Soga配置${plain}"
                read -p "$(echo -e "${yellow}请选择操作类型：${plain} [1. 文件配置 / 2. 修改配置]: ")" config_option
                case $config_option in
                    1)
                        echo -e "${green}下载配置文件${plain}"
                        wget -O /etc/soga/soga.conf https://github.com/WuYtUgXw/almasoga/raw/main/soga.conf
                        if [ $? -eq 0 ]; then
                            echo -e "${green}soga.conf 替换成功${plain}"
                        else
                            echo -e "${red}soga.conf 替换失败${plain}"
                            exit 1
                        fi
                        read -p "$(echo -e "${yellow}请输入编号：${plain}")" node_id
                        sed -i "s/node_id=/node_id=$node_id/" /etc/soga/soga.conf
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
                        read -p "$(echo -e "${yellow}请输入新的编号：${plain}")" new_node_id
                        sed -i "s/node_id=.*/node_id=$new_node_id/" /etc/soga/soga.conf
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
                read -p "$(echo -e "${yellow}请选择解锁配置的类型：${plain} [1. DNS解锁 / 2. DNS修改]: ")" unlock_option
                case $unlock_option in
                    1)
                        echo -e "${green}DNS解锁${plain}"
                        wget -O /etc/soga/dns.yml https://github.com/WuYtUgXw/almasoga/raw/main/dns.yml
                        if [ $? -eq 0 ]; then
                            echo -e "${green}dns.yml 替换成功${plain}"
                        else
                            echo -e "${red}dns.yml 替换失败${plain}"
                            exit 1
                        fi
                        read -p "$(echo -e "${yellow}请输入地区缩写：${plain}")" region_abbr
                        case $region_abbr in
                            hk) sed -i "s/sin.core/hkg.core/" /etc/soga/dns.yml ;;
                            sg) sed -i "s/sin.core/sin.core/" /etc/soga/dns.yml ;;
                            jp) sed -i "s/sin.core/nrt.core/" /etc/soga/dns.yml ;;
                            us) sed -i "s/sin.core/lax.core/" /etc/soga/dns.yml ;;
                            *) echo -e "${red}无效的地区缩写${plain}" ; exit 1 ;;
                        esac
                        echo -e "${green}DNS解锁配置已完成${plain}"
                        ;;
                    2)
                        echo -e "${green}DNS修改${plain}"
                        read -p "$(echo -e "${yellow}请输入地区缩写：${plain}")" region_abbr
                        case $region_abbr in
                            hk) replace_rules="s/sin.core/hkg.core/" ;;
                            sg) replace_rules="s/sin.core/sin.core/" ;;
                            jp) replace_rules="s/sin.core/nrt.core/" ;;
                            us) replace_rules="s/sin.core/lax.core/" ;;
                            *) echo -e "${red}无效的地区缩写${plain}" ; exit 1 ;;
                        esac
                        sed -i "$replace_rules" /etc/soga/dns.yml
                        echo -e "${green}DNS修改配置已完成${plain}"
                        ;;
                    *)
                        echo -e "${red}无效的选项${plain}"
                        exit 1
                        ;;
                esac
                ;;
3)  # 审计配置
            echo -e "${green}审计配置${plain}"
            read -p "$(echo -e "${yellow}选择操作：[1. 删除审计 / 2. 增加审计]: ${plain}")" audit_option
            case $audit_option in
                1)
                    echo -n > /etc/soga/blockList && echo -e "${green}审计记录已清空${plain}" || { echo -e "${red}清空失败${plain}"; exit 1; }
                    ;;
                2)
                    wget -O /etc/soga/blockList https://github.com/WuYtUgXw/almasoga/raw/main/blockList || { echo -e "${red}审计记录下载失败${plain}"; exit 1; }
                    echo -e "${green}审计记录已更新${plain}"
                    ;;
                *)
                    echo -e "${red}无效选项${plain}"
                    ;;
            esac
            ;;
        4)  # Soga重装
            read -p "$(echo -e "${yellow}确认重装 Soga？(yes/no): ${plain}")" reinstall
            if [[ $reinstall == "yes" || $reinstall == "y" ]]; then
                rm -rf /etc/soga
                bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh) && echo -e "${green}soga 重新安装成功${plain}" || { echo -e "${red}重装失败${plain}"; exit 1; }
            else
                echo -e "${yellow_light}取消重装${plain}"
            fi
            ;;
        5)  # 流媒体测试
            bash <(curl -Ls https://raw.githubusercontent.com/WuYtUgXw/almasoga/main/stream.sh)
            ;;
        0)  # 退出
            echo -e "${yellow_light}退出脚本${plain}"
            exit 0
            ;;
        *)
            echo -e "${red}无效选项${plain}"
            ;;
    esac
done
