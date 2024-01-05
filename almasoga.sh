#!/bin/bash

# 定义颜色
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
yellow_light='\033[2;36m'
plain='\033[0m'

# 检测 soga
if command -v soga &> /dev/null; then
  # soga 已安装
  echo "${green}soga 已安装！${plain}"
else
  # soga 未安装
  echo "${red}未检测到 soga，是否安装 yes or no？${plain}"

  # 使用 select 选择器获取用户输入
  select input in "是" "否"; do
    case $input in
      "是")
        # 安装 soga
        echo "${yellow}正在安装 soga...${plain}"
        bash <(curl -sSL https://raw.githubusercontent.com/almasoga/almasoga/main/almasoga.sh)
        echo "${green}soga 安装成功！${plain}"
        break
      ;;
      "否")
        # 取消安装 soga
        echo "${orange}soga 未安装！${plain}"
        exit
      ;;
      *)
        echo "输入错误，请重新输入"
        continue
      ;;
    esac
  done
fi

# 输出版本信息
if command -v soga &> /dev/null; then
  echo "${green}soga 版本：${plain}"
  soga -V
fi
