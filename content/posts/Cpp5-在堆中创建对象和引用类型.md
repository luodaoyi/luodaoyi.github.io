---
title: "Cpp5 在堆中创建对象和引用类型"
categories: [ "CPP" ]
tags: [ "C","cpp" ]
draft: false
slug: "Cpp5 在堆中创建对象和引用类型-cpp5在堆中创建对象和引用类型"
date: "2018-01-30 14:51:00"
---



## 我们可以在什么地方创建对象?

  1. 全局变量区
    
        Person p;

  2. 栈
    
        void Max()
        {
          Person p;
        }

  3. 堆 `new` 和 `delete`
    
        //在堆中创建对象：
          Person* p = new Person();
        //释放对象占用的内存
          delete p;

### 在堆中创建对象: `new``delete`

在C语言中我们使用`malloc`申请堆空间  
使用完毕后使用`free`释放空间  
C++：

    class Person
    {
    private:
        int x;
        int y;
    public:
        Person()
        {
            printf("Person()执行了！ \n");
        }
        Person(int x,int y)
        {
            printf("Person(int x,int y)执行了！ \n");
            this->x=x;
            this->y=y;
        }
        ~Person()
        {
            printf("~Person() 执行了！ \n");
        }
    };
    Person* p =new Person();
    Person* p1=new Person(1,2);
    delete p;
    delete p1;
    //反汇编
    33:       Person* p =new Person();
    00401070   push        8
    00401072   call        operator new (004013c0)
    00401077   add         esp,4
    0040107A   mov         dword ptr [ebp-1Ch],eax
    0040107D   mov         dword ptr [ebp-4],0
    00401084   cmp         dword ptr [ebp-1Ch],0
    00401088   je          main+57h (00401097)
    0040108A   mov         ecx,dword ptr [ebp-1Ch]
    0040108D   call        @ILT+20(Person::Person) (00401019)
    00401092   mov         dword ptr [ebp-38h],eax
    00401095   jmp         main+5Eh (0040109e)
    00401097   mov         dword ptr [ebp-38h],0
    0040109E   mov         eax,dword ptr [ebp-38h]
    004010A1   mov         dword ptr [ebp-18h],eax
    004010A4   mov         dword ptr [ebp-4],0FFFFFFFFh
    004010AB   mov         ecx,dword ptr [ebp-18h]
    004010AE   mov         dword ptr [ebp-10h],ecx
    34:       Person* p1=new Person(1,2);
    004010B1   push        8
    004010B3   call        operator new (004013c0)
    004010B8   add         esp,4
    004010BB   mov         dword ptr [ebp-24h],eax
    004010BE   mov         dword ptr [ebp-4],1
    004010C5   cmp         dword ptr [ebp-24h],0
    004010C9   je          main+9Ch (004010dc)
    004010CB   push        2
    004010CD   push        1
    004010CF   mov         ecx,dword ptr [ebp-24h]
    004010D2   call        @ILT+0(Person::Person) (00401005)
    004010D7   mov         dword ptr [ebp-3Ch],eax
    004010DA   jmp         main+0A3h (004010e3)
    004010DC   mov         dword ptr [ebp-3Ch],0
    004010E3   mov         edx,dword ptr [ebp-3Ch]
    004010E6   mov         dword ptr [ebp-20h],edx
    004010E9   mov         dword ptr [ebp-4],0FFFFFFFFh
    004010F0   mov         eax,dword ptr [ebp-20h]
    004010F3   mov         dword ptr [ebp-14h],eax
    35:       delete p;
    004010F6   mov         ecx,dword ptr [ebp-10h]
    004010F9   mov         dword ptr [ebp-2Ch],ecx
    004010FC   mov         edx,dword ptr [ebp-2Ch]
    004010FF   mov         dword ptr [ebp-28h],edx
    00401102   cmp         dword ptr [ebp-28h],0
    00401106   je          main+0D7h (00401117)
    00401108   push        1
    0040110A   mov         ecx,dword ptr [ebp-28h]
    0040110D   call        @ILT+15(Person::`scalar deleting destructor") (00401014)
    00401112   mov         dword ptr [ebp-40h],eax
    00401115   jmp         main+0DEh (0040111e)
    00401117   mov         dword ptr [ebp-40h],0
    36:       delete p1;
    0040111E   mov         eax,dword ptr [ebp-14h]
    00401121   mov         dword ptr [ebp-34h],eax
    00401124   mov         ecx,dword ptr [ebp-34h]
    00401127   mov         dword ptr [ebp-30h],ecx
    0040112A   cmp         dword ptr [ebp-30h],0
    0040112E   je          main+0FFh (0040113f)
    00401130   push        1
    00401132   mov         ecx,dword ptr [ebp-30h]
    00401135   call        @ILT+15(Person::`scalar deleting destructor") (00401014)
    0040113A   mov         dword ptr [ebp-44h],eax
    0040113D   jmp         main+106h (00401146)
    0040113F   mov         dword ptr [ebp-44h],0
    

`new`关键字到底做了什么？

### `new``delete` 的本质:

  1. 分析`malloc`函数的执行流程  
    `char* p = (char*)malloc(123);`
    
        //逐层调用
        00401072   call        malloc (004013f0)
        00401404   call        _nh_malloc_dbg (00401470)
        00401484   call        _heap_alloc_dbg (004014e0)
        //  00401559   call        dword ptr [__pfnAllocHook (00427cb0)]
        0040167D   call        _heap_alloc_base (00404380)
        0040443C   call        dword ptr [__imp__HeapAlloc@12 (0042d190)]

  2. 分析 `new`的执行流程  
    `Person p = new Person();`
    
        
        36:       Person* p =new Person();
        0040107D   push        8
        0040107F   call        operator new (004013d0)
        //new
        //逐层调用
        004013DA   call        _nh_malloc (00401450)
        00401461   call        _nh_malloc_dbg (00401470)
        00401484   call        _heap_alloc_dbg (004014e0)
        //  00401559   call        dword ptr [__pfnAllocHook (00427cb0)]
        0040167D   call        _heap_alloc_base (00404380)
        0040443C   call        dword ptr [__imp__HeapAlloc@12 (0042d190)]
        //
        00401084   add         esp,4
        00401087   mov         dword ptr [ebp-20h],eax
        0040108A   mov         dword ptr [ebp-4],0
        00401091   cmp         dword ptr [ebp-20h],0
        00401095   je          main+64h (004010a4)
        00401097   mov         ecx,dword ptr [ebp-20h]
        0040109A   call        @ILT+20(Person::Person) (00401019)
        0040109F   mov         dword ptr [ebp-3Ch],eax
        004010A2   jmp         main+6Bh (004010ab)
        004010A4   mov         dword ptr [ebp-3Ch],0
        004010AB   mov         eax,dword ptr [ebp-3Ch]
        004010AE   mov         dword ptr [ebp-1Ch],eax
        004010B1   mov         dword ptr [ebp-4],0FFFFFFFFh
        004010B8   mov         ecx,dword ptr [ebp-1Ch]
        004010BB   mov         dword ptr [ebp-14h],ecx

总结：

new = malloc + 构造函数

动动手：  
分析 delete的执行流程 和free对比

### 数组堆空间申请 new[]/delete[]

分别用C和C++方式在堆中申请Int数组

    int* p = (int*)malloc(sizeof(int)*10);      free(p);
    int* p = new int[10];                       delete[]p;

分别用C和C++方式在堆栈中申请Class类型数组

    int* p = (Person*)malloc(sizeof(Person)*10);    free(p);
    Person* p = new Person[10];                     delete[] p;

delete和delete[]有什么区别？

如果对象数组 只使用`delete p` (一个delete)我们发现 只有一个析构函数执行  
要把10个对象所占用空间全部释放，并且每个都要执行析构函数的话 必须使用 `delete[] p`

## 引用类型

引用类型是C++中的特性

### 引用类型就是变量的别名

  1. 基本类型
    
        int x= 1;
        int& p =x;  //起个别名叫p
        p = 2;        //p就是x
        printf("%d \n",x);

  2. 类
    
        Person p;
        Person& px =p   //起个别名叫px
        px.x = 10;      //px 就是p
        printf("%d \n",p.x);

  3. 指针
    
        int****** i = (int******)1;
        int******& r =i;   //起个别名叫r
        r = (int******)2;   //r就是I
        printf("%d \n",r);

  4. 数组
    
        int arr[] = {1,2,3};
        int (&p)[3] = arr;  //起个别名叫 p
        p[0] =4;            //p 就是arr
        printf("%d \n",arr[0]);

引用类型就是给变量起的别名  
引用类型在定义时必须赋初始值

### 引用类型的本质

    int x= 1;
    int& p =x;  //起个别名叫p
    p = 2;        //p就是x
    printf("%d \n",x);
    43:       int x= 1;
    00401058   mov         dword ptr [ebp-4],1
    44:       int& p =x;  //起个别名叫p
    0040105F   lea         eax,[ebp-4]
    00401062   mov         dword ptr [ebp-8],eax
    45:       p = 2;        //p就是x
    00401065   mov         ecx,dword ptr [ebp-8]
    00401068   mov         dword ptr [ecx],2
    46:       printf("%d \n",x);
    0040106E   mov         edx,dword ptr [ebp-4]
    00401071   push        edx
    00401072   push        offset string "%d \n" (0042501c)
    00401077   call        printf (00403880)
    0040107C   add         esp,8
    //测试 吧上述代码中的引用类型改为指针。
    int x= 1;
    int* p =&x;  //起个别名叫p
    *p = 2;        //p就是x
    printf("%d \n",x);
    //结果发现生成的反汇编结果一模一样
    //这里我们暂时得出结论，，引用类型就是指针。或者说在底层实现上 就是指针

### 引用类型和指针的区别

    int x = 1;
    //必须初始化
    int* p = &x;
    int& ref = x;
    //运算
    p++;
    ref++;
    //赋值
    p = (int*)1;
    ref = 100;
    //反汇编
    49:       int x = 1;
    00401028   mov         dword ptr [ebp-4],1
    50:       //必须初始化
    51:       int* p = &x;
    0040102F   lea         eax,[ebp-4]
    00401032   mov         dword ptr [ebp-8],eax
    52:       int& ref = x;
    00401035   lea         ecx,[ebp-4]
    00401038   mov         dword ptr [ebp-0Ch],ecx
    53:
    54:       //运算
    55:       p++;
    0040103B   mov         edx,dword ptr [ebp-8]
    0040103E   add         edx,4
    00401041   mov         dword ptr [ebp-8],edx
    56:       ref++;
    00401044   mov         eax,dword ptr [ebp-0Ch]
    00401047   mov         ecx,dword ptr [eax]
    00401049   add         ecx,1
    0040104C   mov         edx,dword ptr [ebp-0Ch]
    0040104F   mov         dword ptr [edx],ecx
    57:
    58:       //赋值
    59:       p = (int*)1;
    00401051   mov         dword ptr [ebp-8],1
    60:       ref = 100;
    00401058   mov         eax,dword ptr [ebp-0Ch]
    0040105B   mov         dword ptr [eax],64h
    class Base
    {
    public:
        int x;
        int y;
        Base(int x,int y)
        {
            this->x = x;
            this->y =y;
        }
    }
    Base b(1,2);
    //必须初始化
    Base* p = &b;
    Base& ref = b;
    //运算
    p++;
    //ref++;
    //赋值
    p = (Base*)1;
    //ref = 100;
    

总结：

  1. 被引用必须赋初始值，且只能指向一个变量，“从一而终”。
  2. 对引用复制，是对其指向的变量赋值，而不是修改引用本身的值
  3. 对引用做运算，就是对其指向的变量做运算，而不是对引用本身做运算。
  4. 引用类型就是一个“弱化了的指针”。

> 个人见解，其实我觉得引用类型就像是一个 `*p` 也就是取值了的指针~~~

### 引用在函数参数传递中的作用(基本类型)

    void Plus(int& i)
    {
        i++;
        return;
    }
    int main(int argc,char* argv[])
    {
        int i = 10;
        Plus(i);
        printf("%d \n",i);
        return 0;
    }
    102:      i++;
    00401038   mov         eax,dword ptr [ebp+8]
    0040103B   mov         ecx,dword ptr [eax]
    0040103D   add         ecx,1
    00401040   mov         edx,dword ptr [ebp+8]
    00401043   mov         dword ptr [edx],ecx
    //传入的虽然是指针，但是对参数操作就是对对应参数操作，而不是指针本身的操作
    108:      int i = 10;
    00401078   mov         dword ptr [ebp-4],0Ah
    109:      Plus(i);
    0040107F   lea         eax,[ebp-4]
    00401082   push        eax
    00401083   call        @ILT+0(Plus) (00401005)
    00401088   add         esp,4
    110:      printf("%d \n",i);
    0040108B   mov         ecx,dword ptr [ebp-4]
    0040108E   push        ecx
    0040108F   push        offset string "%d \n" (0042201c)
    00401094   call        printf (004010d0)
    00401099   add         esp,8
    //当函数的参数为引用类型的时候
    //传入的参数为参数的地址

### 引用在函数参数传递中的作用(构造类型)

    struct Base
    {
        int x;
        int y;
        Base(int x,int y)
        {
            this->x = x;
            this->y = y;
        }
    }
    void PrintByRef(Base& refb,Base* pb)
    {
        //通过指针读取
        printf("%d,%d \n",pb->x,pb->y);
        //通过引用获取
        printf("%d %d \n",refb.x,refb.y);
        //指针可以重新赋值，可以做运算
        //引用不可以
        //refb = (Base&)1;
        //refb++;
    }
    //反汇编
    121:      //通过指针读取
    122:      printf("%d,%d \n",pb->x,pb->y);
    00401088   mov         eax,dword ptr [ebp+0Ch]
    0040108B   mov         ecx,dword ptr [eax+4]
    0040108E   push        ecx
    0040108F   mov         edx,dword ptr [ebp+0Ch]
    00401092   mov         eax,dword ptr [edx]
    00401094   push        eax
    00401095   push        offset string "%d,%d \n" (00422028)
    0040109A   call        printf (004011b0)
    0040109F   add         esp,0Ch
    123:      //通过引用获取
    124:      printf("%d %d \n",refb.x,refb.y);
    004010A2   mov         ecx,dword ptr [ebp+8]
    004010A5   mov         edx,dword ptr [ecx+4]
    004010A8   push        edx
    004010A9   mov         eax,dword ptr [ebp+8]
    004010AC   mov         ecx,dword ptr [eax]
    004010AE   push        ecx
    004010AF   push        offset string "%d %d \n" (0042201c)
    004010B4   call        printf (004011b0)
    004010B9   add         esp,0Ch
    125:      //指针可以重新赋值，可以做运算
    126:      //引用不可以
    127:      //refb = (Base&)1;
    128:      //refb++;
    133:      Base b(1,2);
    00401108   push        2
    0040110A   push        1
    0040110C   lea         ecx,[ebp-8]
    0040110F   call        @ILT+5(Base::Base) (0040100a)
    134:      Base* p =&b;
    00401114   lea         eax,[ebp-8]
    00401117   mov         dword ptr [ebp-0Ch],eax
    135:      Base& ref=b;
    0040111A   lea         ecx,[ebp-8]
    0040111D   mov         dword ptr [ebp-10h],ecx
    136:
    137:      PrintByRef(ref,p);
    00401120   mov         edx,dword ptr [ebp-0Ch]
    00401123   push        edx
    00401124   mov         eax,dword ptr [ebp-10h]
    00401127   push        eax
    00401128   call        @ILT+15(PrintByRef) (00401014)
    0040112D   add         esp,8
    

### 给狗起个人的名字？

引用是变量的别名，如：

    int x = 10;
    int& r = x;          //int类型的别名就应该是 Int&
    Base b(1,2);
    Base&r = b;          //Base类型的别名 就应该是 Base&
    Base& r = (Base&)x;  //虽然可以变异 但是意义不大

### 常引用

    class Base
    {
    public:
        int x;
    };
    void Print(const Base& ref)//常量参数
    {
            //ref = 100;    //不论是不是const不能修改
            //ref.x = 200;  //不是const能修改指向的内容 是const 不能修改
            printf("%d \n",ref.x);
    }
    int main(int argc,char* argv[])
    {
        Base b;
        b.x = 100;
        Print(b);
        return 0;
    }