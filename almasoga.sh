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
