+++
title = 'Caddy设置仅允许cloudfalre的ip访问，防止被穿过waf'
date = 2024-10-15T13:42:09+08:00
draft = false
categories=["linux"]
tags= [ "dsm","群晖" ]
+++



此配置的主要用途是确保没有人可以绕过Cloudflare或其他安全反向代理提供商对网站发起拒绝服务攻击（DoS）。类似功能可以通过real_ip和其他插件实现，但本文的重点是简化设置，不需要安装插件。

需要注意的是，Cloudflare的IP范围并非静态的，尽管变化频率非常低，仍需要手动更新。有人仍然可以通过Cloudflare Workers作为第三方在Cloudflare IP范围内发起请求，不过要使用这种方式进行大规模拒绝服务攻击难度较大。



## 1. 创建Shell脚本以输出Cloudflare的IPv4/IPv6地址

首先我们创建一个Shell脚本，该脚本将Cloudflare的IPv4/IPv6地址输出为Caddyfile所需的格式：



`cloudflare-ip-list.sh:`

```bash
#!/bin/sh
#
# 输出最新的Cloudflare IP列表。
#
# 注意：即使阻止这些范围的流量，第三方的Cloudflare Workers仍然可以访问您的网站。
#

for i in `curl -s https://www.cloudflare.com/ips-v4`; do echo -n "$i "; done
for i in `curl -s https://www.cloudflare.com/ips-v6`; do echo -n "$i "; done
echo

```

## 2. 编写Caddyfile，使用生成的IP列表和代码片段


以下是一个针对多个子域配置的Caddyfile示例，每个子域使用相同的规则阻止非Cloudflare的流量。


```bash
#
# Caddy配置示例，阻止非Cloudflare的流量
#
{
    admin off
    email no-reply@example.com

    log {
        output file /var/log/caddy/access.log
        format json
    }
}

#
# Caddy代码片段：用于阻止所有非Cloudflare来源的流量。
#
# 此配置旨在阻止恶意扫描和IP侦查的机器人流量。
#
# 生成remote_ip列表可通过cloudflare-ip-list.sh脚本
#
# 了解更多关于Caddy代码片段的信息：
# - https://caddyserver.com/docs/caddyfile/concepts#snippets
# - https://caddy.community/t/caddy-v2-reusable-snippets/6744
#
(cloudflare-only) {
  # 使用shell脚本输出的IP地址更新此处
  @blocked not remote_ip 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 104.24.0.0/14 172.64.0.0/13 131.0.72.0/22 2400:cb00::/32 2606:4700::/32 2803:f800::/32 2405:b500::/32 2405:8100::/32 2a06:98c0::/29 2c0f:f248::/32 
  respond @blocked "<h1>仅允许通过Cloudflare访问HTTP/HTTPS</h1>" 403
}

# 指定只能通过Cloudflare反向代理访问的子域
#
# 手动测试直接IP是否被阻止：
#
#    curl --header "Host: mysite.example.com" http://1.2.3.4
#
http://mysite.example.com {    
    handle {
        import cloudflare-only

        # 网站处理逻辑
        reverse_proxy 127.0.0.1:8080
    }
}

:80 {
    respond "<h1>未指定站点域名的HTTP请求</h1>" 403
}

:443 {
    respond "<h1>未指定站点域名的HTTPS请求</h1>" 403
}


```


## 3. 测试直接IP访问是否被阻止

使用以下命令测试直接IP访问是否被成功阻止：

```bash
curl --header "Host: mysite.example.com" http://1.2.3.4
```


成功阻止时，应该返回：

```bash
<h1>仅允许通过Cloudflare访问HTTP/HTTPS</h1>
```