---
title: "Android逆向 Android Studio JNI 快速构建项目+动态注册+简易计算器"
categories: [ "Android" ]
tags: [ "安卓逆向","JNI" ]
draft: false
slug: "Android逆向 Android Studio JNI 快速构建项目+动态注册+简易计算器-android逆向androidstudiojni快速构建项目动态注册简易计算器"
date: "2020-04-24 16:04:38"
---



> 本文转发语NCK大佬的博客,并且自己跟着做了一遍 有一点点不同 大致上是大佬的文章:  
> [https://www.cnblogs.com/fuhua/p/12725771.html][1]

**前面几篇文章演示的是比较原始的创建JNI项目的方法，旨在了解JNI项目构建原理！**  
**但是构建项目效率很低，开发，调试都存在很大的效率低下问题。**  
**本篇文章将演示利用Android Studio快速构建JNI项目。本篇文章要点**

  1. 利用Android Studio快速构建JNI项目
  2. 添加日志打印
  3. Android Studio调试C/C++代码
  4. JNI动态注册
  5. 简易计算器实现。

## 1. 新建项目

打开Android Studio新建Project，选中Native c++选项，此选项可以帮助开发人员快速创建JNI项目，免去手动配置等麻烦问题。

![file][2] 

项目取名为JNIRegisterDynamic，点击Next  
![file][3] 

使用 C++17标准，点击Finish  
![file][4] 

## 2. 安装NDK开发组件

`File->Settings->Android SDK->SDK Tools`选项下，安装LLDB,NDK,CMake

![file][5] 

等待安装完毕

![file][6] 

`File->Project Structure->SDK Location->Android NDK Location` ，选择Default xxxx选项，从而配置完成NDK

![file][7] 

为了验证上一步是否配置成功，需要来到`local.properties`，如果同时出现`ndk.dir=xxx sdk.dir=xxx` 证明配置成功

![file][8] 

此时如果我们对`native-lib.cpp`进行编辑，可以看到出现了智能提示。就代表我们的环境配置没有问题了。  
![file][9] 

## 3. 添加日志打印

接下来我们添加日志打印输出，将下面代码添加到cpp文件头部，使用的时候直接调用就行，比如：`LOGI("我是输出的日志信息")`;


```cpp
#include <android/log.h>
#define LOG_TAG    "JniDebugLogger"
#define LOGI(...)  __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...)  __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#define LOGF(...)  __android_log_print(ANDROID_LOG_FATAL, LOG_TAG, __VA_ARGS__)
```


![file][10] 

接下来我们在C/C++代码下断点，并点击Debug图标。看是否能正确断下  
![file][11] 

注意，当出现如下界面时，千万别点击，只需要什么都不做，等几秒钟，断点断下就行  
![file][12] 

![file][13] 

## JNI动态注册和简易计算器实现

接下来我们在MainActivity中定义4个Native方法，分别为 add(+) sub(-) mul(*) div(/)


```cpp
    private native int add(int a, int b);

    private native int sub(int a, int b);

    private native int mul(int a, int b);

    private native int div(int a, int b);
```


![file][14] 

在native-lib.cpp里实现MainActivity的方法，native-lib.cpp源码如下


```cpp
#include <jni.h>
#include <string>

#include <android/log.h>

#define LOG_TAG    "JniDebugLogger"
#define LOGI(...)  __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...)  __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#define LOGF(...)  __android_log_print(ANDROID_LOG_FATAL, LOG_TAG, __VA_ARGS__)

extern "C" JNIEXPORT jstring JNICALL
Java_com_example_jniregisterdynamic_MainActivity_stringFromJNI(
        JNIEnv *env,
        jobject /* this */) {
    std::string hello = "Hello from C++";
    return env->NewStringUTF(hello.c_str());
}

jint NativeAdd(JNIEnv *env, jobject obj, jint a, jint b) {
    return a + b;
}

jint NativeSub(JNIEnv *env, jobject obj, jint a, jint b) {
    return a - b;
}

jint NativeMul(JNIEnv *env, jobject obj, jint a, jint b) {
    return a * b;
}

jint NativeDiv(JNIEnv *env, jobject obj, jint a, jint b) {
    return a / b;
}

// JNI函数签名数组
JNINativeMethod jniNativeMethods[]
        {
                {"add", "(II)I", (void *) NativeAdd},
                {"sub", "(II)I", (void *) NativeSub},
                {"mul", "(II)I", (void *) NativeMul},
                {"div", "(II)I", (void *) NativeDiv}
        };

jint RegistNativeMethods(JNIEnv *env) {
    //获得class
    jclass clazz = env->FindClass("com/example/jniregisterdynamic/MainActivity");
    //执行动态注册
    if (env->RegisterNatives(clazz, jniNativeMethods,
                             sizeof(jniNativeMethods) / sizeof(jniNativeMethods[0])) == JNI_OK) {

        return JNI_OK;
    }
    return JNI_ERR;
}

JNIEXPORT jint JNI_OnLoad(JavaVM *vm, void *reserved) {
    JNIEnv *jniEnv = nullptr;
    if (vm->GetEnv((void **) &jniEnv, JNI_VERSION_1_6) != JNI_OK) {
        LOGE("GetEnv ERROR");
        return JNI_ERR;
    }
    if (RegistNativeMethods(jniEnv) != JNI_OK) {
        LOGE("RegistNativeMethods FAILED");
        return JNI_ERR;
    }
    return JNI_VERSION_1_6;
}
```


![file][15] 

在MainActivity里添加测试代码，运行测试


```java
tv.setText("add" + add(1, 6) + " sub" + sub(10, 3) + " mul" + mul(3, 6) + " div" + div(9, 3));
```


![file][16] 

![file][17] 

运行测试Native层没有问题，接下来添加Java层代码并在界面增加控件，实现简单的计算器。MainActivity代码如下


```java
package com.example.jniregisterdynamic;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    // Used to load the "native-lib" library on application startup.
    static {
        System.loadLibrary("native-lib");
    }

    private native int add(int a, int b);

    private native int sub(int a, int b);

    private native int mul(int a, int b);

    private native int div(int a, int b);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Example of a call to a native method
//        TextView tv = findViewById(R.id.sample_text);
//        tv.setText("add" + add(1, 6) + " sub" + sub(10, 3) + " mul" + mul(3, 6) + " div" + div(9, 3));

//        tv.setText(stringFromJNI());
        Button btn_add = (Button) findViewById(R.id.btn_add);
        Button btn_sub = (Button) findViewById(R.id.btn_sub);
        Button btn_mul = (Button) findViewById(R.id.btn_mul);
        Button btn_div = (Button) findViewById(R.id.btn_div);

        View.OnClickListener ocl = new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                EditText editA = (EditText) findViewById(R.id.editA);
                int nA = Integer.parseInt(editA.getText().toString());
                EditText editB = (EditText) findViewById(R.id.editB);
                int nB = Integer.parseInt(editB.getText().toString());
                TextView tv = findViewById(R.id.text_value);
                switch (v.getId()) {
                    case R.id.btn_add:
                        tv.setText("" + add(nA, nB));
                        break;
                    case R.id.btn_sub:
                        tv.setText("" + sub(nA, nB));
                        break;
                    case R.id.btn_mul:
                        tv.setText("" + mul(nA, nB));
                        break;
                    case R.id.btn_div:
                        tv.setText("" + div(nA, nB));
                        break;
                }
            }
        };
        btn_add.setOnClickListener(ocl);
        btn_sub.setOnClickListener(ocl);
        btn_mul.setOnClickListener(ocl);
        btn_div.setOnClickListener(ocl);
    }

    /**
     * A native method that is implemented by the "native-lib" native library,
     * which is packaged with this application.
     */
    public native String stringFromJNI();
}

```


activity_main.xml代码如下


```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity">

    <EditText
        android:id="@+id/editA"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="91dp"
        android:ems="10"
        android:inputType="textPersonName"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent"  />

    <EditText
        android:id="@+id/editB"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="56dp"
        android:ems="10"
        android:inputType="textPersonName"
        app:layout_constraintStart_toStartOf="@+id/editA"
        app:layout_constraintTop_toBottomOf="@+id/editA" />

    <Button
        android:id="@+id/btn_add"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginEnd="16dp"
        android:text="@string/btn_add"
        app:layout_constraintBaseline_toBaselineOf="@+id/btn_sub"
        app:layout_constraintEnd_toStartOf="@+id/btn_sub"
        app:layout_constraintHorizontal_chainStyle="packed"
        app:layout_constraintStart_toStartOf="parent"  />

    <Button
        android:id="@+id/btn_sub"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="60dp"
        android:layout_marginEnd="5dp"
        android:text="@string/btn_sub"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toEndOf="@+id/btn_add"
        app:layout_constraintTop_toBottomOf="@+id/editB" />

    <Button
        android:id="@+id/btn_mul"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginEnd="16dp"
        android:text="@string/btn_mul"
        app:layout_constraintBaseline_toBaselineOf="@+id/btn_div"
        app:layout_constraintEnd_toStartOf="@+id/btn_div"
        app:layout_constraintHorizontal_chainStyle="packed"
        app:layout_constraintStart_toStartOf="parent"  />

    <Button
        android:id="@+id/btn_div"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="34dp"
        android:layout_marginEnd="5dp"
        android:text="@string/btn_div"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toEndOf="@+id/btn_mul"
        app:layout_constraintTop_toBottomOf="@+id/btn_sub" />

    <TextView
        android:id="@+id/text_value"
        android:layout_width="92dp"
        android:layout_height="23dp"
        android:text="@string/str_text_value"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintHorizontal_bias="0.498"
        app:layout_constraintLeft_toLeftOf="parent"
        app:layout_constraintRight_toRightOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintVertical_bias="0.795"  />
</androidx.constraintlayout.widget.ConstraintLayout>
```


![file][18] 

测试运行  
![file][19] 

源代码:  
[https://github.com/luodaoyi/Android\_JNI/tree/master/04\_JNI\_register\_dynamic][20]

 [1]: https://www.cnblogs.com/fuhua/p/12725771.html "https://www.cnblogs.com/fuhua/p/12725771.html"
 [2]: /uploads/2020/04/image-1587741353729.png
 [3]: /uploads/2020/04/image-1587741397371.png
 [4]: /uploads/2020/04/image-1587741426817.png
 [5]: /uploads/2020/04/image-1587741542717.png
 [6]: /uploads/2020/04/image-1587741567058.png
 [7]: /uploads/2020/04/image-1587741632959.png
 [8]: /uploads/2020/04/image-1587741719955.png
 [9]: /uploads/2020/04/image-1587741785453.png
 [10]: /uploads/2020/04/image-1587741940407.png
 [11]: /uploads/2020/04/image-1587741991148.png
 [12]: /uploads/2020/04/image-1587742020953.png
 [13]: /uploads/2020/04/image-1587742073451.png
 [14]: /uploads/2020/04/image-1587742225372.png
 [15]: /uploads/2020/04/image-1587742479572.png
 [16]: /uploads/2020/04/image-1587742704084.png
 [17]: /uploads/2020/04/image-1587742725276.png
 [18]: /uploads/2020/04/image-1587744100989.png
 [19]: /uploads/2020/04/image-1587744142326.png
 [20]: https://github.com/luodaoyi/Android_JNI/tree/master/04_JNI_register_dynamic "https://github.com/luodaoyi/Android_JNI/tree/master/04_JNI_register_dynamic"