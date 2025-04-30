---
title: "Android逆向 练习1 跳过签名验证"
categories: [ "逆向","Android" ]
tags: [ "安卓逆向","Android逆向" ]
draft: false
slug: "Android逆向 练习1 跳过签名验证-android逆向练习1跳过签名验证"
date: "2020-05-01 12:31:51"
---



今天练练手 做一个跳过签名验证的练习

下手的app ：  
![file][1] 

## 1. 分析apk

首先拖入AndroidKiller  
选择不分析  
![file][2] 

编译打包  
![file][3] 

拖入模拟器  
![file][4] 

发现直接停止运行  
下面来找原因  
![file][5] 

## 2. 分析

拖入GDA3.72 打开入口 发现可以函数调用  
![file][6] 

进去看看  
![file][7] 

读取了签名 但是没有干啥事情  
进kille把这段改掉，试试看  
![file][8]  
![file][9] 

发现崩溃依旧  
继续回到入口找  
![file][10] 

可可疑 进去看看  
![file][11] 

发现是native  
搜索加载的so  
![file][12] 

在这里 

拖入ida 找这个地方  
![file][13] 

发现是静态注册 直接进去f5

![file][14] 

跟进去  
![file][15] 

就是这里了

返回上一级 把调用的


```java
.text:00000D44                 ; int __fastcall Java_com_bug_bt_MainActivity_bug(JNIEnv *env, jobject obj)
.text:00000D44                                 EXPORT Java_com_bug_bt_MainActivity_bug
.text:00000D44                 Java_com_bug_bt_MainActivity_bug        ; DATA XREF: LOAD:00000174↑o
.text:00000D44                 ; __unwind {
.text:00000D44 000 10 B5                       PUSH    {R4,LR}
.text:00000D46 008 04 1C                       MOVS    R4, R0
.text:00000D48 008 FF F7 58 FF                 BL      getSignHashCode          ; 这几句干掉 不去调用就可以 具体方法就是nop掉  ida装一个keypatch 直接改
.text:00000D4C 008 22 68                       LDR     R2, [R4]
.text:00000D4E 008 04 49                       LDR     R1, =(aHttpWwwBtsouOr - 0xD58) ; "http://www.btsou.org/web?q="
.text:00000D50 008 A7 23 9B 00                 MOVS    R3, #0x29C
.text:00000D54 008 79 44                       ADD     R1, PC          ; "http://www.btsou.org/web?q="
.text:00000D56 008 D3 58                       LDR     R3, [R2,R3]
.text:00000D58 008 20 1C                       MOVS    R0, R4
.text:00000D5A 008 98 47                       BLX     R3
.text:00000D5C 008 10 BD                       POP     {R4,PC}
.text:00000D5C                 ; End of function Java_com_bug_bt_MainActivity_bug
```


![file][16] 

![file][17] 

成功！

![file][18]

 [1]: /uploads/2020/05/image-1588330405564.png
 [2]: /uploads/2020/05/image-1588330509180.png
 [3]: /uploads/2020/05/image-1588330557780.png
 [4]: /uploads/2020/05/image-1588330584919.png
 [5]: /uploads/2020/05/image-1588330613971.png
 [6]: /uploads/2020/05/image-1588331480047.png
 [7]: /uploads/2020/05/image-1588331510838.png
 [8]: /uploads/2020/05/image-1588332100338.png
 [9]: /uploads/2020/05/image-1588332132354.png
 [10]: /uploads/2020/05/image-1588332204402.png
 [11]: /uploads/2020/05/image-1588332234979.png
 [12]: /uploads/2020/05/image-1588332312967.png
 [13]: /uploads/2020/05/image-1588332386249.png
 [14]: /uploads/2020/05/image-1588332695683.png
 [15]: /uploads/2020/05/image-1588332756365.png
 [16]: /uploads/2020/05/image-1588335932990.png
 [17]: /uploads/2020/05/image-1588336244073.png
 [18]: /uploads/2020/05/image-1588336288531.png