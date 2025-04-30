---
title: "Linux 命令行下下载 Google Drive/Docs"
categories: [ "linux","工具","转载" ]
tags: [ "google","下载" ]
draft: false
slug: "Linux 命令行下下载 Google DriveDocs-linux命令行下下载googledrivedocs"
date: "2018-09-13 06:07:10"
---



转载自&nbsp;<https://onebox.site/archives/250.html>

说到如何在Linux命令行下下载**Google网盘**（云端硬盘）的文件，第一个想到的应该是**gdrive**（<a href="https://github.com/prasmussen/gdrive" target="_blank" rel="noreferrer noopener">prasmussen/gdrive</a>），这个脚本可以下载、上传、同步等功能，当然需要事先命令`gdrive about`关联网盘，显然适合自己使用。

如果说要下载别人分享的文件呢？直接`wget`命令会多次跳转，可能会导致下载失败。找到个脚本（<a href="https://github.com/circulosmeos/gdown.pl" target="_blank" rel="noreferrer noopener">circulosmeos/gdown.pl</a>）可以实现正常下载。

## 获取 gdown.pl 脚本

项目地址在GitHub：<a href="https://github.com/circulosmeos/gdown.pl" target="_blank" rel="noreferrer noopener">https://github.com/circulosmeos/gdown.pl</a>

环境需求：

  * wget
  * perl

获取脚本：

```shell
wget https://raw.githubusercontent.com/circulosmeos/gdown.pl/master/gdown.pl
chmod +x gdown.pl
```


**注意事项：**

获取脚本后根据`perl`的`PATH`可能需要修改`gdown.pl`文件的第一行，脚本第一行以下：

```shell
#!/usr/local/bin/perl
```


而我系统环境使用命令`whereis perl`显示：

```shell
perl: /usr/bin/perl /etc/perl /usr/share/perl /usr/share/man/man1/perl.1.gz
```


则`gdown.pl`文件的第一行，我修改为：

```shell
#!/usr/bin/perl
```


我这里通过修改脚本，或者也可以通过修改系统的环境变量。

## 如何使用 gdown.pl 脚本下载

如何使用：

```shell
./gdown.pl 'Gdrive 文件地址' &#91;'保存的文件名']
```


例如我要下载`https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download`，文件存为`gdrive`，可以使用如下命令：

```shell
./gdown.pl 'https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download' gdrive
```


## gdown.pl

完整的脚本（v1.1 by circulosmeos 01-2017）：

```shell
#!/usr/local/bin/perl
#
# Google Drive direct download of big files
# ./gdown.pl 'gdrive file url' ['desired file name']
#
# v1.0 by circulosmeos 04-2014.
# v1.1 by circulosmeos 01-2017.
# http://circulosmeos.wordpress.com/2014/04/12/google-drive-direct-download-of-big-files
# Distributed under GPL 3 (http://www.gnu.org/licenses/gpl-3.0.html)
#
use strict;

my $TEMP='gdown.cookie.temp';
my $COMMAND;
my $confirm;
my $check;
sub execute_command();

my $URL=shift;
die "\n./gdown.pl 'gdrive file url' [desired file name]\n\n" if $URL eq '';

my $FILENAME=shift;
$FILENAME='gdown' if $FILENAME eq '';

if ($URL=~m#^https?://drive.google.com/file/d/([^/]+)#) {
    $URL="https://docs.google.com/uc?id=$1&export=download";
}

execute_command();

while (-s $FILENAME < 100000) { # only if the file isn't the download yet
    open fFILENAME, '<', $FILENAME;
    $check=0;
    foreach (<fFILENAME>) {
        if (/href="(\/uc\?export=download[^"]+)/) {
            $URL='https://docs.google.com'.$1;
            $URL=~s/&/&/g;
            $confirm='';
            $check=1;
            last;
        }
        if (/confirm=([^;&]+)/) {
            $confirm=$1;
            $check=1;
            last;
        }
        if (/"downloadUrl":"([^"]+)/) {
            $URL=$1;
            $URL=~s/\\u003d/=/g;
            $URL=~s/\\u0026/&/g;
            $confirm='';
            $check=1;
            last;
        }
    }
    close fFILENAME;
    die "Couldn't download the file :-(\n" if ($check==0);
    $URL=~s/confirm=([^;&]+)/confirm=$confirm/ if $confirm ne '';

    execute_command();
}

unlink $TEMP;

sub execute_command() {
    $COMMAND="wget --no-check-certificate --load-cookie $TEMP --save-cookie $TEMP \"$URL\"";
    $COMMAND.=" -O \"$FILENAME\"" if $FILENAME ne '';
    `$COMMAND`;
    return 1;
}
```