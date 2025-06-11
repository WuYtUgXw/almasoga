#!/bin/bash
# RelayX 服务管理脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 恢复默认颜色

# 项目路径
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/relayx-site"
COMPOSE_FILE="$PROJECT_DIR/compose.yaml"

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检查Docker
check_docker() {
    if ! command_exists docker; then
        echo -e "${RED}错误: Docker未安装${NC}"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}错误: Docker服务未运行${NC}"
        exit 1
    fi
    
    if ! command_exists docker compose; then
        if command_exists docker-compose; then
            echo -e "${YELLOW}警告: 使用旧版docker-compose命令${NC}"
            DOCKER_COMPOSE="docker-compose"
        else
            echo -e "${RED}错误: 未找到docker compose命令${NC}"
            exit 1
        fi
    else
        DOCKER_COMPOSE="docker compose"
    fi
}

# 检查项目目录
check_project() {
    if [ ! -d "$PROJECT_DIR" ]; then
        echo -e "${RED}错误: 项目目录不存在: $PROJECT_DIR${NC}"
        echo "请确保脚本与relayx-site目录在同一父目录下"
        exit 1
    fi
    
    if [ ! -f "$COMPOSE_FILE" ]; then
        echo -e "${RED}错误: Docker Compose文件不存在: $COMPOSE_FILE${NC}"
        exit 1
    fi
}

# 启动服务
start_services() {
    echo -e "${GREEN}正在启动服务...${NC}"
    cd "$PROJECT_DIR" || exit
    
    # 检查环境变量文件
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}警告: .env文件不存在，使用默认配置${NC}"
    fi
    
    # 启动数据库服务
    echo -e "${BLUE}启动MySQL和Redis...${NC}"
    $DOCKER_COMPOSE up -d mysql redis
    
    # 等待数据库启动
    echo -e "${BLUE}等待数据库服务就绪...${NC}"
    sleep 30
    
    # 执行数据库迁移
    echo -e "${BLUE}执行数据库迁移...${NC}"
    $DOCKER_COMPOSE up -d db-migrate
    
    # 等待迁移完成
    sleep 60
    
    # 启动主服务
    echo -e "${BLUE}启动主服务...${NC}"
    $DOCKER_COMPOSE up -d relayx worker web caddy
    
    echo -e "${GREEN}服务启动完成！${NC}"
    echo -e "${BLUE}网站地址: https://www.rtx.sly666.xyz${NC}"
    echo -e "${BLUE}API地址: http://localhost:3000/api/health${NC}"
}

# 停止服务
stop_services() {
    echo -e "${GREEN}正在停止服务...${NC}"
    cd "$PROJECT_DIR" || exit
    $DOCKER_COMPOSE down
    echo -e "${GREEN}服务已停止！${NC}"
}

# 查看服务状态
check_status() {
    echo -e "${GREEN}服务状态:${NC}"
    cd "$PROJECT_DIR" || exit
    $DOCKER_COMPOSE ps
}

# 查看日志
view_logs() {
    echo -e "${GREEN}查看日志:${NC}"
    cd "$PROJECT_DIR" || exit
    
    echo "请选择要查看的服务日志:"
    echo "1. Backend服务"
    echo "2. Web服务"
    echo "3. Caddy服务"
    echo "4. MySQL服务"
    echo "5. Redis服务"
    echo "6. 所有服务"
    echo "7. 返回主菜单"
    
    read -p "请输入选项 [1-7]: " choice
    
    case $choice in
        1)
            $DOCKER_COMPOSE logs -f relayx
            ;;
        2)
            $DOCKER_COMPOSE logs -f web
            ;;
        3)
            $DOCKER_COMPOSE logs -f caddy
            ;;
        4)
            $DOCKER_COMPOSE logs -f mysql
            ;;
        5)
            $DOCKER_COMPOSE logs -f redis
            ;;
        6)
            $DOCKER_COMPOSE logs -f
            ;;
        7)
            return
            ;;
        *)
            echo -e "${RED}无效选项，请重试${NC}"
            view_logs
            ;;
    esac
}

