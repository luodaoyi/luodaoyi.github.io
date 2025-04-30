---
title: "Android逆向 NDK开发总结"
categories: [ "Android" ]
tags: [ "安卓逆向","JNI" ]
draft: false
slug: "Android逆向 NDK开发总结-android逆向ndk开发总结"
date: "2020-04-24 16:29:35"
---



**NDK开发总结**

  1. Jni接口: java native interface
  2. 作用:用于java/c/c++ 代码之间的交互
  3. 使用方法: 
      1. jni静态注册 
          1. 在java代码中定义native修饰的方法;
          2. 根据java中native修饰的方法生成头文件(SRC路径执行`javah -jni`);
          3. 编写c/c++代码,导入头文件,同时实现头文件中的方法;
          4. 编写两个mk文件: `Android.mk`文件 `Application.mk`文件(头文件/代码文件和两个mk放入jni目录);
          5. 来带指定目录(jni所在路径),生成so文件;
      2. 动态注册 
          1. 在java代码中定义native修饰的方法;
          2. 新建c/c++文件,导入`jni.h`头文件,编写c/c++文件 ,实现java层被native修饰的方法;
          3. 通过`JNINativeMethod`结构体绑定java和c/c++方法;
          4. 通过`RegisterNatives`方法注册java相应的类以及方法;
          5. 把c/c++注册方法写入到`JNI_onload`(两个参数),注意: `JNI_onload`是系统调用;
          6. 来到指定路径(jni所在路径),`ndk_build`生成so文件;
  4. 两种注册方法有区别的对比 
      * 静态注册: 
          1. 编写不方便,jni方法名字必须遵循规则且名字比较长;
          2. 运行效率不高;
      * 动态注册: 
          1. 流程清晰可控;
          2. 运行效率高