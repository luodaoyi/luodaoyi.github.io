---
title: "KiFastCallEntry Hook (利用栈回溯技术)"
categories: [ "驱动开发" ]
tags: [ "Hook","驱动" ]
draft: false
slug: "KiFastCallEntry Hook (利用栈回溯技术)-kifastcallentryhook利用栈回溯技术"
date: "2018-11-17 17:22:14"
---



利用 栈回溯 技术,定位 KiFastCallEntry API 地址空间,搜索特征码后进行inline hook,KiFastCallEntry 是大多数 ring3 到 ring0 API调用必经 之路, 所以 hook之后可以 监视很多 程序行为.

基于一个前提:

> KiFastCallEntry 函数 作用是：初始化 kernel stack , 根据 ring3 下 API外壳传来的 系统功能号, 然后转入 执行.

程序流程: 

  1. HOOK SSDT中一个较常用 函数调用,
  2. 在接管函数中 利用 栈回溯 技术 获取KiFastCallEntry的 获取(`[EBP+4]` )
  3. 从获取的返回地址出发,向前搜索特征值 (`sub  esp,ecx shr ecx,2`)的机器码 ,这里刚好是已经获取了 原始函数地址后的下一段指令
  4. 覆盖 5字节数据 ,即 用 JMP offset addr 来替换
  5. 转如hook接管函数 ,从这里就可以干些其他事情 ,比如获取函数参数什么的,判断调用者etc&#8230;
  6. 在驱动 卸载函数中 完成恢复hook点

// kifast.h


```cpp
#include "ntddk.h"

typedef struct _ServiceDescriptorTable
{
    PULONG ServiceTableBase;
    PULONG ServiceCounterTable;
    unsigned int NumberOfServices;
    PVOID paramTableBase;
}*PServiceDescriptorTable, ServiceDescriptorTable;

__declspec(dllimport) ServiceDescriptorTable KeServiceDescriptorTable;

typedef NTSTATUS
(*PNtCreateFile) (
__out PHANDLE FileHandle,
__in ACCESS_MASK DesiredAccess,
__in POBJECT_ATTRIBUTES ObjectAttributes,
__out PIO_STATUS_BLOCK IoStatusBlock,
__in_opt PLARGE_INTEGER AllocationSize,
__in ULONG FileAttributes,
__in ULONG ShareAccess,
__in ULONG CreateDisposition,
__in ULONG CreateOptions,
__in_bcount_opt(EaLength) PVOID EaBuffer,
__in ULONG EaLength
)
;
```


// kifast.c


