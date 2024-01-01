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

# 删除审计配置的功能
echo -e "${green}删除审计配置${plain}"
# 删除 /etc/soga/blockList 文件内容
echo -n > /etc/soga/blockList
echo -e "${green}删除成功${plain}"

# 安装完成后输出消息
echo -e "${yellow}欢迎使用 Damian 的 soga 配置脚本！${plain}"

# 提示用户选择功能
echo -e "\n请选择要执行的功能："
echo -e "${red}1. 增加审计规则${green}"
echo -e "${red}2. 其他功能${green}"

# 读取用户输入
read -p "请输入功能编号（1、2）: " function_number

# 根据用户输入执行不同的功能
case $function_number in
    1)
        echo -e "${red}增加审计规则${plain}"
        # 在 /etc/soga/blockList 文件中添加审计规则
        cat <<'EOF' >> /etc/soga/blockList
# 每行一个审计规则
# 纯字符串匹配规则
360.com
so.cn
qihoo.com
360safe.cn
qhimg.com
360totalsecurity.cn
yunpan.com

# 正则表达式匹配规则
regexp:(.*\\.)(visa|mycard|mastercard|gash|beanfun|bank).*
# 省略其他规则...
EOF
        echo -e "${green}审计规则添加成功${plain}"
        ;;
    2)
        echo -e "${red}其他功能二${plain}"
        # 添加其他功能二的具体操作
        ;;
    *)
        echo -e "${red}无效的功能编号${plain}"
        ;;
esac

# 脚本执行完毕
exit 0
