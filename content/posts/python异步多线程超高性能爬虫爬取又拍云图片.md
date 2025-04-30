---
title: "python异步多线程超高性能爬虫爬取又拍云图片"
categories: [ "python" ]
tags: [ "python" ]
draft: false
slug: "python异步多线程超高性能爬虫爬取又拍云图片-python异步多线程超高性能爬虫爬取又拍云图片"
date: "2017-09-06 06:40:30"
---



## 前言

最近有个奇葩需求：  
`要把又拍云所有的图片全都下载下来 大约10T 3亿张左右`  
联系又拍云 能否邮寄硬盘直接拷贝，答曰不行。。但是给了个下载的python脚本  
[download\_file\_with_iter.py][1]  
我怀着感激的心情下载下来，结果一秒不到3张。。实在是慢，于是乎打算自己写一个

## 版本1

这是刚做的时候的版本，直接使用aio的队列，  
环境：python3.6.2  
所需包:

  1. `pip install asyncio`
  2. `pip install aiohttp`
  3. `pip install aiofiles`

```python
    import asyncio
    import base64
    import os
    import urllib
    import aiohttp
    import aiofiles
    # -----------------------
    # -----------------------
    bucket = "bucket_name" #这里就是空间名称
    username = "username" #操作员账号
    password = "password" #操作员密码
    #空间外联地址 因为又拍云的http下载没有频率限制，所以使用http下载 不适用restful的api接口下载
    hostname = "http://xxxxx"
    # 这里是本地保存的根路径 这样下载后路径地址就跟空间内的地址是相对的了
    base_save_path = "f:"
    # -----------------------
    headers = {}
    auth = base64.b64encode(f"{username}:{password}".encode(encoding="utf-8"))
    headers["Authorization"] = "Basic " + str(auth) #又拍云认证header头
    headers["User-Agent"] = "UPYUN_DOWNLOAD_SCRIPT"
    headers["x-list-limit"] = "300"
    thread_sleep = 1
    def is_dic(url):
        """判断key是否是目录 根据是否有后缀名判断"""
        # print(f"判断url：{url}")
        url = url.replace("http://v0.api.upyun.com/", "")
        if len(url.split(".")) == 1:
            return True
        else:
            return False
    class Crawler:
        def __init__(self, init_key, hostname, max_tasks=10, pic_tsak=50):
            """初始化爬虫"""
            self.loop = asyncio.get_event_loop()
            self.max_tries = 4  # 每个图片重试册数
            self.max_tasks = max_tasks  # 接口请求进程数
            self.key_queue = asyncio.Queue(loop=self.loop)  # 接口队列
            self.pic_queue = asyncio.Queue(loop=self.loop)  # 图片队列
            self.session = aiohttp.ClientSession(loop=self.loop)  # 接口异步http请求
            self.key_queue.put_nowait(
                {"key": init_key, "x-list-iter": None, "hostname": hostname})  # 初始化接口队列 push需要下载的目录
            self.pic_tsak = pic_tsak  # 图片下载队列
        def close(self):
            """回收http session"""
            self.session.close()
        async def work(self):
            """接口请求队列消费者"""
            try:
                while True:
                    url = await self.key_queue.get()
                    # print("key队列数量:" + await self.key_queue.qsize())
                    await self.handle(url)
                    self.key_queue.task_done()
                    await asyncio.sleep(thread_sleep)
            except asyncio.CancelledError:
                pass
        async def work_pic(self):
            """图片请求队列消费者"""
            try:
                while True:
                    url = await self.pic_queue.get()
                    await self.handle_pic(url)
                    self.pic_queue.task_done()
                    await asyncio.sleep(thread_sleep)
            except asyncio.CancelledError:
                pass
        async def handle_pic(self, key):
            """处理图片请求"""
            url = (lambda x: x[0] == "/" and x or "/" + x)(key["key"])
            url = url.encode("utf-8")
            url = urllib.parse.quote(url)
            pic_url = key["hostname"] + url + "!s400"
            tries = 0
            while tries < self.max_tries:
                try:
                    print(f"请求图片:{pic_url}")
                    async with self.session.get(pic_url, timeout=60) as response:
                        async with aiofiles.open(key["save_path"], "wb") as f:
                            # print("保存文件:{}".format(key["save_path"]))
                            await f.write(await response.read())
                    break
                except aiohttp.ClientError:
                    pass
                tries += 1
        async def handle(self, key):
            """处理接口请求"""
            url = "/" + bucket + \
                (lambda x: x[0] == "/" and x or "/" + x)(key["key"])
            url = url.encode("utf-8")
            url = urllib.parse.quote(url)
            if key["x-list-iter"] is not None:
                if key["x-list-iter"] is not None or not "g2gCZAAEbmV4dGQAA2VvZg":
                    headers["X-List-Iter"] = key["x-list-iter"]
            tries = 0
            while tries < self.max_tries:
                try:
                    reque_url = "http://v0.api.upyun.com" + url
                    print(f"请求接口:{reque_url}")
                    async with self.session.get(reque_url, headers=headers, timeout=60) as response:
                        content = await response.text()
                        try:
                            iter_header = response.headers.get("x-upyun-list-iter")
                        except:
                            iter_header = "g2gCZAAEbmV4dGQAA2VvZg"
                        list_json_param = content + "`" + \
                            str(response.status) + "`" + str(iter_header)
                        await self.do_file(self.get_list(list_json_param), key["key"], key["hostname"])
                    break
                except aiohttp.ClientError:
                    pass
                tries += 1
        def get_list(self, content):
            # print(content)
            if content:
                content = content.split("`")
                items = content[0].split("\n")
                content = [dict(zip(["name", "type", "size", "time"], x.split("\t"))) for x in items] + content[1].split() + \
                    content[2].split()
                return content
            else:
                return None
        async def do_file(self, list_json, key, hostname):
            """处理接口数据"""
            for i in list_json[:-2]:
                if not i["name"]:
                    continue
                new_key = key + i["name"] if key == "/" else key + "/" + i["name"]
                try:
                    if i["type"] == "F":
                        self.key_queue.put_nowait(
                            {"key": new_key, "x-list-iter": None, "hostname": hostname})
                    else:
                        try:
                            if not os.path.exists(bucket + key):
                                os.makedirs(bucket + key)
                        except OSError as e:
                            print("新建文件夹错误:" + str(e))
                        save_path = base_save_path + "/" + bucket + new_key
                        if not os.path.isfile(save_path):
                            self.pic_queue.put_nowait(
                                {"key": new_key, "save_path": save_path, "x-list-iter": None, "hostname": hostname})
                        else:
                            print(f"文件已存在:{save_path}")
                except Exception as e:
                    print("下载文件错误！:" + str(e))
                    async with aiofiles.open("download_err.txt", "a") as f:
                        await f.write(new_key + "\n")
            if list_json[-1] != "g2gCZAAEbmV4dGQAA2VvZg":
                self.key_queue.put_nowait({"key": key, "x-list-iter": list_json[-1], "hostname": hostname})
        async def run(self):
            """初始化任务进程"""
            workers = [asyncio.Task(self.work(), loop=self.loop)
                       for _ in range(self.max_tasks)]
            workers_pic = [asyncio.Task(self.work_pic(), loop=self.loop)
                           for _ in range(self.pic_tsak)]
            await self.key_queue.join()
            await self.pic_queue.join()
            workers.append(workers_pic)
            for w in workers:
                w.cancel()
    if __name__ == "__main__":
        loop = asyncio.get_event_loop()
        crawler = Crawler("/", hostname, max_tasks=5, pic_tsak=150)
        loop.run_until_complete(crawler.run())
        crawler.close()
        loop.close()
