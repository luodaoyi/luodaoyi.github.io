---
title: "MetaTrader4 mql语法简介"
categories: [ "其他" ]
tags: [ "MetaTrader","mql" ]
draft: false
slug: "MetaTrader4 mql语法简介-metatrader4mql语法简介"
date: "2017-10-16 07:21:00"
---



![WX20171016-152221@2x][1]

## 基础语法

跟C++差不多 懒得讲

## 常用函数和内置全局变量

### 抓取价格数据

    Ask  -- Double  当前K线(本货币)窗口买价
    Bid  -- Double  当前K线(本货币)窗口卖价
    MarketInfo("GBPUSD",MODE_ASK) --Double  获取指定("GBPUSD")类型货币当前买价
    MarketInfo("GBPUSD",MODE_BID) --Double  获取指定("GBPUSD")类型货币当前卖价

 [1]: /uploads/oss/2017-10-16-WX20171016-152221@2x.png "WX20171016-152221@2x"