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

# 下载并替换 blockList
if [ -d /etc/soga ]; then
    echo -e "${yellow}开始下载 blockList${plain}"
    wget -O /etc/soga/blockList $(echo -e "https://raw.githubusercontent.com/WuYtUgXw/almasoga/main/blockList")
    echo -e "${green}blockList 下载成功${plain}"
fi

# 安装完成后输出消息
echo -e "${yellow}欢迎使用 Damian 的 soga 配置脚本！${plain}"

# 提示用户选择功能
echo -e "\n请选择要执行的功能："
echo -e "${red}1. 删除审计配置${plain}"
echo -e "${red}2. 增加审计规则${plain}"
echo -e "${red}3. 其他功能${plain}"

# 读取用户输入
read -p "$(echo -e "${yellow}请输入功能编号（1、2、3）: ${plain}")" function_number

# 根据用户输入执行不同的功能
case $function_number in
    1)
        echo -e "${red}删除审计配置${plain}"
        # 删除 /etc/soga/blockList 文件内容
        echo -n > /etc/soga/blockList
        echo -e "${green}删除成功${plain}"
        ;;
    2)
        echo -e "${red}增加审计规则${plain}"
        # 在 /etc/soga/blockList 文件中添加审计规则
        cat <<EOF >> /etc/soga/blockList
# 每行一个审计规则
# 纯字符串匹配规则
360.com
so.cn
qihoo.com
360safe.cn
qhimg.com
360totalsecurity.cn
yunpan.com

# 正则表达式匹配规则 (第二部分)
# ...
EOF
        echo -e "${green}添加成功${plain}"
        ;;
    3)
        echo -e "${red}其他功能，暂未实现${plain}"
        ;;
    *)
        echo -e "${red}无效的操作编号${plain}"
        ;;
esac

# 脚本执行完毕
exit 0
