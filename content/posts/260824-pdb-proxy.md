---
title: "我做了一个 PDB 符号代理：本地下载缓存，加速 msdl.microsoft.com"
categories: [ "项目", "开发工具" ]
tags: [ "pdb_proxy", "PDB", "符号服务器", "msdl", "Visual Studio" ]
draft: false
slug: "pdb-proxy"
date: "2026-08-24T20:00:00+08:00"
lastmod: "2026-08-24T20:00:00+08:00"
---

最近用 Visual Studio 写代码，经常卡在从 `msdl.microsoft.com` 下 PDB。

于是我维护了一份符号代理：**pdb_proxy**。上游走微软符号服务器，命中过的文件留在本地，下一次直接从缓存出。

仓库：

<https://github.com/luodaoyi/pdb_proxy>

当前 Latest Release 是 **[v1.1.0](https://github.com/luodaoyi/pdb_proxy/releases/tag/v1.1.0)**。

<!--more-->

我自己对外提供的节点是：

<https://msdl.011f.com>

别人公开的节点不是我的，别写成自己的。

## 怎么装

Linux 跑仓库里的 install.sh：

```shell
curl -o- https://raw.githubusercontent.com/luodaoyi/pdb_proxy/master/install.sh | bash
```

卸载：

```shell
curl -o- https://raw.githubusercontent.com/luodaoyi/pdb_proxy/master/uninstall.sh | bash
```

脚本会拉最新 Release 里对应架构的 `linux-amd64` / `linux-arm64` 包，装成 systemd 服务 `pdb-proxy`，开机自启，默认监听 9000，缓存目录 `/opt/pdb`。

```shell
systemctl start pdb-proxy
systemctl stop pdb-proxy
systemctl restart pdb-proxy
```

## 缓存多久

环境变量 **`PDB_CACHE_TTL`**（配置项 `pdb_cache_ttl`），Go duration，例如 `1h`、`30m`、`24h`。

- 默认 **`1h`**
- 设成 **`0`** 就是永久缓存

装的时候可以直接带：

```shell
PDB_CACHE_TTL=24h bash install.sh
```

Docker 用仓库根目录那份 `docker-compose.yml`。永久缓存：

```shell
PDB_CACHE_TTL=0 docker compose up -d
```

Compose 里默认同样是 `1h`，上游是微软符号服务器，端口 `9000:9000`，缓存卷 `./pdb:/opt/pdb`。

过期后会回源刷新；回源失败时继续用手里这份已经过期的缓存，不把请求直接打挂。

## 链接

- 仓库：<https://github.com/luodaoyi/pdb_proxy>
- Release：[v1.1.0 - Configurable cache TTL](https://github.com/luodaoyi/pdb_proxy/releases/tag/v1.1.0)
- 节点：<https://msdl.011f.com>