```

上面的爬虫 ，速度可达到400张/S 但是 接下来的问题。。

# 版本2

    本来上面的脚本已经爽的不行了。基本上已经可以跑满带宽了，但是有个新的问题。
    用来放图片的硬盘单个只有4T 但是有一个又拍云的空间大小已经达到了7T 也就是说要两个同时下载，于是乎就用上了MQ
    目录爬虫-爬取所有目录放到mq中:
    
```python

    import aiohttp
    import asyncio
    import urllib
    import aiofiles
    import asynqp
    import os
    base_save_path = "f"
    mq_host = "192.168.199.13"
    mq_user = "admin"
    mq_password = "123123"
    bucket = "bucket_name"
    hostname = "http://xxxxxx"
    username = "username"
    password = "password"
    auth = base64.b64encode(f"{username}:{password}".encode(encoding="utf-8"))
    headers = {}
    headers["Authorization"] = "Basic " + str(auth)
    headers["User-Agent"] = "UPYUN_DOWNLOAD_SCRIPT"
    headers["x-list-limit"] = "300"
    class Spider:
        def __init__(self, max_task=10, max_tried=4):
            print(f"新建spider! 线程数：{max_task} 每次最多重试次数: {max_tried}")
            self.loop = asyncio.get_event_loop()
            self.max_tries = max_tried
            self.max_task = max_task
            self.session = aiohttp.ClientSession(loop=self.loop)
        def close(self):
            """回收http session"""
            self.session.close()
        async def download_work(self):
            try:
                while True:
                    received_message = await self.queue.get()
                    if received_message is None:
                        await asyncio.sleep(1)
                        continue
                    msg_json = received_message.json()
                    await self.handle(msg_json)
                    received_message.ack()
                    await asyncio.sleep(500) #爬太快了消费不了 加了很久的延迟
            except asyncio.CancelledError:
                pass
        async def handle(self, key):
            """处理接口请求"""
            url = "/" + key["bucket"] + \
                (lambda x: x[0] == "/" and x or "/" + x)(key["key"])
            url = url.encode("utf-8")
            url = urllib.parse.quote(url)
            if key["x-list-iter"] is not None:
                if key["x-list-iter"] is not None or not "g2gCZAAEbmV4dGQAA2VvZg":
                    headers["X-List-Iter"] = key["x-list-iter"]
            tries = 0
            while tries < self.max_tries:
                try:
                    reque_url = "http://v0.api.upyun.com" + url
                    print(f"请求接口:{reque_url}")
                    async with self.session.get(reque_url, headers=headers, timeout=60) as response:
                        content = await response.text()
                        try:
                            iter_header = response.headers.get("x-upyun-list-iter")
                        except:
                            iter_header = "g2gCZAAEbmV4dGQAA2VvZg"
                        list_json_param = content + "`" + \
                            str(response.status) + "`" + str(iter_header)
                        await self.do_file(self.get_list(list_json_param), key["key"], key["hostname"], key["bucket"])
                    break
                except aiohttp.ClientError:
                    pass
                tries += 1
        def get_list(self, content):
            # print(content)
            if content:
                content = content.split("`")
                items = content[0].split("\n")
                content = [dict(zip(["name", "type", "size", "time"], x.split("\t"))) for x in items] + content[1].split() + \
                    content[2].split()
                return content
            else:
                return None
        async def do_file(self, list_json, key, hostname, bucket):
            """处理接口数据"""
            for i in list_json[:-2]:
                if not i["name"]:
                    continue
                new_key = key + i["name"] if key == "/" else key + "/" + i["name"]
                try:
                    if i["type"] == "F":
                        await self.put_key_queue({"key": new_key, "x-list-iter": None, "hostname": hostname, "bucket": bucket})
                        # self.key_queue.put_nowait(
                        #     {"key": new_key, "x-list-iter": None, "hostname": hostname, "bucket": bucket})
                    else:
                        save_path = "/" + bucket + new_key
                        if not os.path.isfile(base_save_path + save_path):
                            await self.put_pic_queue({"key": new_key, "save_path": save_path, "x-list-iter": None, "hostname": hostname, "bucket": bucket})
                        #else:
                        #    print(f"文件已存在:{base_save_path}{save_path}")
                except Exception as e:
                    print("下载文件错误！:" + str(e))
                    async with aiofiles.open("download_err.txt", "a") as f:
                        await f.write(new_key + "\n")
            if list_json[-1] != "g2gCZAAEbmV4dGQAA2VvZg":
                # self.key_queue.put_nowait(
                #     {"key": key, "x-list-iter": list_json[-1], "hostname": hostname, "bucket": bucket})
                await self.put_key_queue({"key": key, "x-list-iter": list_json[-1], "hostname": hostname, "bucket": bucket})
        async def put_key_queue(self, obj):
            msg = asynqp.Message(obj)
            self.exchange.publish(msg, f"{bucket}.routing.key.key")
        async def put_pic_queue(self, obj):
            msg = asynqp.Message(obj)
            self.pic_exchange.publish(msg, "routing.pic.key")
        async def run(self):
            self.connection = await asynqp.connect(host=mq_host, username=mq_user, password=mq_password)
            self.channel = await self.connection.open_channel()
            self.exchange = await self.channel.declare_exchange("key.exchange", "direct")
            self.queue = await self.channel.declare_queue(f"{bucket}.key.queue", durable=True)
            await self.queue.bind(self.exchange, f"{bucket}.routing.key.key")
            self.channel_pic = await self.connection.open_channel()
            self.pic_exchange = await self.channel_pic.declare_exchange("pic.exchange", "direct")
            self.pic_queue = await self.channel_pic.declare_queue("pic.queue", durable=True)
            await self.pic_queue.bind(self.pic_exchange, "routing.pic.key")
            # 这里新的空间才需要爬取根目录
            # await self.put_key_queue({"key": "/", "x-list-iter": None,"hostname": hostname, "bucket": bucket})
            for _ in range(self.max_task):
                asyncio.ensure_future(self.download_work())
            await asyncio.sleep(2.0)
    if __name__ == "__main__":
        loop = asyncio.get_event_loop()
        spider = Spider(max_task=10)
        # asyncio.ensure_future(spider.run())
        loop.run_until_complete(spider.run())
        loop.run_forever()
        # print(f"Pending tasks at exit:{asyncio.Task.all_tasks(loop)}")
        spider.close()
        loop.close()
