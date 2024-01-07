#!/bin/bash

# ANSI Escape Codes for colors
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RESET='\033[0m'

read -p "${YELLOW}是否安装 Redis？（${GREEN}1是${YELLOW}，${GREEN}2否${YELLOW}）: ${RESET}" install_option

if [ "$install_option" == "1" ]; then
    # 检测系统类型
    if [ -f /etc/redhat-release ]; then
        # CentOS 系统
        echo "${YELLOW}Detected CentOS system.${RESET}"
        sudo yum install epel-release -y
        sudo yum install redis -y
    elif [ -f /etc/lsb-release ]; then
        # Ubuntu/Debian 系统
        echo "${YELLOW}Detected Ubuntu/Debian system.${RESET}"
        sudo apt-get update
        sudo apt-get install redis-server -y
    else
        # 未知系统
        echo "${YELLOW}Unsupported system type.${RESET}"
        exit 1
    fi

    # 启动 Redis 服务
    sudo systemctl start redis

    # 设置 Redis 开机自启
    sudo systemctl enable redis
else
    echo "${YELLOW}未安装 Redis.${RESET}"
    exit 1
fi

read -p "${YELLOW}是否配置 Redis？（${GREEN}1是${YELLOW}，${GREEN}2否${YELLOW}）: ${RESET}" config_option

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
        echo "${YELLOW}Redis configuration file not found.${RESET}"
        exit 1
    fi
else
    echo "${YELLOW}未配置 Redis.${RESET}"
fi

echo "${GREEN}脚本执行完毕.${RESET}"
