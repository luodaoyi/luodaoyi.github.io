---
title: "我写了一个证书监控系统，叫 Certwarden"
categories: [ "项目","运维","开发" ]
tags: [ "ssl", "tls", "证书监控", "golang", "react", "docker" ]
draft: false
slug: "我写了一个证书监控系统-叫-certwarden"
date: "2026-04-20 14:25:00"
lastmod: "2026-08-24T20:00:00+08:00"
---

域名一多，证书这事就没法靠人记。哪些快过期、哪些已经异常、该通知谁、有没有一个页面能直接给别人看——脚本能应付一两张，再多就乱。

所以我整理了一个自己之前写的项目，叫 **Certwarden**。自托管，多租户，持续检测证书、记历史、发通知，每个租户有自己的公开状态页。

仓库：

```text
https://github.com/luodaoyi/Certwarden
```

当前版本 **v1.3.4**。

<!--more-->

## 它管什么

检测不只看还剩多少天，也会把生效时间、到期时间、颁发机构、主题、CN、SAN、序列号、SHA-256 指纹、签名算法放在一起。

通知支持 Email、Telegram、Webhook。租户级和域名级都能配，界面里可以直接测试通知端点通不通。

每个租户有独立的公开状态页：

```text
/status/{tenantId}
```

Telegram 和邮件里的证书通知可以带上该域名的公开状态链接，格式是 `{APP_BASE_URL}/status/{tenantId}?domain={domainId}`，状态页会按这个 query 展开对应主机。没配 `APP_BASE_URL` 时，这条详情不会写进通知。状态页也支持自定义标题和副标题。

数据在共享库里用 `tenant_id` 隔离：域名列表、通知端点、状态页都是租户自己的。注册只需要用户名和密码，邮箱是可选绑定。默认 SQLite，也支持 MySQL 和 PostgreSQL。调度和检测用 Go，管理台是 React（登录、租户后台、公开状态页、管理后台）。

## 怎么跑起来

```bash
git clone https://github.com/luodaoyi/Certwarden.git
cd Certwarden
cp .env.example .env
docker compose up -d
```

默认先用 SQLite。`docker-compose.yml` 也能直接导入 1Panel：按 `.env.example` 填 `APP_BASE_URL`、数据库和管理员账号，再启动。

仓库：<https://github.com/luodaoyi/Certwarden>
