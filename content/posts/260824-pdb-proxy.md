---
title: "我做了一个 PDB 符号代理：本地下载缓存，加速 msdl.microsoft.com"
categories: [ "项目", "开发工具" ]
tags: [ "pdb_proxy", "PDB", "符号服务器", "msdl", "Visual Studio" ]
draft: false
slug: "pdb-proxy"
date: "2026-08-24T20:00:00+08:00"
---

调试 Windows 程序时，Visual Studio 经常卡在从 `msdl.microsoft.com` 拉 PDB。于是我维护了一份符号代理：**pdb_proxy**。上游走微软符号服务器，命中过的文件留在本地，下一次直接从缓存出。

仓库：

<https://github.com/luodaoyi/pdb_proxy>

写这篇文章时，GitHub 上的 Latest Release 是 **v1.1.0**（2026-07-19）。一句话概括：**给 `msdl.microsoft.com` 做一层带本地缓存的代理，用 `PDB_CACHE_TTL` 控制缓存要新鲜多久。**

<!--more-->

我自己对外提供的节点是：

<https://msdl.011f.com>

这是我这边的服务入口。README 里还能看到别人公开的节点，那些不是我的，这里不写进使用说明。

## v1.1.0 在管什么

v1.1.0 的主题就是可配置缓存有效期。README 和 [v1.1.0 Release](https://github.com/luodaoyi/pdb_proxy/releases/tag/v1.1.0) 对得上的行为只有这些：

- 环境变量 **`PDB_CACHE_TTL`**，对应配置项 `pdb_cache_ttl`
- 用 Go duration，例如 `1h`、`30m`、`24h`
- **默认 `1h`**
- **设成 `0` 就是永久缓存**
- 过期后会回源刷新
- 回源失败时继续用手里这份已经过期的缓存，不把请求直接打挂
- 刷新先写临时文件，再替换缓存
- 已缓存的文件可以直接流式读出去，刷新完成后立刻能用上新内容

默认上游是 `https://msdl.microsoft.com/download/symbols`。本地安装脚本把缓存目录放在 `/opt/pdb`，监听 **9000**。

## Linux：仓库里的 install.sh

不要自己拼下载命令。仓库 README 写的安装 / 更新是：

```shell
curl -o- https://raw.githubusercontent.com/luodaoyi/pdb_proxy/master/install.sh | bash
```

卸载：

```shell
curl -o- https://raw.githubusercontent.com/luodaoyi/pdb_proxy/master/uninstall.sh | bash
```

脚本会拉最新 Release 里对应架构的 `linux-amd64` / `linux-arm64` 包，装成 systemd 服务 `pdb-proxy`，开机自启，默认监听 9000。装完用这三组命令管：

```shell
systemctl start pdb-proxy
systemctl stop pdb-proxy
systemctl restart pdb-proxy
```

Linux 安装脚本可以直接带 TTL。例如缓存 24 小时：

```shell
PDB_CACHE_TTL=24h bash install.sh
```

不传的话，脚本里的默认值就是 `1h`。

## Compose：跟仓库一起带的那份

仓库根目录有 `docker-compose.yml`。README 给的永久缓存例子是：

```shell
PDB_CACHE_TTL=0 docker compose up -d
```

Compose 文件里 `PDB_CACHE_TTL` 的默认值同样是 `1h`，上游同样是微软符号服务器，端口映射 `9000:9000`，缓存卷是 `./pdb:/opt/pdb`。

## 链接

当前就是 **v1.1.0**：

- 仓库：<https://github.com/luodaoyi/pdb_proxy>
- Release：[v1.1.0 - Configurable cache TTL](https://github.com/luodaoyi/pdb_proxy/releases/tag/v1.1.0)
- 我这边的节点：<https://msdl.011f.com>
