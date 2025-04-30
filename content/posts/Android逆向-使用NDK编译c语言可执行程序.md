---
title: "Android逆向 使用NDK编译c语言可执行程序"
categories: [ "Android" ]
tags: [ "安卓逆向","JNI" ]
draft: false
slug: "Android逆向 使用NDK编译c语言可执行程序-android逆向使用ndk编译c语言可执行程序"
date: "2020-04-24 08:31:28"
---



# 使用ndk构建c语言可执行程序

## 1. 新建代码文件

> hello.c


```cpp
#include <stdio.h>

int main()
{
    printf("hello android JNI!");
    return 0;
}
```


## 2. 新建android编译make文件

> Android.mk


```conf
LOCAL_PATH  := $(call my-dir)       # 获取jni文件路径
include $(CLEAR_VARS)               # 因为是全局变量 所以要清理设置
LOCAL_CFLAGS += -std=c99            #使用c语言c99规范
LOCAL_CFLAGS += -pie -fPIE          #相当于在源文件中增加宏定义，安卓5.0以上需要添加,否则编译出来无法使用
LOCAL_LDFLAGS += -pie -fPIE         #相当于在源文件中增加宏定义，安卓5.0以上需要添加,否则编译出来无法使用
LOCAL_ARM_MODE  := arm              # 编译后的指令集
LOCAL_MODULE    := hello            # 编译后的名字 唯一且不可以包含空格 不是so就不会加.so so模块=> libbuild.so
LOCAL_SRC_FILES := hello.c          # 指定源文件
include $(BUILD_EXECUTABLE)         # 指定为构建可执行文件 
                                    # 如果是SO库为:    $(shared library) 
                                    # 如果是静态库为:   $(static library)
```


> Application.mk文件


```conf
APP_ABI := x86 armeabi-v7a
```


## 3. 编译ndk代码


```conf
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk
```


![file][1] 

## 4. 在android系统中执行

打开模拟器 将文件push进安卓虚拟机,赋予执行权限并且执行


```shell
adb push libs/armeabi/hello /data/local/tmp
adb shell
su
cd /data/local/tmp
chmod 777 /data/local/tmp/hello
./hello
```


> 运行结果

![file][2] 

## 5. 可能出现的问题

如果代码中有中文输入输出,编译后cmd中执行发现是乱码的话 则需要在执行钱将cmd窗口字符集改为UTF-8


```conf
chcp 65001
```


## 相关代码:

[Android\_JNI/00\_build\_so at master · luodaoyi/Android\_JNI][3]

 [1]: /uploads/2020/04/image-1587716679995.png
 [2]: /uploads/2020/04/image-1587716802010.png
 [3]: https://github.com/luodaoyi/Android_JNI/tree/master/00_build_so "Android_JNI/00_build_so at master · luodaoyi/Android_JNI"