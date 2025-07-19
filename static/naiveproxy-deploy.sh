#!/bin/bash

# NaiveProxy 一键部署脚本
# 作者: luodaoyi
# 支持安装、升级、卸载功能

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 配置变量
GO_INSTALL_PATH="/usr/local/go"
CADDY_PATH="/usr/bin/caddy"
CADDY_CONFIG_PATH="/etc/caddy"
CADDY_SERVICE_PATH="/etc/systemd/system/caddy.service"
GO_PROFILE_PATH="/etc/profile.d/go.sh"

# 显示使用说明
show_usage() {
    echo
    echo "=========================================="
    echo "  NaiveProxy 一键部署脚本"
    echo "  作者: luodaoyi"
    echo "  版本: v1.0"
    echo "  时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=========================================="
    echo
    echo "📋 功能说明："
    echo "   NaiveProxy是基于Caddy forwardproxy的高性能代理工具"
    echo "   支持HTTP/2协议，具有强抗检测能力"
    echo "   ⚠️  注意：NaiveProxy不支持UDP代理"
    echo
    echo "🔧 使用方法："
    echo "   $0 --install     安装NaiveProxy服务"
    echo "   $0 --upgrade     升级NaiveProxy（重新编译Caddy）"
    echo "   $0 --uninstall   完全卸载NaiveProxy及相关组件"
    echo
    echo "⚡ 一键执行命令："
    echo "   # 一键安装"
    echo "   wget -qO- http://luodaoyi.com/naiveproxy-deploy.sh | sudo bash -s -- --install"
    echo "   curl -sSL http://luodaoyi.com/naiveproxy-deploy.sh | sudo bash -s -- --install"
    echo
    echo "   # 一键升级"
    echo "   wget -qO- http://luodaoyi.com/naiveproxy-deploy.sh | sudo bash -s -- --upgrade"
    echo "   curl -sSL http://luodaoyi.com/naiveproxy-deploy.sh | sudo bash -s -- --upgrade"
    echo
    echo "   # 一键卸载"
    echo "   wget -qO- http://luodaoyi.com/naiveproxy-deploy.sh | sudo bash -s -- --uninstall"
    echo "   curl -sSL http://luodaoyi.com/naiveproxy-deploy.sh | sudo bash -s -- --uninstall"
    echo
    echo "💡 本地下载使用："
    echo "   # 下载脚本"
    echo "   wget http://luodaoyi.com/naiveproxy-deploy.sh"
    echo "   chmod +x naiveproxy-deploy.sh"
    echo
    echo "   # 安装"
    echo "   sudo ./naiveproxy-deploy.sh --install"
    echo
    echo "📦 安装内容："
    echo "   - Golang最新版本环境"
    echo "   - 带NaiveProxy插件的Caddy"
    echo "   - 自动SSL证书管理"
    echo "   - systemd服务配置"
    echo "   - DNS插件支持（Cloudflare/DNSPod/AliDNS）"
    echo
    echo "🌐 支持的DNS插件："
    echo "   - Cloudflare DNS"
    echo "   - DNSPod（腾讯云DNS）"
    echo "   - AliDNS（阿里云DNS）"
    echo
    echo "⚡ 系统要求："
    echo "   - Ubuntu/Debian系统"
    echo "   - 需要root权限"
    echo "   - 支持AMD64/ARM64架构"
    echo "   - 需要有效的域名和DNS解析"
    echo
    echo "🔗 相关链接："
    echo "   - GitHub: https://github.com/klzgrad/naiveproxy"
    echo "   - Caddy: https://caddyserver.com/"
    echo
    echo "=========================================="
}

# 检查root权限
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要root权限运行"
        echo
        log_info "请使用以下命令之一："
        echo "   # 一键安装"
        echo "   wget -qO- http://luodaoyi.com/naiveproxy-deploy.sh | sudo bash -s -- --install"
        echo "   curl -sSL http://luodaoyi.com/naiveproxy-deploy.sh | sudo bash -s -- --install"
        echo
        echo "   # 本地执行"
        echo "   sudo $0 --install"
        echo
        exit 1
    fi
}

# 检查系统架构
detect_arch() {
    local arch=$(uname -m)
    case $arch in
        x86_64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            log_error "不支持的系统架构: $arch"
            exit 1
            ;;
    esac
}

# 安装依赖
install_dependencies() {
    log_info "更新软件包列表并安装依赖..."
    apt update
    apt install -y wget curl jq libnss3 debian-keyring debian-archive-keyring apt-transport-https python3
    log_success "依赖软件包安装完成"
}

