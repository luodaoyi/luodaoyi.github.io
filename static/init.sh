#!/bin/bash

# Debian 12 系统初始化脚本
# 作者: luodaoyi
# 日期: 2025-07-19
# 用途: 安装必要软件包，配置vim，启用BBR，安装Docker

set -e  # 遇到错误时退出

# 颜色输出函数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要root权限运行"
        log_info "请使用: curl luodaoyi.com/init.sh | sudo bash"
        exit 1
    fi
}

# 检查系统版本
check_system() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" != "debian" ]] || [[ "$VERSION_ID" != "12" ]]; then
            log_warning "此脚本专为Debian 12设计，当前系统: $PRETTY_NAME"
            log_info "继续执行可能会遇到问题，5秒后继续..."
            sleep 5
        fi
    else
        log_warning "无法检测系统版本，继续执行..."
    fi
}

# 更新软件包列表
update_packages() {
    log_info "更新软件包列表..."
    apt update
    log_success "软件包列表更新完成"
}

# 安装必要软件包
install_packages() {
    log_info "安装必要软件包: vim git curl wget btop htop..."
    apt install -y vim git curl wget btop htop
    log_success "软件包安装完成"
}

# 配置vim禁用鼠标功能
configure_vim() {
    log_info "配置vim禁用鼠标功能..."
    
    VIM_DEFAULTS="/usr/share/vim/vim90/defaults.vim"
    
    if [[ -f "$VIM_DEFAULTS" ]]; then
        # 备份原文件
        cp "$VIM_DEFAULTS" "${VIM_DEFAULTS}.backup.$(date +%Y%m%d_%H%M%S)"
        
        # 替换鼠标设置
        sed -i "s/set mouse=a/set mouse-=a/g" "$VIM_DEFAULTS"
        sed -i "s/set mouse=nvi/set mouse-=nvi/g" "$VIM_DEFAULTS"
        
        log_success "vim鼠标功能已禁用"
    else
        log_warning "未找到vim配置文件: $VIM_DEFAULTS"
    fi
}

# 启用BBR TCP拥塞控制
enable_bbr() {
    log_info "配置BBR TCP拥塞控制算法..."
    
    # 检查是否已经配置
    if ! grep -q "net.core.default_qdisc=fq" /etc/sysctl.conf; then
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    fi
    
    if ! grep -q "net.ipv4.tcp_congestion_control=bbr" /etc/sysctl.conf; then
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    fi
    
    # 应用配置
    sysctl -p
    
    log_info "当前可用的拥塞控制算法:"
    sysctl net.ipv4.tcp_available_congestion_control
    
    log_info "检查BBR模块:"
    if lsmod | grep -q bbr; then
        log_success "BBR模块已加载"
    else
        log_warning "BBR模块未加载，可能需要重启后生效"
    fi
    
    log_success "BBR配置完成"
}

# 设置时区为香港时区
set_timezone() {
    log_info "设置时区为香港时区 (Asia/Hong_Kong)..."
    
    # 设置时区
    timedatectl set-timezone Asia/Hong_Kong
    
    # 显示当前时间
    log_success "时区设置完成，当前时间: $(date)"
}

# 安装Docker
install_docker() {
    log_info "安装Docker..."
    
    # 检查Docker是否已安装
    if command -v docker &> /dev/null; then
        log_warning "Docker已经安装，跳过安装步骤"
        return
    fi
    
    # 下载并执行Docker安装脚本
    curl -sSL https://get.docker.com/ | sh
    
    # 启动Docker服务
    systemctl start docker
    systemctl enable docker
    
    # 将当前用户添加到docker组（如果不是通过sudo运行）
    if [[ -n "$SUDO_USER" ]]; then
        usermod -aG docker "$SUDO_USER"
        log_success "用户 $SUDO_USER 已添加到docker组"
        log_info "请重新登录以使docker组权限生效"
    fi
    
    # 检查Docker版本
    DOCKER_VERSION=$(docker --version)
    log_success "Docker安装完成: $DOCKER_VERSION"
}

# 显示完成信息
show_completion() {
    echo
    echo "=========================================="
    log_success "Debian 12 系统初始化完成！"
    echo "=========================================="
    echo
    echo "✅ 已安装软件包:"
    echo "   - vim (已禁用鼠标功能)"
    echo "   - git"
    echo "   - curl"
    echo "   - wget" 
    echo "   - btop"
    echo "   - htop"
    echo "   - docker"
    echo
    echo "✅ BBR TCP拥塞控制已启用"
    echo "✅ 时区已设置为香港时区 (UTC+8)"
    echo "✅ Docker已安装并启动"
    echo
    echo "📝 注意事项:"
    echo "   - vim配置文件已备份"
    echo "   - BBR可能需要重启后完全生效"
    echo "   - 如果通过sudo执行，请重新登录以使docker组权限生效"
    echo
    echo "🔄 建议重启系统以确保所有配置生效:"
    echo "   sudo reboot"
    echo
    echo "=========================================="
}

# 主函数
main() {
    echo
    echo "=========================================="
    echo "  Debian 12 系统初始化脚本"
    echo "  作者: luodaoyi"
    echo "  时间: $(date)"
    echo "=========================================="
    echo
    
    check_root
    check_system
    update_packages
    install_packages
    configure_vim
    enable_bbr
    set_timezone
    install_docker
    show_completion
}

# 执行主函数
main "$@"