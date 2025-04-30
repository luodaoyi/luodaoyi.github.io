---
title: "批量提取公众号文章的python脚本"
categories: [ "python" ]
tags: [  ]
draft: false
slug: "批量提取公众号文章的python脚本-批量提取公众号文章的python脚本"
date: "2018-09-25 06:06:30"
---



如何获取？<a href="http://xingyue.artizen.me/2018/04/27/%E6%9C%89%E7%94%A8%E5%8A%9F%EF%BD%9C%E5%A6%82%E4%BD%95%E9%87%87%E9%9B%86%E5%85%AC%E4%BC%97%E5%8F%B7%E5%8E%86%E5%8F%B2%E6%96%87%E7%AB%A0/" target="_blank" rel="noopener noreferrer">http://xingyue.artizen.me</a>





```python
coding:utf-8
import json
import pprint

links_array = []
with open('msg.txt',encoding='utf-8') as file:
	for line in file:
		s = json.loads(line)
		[links_array.append(i['link']) for i in s['app_msg_list']]
		
with open('link.txt','w') as f :
	[f.write(l + '\n') for l in links_array]

```