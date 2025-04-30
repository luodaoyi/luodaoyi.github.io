+++
title = '禁用docker的ufw,禁止docker无视ufw规则'
date = 2024-11-23T08:33:14+08:00 
draft = false
categories=["linux"]
tags= [ "dsm","debian", "ubuntu" ]
+++


默认情况下，创建容器如果绑定了端口，则 docker 会自动修改 iptables 打开这个端口。然而 UFW 并不会显示这个规则，这就导致了不管使用 UFW 做什么限制，docker 绑定的这个端口都是开放的。
# 问题所在

默认情况下，创建容器如果绑定了端口，则 docker 会自动修改 iptables 打开这个端口。然而 [UFW(uncomplicated firewall)](https://linux.cn/article-8087-1.html) 并不会显示这个规则，这就导致了不管使用 UFW 做什么限制，docker 绑定的这个端口都是开放的。

可以使用 iptables -L DOCKER 查看 docker 在防火墙上开的洞，而且[官方并不打算修复这个问题](https://github.com/moby/moby/issues/4737)。

那么现在要做的就是禁止 docker 自作聪明的修改 iptables，并使用 UFW 来限制 docker 的端口开放。
# 1 启用 UFW

在启动 UFW 之前务必添加规则允许 ssh 通过，否则...

```shell
ufw allow ssh
ufw allow from 172.16.0.0/12 # 允许 docker 容器之间相互访问
ufw allow from 10.0.0.0/8	 # 允许内网
ufw allow from 192.168.0.0/16	#允许内网
ufw default deny incoming
ufw default allow outgoing
ufw default allow routed
ufw disable && ufw enable
```

# 2 禁止 docker 更新 iptables
Ubuntu 16.04 之后使用 systemd 替代 upstart，所以在 `/etc/default/docker` 修改 DOCKER_OPTS 加上 `--iptables=false` 的方式不起作用了。

```shell
mkdir -p /lib/systemd/system/docker.service.d

cat << EOF > /lib/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd
EOF

cat << EOF > /etc/docker/daemon.json
{
  "hosts": ["fd://"],
  "dns": ["8.8.8.8", "8.8.4.4"],
  "iptables": false
}
EOF

systemctl daemon-reload && systemctl restart docker
```

检查 docker 的启动命令

```shell
ps aux | grep docker | grep -v grep
```

# 3 配置 docker 的 NAT
完成上面两步之后 docker 就应该处于 UFW 的限制之下了。如果重启之后发现 docker 容器无法连接外网的话，还需要这里配置

```shell
cat << EOF >> /etc/ufw/before.rules
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING ! -o docker0 -s 172.17.0.0/16 -j MASQUERADE
COMMIT
EOF
```


检查 docker 容器是否能连接外网

```shell
docker run -it --rm alpine ping -c 1 8.8.8.8
```

列出 docker 的网络

```shell
docker network ls

```

# 其他

nginx 无法获取真实 ip
可以使用 host 模式启动容器

```shell
docker run --net=host ...
```



# docker for macOS


[There is no docker0 bridge on macOS](https://docs.docker.com/desktop/features/networking/#there-is-no-docker0-bridge-on-macos)

在 macOS 上是看不到 docker0 这个网桥的，所以容器是无法通过 172.0.0.1 来向宿主机通信，这时候就可以使用 `docker.for.mac.localhost` 来连接（v17.06+ only）。

然而容器内还是无法获取客户端的真实 IP 的，也是一个(几年前的坑)(https://github.com/moby/moby/issues/15086)。

有人提出3个方案：

一是使用 --net=host 启动容器，二是 disable the userland proxy ，然而在 macOS 上并没什么卵用。

最后一个令人窒息的操作，即在宿主机开一个 nginx 反向代理，在请求头加上 IP。

# 参考

* [让 docker 向 UFW 低头 - keng42 ](https://keng42.com/blog/article/docker-ufw/)
* [无视系统防火墙的docker](https://www.binss.me/blog/docker-pass-through-system-firewall/)
