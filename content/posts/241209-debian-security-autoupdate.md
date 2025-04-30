+++
title = 'Debian和Centos自动更新安全补丁，防止被黑'
date = 2024-12-09T11:10:16+08:00
draft = false
categories=["linux"]
tags= [ "dsm","debian", "ubuntu", "centos" ]
+++


## Debian 12 启用自动更新安全补丁

在 Debian 12 上启用自动更新安全补丁（自动安全更新）通常可以使用 unattended-upgrades 工具来实现。下面是详细步骤：


## 安装 unattended-upgrades 软件包：
通常 Debian 12 默认源中已经包含此工具，如未安装可执行：

```bash
sudo apt-get update
sudo apt-get install unattended-upgrades
```

## 通过交互式配置启用自动更新：

安装完成后，可以使用 dpkg-reconfigure 来进行配置：

```bash
sudo dpkg-reconfigure unattended-upgrades
```

此时会有一个交互式对话框，选择 `Yes` 启用自动更新。

## 编辑配置文件(可选但推荐) 

配置文件位于 `/etc/apt/apt.conf.d/50unattended-upgrades`，在这里可以启用或禁用不同类型的更新源。
默认会有类似于：

```ruby
Unattended-Upgrade::Origins-Pattern {
    "origin=Debian,codename=${distro_codename},label=Debian-Security";
};
```

确保该安全源已解注释(启用状态)。

若想同时自动更新一般安全补丁和其他更新，可以在此文件中添加或启用对应的源配置行。

启用自动更新策略：
在 `/etc/apt/apt.conf.d/20auto-upgrades` 文件中确认类似以下内容，如果没有可以手动添加：

```ruby
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
Update-Package-Lists "1" 表示每天更新软件包列表。
Unattended-Upgrade "1" 表示每天执行自动更新操作。
```

验证及查看日志：

自动更新执行后可在 `/var/log/unattended-upgrades/` 下查看日志，例如：

```bash
cat /var/log/unattended-upgrades/unattended-upgrades.log
```

通过日志可以查看系统是否正常进行安全补丁自动更新。

通过上述步骤，即可在 Debian 12 上较为方便地开启并确认自动安装安全更新的功能。




## 再说一下centos7如何启用



在 CentOS 7 上，可以使用 yum-cron 来实现自动更新（包括安全更新）功能。以下是详细步骤：

## 安装 yum-cron：

```bash
sudo yum install -y yum-cron
```

## 配置 yum-cron：

安装完成后，主要配置文件有两个：

* `/etc/yum/yum-cron.conf`: 全局配置文件
* `/etc/yum/yum-cron-hourly.conf` 和 `/etc/yum/yum-cron.daily.conf`: 用于设定每日或每小时的更新行为(通常用 daily 就够了)


在 `/etc/yum/yum-cron.conf` 中你可以修改以下参数：

```bash
apply_updates = yes
```

将 `apply_updates` 改为 `yes`，表示自动安装更新。

如果你想只自动安装安全更新，可以在配置中指定：

```makefile
update_cmd = security
```

这样就只会应用安全相关的更新。

其他有用的选项包括：

```makefile 
download_updates = yes     # 自动下载更新包
emit_via = email           # 使用邮件通知方式（可选）
email_to = root            # 通知发送给谁（可选）
```

## 启用并启动 yum-cron 服务：

```bash 
sudo systemctl enable yum-cron
sudo systemctl start yum-cron
```

## 验证服务状态：

```bash
systemctl status yum-cron
```

如果显示为 `active (running)`，则说明自动更新服务已正常启用。

## 查看日志：
`yum-cron` 的日志信息通常在 `/var/log/yum.log`，更新执行后可以查看此文件确认更新是否已自动完成。


通过上述步骤，CentOS 7 将会定期自动更新系统，若指定 `security` 将仅更新安全补丁，从而保证服务器保持在相对安全的状态。