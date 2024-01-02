#!/bin/bash

# 函数：提示用户是否执行下一步
prompt_user() {
    read -p "是否执行当前步骤？ (y/n): " choice
    case "$choice" in
        y|Y ) return 0 ;;
        n|N ) return 1 ;;
        * ) echo "请输入 y 或 n." && prompt_user ;;
    esac
}

# 步骤 1：安装系统组件
echo "步骤 1：安装系统组件"
prompt_user && apt update -y && apt install -y wget gnupg

# 步骤 2：注册PGP密钥
echo "步骤 2：注册PGP密钥"
prompt_user && wget -qO - https://dl.xanmod.org/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes

# 步骤 3：添加存储库
echo "步骤 3：添加存储库"
prompt_user && echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list

# 步骤 4：查看当前VPS适合的版本
echo "步骤 4：查看当前VPS适合的版本"
prompt_user && wget -q https://dl.xanmod.org/check_x86-64_psabi.sh && chmod +x check_x86-64_psabi.sh && ./check_x86-64_psabi.sh

echo "脚本执行完毕。"
