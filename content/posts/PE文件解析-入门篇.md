---
title: "PE文件解析 入门篇"
categories: [ "逆向","转载" ]
tags: [  ]
draft: false
slug: "PE文件解析 入门篇-pe文件解析入门篇"
date: "2018-10-29 02:32:29"
---



前言 - PE文件解析 系列文章的第二篇，上一篇参考：PE文件解析 基础篇
- 介绍区块头表和区块
- 解析出区段表 完成RVA转FOA的功能
- 解析出数据目录表各种表的位置和大小
- 源码放在附件

1.区块头表 - pe文件头与原始数据之间存在一个区块表，区块表包含了每个块在映像(内存)中的信息，分别指向不同的区块实体。

![PE文件解析](/uploads/2018/10/8-1540780349.jpg "PE文件解析")- PE文件中所有节的属性都被定义在节表中，节表由一系列的IMAGE_SECTION_HEADER结构排列而成，每个结构用来描述一个节，结构的排列顺序和它们描述的节在文件中的排列顺序是一致的。全部有效结构的最后以一个空的IMAGE_SECTION_HEADER结构作为结束，所以节表中总的IMAGE_SECTION_HEADER结构数量等于节的数量加一。节表总是被存放在紧接在PE文件头的地方。另外，节表中 IMAGE_SECTION_HEADER 结构的总数总是由PE文件头 IMAGE_NT_HEADERS 结构中的 FileHeader.NumberOfSections字段来指定的。

- IMAGE_SECTION_HEADER 结构体包含了对应的区块的具体信息，位置、长度和属性。

```
<span class="hljs-default-keyword">typedef</span> <span class="hljs-default-class"><span class="hljs-default-keyword">struct</span> _<span class="hljs-default-title">IMAGE_SECTION_HEADER</span> 
{</span>
       BYTE Name[IMAGE_SIZEOF_SHORT_NAME]; <span class="hljs-default-comment">// 节表名称,如“.text”</span>
        <span class="hljs-default-comment">//IMAGE_SIZEOF_SHORT_NAME=8</span>
        <span class="hljs-default-keyword">union</span>
         {
                DWORD PhysicalAddress;      <span class="hljs-default-comment">// 物理地址</span>
                DWORD VirtualSize;          <span class="hljs-default-comment">// 真实长度，这两个值是一个联合结构，可以使用其中的任何一个，一般是取后一个</span>
        } Misc;
        DWORD VirtualAddress;               <span class="hljs-default-comment">// 节区的 RVA 地址        </span>
        DWORD SizeOfRawData;                <span class="hljs-default-comment">// 在文件中对齐后的尺寸     </span>
        DWORD PointerToRawData;             <span class="hljs-default-comment">// 在文件中的偏移量        </span>
        DWORD PointerToRelocations;         <span class="hljs-default-comment">// 在OBJ文件中使用，重定位的偏移  </span>
        DWORD PointerToLinenumbers;         <span class="hljs-default-comment">// 行号表的偏移（供调试使用地)</span>
        WORD NumberOfRelocations;           <span class="hljs-default-comment">// 在OBJ文件中使用，重定位项数目</span>
        WORD NumberOfLinenumbers;           <span class="hljs-default-comment">// 行号表中行号的数目</span>
        DWORD Characteristics;              <span class="hljs-default-comment">// 节属性如可读，可写，可执行等</span>
} IMAGE_SECTION_HEADER, *PIMAGE_SECTION_HEADER;
```

Name: 这是一个由8位的ASCII 码名，用来定义区块的名称。 VirtualAddress:区块的RVA。 SizeOfRawData：区块在磁盘文件中的占用大小 200h。 PointerToRawData:文件中的偏移量。 NumberOfRelocations：在exe文件中无意义，在OBJ 文件中 是本快在重定位表中重定位数目。 用loadPE打开： ![PE文件解析](/uploads/2018/10/2-1540780350.jpeg "PE文件解析")代码实现区段头表的解析： ```
<span class="hljs-default-comment">//通过NT头找到区段头首地址</span>
PIMAGE_SECTION_HEADER pSec = IMAGE_FIRST_SECTION(m_pNTHeader);
 
<span class="hljs-default-keyword">for</span> (<span class="hljs-default-keyword">int</span> i = <span class="hljs-default-number">0</span>;i< m_pNTHeader->FileHeader.NumberOfSections;i++)
{
    CHAR pName[<span class="hljs-default-number">9</span>] = {};
    memcpy_s(pName,<span class="hljs-default-number">9</span>,pSec[i].Name,<span class="hljs-default-number">8</span>);
    m_strName = pName;
 
    m_strVO.Format(L<span class="hljs-default-string">%p</span>,pSec[i].VirtualAddress);
    m_strVS.Format(L<span class="hljs-default-string">%p</span>, pSec[i].Misc.VirtualSize);
    m_strRO.Format(L<span class="hljs-default-string">%p</span>, pSec[i].PointerToRawData);
    m_strRS.Format(L<span class="hljs-default-string">%p</span>, pSec[i].SizeOfRawData);
    m_strSig.Format(L<span class="hljs-default-string">%p</span>, pSec[i].Characteristics);
 
    m_SectionInfoList.AddItem(<span class="hljs-default-number">6</span>, m_strName, m_strVO, m_strVS, m_strRO, m_strRS, m_strSig);
}
```

