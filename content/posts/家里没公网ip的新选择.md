---
title: "家里没公网ip的新选择"
categories: [ "工具" ]
tags: [ "工具","docker","dsm" ]
draft: false
slug: "家里没公网ip的新选择-家里没公网ip的新选择"
date: "2017-11-14 03:32:00"
---



我的就没有。。。

我办理的联通的宽带，但是小区木有联通宽带 然后给弄的华数宽带

后来我发现华数宽带可以&#8212;多拨。。上下行都叠加

![][1] 

但是还是没有公网ip。我家里有个gen8服务器，直接装了dsm

![][2] 

于是找了个所谓ipv4的玩意

![][3] 

然后把盒子wan扣连接到路由器 lan口插到gen8的dsm上。设置双网口

![][4] 

![][5] 

跑了docker

![][6] 

dsm 6.x 可以用虚拟机 就跑了个arch  
![][7] 

用上面docker中的harpoxy炮三层tcp代理，就可以在办公室远程连接arch了  
![][8] 

dsm还有个web station 可以直接跑php  
![][9] 

我的小博客就是跑在这个上面的<https://luodaoyi.com>

> 因为ip是国内的 所以必须要beian

还有。。。  
Let\&#8217;s Encrypt 也可以直接申请证书了。。因为80 443都可以用了  
![][10] 

![][11]

 [1]: https://ws2.sinaimg.cn/large/006tNc79gy1flhg5ckblaj30v807emy5.jpg ""
 [2]: https://ws4.sinaimg.cn/large/006tNc79gy1flhg7hk02rj30kl0fq0ug.jpg ""
 [3]: https://ws2.sinaimg.cn/large/006tNc79gy1flhg965sqyj30ow060tae.jpg ""
 [4]: https://ws3.sinaimg.cn/large/006tNc79gy1flhgbq9toej30fc0fp3zx.jpg ""
 [5]: https://ws3.sinaimg.cn/large/006tNc79gy1flhgcadogkj30kc0eu40d.jpg ""
 [6]: https://ws2.sinaimg.cn/large/006tNc79gy1flhgaa7plxj30na0a6q3z.jpg ""
 [7]: https://ws2.sinaimg.cn/large/006tNc79gy1flhgd9s4jtj30ut0hjact.jpg ""
 [8]: https://ws1.sinaimg.cn/large/006tNc79gy1flhgh2w43mj30s209edib.jpg ""
 [9]: https://ws3.sinaimg.cn/large/006tNc79gy1flhgijpp53j30ro0edwg9.jpg ""
 [10]: https://ws2.sinaimg.cn/large/006tNc79gy1flhgky08q9j30hs0f9ac4.jpg ""
 [11]: https://ws3.sinaimg.cn/large/006tNc79gy1flhgjvnxsmj30kq0g0gn3.jpg ""