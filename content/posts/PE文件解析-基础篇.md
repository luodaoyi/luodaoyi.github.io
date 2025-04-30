---
title: "PE文件解析 基础篇"
categories: [ "逆向","转载" ]
tags: [  ]
draft: false
slug: "PE文件解析 基础篇-pe文件解析基础篇"
date: "2018-10-29 02:32:22"
---



前言 - 之前学习了PE格式，为了更好的理解，决定写一个类似LoadPE的小工具。
- 编译器是VS2015，采用MFC框架。
- 此系列文章采用边介绍知识点，边写代码的形式，以免变的无聊丧失兴趣。
- PE知识请参照《加密与解密》第10章。

**PE文件格式**1. PE文件基本概念 - PE文件是windows系统中遵循PE结构的文件，比如以.exe .dll为后缀名的文件以及系统驱动文件。**(PE结构框架看下图）**

PE文件大体分为两部分，头(包括下图中的DOS头，PE文件头，块表)与主体(块)。 ![PE文件解析](/uploads/2018/10/4-1540780342.jpg "PE文件解析")- PE文件从磁盘当中像内存中的映射，不是简单的“1对1”的关系，而是“拉长”了。具体的位置表现在块。 但是磁盘上的数据结构与在内存中的结构是一致的。

## ![PE文件解析](/uploads/2018/10/7-1540780342.jpg "PE文件解析")

- 无论PE文件在磁盘中还是在内存中，都少不了地址的概念，理解一下几个概念至关重要。

虚拟地址(VA)： 在一个程序运行起来的时候，会被加载到内存中，并且每个进程都有自己的4GB，这个4GB当中的某个位置叫做**虚拟地址**，由物理地址映射过来的，4GB的空间，并没有全部被用到。 基地址( Imagebase ):磁盘中的文件加载到内存当中的时候可以加载到任意位置，而这个位置就是程序的基址。EXE默认的加载基址是400000h,DLL文件默认基址是10000000h。需要注意的是基地址不是程序的入口点。 相对虚拟地址(RVA):为了避免PE文件中有确定的内存地址，引入了相对虚拟地址的概念。RVA是在内存中相对与载入地址(基地址）的偏移量，所以你可以发现前三个概念的关系：虚拟地址(VA)= 基地址+ 相对虚拟地址(RVA) 文件偏移地址(FOA)：当PE文件储存在某个磁盘当中的时候，某个数据的位置相对于文件头的偏移量。 入口点(OEP)：首先明确一个概念就是OEP是一个RVA，然后使用OEP + Imagebase == 入口点的VA，通常情况下，OEP指向的不是main函数。 - 存了张图 比较好的解释了各部分的关系

![PE文件解析](/uploads/2018/10/8-1540780343.jpg "PE文件解析")接下来依次介绍PE结构框图的每个部分。 2. DOS头部 每个PE文件都是以DOS头开始的，IMAGE_DOS_HEADER 结构如下所示： 

```cpp
（最左边是文件头的偏移量。） 
IMAGE_DOS_HEADER STRUCT 
{ 
+0h WORD    e_magic        <span class="hljs-default-comment">//   MZ(4Dh 5Ah)     DOS可执行文件标记 </span>
+2h     WORD    e_cblp            
+4h     WORD    e_cp                         
+6h     WORD    e_crlc                      
+8h     WORD    e_cparhdr      
+0ah    WORD    e_minalloc       
+0ch    WORD    e_maxalloc  
+0eh    WORD    e_ss           
+10h    WORD    e_sp       
+12h    WORD    e_csum      
+14h    WORD    e_ip        
+16h    WORD    e_cs        
+18h    WORD    e_lfarlc       
+1ah    WORD    e_ovno          
+1ch    WORD    e_res<span class="hljs-default-selector-attr">[4]</span>        
+24h    WORD    e_oemid         
+26h    WORD    e_oeminfo    
+29h    WORD    e_res2<span class="hljs-default-selector-attr">[10]</span>  
+3ch    DWORD   e_lfanew     <span class="hljs-default-comment">//  RVA     指向PE文件头 </span>
} IMAGE_DOS_HEADER ENDS
```

需要关注的点是结构体的第一个和第二个元素。 e_magic:DOS头的标记位，值为4D5Ah。ASCII为”MZ“，判断一个文件是否为PE文件是会用。 e_lfanew:这是一个RVA，代表了PE文件头到基址的偏移量，我们可以用它来找到PE文件头的位置。 我们用010editor打开一个exe文件： ![PE文件解析](/uploads/2018/10/6-1540780344.jpg "PE文件解析")3. PE文件头 IMAGE_NT_HEADERS STRUCT 结构体 

```cpp
IMAGE_NT_HEADERS STRUCT 
{
+0h       DWORD    Signature  
+4h       IMAGE_FILE_HEADER    FileHeader 
+18h      IMAGE_OPTIONAL_HEADER32   OptionalHeader   
} IMAGE_NT_HEADERS ENDS
```

- Signature 字段

在一个PE文件中Signature字段被设置为4550h,ASCII码为”PE00“。如上图所示。 - IMAGE_FILE_HEADER 结构体

```cpp
struct IMAGE_FILE_HEADER
{
  WORD Machine;                   //运行平台
  WORD NumberOfSections;          //区块表的个数
  DWORD TimeDataStamp;            //文件创建时间，是从1970年至今的秒数
  DWORD PointerToSymbolicTable;   //指向符号表的指针
  DWORD NumberOfSymbols;          //符号表的数目
  WORD SizeOfOptionalHeader;      //IMAGE_NT_HEADERS结构中OptionHeader成员的大小，对于win32平台这个值通常是0x00e0      //文件的属性值
  WORD Characteristics;           
}
```

在010 Editor上查看一下： ![PE文件解析](/uploads/2018/10/6-1540780344-1.jpg "PE文件解析")- IMAGE_OPTIONAL_HEADER 结构体

``` shell
<span class="hljs-default-keyword">typedef</span> <span class="hljs-default-class"><span class="hljs-default-keyword">struct</span> _<span class="hljs-default-title">IMAGE_OPTIONAL_HEADER</span>
{</span>
    <span class="hljs-default-comment">//</span>
    <span class="hljs-default-comment">// Standard fields.  </span>
    <span class="hljs-default-comment">//</span>
+<span class="hljs-default-number">18</span>h    WORD    Magic;                   <span class="hljs-default-comment">// 标志字, ROM 映像（0107h）,普通可执行文件（010Bh）</span>
+<span class="hljs-default-number">1</span>Ah    BYTE    MajorLinkerVersion;      <span class="hljs-default-comment">// 链接程序的主版本号</span>
+<span class="hljs-default-number">1B</span>h    BYTE    MinorLinkerVersion;      <span class="hljs-default-comment">// 链接程序的次版本号</span>
+<span class="hljs-default-number">1</span>Ch    DWORD   SizeOfCode;              <span class="hljs-default-comment">// 所有含代码的节的总大小</span>
+<span class="hljs-default-number">20</span>h    DWORD   SizeOfInitializedData;   <span class="hljs-default-comment">// 所有含已初始化数据的节的总大小</span>
+<span class="hljs-default-number">24</span>h    DWORD   SizeOfUninitializedData; <span class="hljs-default-comment">// 所有含未初始化数据的节的大小</span>
+<span class="hljs-default-number">28</span>h    DWORD   AddressOfEntryPoint;     <span class="hljs-default-comment">// 程序执行入口RVA</span>
+<span class="hljs-default-number">2</span>Ch    DWORD   BaseOfCode;              <span class="hljs-default-comment">// 代码的区块的起始RVA</span>
+<span class="hljs-default-number">30</span>h    DWORD   BaseOfData;              <span class="hljs-default-comment">// 数据的区块的起始RVA</span>
    <span class="hljs-default-comment">//</span>
    <span class="hljs-default-comment">// NT additional fields.    以下是属于NT结构增加的领域。</span>
    <span class="hljs-default-comment">//</span>
+<span class="hljs-default-number">34</span>h    DWORD   ImageBase;               <span class="hljs-default-comment">// 程序的首选装载地址</span>
+<span class="hljs-default-number">38</span>h    DWORD   SectionAlignment;        <span class="hljs-default-comment">// 内存中的区块的对齐大小</span>
+<span class="hljs-default-number">3</span>Ch    DWORD   FileAlignment;           <span class="hljs-default-comment">// 文件中的区块的对齐大小</span>
+<span class="hljs-default-number">40</span>h    WORD    MajorOperatingSystemVersion;  <span class="hljs-default-comment">// 要求操作系统最低版本号的主版本号</span>
+<span class="hljs-default-number">42</span>h    WORD    MinorOperatingSystemVersion;  <span class="hljs-default-comment">// 要求操作系统最低版本号的副版本号</span>
+<span class="hljs-default-number">44</span>h    WORD    MajorImageVersion;       <span class="hljs-default-comment">// 可运行于操作系统的主版本号</span>
+<span class="hljs-default-number">46</span>h    WORD    MinorImageVersion;       <span class="hljs-default-comment">// 可运行于操作系统的次版本号</span>
+<span class="hljs-default-number">48</span>h    WORD    MajorSubsystemVersion;   <span class="hljs-default-comment">// 要求最低子系统版本的主版本号</span>
+<span class="hljs-default-number">4</span>Ah    WORD    MinorSubsystemVersion;   <span class="hljs-default-comment">// 要求最低子系统版本的次版本号</span>
+<span class="hljs-default-number">4</span>Ch    DWORD   Win32VersionValue;       <span class="hljs-default-comment">// 莫须有字段，不被病毒利用的话一般为0</span>
+<span class="hljs-default-number">50</span>h    DWORD   SizeOfImage;             <span class="hljs-default-comment">// 映像装入内存后的总尺寸</span>
+<span class="hljs-default-number">54</span>h    DWORD   SizeOfHeaders;           <span class="hljs-default-comment">// 所有头 + 区块表的尺寸大小</span>
+<span class="hljs-default-number">58</span>h    DWORD   CheckSum;                <span class="hljs-default-comment">// 映像的校检和</span>
+<span class="hljs-default-number">5</span>Ch    WORD    Subsystem;               <span class="hljs-default-comment">// 可执行文件期望的子系统</span>
+<span class="hljs-default-number">5</span>Eh    WORD    DllCharacteristics;      <span class="hljs-default-comment">// DllMain()函数何时被调用，默认为 0</span>
+<span class="hljs-default-number">60</span>h    DWORD   SizeOfStackReserve;      <span class="hljs-default-comment">// 初始化时的栈大小</span>
+<span class="hljs-default-number">64</span>h    DWORD   SizeOfStackCommit;       <span class="hljs-default-comment">// 初始化时实际提交的栈大小</span>
+<span class="hljs-default-number">68</span>h    DWORD   SizeOfHeapReserve;       <span class="hljs-default-comment">// 初始化时保留的堆大小</span>
+<span class="hljs-default-number">6</span>Ch    DWORD   SizeOfHeapCommit;        <span class="hljs-default-comment">// 初始化时实际提交的堆大小</span>
+<span class="hljs-default-number">70</span>h    DWORD   LoaderFlags;             <span class="hljs-default-comment">// 与调试有关，默认为 0 </span>
+<span class="hljs-default-number">74</span>h    DWORD   NumberOfRvaAndSizes;     <span class="hljs-default-comment">// 下边数据目录的项数，这个字段自Windows NT 发布以来一直是16</span>
+<span class="hljs-default-number">78</span>h    IMAGE_DATA_DIRECTORY DataDirectory[IMAGE_NUMBEROF_DIRECTORY_ENTRIES];   
<span class="hljs-default-comment">// 数据目录表</span>
} IMAGE_OPTIONAL_HEADER32, *PIMAGE_OPTIONAL_HEADER32;
```

重要的有： AddressOfEntryPoint: 也就是上文提到的OEP，程序源入口点。 ImageBase: 默认加载基址。 SectionAlignment: 内存当中的块对齐数，一般为0x1000。 FileAlignment:磁盘当中块对齐数，一般为0x200。 SizeOfHeaders:所有头部大小 也就是DOS头 文件头 以及区块头的总大小，文件主体相对文件其实的偏移。 IMAGE_DATA_DIRECTORY DataDirectory[IMAGE_NUMBEROF_DIRECTORY_ENTRIES]：数据目录表，保存了各种表的RVA及大小。 来看一下数据目录的定义： ```
IMAGE_DATA_DIRECTORY STRUCT
      VirtualAddress    DWORD       ?   ; 数据的起始RVA
      Size             DWORD       ?   ; 数据块的长度
IMAGE_DATA_DIRECTORY ENDS
```

在010 Editor上查看一下： ![PE文件解析](/uploads/2018/10/0-1540780345.jpg "PE文件解析")4. 写代码操作一下 主要解析了DOS头与PE文件头比较重要的字段，直接放代码。 ```
<span class="hljs-default-comment">//打开文件</span>
m_hFile = CreateFile(
    m_DeleFileName,GENERIC_READ,<span class="hljs-default-keyword">NULL</span>,<span class="hljs-default-keyword">NULL</span>,OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL,<span class="hljs-default-keyword">NULL</span>);
 
DWORD dwSize = GetFileSize(m_hFile, <span class="hljs-default-keyword">NULL</span>);
 
PBYTE pBuf = <span class="hljs-default-keyword">new</span> BYTE[dwSize]{};
 
<span class="hljs-default-comment">//读取</span>
ReadFile(m_hFile,pBuf,dwSize,&dwSize,<span class="hljs-default-keyword">NULL</span>);
 
<span class="hljs-default-comment">//判断是否为PE文件</span>
m_pDos = PIMAGE_DOS_HEADER(pBuf);
<span class="hljs-default-keyword">if</span> (m_pDos->e_magic!=IMAGE_DOS_SIGNATURE)
{
    MessageBox(L<span class="hljs-default-string">不是有效的PE文件 n</span>);
    CloseHandle(m_hFile);
    m_hFile = <span class="hljs-default-keyword">NULL</span>;
    <span class="hljs-default-keyword">return</span>;
}
m_pNTHeader = PIMAGE_NT_HEADERS(pBuf+m_pDos->e_lfanew);
<span class="hljs-default-keyword">if</span> (m_pNTHeader->Signature!= IMAGE_NT_SIGNATURE)
{
    MessageBox(L<span class="hljs-default-string">不是有效的PE文件 n</span>);
    CloseHandle(m_hFile);
    m_hFile = <span class="hljs-default-keyword">NULL</span>;
    <span class="hljs-default-keyword">return</span>;
}
 
 
<span class="hljs-default-comment">//读取文件头信息</span>
m_pFileHeader = &(m_pNTHeader->FileHeader);
 
m_NumberOfSections.Format(L<span class="hljs-default-string">%X</span>,m_pFileHeader->NumberOfSections);
m_TimeDateStamp.Format(L<span class="hljs-default-string">%p</span>, m_pFileHeader->TimeDateStamp);
m_SizeOfOptionalHeader.Format(L<span class="hljs-default-string">%X</span>, m_pFileHeader->SizeOfOptionalHeader);
 
<span class="hljs-default-comment">//拓展头信息</span>
m_pOptionalHeader = &(m_pNTHeader->OptionalHeader);
 
m_AddressOfEntryPoint.Format(L<span class="hljs-default-string">%X</span>,m_pOptionalHeader->AddressOfEntryPoint);
m_SizeOfHeaders.Format(L<span class="hljs-default-string">%X</span>, m_pOptionalHeader->SizeOfHeaders);
m_ImageBase.Format(L<span class="hljs-default-string">%X</span>, m_pOptionalHeader->ImageBase);
m_SizeOfImage.Format(L<span class="hljs-default-string">%X</span>, m_pOptionalHeader->ImageBase);
m_BaseOfCode.Format(L<span class="hljs-default-string">%X</span>, m_pOptionalHeader->BaseOfCode);
m_DllCharacteristics.Format(L<span class="hljs-default-string">%X</span>, m_pOptionalHeader->DllCharacteristics);
m_BaseOfData.Format(L<span class="hljs-default-string">%X</span>, m_pOptionalHeader->BaseOfData);
m_NumberOfRvaAndSizes.Format(L<span class="hljs-default-string">%X</span>, m_pOptionalHeader->NumberOfRvaAndSizes);
m_SectionAlignment.Format(L<span class="hljs-default-string">%X</span>, m_pOptionalHeader->SectionAlignment);
m_FileAlignment.Format(L<span class="hljs-default-string">%X</span>, m_pOptionalHeader->FileAlignment);
m_CheckSum.Format(L<span class="hljs-default-string">%X</span>, m_pOptionalHeader->CheckSum);
m_Magic.Format(L<span class="hljs-default-string">%X</span>, m_pOptionalHeader->CheckSum);
m_Subsystem.Format(L<span class="hljs-default-string">%X</span>, m_pOptionalHeader->Subsystem);
```

实现的效果如下： ![PE文件解析](/uploads/2018/10/7-1540780345.png "PE文件解析")第一部分比较简单，完整代码放到附件。（点击阅读原文，即可获取附件） - End -![PE文件解析](/uploads/2018/10/4-1540780345.jpg "PE文件解析")**看雪ID：Jabez** https://bbs.pediy.com/user-825190.htm 本文由看雪论坛 **Jabez** 原创 转载请注明来自看雪社区 > 原文始发于微信公众号（ 看雪学院 ）：PE文件解析 基础篇