# 安装Golang
install_golang() {
    log_info "开始安装Golang..."
    
    # 获取最新版本
    local go_version
    go_version=$(curl -s https://go.dev/dl/?mode=json | jq -r '.[0].version')
    log_info "最新Go版本: $go_version"
    
    # 检测架构
    local arch=$(detect_arch)
    local go_file="${go_version}.linux-${arch}.tar.gz"
    
    # 清理旧版本
    rm -rf $GO_INSTALL_PATH
    mkdir -p $GO_INSTALL_PATH
    
    # 下载并安装
    log_info "下载Go安装包: $go_file"
    cd /tmp
    wget -O "$go_file" "https://go.dev/dl/$go_file"
    
    log_info "解压安装Go..."
    tar -zxf "$go_file" -C /usr/local/
    
    # 配置环境变量
    log_info "配置Go环境变量..."
    cat > $GO_PROFILE_PATH << 'EOF'
export GOROOT=/usr/local/go
export PATH=$GOROOT/bin:$PATH
EOF

    source $GO_PROFILE_PATH
    
    # 为所有用户配置GOPATH
    if [[ -n "$SUDO_USER" ]]; then
        local user_home="/home/$SUDO_USER"
        sudo -u "$SUDO_USER" bash -c "
            cat >> $user_home/.bashrc << 'EOF'
export GOPATH=\$HOME/.gopath
export PATH=\$GOPATH/bin:\$PATH
export GO111MODULE=on
EOF
            mkdir -p $user_home/.gopath
        "
    fi
    
    # 验证安装
    /usr/local/go/bin/go version
    log_success "Golang安装完成"
}

# 编译Caddy
build_caddy() {
    log_info "开始编译Caddy..."
    
    # 设置Go环境
    export GOROOT=/usr/local/go
    export PATH=$GOROOT/bin:$PATH
    
    # 创建工作目录
    local work_dir="/tmp/caddy-build"
    rm -rf "$work_dir"
    mkdir -p "$work_dir"
    cd "$work_dir"
    
    # 安装xcaddy
    log_info "安装xcaddy工具..."
    $GOROOT/bin/go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
    
    # 设置GOPATH
    export GOPATH="/root/.gopath"
    mkdir -p "$GOPATH"
    export PATH="$GOPATH/bin:$PATH"
    
    # 构建Caddy
    log_info "构建带有NaiveProxy插件的Caddy..."
    log_info "这可能需要几分钟时间，请耐心等待..."
    $GOPATH/bin/xcaddy build \
        --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive \
        --with github.com/caddy-dns/cloudflare@latest \
        --with github.com/caddy-dns/dnspod@latest \
        --with github.com/caddy-dns/alidns@latest
    
    # 安装Caddy
    log_info "安装Caddy到系统路径..."
    mv caddy $CADDY_PATH
    chmod +x $CADDY_PATH
    
    # 设置权限
    setcap cap_net_bind_service=+ep $CADDY_PATH
    
    # 验证安装
    $CADDY_PATH version
    log_success "Caddy编译安装完成"
}

# 创建用户和组
create_caddy_user() {
    log_info "创建Caddy用户和组..."
    
    if ! getent group caddy >/dev/null 2>&1; then
        groupadd --system caddy
    fi
    
    if ! getent passwd caddy >/dev/null 2>&1; then
        useradd --system \
            --gid caddy \
            --create-home \
            --home-dir /var/lib/caddy \
            --shell /usr/sbin/nologin \
            --comment "Caddy web server" \
            caddy
    fi
    
    log_success "Caddy用户创建完成"
}

# 配置Caddy服务
configure_caddy() {
    log_info "配置Caddy服务..."
    
    # 创建配置目录
    mkdir -p $CADDY_CONFIG_PATH
    
    # 获取用户输入
    echo
    log_info "请按提示输入配置信息："
    read -p "请输入您的域名 (例: example.com): " DOMAIN
    while [[ -z "$DOMAIN" ]]; do
        log_warning "域名不能为空，请重新输入"
        read -p "请输入您的域名 (例: example.com): " DOMAIN
    done
    
    read -p "请输入管理员邮箱 (用于SSL证书): " EMAIL
    while [[ -z "$EMAIL" ]]; do
        log_warning "邮箱不能为空，请重新输入"
        read -p "请输入管理员邮箱 (用于SSL证书): " EMAIL
    done
    
    read -p "请输入代理用户名 (默认: naiveuser): " USERNAME
    USERNAME=${USERNAME:-naiveuser}
    
    while true; do
        read -s -p "请输入代理密码: " PASSWORD
        echo
        if [[ -z "$PASSWORD" ]]; then
            log_warning "密码不能为空，请重新输入"
        else
            break
        fi
    done
    
    read -p "请输入反向代理目标 (默认: www.bing.com): " REVERSE_TARGET
    REVERSE_TARGET=${REVERSE_TARGET:-www.bing.com}
    
    # 生成配置文件
    cat > $CADDY_CONFIG_PATH/Caddyfile << EOF
{
    admin off
    order forward_proxy before reverse_proxy
}

:443, $DOMAIN {
    tls $EMAIL
    request_body {
        max_size 1GB
    }
    forward_proxy {
        basic_auth $USERNAME $PASSWORD
        hide_ip
        hide_via
        probe_resistance
    }
    reverse_proxy $REVERSE_TARGET
}
EOF

    # 创建systemd服务文件
    cat > $CADDY_SERVICE_PATH << 'EOF'
[Unit]
Description=Caddy
Documentation=https://caddyserver.com/docs/
After=network.target network-online.target
Requires=network-online.target

[Service]
User=caddy
Group=caddy
ExecStart=/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/bin/caddy reload --config /etc/caddy/Caddyfile
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOF

    # 启动服务
    log_info "启动Caddy服务..."
    systemctl daemon-reload
    systemctl enable caddy
    systemctl start caddy
    
    # 检查服务状态
    if systemctl is-active --quiet caddy; then
        log_success "Caddy服务启动成功"
    else
        log_warning "Caddy服务启动可能有问题，请检查日志: journalctl -u caddy -f"
    fi
}

# 检查JARM指纹
check_jarm() {
    log_info "检查JARM指纹..."
    
    if [[ -z "$DOMAIN" ]]; then
        log_warning "未设置域名，跳过JARM检查"
        return
    fi
    
    # 等待服务完全启动
    log_info "等待Caddy服务完全启动..."
    sleep 10
    
    # 下载JARM工具
    cd /tmp
    if ! wget -q https://raw.githubusercontent.com/salesforce/jarm/master/jarm.py; then
        log_warning "无法下载JARM工具，跳过指纹检查"
        return
    fi
    
    # 检查指纹
    log_info "正在检查JARM指纹，请稍候..."
    local jarm_result
    jarm_result=$(timeout 30 python3 jarm.py "$DOMAIN" 2>/dev/null | tail -1 || echo "检查超时或失败")
    
    echo
    log_info "JARM指纹检查结果: $jarm_result"
    
    if [[ "$jarm_result" != "检查超时或失败" ]]; then
        log_info "指纹检查建议："
        log_info "1. 访问 https://fofa.info"
        log_info "2. 搜索框输入: jarm=\"$jarm_result\""
        log_info "3. 如果结果有数万个以上，说明指纹正常"
        log_info "4. 如果只有几十个，建议重新部署或更换配置"
    fi
    echo
}

# 显示完成信息
show_completion() {
    local server_ip
    server_ip=$(curl -s --max-time 10 ifconfig.me 2>/dev/null || curl -s --max-time 10 icanhazip.com 2>/dev/null || hostname -I | awk '{print $1}' || echo "无法获取")
    
    echo
    echo "=========================================="
    log_success "NaiveProxy 安装部署完成！"
    echo "=========================================="
    echo
    echo "📋 服务信息:"
    echo "   域名: $DOMAIN"
    echo "   服务器IP: $server_ip"
    echo "   代理用户名: $USERNAME"
    echo "   代理密码: $PASSWORD"
    echo "   反向代理目标: $REVERSE_TARGET"
    echo
    echo "🔧 管理命令:"
    echo "   查看状态: systemctl status caddy"
    echo "   重启服务: systemctl restart caddy"
    echo "   查看日志: journalctl -u caddy -f"
    echo "   重载配置: systemctl reload caddy"
    echo "   测试配置: caddy validate --config /etc/caddy/Caddyfile"
    echo
    echo "📱 客户端配置:"
    echo "   协议: HTTPS"
    echo "   服务器: $DOMAIN:443"
    echo "   用户名: $USERNAME"
    echo "   密码: $PASSWORD"
    echo
    echo "⚠️  重要提醒:"
    echo "   - NaiveProxy 不支持UDP代理"
    echo "   - 请确保域名 $DOMAIN 正确解析到服务器IP: $server_ip"
    echo "   - SSL证书会自动申请，首次访问可能需要等待几分钟"
    echo "   - 建议定期检查服务状态和日志"
    echo
    echo "🔄 脚本管理命令:"
    echo "   # 升级"
    echo "   wget -qO- http://luodaoyi.com/naiveproxy-deploy.sh | sudo bash -s -- --upgrade"
    echo
    echo "   # 卸载"  
    echo "   wget -qO- http://luodaoyi.com/naiveproxy-deploy.sh | sudo bash -s -- --uninstall"
    echo
    echo "=========================================="
}

# 安装NaiveProxy
install_naiveproxy() {
    echo
    echo "=========================================="
    log_info "开始安装NaiveProxy..."
    echo "=========================================="
    
    check_root
    install_dependencies
    install_golang
    build_caddy
    create_caddy_user
    configure_caddy
    check_jarm
    show_completion
}

# 升级功能
upgrade_naiveproxy() {
    echo
    echo "=========================================="
    log_info "开始升级NaiveProxy..."
    echo "=========================================="
    
    check_root
    
    # 检查是否已安装
    if [[ ! -f $CADDY_PATH ]]; then
        log_error "未检测到已安装的NaiveProxy"
        log_info "请先使用以下命令进行安装："
        echo "   wget -qO- http://luodaoyi.com/naiveproxy-deploy.sh | sudo bash -s -- --install"
        exit 1
    fi
    
    # 停止服务
    log_info "停止Caddy服务..."
    systemctl stop caddy
    
    # 备份配置
    log_info "备份当前配置..."
    cp $CADDY_CONFIG_PATH/Caddyfile /tmp/Caddyfile.backup.$(date +%Y%m%d_%H%M%S)
    
    # 重新编译Caddy
    build_caddy
    
    # 恢复配置
    log_info "恢复配置文件..."
    # 这里我们不恢复备份，而是保持现有配置
    
    # 重启服务
    log_info "重启Caddy服务..."
    systemctl start caddy
    
    # 检查状态
    if systemctl is-active --quiet caddy; then
        log_success "NaiveProxy升级完成！"
        echo
        log_info "当前版本信息："
        $CADDY_PATH version
    else
        log_error "服务启动失败，请检查日志: journalctl -u caddy -f"
    fi
}

# 卸载功能
uninstall_naiveproxy() {
    echo
    echo "=========================================="
    log_warning "开始卸载NaiveProxy..."
    echo "=========================================="
    
    check_root
    
    echo
    log_warning "⚠️  警告：此操作将完全删除以下内容："
    echo "   - Caddy服务和配置文件"
    echo "   - Golang环境 ($GO_INSTALL_PATH)"
    echo "   - 用户环境变量配置"
    echo "   - systemd服务配置"
    echo
    
    read -p "确定要完全卸载NaiveProxy吗？请输入 'yes' 确认: " confirm
    if [[ "$confirm" != "yes" ]]; then
        log_info "取消卸载操作"
        return
    fi
    
    log_info "开始卸载过程..."
    
    # 停止并禁用服务
    log_info "停止Caddy服务..."
    systemctl stop caddy 2>/dev/null || true
    systemctl disable caddy 2>/dev/null || true
    
    # 删除服务文件
    log_info "删除systemd服务文件..."
    rm -f $CADDY_SERVICE_PATH
    systemctl daemon-reload
    
    # 删除Caddy可执行文件
    log_info "删除Caddy可执行文件..."
    rm -f $CADDY_PATH
    
    # 删除配置目录
    log_info "删除配置目录..."
    rm -rf $CADDY_CONFIG_PATH
    
    # 删除用户和组
    log_info "删除Caddy用户和组..."
    userdel -r caddy 2>/dev/null || true
    groupdel caddy 2>/dev/null || true
    
    # 删除Go环境
    log_info "删除Golang环境..."
    rm -rf $GO_INSTALL_PATH
    rm -f $GO_PROFILE_PATH
    
    # 清理用户环境变量（如果存在）
    if [[ -n "$SUDO_USER" ]]; then
        local user_home="/home/$SUDO_USER"
        if [[ -f "$user_home/.bashrc" ]]; then
            log_info "清理用户环境变量..."
            sed -i '/export GOPATH=/d' "$user_home/.bashrc"
            sed -i '/export PATH=.*GOPATH/d' "$user_home/.bashrc"
            sed -i '/export GO111MODULE/d' "$user_home/.bashrc"
        fi
        rm -rf "$user_home/.gopath" 2>/dev/null || true
    fi
    
    echo
    log_success "NaiveProxy卸载完成！"
    log_info "所有相关文件和配置已删除"
}

# 主函数
main() {
    case "${1:-}" in
        --install)
            install_naiveproxy
            ;;
        --upgrade)
            upgrade_naiveproxy
            ;;
        --uninstall)
            uninstall_naiveproxy
            ;;
        *)
            show_usage
            echo
            log_warning "请指定操作参数！"
            echo
            log_info "常用一键命令："
            echo "   wget -qO- http://luodaoyi.com/naiveproxy-deploy.sh | sudo bash -s -- --install"
            echo
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"