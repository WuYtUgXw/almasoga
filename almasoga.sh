#!/bin/bash

# Define colors
RED="\033[0;31m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
WHITE="\033[0;37m"
ORANGE="\033[0;33m"

# Check for soga
if command -v soga &> /dev/null; then
  # soga is installed
  echo -e "${GREEN}soga 已安装！${WHITE}"
  echo -e "${ORANGE}跳过安装 soga...${WHITE}"
else
  # soga is not installed
  echo -e "${RED}未检测到 soga，是否安装 yes or no？${WHITE}"
  read -p "请输入：" input
  if [ "$input" = "y" -o "$input" = "yes" ]; then
    # Install soga
    echo -e "${YELLOW}正在安装 soga...${WHITE}"
    bash <(curl -sSL https://raw.githubusercontent.com/WuYtUgXw/almasoga/main/almasoga.sh)
    echo -e "${GREEN}soga 安装成功！${WHITE}"
  else
    # Cancel soga installation
    echo -e "${ORANGE}soga 未安装！${WHITE}"
  fi
fi