```cpp
#include "kifast.h"

//
//globle
//
int g_Org_call;
UCHAR KEYCODE[5] = { 0x2b, 0xe1, 0xc1, 0xe9, 0x02 };
ULONG g_NtCreateFileAddr;
NTSTATUS Flag;
ULONG g_HookAddr;
ULONG NextAddr;

//开启页保护
VOID PageprotectOn()
{
    __asm
    {
        mov eax, cr0
            or eax, 10000h
            mov cr0, eax
            sti
    }
}

//关闭页保护
VOID PageprotectOff()
{

    _asm
    {
        cli
            mov eax, cr0
            and eax, not 10000h
            mov cr0, eax
    }

}

//利用特征码搜索Hook点
NTSTATUS  SearchHookAddr(ULONG g_BeginAddr)
{
    UCHAR* p;
    ULONG u_index;
    p = (UCHAR*)g_BeginAddr;
    for (u_index = 0; u_index < 200; u_index++)
    {
        if (*p == KEYCODE[0] && *(p + 1) == KEYCODE[1] &&
            *(p + 2) == KEYCODE[2] &&
            *(p + 3) == KEYCODE[3] &&
            *(p + 4) == KEYCODE[4]
            )
        {
            g_HookAddr = (ULONG)p;

            return STATUS_SUCCESS;
        }
        p--;
    }

    return STATUS_UNSUCCESSFUL;
}

// 钩子函数调用 过滤函数 
// 判断当前是否是 SSDT
// 若是则判断 NtOpenProcess 是被那个进程调用

VOID FilterFuction(ULONG index, ULONG BaseAddr)
{
    if (BaseAddr == (ULONG)KeServiceDescriptorTable.ServiceTableBase)
    {
        if (index == 0x25)
        {
            KdPrint(("from :%s", (UCHAR*)PsGetCurrentProcess() + 0x174));
        }
    }

}

// 不生成 栈帧 所以用汇编写
__declspec(naked)

VOID MyhookCall()
{
    __asm
    {
        pushad;
        pushf;
        push edi;
        push eax;
        call FilterFuction;
        popf;
        popad;
        // 转入正常流程
        sub     esp, ecx
            shr     ecx, 2
            JMP  NextAddr
    }
}

VOID HookKiFastCallEntry()
{
    UCHAR JMP_CODE[5];
    ULONG offset;
    JMP_CODE[0] = 0xE9;
    offset = (ULONG)MyhookCall - g_HookAddr - 5; //JMP的偏移地址
    *(ULONG*)&JMP_CODE[1] = offset;
    // 5 inline hook KifastcallEntry

    KdPrint(("offset %x", *(ULONG*)&JMP_CODE[1]));
    PageprotectOff();
    RtlCopyMemory((PVOID)g_HookAddr, JMP_CODE, 5);
    PageprotectOn();

    KdPrint(("Hook Successful", g_HookAddr));
}

NTSTATUS
MyNtCreateFile(
__out PHANDLE FileHandle,
__in ACCESS_MASK DesiredAccess,
__in POBJECT_ATTRIBUTES ObjectAttributes,
__out PIO_STATUS_BLOCK IoStatusBlock,
__in_opt PLARGE_INTEGER AllocationSize,
__in ULONG FileAttributes,
__in ULONG ShareAccess,
__in ULONG CreateDisposition,
__in ULONG CreateOptions,
__in_bcount_opt(EaLength) PVOID EaBuffer,
__in ULONG EaLength
)
{

    ULONG g_BeginAddr = NULL;
    NTSTATUS status;
    //  | stack  |
    // mov edi ,edi
    // push ebp
    // mov ebp ,esp  执行上述操作后
    // ---------------------------------
    // | ebp     :  old ebp  |  
    // | ebp + 4 :  ret addr |   | 这里就是 KiFastCallEntry 栈空间
    //
    // 2 栈回溯 找kiFastCallEntry地址空间
    __asm
    {
        pushad
            mov  eax, [ebp + 4]
            mov  g_BeginAddr, eax
            popad
    }
    //
    // 从获取的地址空间 向前查找特征码
    //
    status = SearchHookAddr(g_BeginAddr);

    if (NT_SUCCESS(status))
    {

        KdPrint(("Find Hook Address %x", g_HookAddr));
        NextAddr = g_HookAddr + 5;  //计算正常程序流程的下条指令地址 方便 hook 后转入继续执行

        // 3 hook KiFastCallEntry
        HookKiFastCallEntry();

        //4  恢复 NtCreateFile Hook
        PageprotectOff();
        KeServiceDescriptorTable.ServiceTableBase[0x25] = (ULONG)g_NtCreateFileAddr;
        PageprotectOn();

    }

    return ((PNtCreateFile)g_NtCreateFileAddr)(FileHandle, DesiredAccess, ObjectAttributes, IoStatusBlock, AllocationSize, FileAttributes,
        ShareAccess, CreateDisposition, CreateOptions, EaBuffer, EaLength);
}

NTSTATUS HookSSDT()
{
    ; // 1 利用SSDT Hook 进入目标API调用栈
    g_NtCreateFileAddr = KeServiceDescriptorTable.ServiceTableBase[0x25];
    PageprotectOff();
    KeServiceDescriptorTable.ServiceTableBase[0x25] = (ULONG)MyNtCreateFile;
    PageprotectOn();

}

VOID HookKifastcallentry()
{
    HookSSDT();
}

VOID MyUnload(PDRIVER_OBJECT pDriverObject)
{
    PageprotectOff();
    RtlCopyMemory((PVOID)g_HookAddr, KEYCODE, 5);
    PageprotectOn();
    KdPrint(("Unhook Successful", g_HookAddr));
}

NTSTATUS DriverEntry(PDRIVER_OBJECT pDriverObject, PUNICODE_STRING RegistryPath)
{

    KdPrint(("int DriverEntry"));
    HookKifastcallentry();

    pDriverObject->DriverUnload = MyUnload;
    KdPrint(("out DriverEntry"));
    return STATUS_SUCCESS;
}

```