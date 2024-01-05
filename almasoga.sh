#!/bin/bash

# 检测当前系统
if [ -f /etc/debian_version ]; then
  # debian系统
  sudo apt install wget
elif [ -f /etc/centos-release ]; then
  # centos系统
  sudo yum install wget
fi

# 检测soga是否存在
if [ -d /etc/soga ]; then
  # 存在
  echo "soga已安装，跳过安装"
  exit 0
else
  # 不存在
  read -p "未检测到soga，是否安装？(yes/no) " answer
  if [ "$answer" = "yes" ] || [ "$answer" = "y" ]; then
    # 安装soga
    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)
  else
    # 不安装soga
    echo "跳过安装"
  fi
fi

# 欢迎用户使用飒珑常用配置脚本
echo "欢迎使用飒珑常用配置脚本"

# 显示菜单
echo "1.配置soga"
echo "2.配置审计"
echo "3.配置解锁"
read -p "请选择： " choice

# 执行相应的操作
case $choice in
  1)
    # 配置soga
    ./config_soga.sh
    ;;
  2)
    # 配置审计
    ./config_audit.sh
    ;;
  3)
    # 配置解锁
    ./config_unlock.sh
    ;;
  *)
    echo "无效的选择"
    ;;
esac
