---
title: "C#在winform中调用系统控制台输出"
categories: [ "CSharp" ]
tags: [ "asp.net","csharp","winform" ]
draft: false
slug: "C#在winform中调用系统控制台输出-c在winform中调用系统控制台输出"
date: "2017-09-12 15:25:54"
---



在Winform程序中有时候调试会通过Console.Write()方式输出一些信息，这些信息是在Visual Studio的输出窗口显示。

所以就会想，能不能调用系统的Cmd窗口输出呢，经过一番查阅，发现是可以的，现在就把方法写下了：

主要用到的是win32 API函数实现的：

    [DllImport("kernel32.dll")]
    static extern bool FreeConsole();
    [DllImport("kernel32.dll")]
    public static extern bool AllocConsole();

在Program.cs文件中调用方法即可

完整代码：

```cs
    
    using System;
    using System.Collections.Generic;
    using System.Windows.Forms;
    using System.Runtime.InteropServices;
    namespace XY.WinformDebug
    {
    static class Program
    {
            [DllImport("kernel32.dll")]
            static extern bool FreeConsole();
            [DllImport("kernel32.dll")]
            public static extern bool AllocConsole();
            ///
            /// 应用程序的主入口点。
            ///
            [STAThread]
            static void Main()
            {
                AllocConsole();//调用系统API，调用控制台窗口
                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);
                Application.Run(new FrmMain());
                FreeConsole();//释放控制台
            }
        }
    }
```