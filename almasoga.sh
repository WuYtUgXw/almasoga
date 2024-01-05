#!/bin/bash

# 定义颜色
RED="\033[0;31m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
WHITE="\033[0;37m"
ORANGE="\033[0;33m"

# 检测 soga
if command -v soga &> /dev/null; then
  # soga 已安装
  echo "${GREEN}soga 已安装！${WHITE}"
else
  # soga 未安装
  echo "${RED}未检测到 soga，是否安装 yes or no？${WHITE}"
  read -p "请输入：" input
  if [ "$input" = "y" -o "$input" = "yes" ]; then
    # 安装 soga
    echo "${YELLOW}正在安装 soga...${WHITE}"
    bash <(curl -sSL https://raw.githubusercontent.com/WuYtUgXw/almasoga/main/almasoga.sh)
    echo "${GREEN}soga 安装成功！${WHITE}"
  else
    # 取消安装 soga
    echo "${ORANGE}soga 未安装！${WHITE}"
  fi
fi
