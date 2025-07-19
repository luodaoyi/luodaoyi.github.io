#!/bin/bash

# Debian 12 系统初始化脚本
# 作者: luodaoyi
# 日期: 2025-07-19
# 用途: 安装必要软件包，配置vim，启用BBR，安装Docker，配置SSH公钥

set -e  # 遇到错误时退出

# 颜色输出函数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

log_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# SSH公钥常量
SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5zZNf5YHXkO89QmI/ecp5uPxMDMtYQhdoOPuP98b99I0dhLc7FK7/T3OwJBnNF7sTbl5ULDmhyAyyJmwcKOza7cgL13VQ2bw46T78eAu3owZBDt5vvmZjKC/aIdENtFa+cRcOnjuAlZe1b6kur+/1wD5w1qrzGEJ2ErWU6/6exjGXzfol5nWIrF9dwjBgXK818Vl8/YHLi26DYL+lfR2/eynrIuDIisyQp726qstkBIVNnDE3DYHP/X/+lmYaaz5fUSyvuxVQR2UG1OUo5xl9CGC8oQnCtWGDoToEKzktcIKSEKPmHWOGO4AzGB+mjXNV6+YXe4E623mG9hMbl+Ff"

# 检查是否为root用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要root权限运行"
        echo
        log_info "请使用以下任一命令执行："
        echo "   curl http://luodaoyi.com/init.sh | sudo bash"
        echo "   wget -qO- http://luodaoyi.com/init.sh | sudo bash"
        echo
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

# 配置SSH公钥
setup_ssh_key() {
    log_info "开始配置SSH公钥..."
    
    # 确定目标用户
    local target_user
    if [[ -n "$SUDO_USER" && "$SUDO_USER" != "root" ]]; then
        target_user="$SUDO_USER"
        log_info "检测到sudo用户，将为用户 $target_user 配置SSH公钥"
    else
        target_user="root"
        log_info "将为root用户配置SSH公钥"
    fi
    
    # 确定用户主目录
    local user_home
    if [[ "$target_user" == "root" ]]; then
        user_home="/root"
    else
        user_home="/home/$target_user"
    fi
    
    local ssh_dir="$user_home/.ssh"
    local authorized_keys="$ssh_dir/authorized_keys"
    
    # 创建.ssh目录（如果不存在）
    if [[ ! -d "$ssh_dir" ]]; then
        log_info "创建SSH目录: $ssh_dir"
        mkdir -p "$ssh_dir"
        chown "$target_user:$target_user" "$ssh_dir"
        chmod 700 "$ssh_dir"
    fi
    
    # 创建authorized_keys文件（如果不存在）
    if [[ ! -f "$authorized_keys" ]]; then
        log_info "创建authorized_keys文件"
        touch "$authorized_keys"
        chown "$target_user:$target_user" "$authorized_keys"
        chmod 600 "$authorized_keys"
    fi
    
    # 检查公钥是否已存在
    local key_exists=false
    if grep -Fq "$(echo "$SSH_PUBLIC_KEY" | cut -d' ' -f2)" "$authorized_keys" 2>/dev/null; then
        key_exists=true
    fi
    
    if [[ "$key_exists" == true ]]; then
        log_success "SSH公钥已存在，跳过添加"
    else
        # 添加公钥
        log_info "添加SSH公钥到authorized_keys..."
        echo "$SSH_PUBLIC_KEY luodaoyi@$(date +%Y%m%d)" >> "$authorized_keys"
        
        # 确保文件权限正确
        chown "$target_user:$target_user" "$authorized_keys"
        chmod 600 "$authorized_keys"
        
        log_success "SSH公钥已成功添加到用户 $target_user"
    fi
    
    # 检查并启动SSH服务
    log_info "检查SSH服务状态..."
    if systemctl is-active --quiet ssh || systemctl is-active --quiet sshd; then
        log_success "SSH服务正在运行"
    else
        log_info "启动SSH服务..."
        systemctl start ssh 2>/dev/null || systemctl start sshd 2>/dev/null || true
    fi
    
    # 设置SSH服务开机自启
    if ! systemctl is-enabled --quiet ssh && ! systemctl is-enabled --quiet sshd; then
        log_info "设置SSH服务开机自启..."
        systemctl enable ssh 2>/dev/null || systemctl enable sshd 2>/dev/null || true
    fi
    
    log_success "SSH配置完成"
}

# 更新软件包列表
update_packages() {
    log_info "更新软件包列表..."
    apt update
    log_success "软件包列表更新完成"
}

# 安装必要软件包
install_packages() {
    log_info "安装必要软件包: vim git curl wget btop htop openssh-server..."
    apt install -y vim git curl wget btop htop openssh-server
    log_success "软件包安装完成"
}

