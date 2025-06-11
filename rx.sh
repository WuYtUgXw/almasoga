#!/bin/bash
# RelayX面板一键部署脚本
# 适用于 Ubuntu/Debian/CentOS 系统
# 已预配置域名: rtx.sly666.xyz
# StackAuth配置: a9842990-fc88-4a3e-a0ed-ee7ec0c9dd27

# 颜色定义
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # 恢复默认颜色

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 安装依赖
install_dependencies() {
    log_info "检查并安装必要的依赖..."
    
    # 检测操作系统类型
    if command_exists apt-get; then
        # Debian/Ubuntu
        sudo apt-get update -y
        sudo apt-get install -y curl wget git openssl
    elif command_exists yum; then
        # CentOS/RHEL
        sudo yum update -y
        sudo yum install -y curl wget git openssl
    else
        log_error "无法识别的操作系统，无法自动安装依赖"
        exit 1
    fi
    
    log_info "依赖安装完成"
}

# 安装Docker
install_docker() {
    log_info "检查Docker安装..."
    
    if ! command_exists docker; then
        log_info "开始安装Docker..."
        curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
        sudo usermod -aG docker $USER
        log_info "Docker安装完成"
    else
        log_info "Docker已安装，跳过安装步骤"
    fi
    
    # 检查Docker Compose
    if ! command_exists docker-compose; then
        log_info "开始安装Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        log_info "Docker Compose安装完成"
    else
        log_info "Docker Compose已安装，跳过安装步骤"
    fi
    
    # 启动Docker服务
    sudo systemctl start docker
    sudo systemctl enable docker
    
    log_info "Docker环境准备完成"
}

# 配置防火墙
configure_firewall() {
    log_info "配置防火墙..."
    
    if command_exists ufw; then
        # Ubuntu/Debian
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp
        if ! sudo ufw status | grep -q "Status: active"; then
            sudo ufw enable
        fi
    elif command_exists firewall-cmd; then
        # CentOS/RHEL
        sudo firewall-cmd --add-port=80/tcp --permanent
        sudo firewall-cmd --add-port=443/tcp --permanent
        sudo firewall-cmd --reload
    else
        log_warn "未检测到防火墙服务，跳过配置"
    fi
    
    log_info "防火墙配置完成"
}

# 生成随机密钥
generate_random_key() {
    openssl rand -base64 32
}

# 创建部署目录
create_deployment_directory() {
    log_info "创建部署目录..."
    mkdir -p relayx-site
    cd relayx-site
    log_info "部署目录创建完成: $(pwd)"
}

# 生成Docker Compose文件
generate_docker_compose() {
    log_info "生成Docker Compose配置..."
    
    cat > compose.yaml << 'EOF'
version: '3.8'

services:
  caddy:
    image: caddy:2.7.5-alpine
    cap_add:
      - NET_ADMIN
    container_name: caddy
    restart: always
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    ports:
      - "80:80"
      - "443:443"
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "caddy", "validate"]
      interval: 30s
      timeout: 10s
      retries: 3

  db-migrate:
    image: relayx/db-migrate
    container_name: db-migrate
    env_file:
      - .env
    depends_on:
      mysql:
        condition: service_healthy
    networks:
      - app-network

  relayx:
    image: relayx/backend
    container_name: backend
    restart: always
    env_file:
      - .env
    depends_on:
      redis:
        condition: service_healthy
      mysql:
        condition: service_healthy
      db-migrate:
        condition: service_completed_successfully
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  worker:
    image: relayx/backend
    container_name: worker
    restart: always
    env_file:
      - .env
    command: ["./relayx-worker"]
    depends_on:
      redis:
        condition: service_healthy
      mysql:
        condition: service_healthy
      db-migrate:
        condition: service_completed_successfully
    networks:
      - app-network

  web:
    image: relayx/web
    container_name: web
    restart: always
    env_file:
      - .env
    depends_on:
      - relayx
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3

  redis:
    image: redis:7.2-alpine
    container_name: redis
    restart: always
    volumes:
      - redis:/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  mysql:
    image: mysql:8.2
    container_name: mysql
    environment:
      MYSQL_ROOT_PASSWORD: changeme
      MYSQL_DATABASE: relayx
    restart: always
    volumes:
      - mysql:/var/lib/mysql
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 20s
      timeout: 5s
      retries: 5
    command: --default-authentication-plugin=mysql_native_password