# 修复服务
fix_services() {
    echo -e "${GREEN}正在修复服务...${NC}"
    cd "$PROJECT_DIR" || exit
    
    # 停止所有服务
    $DOCKER_COMPOSE down
    
    # 清理缓存
    rm -rf caddy_data caddy_config
    mkdir -p caddy_data caddy_config
    
    # 检查并修复compose.yaml
    if grep -q "version:" compose.yaml; then
        echo -e "${YELLOW}修复compose.yaml中的version字段...${NC}"
        sed '/version:/d' compose.yaml > compose.yaml.tmp
        mv compose.yaml.tmp compose.yaml
    fi
    
    # 检查环境变量
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}创建默认.env文件...${NC}"
        cat > .env << EOF
SITE_URL="https://www.rtx.sly666.xyz"
API_URL="http://relayx:3000"
DATABASE_URL="mysql://root:changeme@mysql:3306/relayx"
REDIS_URL="redis://redis:6379"
STACK_PROJECT_ID="a9842990-fc88-4a3e-a0ed-ee7ec0c9dd27"
STACK_SECRET_SERVER_KEY="ssk_1gjt814kznam5hrybej005z3wxkn7tqwxcp4rf8xjj5tr"
STACK_PUBLISHABLE_CLIENT_KEY="pck_24nn23tvpmne289pdz62xfy4b9tx1sqnmpkcww2n74rc8"
TELEGRAM_BOT_TOKEN=""
EOF
    else
        # 确保关键环境变量存在
        if ! grep -q "TELEGRAM_BOT_TOKEN" .env; then
            echo "TELEGRAM_BOT_TOKEN=\"\"" >> .env
        fi
    fi
    
    # 重新启动服务
    start_services
    
    echo -e "${GREEN}服务修复完成！${NC}"
}

# 清理所有组件
clean_all() {
    echo -e "${RED}警告: 此操作将删除所有服务、数据和配置！${NC}"
    read -p "确定要继续吗？(y/N): " confirm
    
    if [[ $confirm != [yY] ]]; then
        echo -e "${GREEN}操作已取消${NC}"
        return
    fi
    
    echo -e "${RED}正在清理所有组件...${NC}"
    cd "$PROJECT_DIR" || exit
    
    # 停止所有服务
    $DOCKER_COMPOSE down -v
    
    # 删除所有数据卷
    docker volume prune -f
    
    # 删除所有镜像
    docker rmi $(docker images -q "relayx/*") 2>/dev/null || true
    
    # 删除缓存目录
    rm -rf caddy_data caddy_config mysql_data redis_data web_cache
    
    echo -e "${RED}所有组件已清理完成！${NC}"
}

# 显示主菜单
show_menu() {
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${GREEN}       RelayX 服务管理工具${NC}"
    echo -e "${BLUE}=====================================${NC}"
    echo "1. 启动服务"
    echo "2. 停止服务"
    echo "3. 查看服务状态"
    echo "4. 查看日志"
    echo "5. 修复服务"
    echo "6. 清理所有组件"
    echo "7. 退出"
    echo -e "${BLUE}=====================================${NC}"
}

# 主函数
main() {
    check_docker
    check_project
    
    while true; do
        show_menu
        read -p "请输入选项 [1-7]: " choice
        
        case $choice in
            1)
                start_services
                ;;
            2)
                stop_services
                ;;
            3)
                check_status
                ;;
            4)
                view_logs
                ;;
            5)
                fix_services
                ;;
            6)
                clean_all
                ;;
            7)
                echo -e "${GREEN}感谢使用，再见！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效选项，请重试${NC}"
                ;;
        esac
        
        read -p "按Enter键返回主菜单..."
        clear
    done
}

# 执行主函数
main