# 自动检测vim版本并获取配置文件路径
get_vim_defaults_path() {
    local vim_defaults=""
    
    # 方法1: 检查常见的vim版本目录
    for vim_dir in /usr/share/vim/vim*; do
        if [[ -d "$vim_dir" && -f "$vim_dir/defaults.vim" ]]; then
            vim_defaults="$vim_dir/defaults.vim"
            break
        fi
    done
    
    # 方法2: 如果方法1失败，尝试通过vim命令获取版本
    if [[ -z "$vim_defaults" ]] && command -v vim &> /dev/null; then
        local vim_version
        vim_version=$(vim --version 2>/dev/null | head -1 | grep -o 'Vi IMproved [0-9]\+\.[0-9]\+' | grep -o '[0-9]\+\.[0-9]\+' | tr -d '.')
        if [[ -n "$vim_version" ]]; then
            local possible_path="/usr/share/vim/vim${vim_version}/defaults.vim"
            if [[ -f "$possible_path" ]]; then
                vim_defaults="$possible_path"
            fi
        fi
    fi
    
    # 方法3: 通过find命令查找
    if [[ -z "$vim_defaults" ]]; then
        vim_defaults=$(find /usr/share/vim -name "defaults.vim" 2>/dev/null | head -1)
    fi
    
    echo "$vim_defaults"
}

# 配置vim禁用鼠标功能
configure_vim() {
    log_info "配置vim禁用鼠标功能..."
    
    # 自动检测vim配置文件路径
    local vim_defaults
    vim_defaults=$(get_vim_defaults_path)
    
    if [[ -n "$vim_defaults" && -f "$vim_defaults" ]]; then
        log_info "检测到vim配置文件: $vim_defaults"
        
        # 备份原文件
        cp "$vim_defaults" "${vim_defaults}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "已备份原配置文件"
        
        # 替换鼠标设置
        sed -i "s/set mouse=a/set mouse-=a/g" "$vim_defaults"
        sed -i "s/set mouse=nvi/set mouse-=nvi/g" "$vim_defaults"
        
        # 验证修改结果
        if grep -q "mouse-=" "$vim_defaults"; then
            log_success "vim鼠标功能已成功禁用"
        else
            log_warning "vim鼠标设置可能未找到对应配置，但脚本已执行"
        fi
    else
        log_warning "未找到vim默认配置文件，尝试创建全局配置..."
        
        # 创建全局vim配置
        if [[ ! -f /etc/vim/vimrc.local ]]; then
            echo '" 禁用鼠标功能' > /etc/vim/vimrc.local
            echo 'set mouse-=a' >> /etc/vim/vimrc.local
            log_success "已创建全局vim配置文件 /etc/vim/vimrc.local"
        else
            # 检查是否已经配置
            if ! grep -q "mouse-=" /etc/vim/vimrc.local; then
                echo 'set mouse-=a' >> /etc/vim/vimrc.local
                log_success "已在现有全局配置中禁用鼠标功能"
            else
                log_success "全局配置中已存在鼠标禁用设置"
            fi
        fi
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
    local server_ip
    server_ip=$(hostname -I | awk '{print $1}' || echo "获取IP失败")
    
    local target_user
    if [[ -n "$SUDO_USER" && "$SUDO_USER" != "root" ]]; then
        target_user="$SUDO_USER"
    else
        target_user="root"
    fi
    
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
    echo "   - openssh-server"
    echo "   - docker"
    echo
    echo "✅ 系统配置:"
    echo "   - BBR TCP拥塞控制已启用"
    echo "   - 时区已设置为香港时区 (UTC+8)"
    echo "   - SSH服务已启动并设为开机自启"
    echo "   - SSH公钥已配置完成"
    echo
    echo "🔑 SSH连接信息:"
    echo "   服务器IP: $server_ip"
    echo "   用户名: $target_user"
    echo "   连接命令: ssh $target_user@$server_ip"
    echo
    echo "📝 重要提示:"
    echo "   - vim配置文件已备份"
    echo "   - BBR可能需要重启后完全生效"
    echo "   - 如果通过sudo执行，请重新登录以使docker组权限生效"
    echo "   - 现在可以使用配置的SSH私钥远程登录服务器"
    echo
    echo "🔄 建议重启系统以确保所有配置生效:"
    echo "   sudo reboot"
    echo
    echo "💡 脚本使用说明："
    echo "   curl http://luodaoyi.com/init.sh | sudo bash"
    echo "   wget -qO- http://luodaoyi.com/init.sh | sudo bash"
    echo
    echo "=========================================="
}

# 主函数
main() {
    echo
    echo "=========================================="
    echo "  Debian 12 系统初始化脚本"
    echo "  作者: luodaoyi"
    echo "  时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=========================================="
    echo
    
    check_root
    check_system
    setup_ssh_key          # 首先配置SSH，确保远程访问
    update_packages
    install_packages       # 现在包含openssh-server
    configure_vim
    enable_bbr
    set_timezone
    install_docker
    show_completion
}

# 执行主函数
main "$@"