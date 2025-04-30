---
title: "office2016 visio2016 project2016零售版转换vol版bat"
categories: [ "激活","工具" ]
tags: [ "kms","office" ]
draft: false
slug: "office2016 visio2016 project2016零售版转换vol版bat-office2016visio2016project2016零售版转换vol版bat"
date: "2018-05-29 00:53:24"
---



在<http://msdn.itellyou.cn/>网站上下载的是office2016是零售版的，转换为vol，将下列文本另存为bat文件，运行即可

    @ECHO OFF&PUSHD %~DP0
    setlocal EnableDelayedExpansion&color 3e & cd /d "%~dp0"
    title office2016 retail转换vol版
    %1 %2
    mshta vbscript:createobject("shell.application").shellexecute("%~s0","goto :runas","","runas",1)(window.close)&goto :eof
    :runas
    if exist "%ProgramFiles%\Microsoft Office\Office16\ospp.vbs" cd /d "%ProgramFiles%\Microsoft Office\Office16"
    if exist "%ProgramFiles(x86)%\Microsoft Office\Office16\ospp.vbs" cd /d "%ProgramFiles(x86)%\Microsoft Office\Office16"
    :WH
    cls
    echo.
    echo                         选择需要转化的office版本序号
    echo.
    echo --------------------------------------------------------------------------------
    echo                 1. 零售版 Office Pro Plus 2016 转化为VOL版
    echo.
    echo                 2. 零售版 Office Visio Pro 2016 转化为VOL版
    echo.
    echo                 3. 零售版 Office Project Pro 2016 转化为VOL版
    echo.
    echo. --------------------------------------------------------------------------------
    set /p tsk="请输入需要转化的office版本序号【回车】确认（1-3）: "
    if not defined tsk goto:err
    if %tsk%==1 goto:1
    if %tsk%==2 goto:2
    if %tsk%==3 goto:3
    :err
    goto:WH
    :1
    cls
    echo 正在重置Office2016零售激活...
    cscript ospp.vbs /rearm
    echo 正在安装 KMS 许可证...
    for /f %%x in ("dir /b ..\root\Licenses16\proplusvl_kms*.xrm-ms") do cscript ospp.vbs /inslic:"..\root\Licenses16\%%x" >nul
    echo 正在安装 MAK 许可证...
    for /f %%x in ("dir /b ..\root\Licenses16\proplusvl_mak*.xrm-ms") do cscript ospp.vbs /inslic:"..\root\Licenses16\%%x" >nul
    echo 正在安装 KMS 密钥...
    cscript ospp.vbs /inpkey:XQNVK-8JYDB-WJ9W3-YJ8YR-WFG99
    goto :e
    :2
    cls
    echo 正在重置Visio2016零售激活...
    cscript ospp.vbs /rearm
    echo 正在安装 KMS 许可证...
    for /f %%x in ("dir /b ..\root\Licenses16\visio???vl_kms*.xrm-ms") do cscript ospp.vbs /inslic:"..\root\Licenses16\%%x" >nul
    echo 正在安装 MAK 许可证...
    for /f %%x in ("dir /b ..\root\Licenses16\visio???vl_mak*.xrm-ms") do cscript ospp.vbs /inslic:"..\root\Licenses16\%%x" >nul
    echo 正在安装 KMS 密钥...
    cscript ospp.vbs /inpkey:PD3PC-RHNGV-FXJ29-8JK7D-RJRJK
    goto :e
    :3
    cls
    echo 正在重置Project2016零售激活...
    cscript ospp.vbs /rearm
    echo 正在安装 KMS 许可证...
    for /f %%x in ("dir /b ..\root\Licenses16\project???vl_kms*.xrm-ms") do cscript ospp.vbs /inslic:"..\root\Licenses16\%%x" >nul
    echo 正在安装 MAK 许可证...
    for /f %%x in ("dir /b ..\root\Licenses16\project???vl_mak*.xrm-ms") do cscript ospp.vbs /inslic:"..\root\Licenses16\%%x" >nul
    echo 正在安装 KMS 密钥...
    cscript ospp.vbs /inpkey:YG9NW-3K39V-2T3HJ-93F3Q-G83KT
    goto :e
    :e
    echo.
    echo 转化完成，按任意键退出！
    pause >nul
    exit