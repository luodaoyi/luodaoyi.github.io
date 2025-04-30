---
title: "C语言对应汇编代码"
categories: [ "C-lang" ]
tags: [ "C","vc6","C语言" ]
draft: false
slug: "C语言对应汇编代码-c语言对应汇编代码"
date: "2017-09-24 00:53:00"
---



    
    void main(){
        __asm
        {
            mov eax,eax
            mov eax,eax
            mov eax,eax
            mov eax,eax
        }
        return;
    }
    int plus(int x,int y)
    {
        return 0;
    }
    

    
    --- C:\Project\2017_09_24\Main.cpp   ------------------------------------------
    1:
    2:    void main(){
    0040D3F0   push        ebp
    0040D3F1   mov         ebp,esp
    0040D3F3   sub         esp,40h
    0040D3F6   push        ebx
    0040D3F7   push        esi
    0040D3F8   push        edi
    0040D3F9   lea         edi,[ebp-40h]
    0040D3FC   mov         ecx,10h
    0040D401   mov         eax,0CCCCCCCCh
    0040D406   rep stos    dword ptr [edi]
    3:        __asm
    4:        {
    5:            mov eax,eax
    0040D408   mov         eax,eax
    6:            mov eax,eax
    0040D40A   mov         eax,eax
    7:            mov eax,eax
    0040D40C   mov         eax,eax
    8:            mov eax,eax
    0040D40E   mov         eax,eax
    9:        }
    10:       return;
    11:   }
    0040D410   pop         edi
    0040D411   pop         esi
    0040D412   pop         ebx
    0040D413   add         esp,40h
    0040D416   cmp         ebp,esp
    0040D418   call        __chkesp (0040d430)
    0040D41D   mov         esp,ebp
    0040D41F   pop         ebp
    0040D420   ret
    --- C:\Project\2017_09_24\Main.cpp  ------------------------------------------
    12:
    13:   int plus(int x,int y)
    14:   {
    0040D470   push        ebp
    0040D471   mov         ebp,esp
    0040D473   sub         esp,40h
    0040D476   push        ebx
    0040D477   push        esi
    0040D478   push        edi
    0040D479   lea         edi,[ebp-40h]
    0040D47C   mov         ecx,10h
    0040D481   mov         eax,0CCCCCCCCh
    0040D486   rep stos    dword ptr [edi]
    15:       return 0;
    0040D488   xor         eax,eax
    16:   }
    0040D48A   pop         edi
    0040D48B   pop         esi
    0040D48C   pop         ebx
    0040D48D   mov         esp,ebp
    0040D48F   pop         ebp
    0040D490   ret