#!/bin/bash

config_file="/etc/soga/soga.conf"

# 替换文本
sed -i 's/redis_enable=false/redis_enable=true/g; s/redis_addr=.*/redis_addr=redis.aadong.xyz:21145/g; s/redis_password=.*/redis_password=OGzsiNagYUzH0z3D/g; s/redis_db=0/redis_db=0/g; s/conn_limit_expiry=60/conn_limit_expiry=60/g' "$config_file"

# 修改user_conn_limit的值为8
sed -i 's/user_conn_limit=.*/user_conn_limit=8/g' "$config_file"

# 执行soga命令并输入6
echo "soga" | ./soga | echo "6" | ./soga

echo "脚本执行完成。"
