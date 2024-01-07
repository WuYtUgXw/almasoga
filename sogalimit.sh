#!/bin/bash

# 安装expect工具
install_expect() {
  echo "正在安装 expect 工具..."
  if [[ "$(command -v expect)" ]]; then
    echo "expect 工具已安装。"
  else
    if [[ "$(command -v apt-get)" ]]; then
      sudo apt-get update
      sudo apt-get install -y expect
    elif [[ "$(command -v apt)" ]]; then
      sudo apt update
      sudo apt install -y expect
    else
      echo "无法安装 expect 工具，请手动安装。"
      exit 1
    fi
  fi
}

# 替换文本
sed -i 's/redis_enable=false/redis_enable=true/g; s/redis_addr=.*/redis_addr=redis.aadong.xyz:21145/g; s/redis_password=.*/redis_password=OGzsiNagYUzH0z3D/g; s/redis_db=0/redis_db=0/g; s/conn_limit_expiry=60/conn_limit_expiry=60/g' "/etc/soga/soga.conf"

# 修改user_conn_limit的值为8
sed -i 's/user_conn_limit=.*/user_conn_limit=8/g' "/etc/soga/soga.conf"

# 执行soga命令并输入6
install_expect
expect -c '
spawn soga
expect "Please choose your option:"
send "6\r"
expect eof
'

echo "脚本执行完成。"