2. 区块 - PE文件至少要有两个区块，代码块 数据块。

- 常见区块的介绍

.text: 默认的代码区块，内容都是指令代码。 .data：默认的读写数据块，全局变量，静态变量一般放在这里。 .rdata: 默认的只读数据块，一般很少用到。 .idata:包含外来的DLL数据及数据信息，也就是输入表之后会讲到， 通常情况下把他合并到.rdata中。 .edata: 当创建一个用于输出数据的可执行文件时，(输出表)，数据会 放在这里，通常情况下会被合并到.text 或.tdata中。 .rsrs：资源块 包含一切图标菜单等。 (还有一些可参考《加密与解密》 不在这里列举了)。 - 区块的对齐

区块的对齐有两种，一是磁盘当中的区块对齐，二是内存当中的区块对齐。磁盘当中的对齐值是200h,所以每个区块都应该是200h的倍数。内存当中的对齐值为1000h，也就是4KB。 3. 文件偏移与虚拟地址的转换 - - 由于磁盘与内存当中的对齐值不一样，不免会带来地址的相互转换问题。要转换的RVA一定落在一个区段内，首先判断它落在哪个区段。然后减去这个区段的RVA再加上这个区段的文件偏移量，就可以得到要转换的FOA值。Offect(转) = RVA(转) -RVA(区段）+Offect(区段)。而这些关于区段的信息都保存在区段头表中。

具体找个例子实验一下： 用loadPE打开一个exe。随机选取一个RVA值如1100h。首先找出它所在的区段。发现所在的区段为.text区段。.text区段的RVA值为1000h,大小为110D1h,可以判断1100h落在了.text区段内。所以用1100h-1000h+600h = 700h ,即为FOA。 ![PE文件解析](/uploads/2018/10/8-1540780350.png "PE文件解析")验证一下： ![PE文件解析](/uploads/2018/10/6-1540780350.png "PE文件解析")写代码实现一下： ```
<span class="hljs-default-comment">//循环查找</span>
<span class="hljs-default-keyword">for</span> (<span class="hljs-default-keyword">int</span> i=<span class="hljs-default-number">0</span>; i < pNt->FileHeader.NumberOfSections;i++)
{
 
    <span class="hljs-default-keyword">if</span> (dwRva >= pSec[i].VirtualAddress && 
        dwRva <= pSec[i].VirtualAddress + pSec[i].SizeOfRawData)                                <span class="hljs-default-comment">//判断在哪个区段</span>
    {
        <span class="hljs-default-keyword">return</span> (dwRva - pSec[i].VirtualAddress + pSec[i].PointerToRawData);                  <span class="hljs-default-comment">//用公式进行计算</span>
    }
 
 
}
```

4. 完整效果 - 实现RVA到VA和FOA的转换 ：

# ![PE文件解析](/uploads/2018/10/9-1540780351.png "PE文件解析")

- 打印数据目录信息：

![PE文件解析](/uploads/2018/10/6-1540780351.png "PE文件解析")- 打印区段相关信息：

![PE文件解析](/uploads/2018/10/9-1540780351-1.png "PE文件解析")- 完整代码放到附件 （点击阅读原文即可获得）

- End -![PE文件解析](/uploads/2018/10/1-1540780351.jpg "PE文件解析")**看雪ID：Jabez** https://bbs.pediy.com/user-825190.htm 本文由看雪论坛 **Jabez** 原创 > 原文始发于微信公众号（ 看雪学院 ）：PE文件解析 入门篇