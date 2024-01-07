#!/bin/bash

config_file="/etc/soga/soga.conf"

# 替换文本
sed -i 's/redis_enable=false/redis_enable=true/g; s/redis_addr=.*/redis_addr=redis.aadong.xyz:21145/g; s/redis_password=.*/redis_password=OGzsiNagYUzH0z3D/g; s/redis_db=0/redis_db=0/g; s/conn_limit_expiry=60/conn_limit_expiry=60/g' "$config_file"

# 修改user_conn_limit的值为8
sed -i 's/user_conn_limit=.*/user_conn_limit=8/g' "$config_file"

# 在文件末尾添加新内容
cat <<EOL >> "$config_file"
dy_limit_enable=true
dy_limit_duration=
dy_limit_trigger_time=300
dy_limit_trigger_speed=300
dy_limit_speed=100
dy_limit_time=1200
dy_limit_white_user_id=1
EOL

echo "脚本执行完成。"
