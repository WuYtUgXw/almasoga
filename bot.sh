#!/bin/bash
set -e  # 遇到错误立即退出

# 颜色输出函数
echo_green() { echo -e "\e[32m$1\e[0m"; }
echo_red() { echo -e "\e[31m$1\e[0m"; }

# 确保以 root 运行
if [ "$(id -u)" -ne 0 ]; then
    echo_red "请使用 root 用户执行此脚本！"
    exit 1
fi

echo_green "更新系统软件包..."
apt update && apt upgrade -y

# 安装必要依赖
apt install -y curl git ca-certificates lsb-release apt-transport-https

# 安装 Docker
if ! command -v docker &>/dev/null; then
    echo_green "安装 Docker..."
    curl -fsSL https://get.docker.com | bash
else
    echo_green "Docker 已安装，跳过..."
fi

# 启动 Docker 并设置开机自启
systemctl enable --now docker

# 安装 Docker Compose
if ! command -v docker compose &>/dev/null; then
    echo_green "安装 Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    echo_green "Docker Compose 已安装，跳过..."
fi

# 拉取 AstrBot
if [ ! -d "AstrBot" ]; then
    echo_green "克隆 AstrBot 仓库..."
    git clone https://github.com/Soulter/AstrBot.git
else
    echo_green "AstrBot 仓库已存在，跳过克隆..."
fi

cd AstrBot

# 启动 AstrBot
if [ ! "$(docker ps -q -f name=astrbot)" ]; then
    echo_green "启动 AstrBot..."
    docker compose up -d
else
    echo_green "AstrBot 已在运行，跳过启动..."
fi

# 显示运行状态
echo_green "AstrBot 部署完成！"
docker ps | grep astrbot

echo_green "🎉 管理面板已启动，可访问:"
echo_green "http://$(hostname -I | awk '{print $1}'):6185"
echo_green "默认用户名和密码: astrbot / astrbot"
