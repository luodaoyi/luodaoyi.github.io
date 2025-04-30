---
title: "解决windows 无法访问指定设备、路径或文件。你可能没有适当的权限访问该项目。"
categories: [ "windwos","奇技淫巧" ]
tags: [ "windows","文件权限" ]
draft: false
slug: "解决windows 无法访问指定设备、路径或文件。你可能没有适当的权限访问该项目。-解决windows无法访问指定设备路径或文件你可能没有适当的权限访问该项目"
date: "2020-04-01 18:46:14"
---



[![][1]][2]  
文件权限出现了问题

下面是一些可用的命令行帮助恢复


```bat
# 取得目录和内容的所有权 可以将其范围缩小到要更改的特定项，具体取决于有多少项。
takeown /f C:\Windows\Web /r

# 授予自己完全的控制权 注意 %USERDOMAIN%\%USERNAME% 将自动替换为您的用户-所以这里无需在此替换任何内容
icacls C:\Windows\Web /grant "%USERDOMAIN%\%USERNAME%":(F) /t

# 恢复windows10默认的所有者
icacls c:\Windows\Web /setowner "NT SERVICE\TrustedInstaller" /t

# 删除授予的权限
icacls C:\Windows\Web /remove:g "%USERDOMAIN%\%USERNAME%":(F) /t

```


一种替代方法是保存和恢复ACL


```bat
# 将当前的ACL保存到某个文件中。
icacls C:\Windows\Web /save "C:\Web.acl" /t

# 获得所有权
takeown /f C:\Windows\Web /r

# 授予自己完全的控制权
icacls C:\Windows\Web /grant "%USERDOMAIN%\%USERNAME%":(F) /t

# 恢复windows10默认的所有者
icacls c:\Windows\Web /setowner "NT SERVICE\TrustedInstaller" /t

# 从步骤1中创建的文件中还原ACL。请注意，这些ACL是为父目录还原的，所以还原的时候是 C:\Windows 而不是 C:\Windows\Web
icacls C:\Windows /restore "C:\Web.acl"
```


 [1]: /uploads/2020/04/awqr5-l1rbg-300x225.jpg
 [2]: https://luodaoyi.com/p/%e8%a7%a3%e5%86%b3windows-%e6%97%a0%e6%b3%95%e8%ae%bf%e9%97%ae%e6%8c%87%e5%ae%9a%e8%ae%be%e5%a4%87%e3%80%81%e8%b7%af%e5%be%84%e6%88%96%e6%96%87%e4%bb%b6%e3%80%82%e4%bd%a0%e5%8f%af%e8%83%bd%e6%b2%a1.html/awqr5-l1rbg