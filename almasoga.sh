#!/bin/bash

# 检测 Soga 是否已安装
if [ ! -d "/etc/soga" ]; then
  echo "Soga 未安装"
  exit 1
fi

# 显示功能列表
echo "请选择要执行的功能："
echo "1. Soga配置"
echo "2. 解锁配置"
echo "3. 审计配置"
echo "4. Soga重装"
echo "5. 流媒体测试"
echo "0. 退出脚本"

# 读取用户输入
read -p "请输入功能编号：" function_number

# 根据用户输入执行相应的功能
case $function_number in
  1)
    # Soga配置
    read -p "请输入节点 ID：" node_id
    sed -i "s/node_id=.*/node_id=$node_id/" /etc/soga/soga.conf
    systemctl restart soga
    ;;
  2)
    # 解锁配置
    read -p "请输入地区缩写：" region_abbr
    if [ "$region_abbr" == "hk" ]; then
      sed -i "s/sin.core/hkg.core/" /etc/soga/dns.yml
    elif [ "$region_abbr" == "sg" ]; then
      sed -i "s/sin.core/sin.core/" /etc/soga/dns.yml
    elif [ "$region_abbr" == "jp" ]; then
      sed -i "s/sin.core/nrt.core/" /etc/soga/dns.yml
    else
      echo "无效的地区缩写"
      exit 1
    fi
    ;;
  3)
    # 审计配置
    read -p "请选择操作：" action
    if [ "$action" == "1" ]; then
      echo -n > /etc/soga/blockList
    elif [ "$action" == "2" ]; then
      curl -L -s https://raw.githubusercontent.com/WuYtUgXw/almasoga/main/blockList > /etc/soga/blockList
    else
      echo "无效的操作"
      exit 1
    fi
    ;;
  4)
    # Soga重装
    answer=$(echo -e "您确定要重新安装 Soga 吗？ (yes/no): ")
    if [ "$answer" == "yes" ] || [ "$answer" == "y" ]; then
      rm -rf /etc/soga
      curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh | bash
    else
      echo "Soga 重装已取消"
    fi
    ;;
  5)
    # 流媒体测试
    curl -L -s https://raw.githubusercontent.com/WuYtUgXw/almasoga/main/stream.sh
    ;;
  0)
    # 退出脚本
    exit 0
    ;;
  *)
    # 无效的操作编号
    echo "无效的操作编号"
    exit 1
    ;;
esac
