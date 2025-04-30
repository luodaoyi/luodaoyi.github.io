---
title: "Python读取指定目录下指定后缀文件并保存为docx"
categories: [ "python" ]
tags: [ "python" ]
draft: false
slug: "Python读取指定目录下指定后缀文件并保存为docx-python读取指定目录下指定后缀文件并保存为docx"
date: "2017-04-07 08:08:05"
---



最近有个奇葩要求 要项目中的N行代码 申请专利啥的  
然后作为程序员当然不能复制粘贴 用代码解决。。

## 使用python-docx读写docx文件

环境使用python3.6.0  
首先pip安装python-docx

    pip install python-docx

然后下面是脚本 修改目录，这里默认取脚本运行目录下的src文件夹  
取`.cs`后缀的所有文件 读取并保存为docx

> 有一点需要注意，如果文件中有中文，请用vscode或者其他编辑器使用utf-8格式打开，看看有没有乱码 其中每处理一个文件都会有print输出 当看到只有&#8212;start没有end的时候就可以找到该文件查看是否有上面说的情况，修改后保存重新执行，一直到全部执行完毕，保存好docx文件

## 代码

```python
    # -- coding: UTF-8 --
    # Created by luody on 2017/4/7.
    import os
    from docx import Document
    saveFile = os.getcwd() + "/code.docx"
    mypath = os.getcwd() + "/src"
    doc = Document()
    doc.add_heading("代码文档", 0)
    p = doc.add_paragraph("服务端代码,使用语言")
    p.add_run("C#,SQL").bold = True
    lineNum = 0
    for root, dirs, files in os.walk(mypath):
        for filespath in files:
            if (filespath.endswith(".cs")):
                doc.add_heading(filespath, level=1)
                codePage = ""
                print(filespath+" ----  start")
                for line in open(os.path.join(root, filespath), encoding="utf-8"):
                    codePage += line
                    lineNum += 1
                print(filespath+" ----  end")
                doc.add_paragraph(codePage, style="IntenseQuote")
                doc.add_page_break()
    p = doc.add_paragraph(u"总行数:")
    p.add_run(str(lineNum)).bold = True
    doc.save("code.docx")
    print(lineNum)
```