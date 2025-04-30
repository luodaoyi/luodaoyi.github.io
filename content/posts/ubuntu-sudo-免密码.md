---
title: "ubuntu sudo 免密码"
categories: [ "linux" ]
tags: [  ]
draft: false
slug: "ubuntu sudo 免密码-ubuntusudo免密码"
date: "2018-04-18 14:03:22"
---



# ubuntu sudo 免密码

    cd /etc/sudoers.d
    sudo touch nopasswd4sudo
    sudo vi nopasswd4sudo
    //输入
    ubuntu ALL=(ALL) NOPASSWD : ALL
    ESC :wq!