```    

下面是下载服务，可以断点续传，多个机器同时下载：

```python
    import asyncio
    import urllib
    import os
    import asynqp
    import aiofiles
    import aiohttp
    import time
    class Spider:
        def __init__(self, base_save_path, max_tried=4, mq_host="192.168.199.13", mq_user="admin", mq_password="123123"):
            self.loop = asyncio.get_event_loop()
            self.max_tries = max_tried
            self.session = aiohttp.ClientSession(loop=self.loop)
            self.mq_host = mq_host
            self.mq_user = mq_user
            self.mq_password = mq_password
            self.base_save_path = base_save_path
        def __del__(self):
            print("进程完成!,关闭aiohttp.session 和mq连接")
            self.session.close()
        async def download_work(self):
            print(f"创建mq连接")
            self.connection = await asynqp.connect(host=self.mq_host, username=self.mq_user, password=self.mq_password)
            self.channel = await self.connection.open_channel()
            self.exchange = await self.channel.declare_exchange("pic.exchange", "direct")
            self.queue = await self.channel.declare_queue("pic.queue", durable=True)
            await self.queue.bind(self.exchange, "routing.pic.key")
            print("连接成功！，建立队列通道")
            try:
                for _ in range(10000):
                    try:
                        received_message = await self.queue.get()
                        if received_message is None:
                            await asyncio.sleep(1)
                            continue
                        msg_json = received_message.json()
                        await self.handle_pic(msg_json)
                    except Exception:
                        async with aiofiles.open("download_error.txt", "a") as f:
                            await f.write(msg_json["hostname"] + msg_json["key"] + "\n")
                    finally:
                        received_message.ack()
                        await asyncio.sleep(0.01)
                        del received_message, msg_json  # 释放变量
            except asyncio.CancelledError:  # 进程退出
                pass
        async def handle_pic(self, key):
            """处理图片请求"""
            url = (lambda x: x[0] == "/" and x or "/" + x)(key["key"])
            url = url.encode("utf-8")
            url = urllib.parse.quote(url)
            pic_url = key["hostname"] + url + "!s400"
            # del url  # 释放变量
            tries = 0
            while tries < self.max_tries:
                try:
                    # print(f"请求图片:{pic_url}")
                    async with self.session.get(pic_url, timeout=60) as response:
                        save_path = self.base_save_path + key["save_path"]
                        dir_name = os.path.dirname(save_path)
                        # print(f"文件夹路径：{dir_name}")
                        try:
                            if not os.path.exists(dir_name):
                                os.makedirs(dir_name)
                        except OSError as e:
                            print("新建文件夹错误:" + str(e))
                        if os.path.isfile(save_path):
                            break
                        async with aiofiles.open(save_path, "wb") as f:
                            print(f"保存文件:{save_path}")
                            await f.write(await response.read())
                            del save_path, dir_name
                    break
                except aiohttp.ClientError:
                    pass
                tries += 1
            del url, pic_url  # 释放变量
    def restart_program():
        import sys
        import os
        python = sys.executable
        os.execl(python, python, * sys.argv)
    def main():
        base_path = "/Users/luoda/Documents/project/pic_downloader"
        thread_count = 2
        loop = asyncio.get_event_loop()
        spider = Spider(base_path)
        works = []
        for _ in range(int(thread_count)):
            works.append(spider.download_work())
        loop.run_until_complete(asyncio.wait(works))
        print(f"麻痹的执行完了")
        time.sleep(20)
        restart_program()
    if __name__ == "__main__":
        main()
```

# 效果

![WX20170906-144202][2] 

![WX20170906-144225@2x][3] 

![WX20170906-144238@2x][4] 

![WX20170906-144310@2x][5]

 [1]: https://github.com/monkey-wenjun/upyun-sdk-script/blob/master/download_file/download_file_with_iter.py
 [2]: /uploads/oss/2017-09-06-WX20170906-144310@2x.png "WX20170906-144202"
 [3]: /uploads/oss/2017-09-06-WX20170906-144225@2x.png "WX20170906-144225@2x"
 [4]: /uploads/oss/2017-09-06-WX20170906-144238@2x.png "WX20170906-144238@2x"
 [5]: /uploads/oss/2017-09-06-WX20170906-144310@2x.png "WX20170906-144310@2x"