networks:
  app-network:

volumes:
  redis:
  mysql:
  caddy_data:
  caddy_config:
EOF
    
    log_info "Docker Compose配置生成完成"
}

# 生成环境变量文件（已填入你的配置）
generate_env_file() {
    log_info "生成环境变量配置..."
    
    # 生成随机密钥
    JWT_SECRET=$(generate_random_key)
    COOKIE_SECRET=$(generate_random_key)
    
    cat > .env << EOF
DATABASE_URL="mysql://root:changeme@mysql:3306/relayx"
REDIS_URL="redis://redis:6379"
SITE_URL="https://www.rtx.sly666.xyz"
STACK_API_URL="https://api.stack-auth.com"
STACK_PROJECT_ID="a9842990-fc88-4a3e-a0ed-ee7ec0c9dd27"
STACK_SECRET_SERVER_KEY="ssk_1gjt814kznam5hrybej005z3wxkn7tqwxcp4rf8xjj5tr"
STACK_PUBLISHABLE_CLIENT_KEY="pck_24nn23tvpmne289pdz62xfy4b9tx1sqnmpkcww2n74rc8"
TELEGRAM_BOT_TOKEN=""
API_URL="http://relayx:3000"

# 安全配置
NODE_ENV=production
LOG_LEVEL=info
JWT_SECRET=${JWT_SECRET}
COOKIE_SECRET=${COOKIE_SECRET}
EOF
    
    log_info "环境变量配置生成完成"
}

# 生成Caddy配置文件（已填入你的域名）
generate_caddyfile() {
    log_info "生成Caddy配置..."
    
    cat > Caddyfile << EOF
www.rtx.sly666.xyz {
    reverse_proxy web:3000

    # 安全头设置
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "SAMEORIGIN"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
    }

    # HTTP/2和WebSocket优化
    encode zstd gzip
    tls {
        protocols tls1.2 tls1.3
        ciphers TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256 TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
    }
}

# 根域名重定向到www
rtx.sly666.xyz {
    redir https://www.rtx.sly666.xyz{uri}
}
EOF
    
    log_info "Caddy配置生成完成"
}

# 启动服务
start_services() {
    log_info "开始启动服务..."
    
    # 先启动数据库服务
    docker compose up -d mysql redis
    
    log_info "等待数据库服务启动..."
    sleep 30
    
    # 启动迁移服务
    docker compose up -d db-migrate
    
    log_info "等待数据库迁移完成..."
    sleep 60
    
    # 启动其他服务
    docker compose up -d relayx worker web caddy
    
    log_info "所有服务启动完成"
}

# 验证部署
verify_deployment() {
    log_info "验证部署状态..."
    
    # 检查服务状态
    log_info "服务状态:"
    docker compose ps
    
    # 检查Caddy日志
    log_info "检查Caddy日志..."
    docker compose logs caddy | grep -E "certificate|obtaining|success"
    
    log_info "验证完成，请访问 https://www.rtx.sly666.xyz 检查网站是否正常运行"
    log_info "如需查看实时日志，请执行: docker compose logs -f"
}

# 主函数
main() {
    # 欢迎信息
    echo -e "${GREEN}=============================================${NC}"
    echo -e "${GREEN}       RelayX 面板一键部署脚本 v1.0          ${NC}"
    echo -e "${GREEN}=============================================${NC}"
    echo "即将部署到域名: https://www.rtx.sly666.xyz"
    echo "请确保此域名已正确解析到当前服务器IP"
    echo ""
    
    # 确认继续
    read -p "是否继续? (y/n): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        log_info "操作已取消"
        exit 0
    fi
    
    # 执行部署步骤
    install_dependencies
    install_docker
    configure_firewall
    create_deployment_directory
    generate_docker_compose
    generate_env_file
    generate_caddyfile
    start_services
    verify_deployment
    
    log_info "部署完成!"
    echo -e "${GREEN}=============================================${NC}"
    echo -e "${GREEN}  部署成功! 请访问 https://www.rtx.sly666.xyz  ${NC}"
    echo -e "${GREEN}=============================================${NC}"
}

# 执行主函数
main
