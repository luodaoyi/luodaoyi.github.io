---
title: "ubuntu 添加新硬盘"
categories: [ "linux" ]
tags: [ "linux" ]
draft: false
slug: "ubuntu 添加新硬盘-ubuntu添加新硬盘"
date: "2017-03-12 06:14:47"
---



查看硬盘：

    # fdisk -l
    ...
    Disk /dev/sdb: 274.9 GB, 274877906944 bytes
    255 heads, 63 sectors/track, 33418 cylinders, total     536870912 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disk identifier: 0x00000000
    Disk /dev/sdb doesn"t contain a valid partition table
    

可以看到，有一块大小为256G的磁盘未初始化

格式化硬盘（如果需要多个分区，请先创建磁盘分区）：

    # mkfs.ext4 /dev/sdb
    mke2fs 1.42.9 (4-Feb-2014)
    /dev/sdb is entire device, not just one partition!
    Proceed anyway? (y,n) y
    Filesystem label=
    OS type: Linux
    Block size=4096 (log=2)
    Fragment size=4096 (log=2)
    Stride=0 blocks, Stripe width=0 blocks
    16777216 inodes, 67108864 blocks
    3355443 blocks (5.00%) reserved for the super user
    First data block=0
    Maximum filesystem blocks=4294967296
    2048 block groups
    32768 blocks per group, 32768 fragments per group
    8192 inodes per group
    Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000, 7962624, 11239424, 20480000, 23887872
    Allocating group tables: done
    Writing inode tables: done
    Creating journal (32768 blocks): done
    Writing superblocks and filesystem accounting information: done
    

查看磁盘的UUID：

    # blkid
    /dev/sda1: UUID="05003145-9b91-4943-aaa8-22cb496fd4d8" TYPE="ext4"
    /dev/sda5: UUID="ca0012ba-2bf1-4d0b-94d3-3e4043746a14" TYPE="swap"
    /dev/sdb: UUID="e23a1c1e-8d91-4df8-8fba-f0656a1080ab" TYPE="ext4"
    

记录下/dev/sdb（刚才格式化的分区）的UUID。

_注意：你看到的UUID的值与例子不同_

编辑/etc/fstab

    # editor /etc/fstab
    

添加以下行

    UUID=e23a1c1e-8d91-4df8-8fba-f0656a1080ab    /home    ext4    defaults,errors=remount-ro    0    1
    

**_注意：UUID替换为上一步你获取到的值_**

_P.S.`/home`为你要挂载的目标目录_

现在重启电脑，应用新的磁盘配置

    # reboot
    

查看磁盘配置：

    # df -h
    Filesystem      Size  Used Avail Use% Mounted on
    /dev/sda1       8.8G  1.3G  7.1G  15% /
    none            4.0K     0  4.0K   0% /sys/fs/cgroup
    udev            8.2G  4.0K  8.2G   1% /dev
    tmpfs           1.7G  492K  1.7G   1% /run
    none            5.0M  8.0K  5.0M   1% /run/lock
    none            8.2G     0  8.2G   0% /run/shm
    none            100M     0  100M   0% /run/user
    /dev/sdb        252G   60M  239G   1% /home