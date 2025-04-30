---
title: "群晖dsm增加ddns提供商 (HE.net)"
categories: [ "linux" ]
tags: [  ]
draft: false
slug: "群晖增加ddns"
date: "2023-11-07 11:48:00"
---

只需要在 /etc.defaults/ddns_provider.conf  文件中加入以下内容：

```shell
[HE_DDNS]
        modulepath=DynDNS
        queryurl=https://dyn.dns.he.net/nic/update?hostname=__HOSTNAME__&myip=__MYIP__
```

然后在DDNS配置中选择HE_DDNS，假设主机名是 abc.example.org ，在主机名和用户名都填写 abc.example.org ， 密码处填写HE.NET中生成的TOKEN即可



来源:
[https://www.right.com.cn/forum/forum.php?mod=redirect&goto=findpost&ptid=1326840&pid=11006444][1]


  [1]: https://www.right.com.cn/forum/forum.php?mod=redirect&goto=findpost&ptid=1326840&pid=11006444