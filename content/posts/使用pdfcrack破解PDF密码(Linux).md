---
title: "使用pdfcrack破解PDF密码(Linux)"
categories: [ "安全" ]
tags: [ "密码安全" ]
draft: false
slug: "使用pdfcrack破解PDF密码(Linux)-使用pdfcrack破解pdf密码linux"
date: "2017-04-08 07:40:52"
---



pdfcrack是破解PDF保护密码的Linux命令行工具。

## 安装pdfcrack

Debian系列：

    # apt install pdfcrack

![][1] 

## 暴力破解

    # pdfcrack -f filename.pdf -n 6 -m 8 -c 0123456789

暴力破解密码是漫长单调的过程。

上面使用的参数解释：

  * -n：密码最短多少个字符
  * -m：密码最长多少个字符
  * -c：使用的字符集

更多选项，查看帮助：

    # man pdfcrack

你可以随时使用 Ctrl+c 终止破解，它会保存破解的进度，下次继续在终止的地方执行。

![][2] 

## 使用密码字典

    # pdfcrack -f high.pdf -w wordlist.txt

![][3]

 [1]: /uploads/oss/2017-04-25-14916372807669.png ""
 [2]: /uploads/oss/2017-04-25-14916373463085.png ""
 [3]: /uploads/oss/2017-04-25-14916373619379.png ""