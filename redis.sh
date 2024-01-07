#!/bin/bash

# ANSI Escape Codes for colors
yellow='\033[1;33m'
green='\033[1;32m'
reset='\033[0m'

echo -e "${yellow}欢迎使用 Redis 安装和配置脚本.${reset}"

read -p "是否安装 Redis？（${green}1是${reset}，${green}2否${reset}）: " install_option

if [ "$install_option" == "1" ]; then
    # 检测系统类型
    if [ -f /etc/redhat-release ]; then
        # CentOS 系统
        echo -e "${yellow}检测到 CentOS 系统.${reset}"
        sudo yum install epel-release -y
        sudo yum install redis -y
    elif [ -f /etc/lsb-release ]; then
        # Ubuntu/Debian 系统
        echo -e "${yellow}检测到 Ubuntu/Debian 系统.${reset}"
        sudo apt-get update
        sudo apt-get install redis-server -y
    else
        # 未知系统
        echo -e "${yellow}不支持的系统类型.${reset}"
        exit 1
    fi

    # 启动 Redis 服务
    sudo systemctl start redis

    # 设置 Redis 开机自启
    sudo systemctl enable redis
else
    echo -e "${yellow}未安装 Redis.${reset}"
    exit 1
fi

read -p "是否配置 Redis？（${green}1是${reset}，${green}2否${reset}）: " config_option

if [ "$config_option" == "1" ]; then
    # 配置 Redis
    if [ -f /etc/redis.conf ]; then
        # 清空 Redis 配置文件
        echo "" > /etc/redis.conf

        # 设置 Redis 公网可访问
        echo "bind 0.0.0.0" >> /etc/redis.conf

        # 设置 Redis 端口，建议设置一个随机端口
        echo "port 21145" >> /etc/redis.conf

        # 设置 Redis 密码，为确保安全，请设置一个较长的随机密码
        echo "requirepass OGzsiNagYUzH0z3D" >> /etc/redis.conf

        # 重启 Redis 服务使配置生效
        sudo systemctl restart redis
    elif [ -f /etc/redis/redis.conf ]; then
        # 清空 Redis 配置文件
        echo "" > /etc/redis/redis.conf

        # 设置 Redis 公网可访问
        echo "bind 0.0.0.0" >> /etc/redis/redis.conf

        # 设置 Redis 端口，建议设置一个随机端口
        echo "port 21145" >> /etc/redis/redis.conf

        # 设置 Redis 密码，为确保安全，请设置一个较长的随机密码
        echo "requirepass OGzsiNagYUzH0z3D" >> /etc/redis/redis.conf

        # 重启 Redis 服务使配置生效
        sudo systemctl restart redis-server
    else
        echo -e "${yellow}未找到 Redis 配置文件.${reset}"
        exit 1
    fi
else
    echo -e "${yellow}未配置 Redis.${reset}"
fi

echo -e "${green}脚本执行完毕.${reset}"
