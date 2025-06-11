#!/bin/bash
# RelayX一键修复脚本（修复版）

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

# 检查Docker
check_docker() {
    if ! command_exists docker; then
        log_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker服务未运行，请启动Docker服务"
        exit 1
    fi
}

# 进入项目目录
cd_project() {
    # 检查当前目录是否为项目目录
    if [ -f "compose.yaml" ] || [ -f "docker-compose.yml" ]; then
        log_info "已在项目目录: $(pwd)"
        return
    fi
    
    # 检查上级目录
    if [ -d "../relayx-site" ] && [ -f "../relayx-site/compose.yaml" ]; then
        cd ../relayx-site || exit
        log_info "已进入项目目录: $(pwd)"
        return
    fi
    
    # 检查同级目录
    if [ -d "relayx-site" ] && [ -f "relayx-site/compose.yaml" ]; then
        cd relayx-site || exit
        log_info "已进入项目目录: $(pwd)"
        return
    fi
    
    log_error "未找到项目目录，请确保在正确的目录下运行此脚本"
    exit 1
}

# 备份当前配置
backup_config() {
    log_info "备份当前配置..."
    backup_dir="../relayx-backup-$(date +%Y%m%d%H%M%S)"
    mkdir -p "$backup_dir"
    cp -r ./* "$backup_dir/"
    log_info "配置已备份到: $backup_dir"
}

# 检查并修复compose.yaml
fix_compose() {
    log_info "检查并修复compose.yaml..."
    
    # 检查是否存在version字段
    if grep -q "version:" compose.yaml; then
        log_warn "发现过时的version字段，正在修复..."
        
        # 创建临时文件
        sed '/version:/d' compose.yaml > compose.yaml.tmp
        mv compose.yaml.tmp compose.yaml
        
        log_info "compose.yaml修复完成"
    else
        log_info "compose.yaml格式正常"
    fi
}

# 检查环境变量
check_env() {
    log_info "检查环境变量..."
    
    # 检查必要的环境变量
    if [ ! -f ".env" ]; then
        log_error ".env文件不存在"
        exit 1
    fi
    
    # 检查数据库配置
    if ! grep -q "DATABASE_URL" .env; then
        log_error "缺少DATABASE_URL配置"
        echo "DATABASE_URL=\"mysql://root:changeme@mysql:3306/relayx\"" >> .env
        log_info "已添加默认DATABASE_URL配置"
    fi
    
    # 检查Redis配置
    if ! grep -q "REDIS_URL" .env; then
        log_error "缺少REDIS_URL配置"
        echo "REDIS_URL=\"redis://redis:6379\"" >> .env
        log_info "已添加默认REDIS_URL配置"
    fi
    
    # 检查API_URL配置
    if ! grep -q "API_URL" .env; then
        log_error "缺少API_URL配置"
        echo "API_URL=\"http://relayx:3000\"" >> .env
        log_info "已添加默认API_URL配置"
    fi
    
    # 检查StackAuth配置
    if ! grep -q "STACK_PROJECT_ID" .env; then
        log_error "缺少STACK_PROJECT_ID配置"
        exit 1
    fi
    
    if ! grep -q "STACK_SECRET_SERVER_KEY" .env; then
        log_error "缺少STACK_SECRET_SERVER_KEY配置"
        exit 1
    fi
    
    if ! grep -q "STACK_PUBLISHABLE_CLIENT_KEY" .env; then
        log_error "缺少STACK_PUBLISHABLE_CLIENT_KEY配置"
        exit 1
    fi
    
    log_info "环境变量检查完成"
}

# 重启所有服务
restart_services() {
    log_info "重启所有服务..."
    
    # 停止所有服务
    docker compose down
    
    # 分阶段启动服务
    log_info "启动数据库服务..."
    docker compose up -d mysql redis
    
    log_info "等待数据库服务启动..."
    sleep 30
    
    log_info "启动迁移服务..."
    docker compose up -d db-migrate
    
    log_info "等待数据库迁移完成..."
    sleep 60
    
    log_info "启动主服务..."
    docker compose up -d relayx worker web caddy
    
    log_info "服务重启完成"
}

# 检查服务状态
check_status() {
    log_info "检查服务状态..."
    
    # 显示服务状态
    docker compose ps
    
    # 检查relayx服务状态
    relayx_status=$(docker compose ps relayx | awk 'NR==2 {print $4}')
    
    if [ "$relayx_status" = "running" ]; then
        log_info "Backend服务状态: ${GREEN}正常${NC}"
    else
        log_error "Backend服务状态: ${RED}异常 ($relayx_status)${NC}"
        log_info "查看Backend服务日志..."
        docker compose logs --tail=50 relayx
    fi
    
    # 测试API连接
    log_info "测试API连接..."
    curl -v http://localhost:3000/api/health
    
    log_info "服务状态检查完成"
}

# 修复Caddy配置
fix_caddy() {
    log_info "检查并修复Caddy配置..."
    
    # 检查Caddyfile是否存在
    if [ ! -f "Caddyfile" ]; then
        log_error "Caddyfile不存在"
        exit 1
    fi
    
    # 检查是否有正确的域名配置
    if ! grep -q "rtx.sly666.xyz" Caddyfile; then
        log_error "Caddyfile中未配置正确的域名"
        
        # 创建临时文件
        cat > Caddyfile.tmp << EOF
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
        
        mv Caddyfile.tmp Caddyfile
        log_info "已更新Caddyfile配置"
    fi
    
    # 重启Caddy服务
    docker compose restart caddy
    log_info "Caddy服务已重启"
}

# 清理缓存
clean_cache() {
    log_info "清理缓存..."
    
    # 停止所有服务
    docker compose down
    
    # 删除Caddy缓存
    rm -rf caddy_data caddy_config
    
    # 删除前端缓存
    if [ -d "web_cache" ]; then
        rm -rf web_cache
    fi
    
    # 重新创建目录
    mkdir -p caddy_data caddy_config
    
    log_info "缓存清理完成"
}

# 主函数
main() {
    log_info "===== RelayX一键修复工具 ====="
    
    check_docker
    cd_project
    backup_config
    fix_compose
    check_env
    clean_cache
    fix_caddy
    restart_services
    check_status
    
    log_info "===== 修复完成 ====="
    log_info "请访问 https://www.rtx.sly666.xyz 检查网站是否正常运行"
    log_info "如需查看详细日志，请执行: docker compose logs -f"
}

# 执行主函数
main
