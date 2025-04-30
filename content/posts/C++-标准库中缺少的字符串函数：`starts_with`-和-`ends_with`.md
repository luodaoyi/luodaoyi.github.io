---
title: "C++ 标准库中缺少的字符串函数：`starts_with` 和 `ends_with`"
categories: [ "CPP" ]
tags: [  ]
draft: false
slug: "C++ 标准库中缺少的字符串函数：`starts_with` 和 `ends_with`-c标准库中缺少的字符串函数startswith和endswith"
date: "2018-09-17 00:08:02"
---



 

C++ 标准模板库的&nbsp;`std::string`&nbsp;很好很强大，但是并没有提供判断一个字符串是否以另一个字符串开始/结束的接口。这里为&nbsp;`std::basic_string<charT>`&nbsp;提供这两个接口。 

```cpp
//string_predicate.hpp

#include <string>
namespace std {
template <typename charT>
inline bool starts_with(const basic_string<charT>& big, const basic_string<charT>& small) {
    if (&big == &small) return true;
    const typename basic_string<charT>::size_type big_size = big.size();
    const typename basic_string<charT>::size_type small_size = small.size();
    const bool valid_ = (big_size >= small_size);
    const bool starts_with_ = (big.compare(0, small_size, small) == 0);
    return valid_ and starts_with_;
}

template <typename charT>
inline bool ends_with(const basic_string<charT>& big, const basic_string<charT>& small) {
    if (&big == &small) return true;
    const typename basic_string<charT>::size_type big_size = big.size();
    const typename basic_string<charT>::size_type small_size = small.size();
    const bool valid_ = (big_size >= small_size);
    const bool ends_with_ = (big.compare(big_size - small_size, small_size, small) == 0);
    return valid_ and ends_with_;
}
}  // namespace std
```


用法： 

```cpp
#include <iostream>
#include <string>

#include "string_predicate.hpp"

int main() {
    std::string compared = "Hello world!";
    std::string start    = "Hello";
    std::string end      = "world!";

    std::cout << std::starts_with(compared, start) << std::endl;
    std::cout << std::ends_with(compared, end) << std::endl;

    std::wstring wcompared = L"你好世界";
    std::wstring wstart    = L"你好";
    std::wstring wend      = L"世界";

    std::cout << std::starts_with(wcompared, wstart) << std::endl;
    std::cout << std::ends_with(wcompared, wend) << std::endl;

    return 0;
}
```


结果：

```cpp
$ g++ test.cc
$ ./a.out
1
1
1
1
```


转载自：&nbsp;https://liam0205.me/2017/12/14/the-missing-starts-with-and-ends-with-in-Cpp-for-std-string/