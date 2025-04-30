+++
title = 'NaiveProxy 简易配置'
date = 2023-12-05 17:15:30
draft = false
+++


> 20250324 更新 
> naiveproxy不可以代理udp


## 安装golang

```shell
sudo apt update
sudo apt install wget -y

# 获取最新版本
export GO_VER=$(curl -s https://go.dev/dl/?mode=json | jq -r '.[0].version')
echo $GO_VER

## 清空目录
rm -rf /usr/local/go && mkdir -p /usr/local/go

# amd机器
wget https://go.dev/dl/${GO_VER}.linux-amd64.tar.gz 
sudo tar -zxvf ${GO_VER}.linux-amd64.tar.gz -C /usr/local/

# 甲骨文之类的arm机器
wget https://go.dev/dl/${GO_VER}.linux-arm64.tar.gz
sudo tar -zxvf ${GO_VER}.linux-arm64.tar.gz -C /usr/local/

# 配置path
cat > /etc/profile.d/go.sh << \EOF
export GOROOT=/usr/local/go
export PATH=$GOROOT/bin:$PATH
EOF

source /etc/profile.d/go.sh

# 加入环境变量
cat >> ~/.bashrc << \EOF
export GOPATH=$HOME/.gopath
export PATH=$GOPATH/bin:$PATH
export GO111MODULE=on
#export GOPROXY=https://goproxy.cn
EOF

source ~/.bashrc && mkdir -p $GOPATH && echo $GOPATH

# 看看正常不
go version
go env

```

## 编译安装

```shell
# 开始编译
sudo apt-get install libnss3 debian-keyring debian-archive-keyring apt-transport-https

mkdir ~/src &&  cd ~/src/

# 用xcaddy构建
go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest

# 开始构建
xcaddy build \
    --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive \
    --with github.com/caddy-dns/cloudflare@latest \
    --with github.com/caddy-dns/dnspod@latest \
    --with github.com/caddy-dns/alidns@latest 


sudo mv caddy /usr/bin/
caddy version
sudo setcap cap_net_bind_service=+ep /usr/bin/caddy  # 设置bind权限，可443

# 检查正常不
caddy version 

# 查看caddy已经安装的第三方模块
caddy list-modules --packages

```

## 配置服务

```shell
# 开始配置

mkdir -p /etc/caddy/ && touch /etc/caddy/Caddyfile

cat > /etc/caddy/Caddyfile << \EOF
{
    admin off
    order forward_proxy before reverse_proxy
}

:443, luodaoyi.com {
    tls asura@asura.com 
    request_body {
            max_size 1GB
    }
    forward_proxy {
            basic_auth asura asura123
            hide_ip
            hide_via
            probe_resistance
    }
    # 这里的端口是你反代的地址 随便你填 没的话填域名也可以
    # reverse_proxy www.bing.com
    reverse_proxy 127.0.0.1:33000
}

EOF

# 封装成服务 开机启动
groupadd --system caddy

useradd --system \
    --gid caddy \
    --create-home \
    --home-dir /var/lib/caddy \
    --shell /usr/sbin/nologin \
    --comment "Caddy web server" \
    caddy

cat > /etc/systemd/system/caddy.service << \EOF
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


# 测试正常不正常
sudo systemctl daemon-reload && sudo systemctl enable caddy  
sudo systemctl start caddy  && sudo systemctl status caddy
 
```


## 检查指纹

```shell

 # 检查指纹
# 下载jarm
wget https://raw.githubusercontent.com/salesforce/jarm/master/jarm.py

# 查看网站jarm指纹 
python3 jarm.py 你的域名

# 网络空间资产搜索引擎：
# 打开网址 https://fofa.info  
# 搜索框输入:  jarm="xxxxx"
# 如果结果有几百万个 那就没问题了，要是几十个就有问题，说明有特征了，重新搞吧
```

