---
title: "Online.net 服务器监控脚本"
categories: [ "python" ]
tags: [ "linux","python" ]
draft: false
slug: "Onlinenet 服务器监控脚本-onlinenet服务器监控脚本"
date: "2017-12-20 16:05:00"
---



今天的kimsufi 4C没抢到。不过这个垃圾网还不如oline的。就找了个脚本改改 部署方便些

## 脚本

脚本使用python3.6编写，下面是脚本

需要更改的是价格。这个脚本是根据价格判断需要的服务器是否有货的

地址的话 这个是官网默认的地址，如果有活动的话 如果活动的界面跟这个地址的界面一样的话 直接改地址就可以了


```python
# coding:utf-8
import time
from datetime import datetime
import requests
from bs4 import BeautifulSoup
## 需要监控的价格
prices = ["6.99","16.99", "19.99","15.99"] #15.99不是特价款
# 通知的server酱的key  https://sc.ftqq.com 这里注册 然后去用微信扫描生成一个key就行了
keys = [
    "xxxxxxx",
]
# 检查间隔
check_interval = 60
# 服务器列表订购列表
url = "https://console.online.net/en/order/server"
notified = {}
## 通知次数
notice_times = 50
timeout = 20
# 获得购买页面
def get_page():
    with requests.get(url) as resp:
        return resp.content
# 发送消息通知
def send_message(key, text, desp=""):
    url = f"https://sc.ftqq.com/{key}.send"
    data = {
        "text": text,
        "desp": desp
    }
    requests.post(url, data=data, timeout=timeout)
# 检查每条数据是不是有货
def check_server(tr):
    tds = tr.find_all("td")
    if tds and tds[-1].find("form"): #有form就是有货啊
        tds_text = [td.text for td in tds]
        price = tds_text[-2].replace(" € pre-tax", "").strip()
        details = "\n\n".join(tds_text[:-1])
        if price in prices:
            if notified.get(price, 0) < notice_times:
                send_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                text = f"{price}O有货啦"
                desp = details + "\n\n 监控时间:   " + send_time + "\n\n 购买地址:   " + url
                notified[price] = notified.get(price, 0) + 1
                print(f"{price}O有货了，第{notified[price]}次通知")
                for key in keys:
                    send_message(key, text, desp)
                    time.sleep(1)
            else:
                print(f"{price}O的相关信息超过最大通知次数，不再微信通知...")
        else:
            notified.setdefault(price, 0)
# 跑脚本
def run():
    content = get_page()
    if not content:
        print("没有返回任何内容")
        return
    soup = BeautifulSoup(content, "html.parser")
    trs = soup.find_all("tr")
    for tr in trs:
        check_server(tr)
def main():
    while True:
        try:
            run()
            print(
                f"{check_interval}秒后再次检查,当前时间: { datetime.now().strftime("%Y-%m-%d %H:%M:%S")}")
            time.sleep(check_interval)
        except Exception as e:
            print(e)
            pass
if __name__ == "__main__":
    main()

```


## 部署和运行

这里只说ubuntu 16.04  
服务器上的python版本太低 这里自己装个pyenv

    sudo apt-get install -y build-essential libbz2-dev libssl-dev libreadline-dev \
                            libsqlite3-dev tk-dev
    sudo apt-get install -y libpng-dev libfreetype6-dev
    curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
    

然后根据自己的shell设置好

一般在 `~/.profile` 或者 `~/.bashrc` 我是zsh 就在 `~/.zshrc`

    export PATH="~/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"

然后 使配置生效 (后面的文件名根据你自己的shell改):

    source ~/.bashrc

安装python

    pyenv install 3.6.2

我使用的是screen运行，这样就算终端断掉 也可以继续监控

    screen -S online_mon

然后使用3.6.2版本的python

    pyenv shell 3.6.2

安装依赖包

    pip install requests
    pip install BeautifulSoup4

运行  
这里的xxx.py就是脚本的名字

    python xxx.py

然后？ 然后就是等了。。