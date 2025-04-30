---
title: "HttpClient缺陷引起的 无法连接到远程服务器 通常每个套接字地址只允许使用一次"
categories: [ "CSharp" ]
tags: [ "asp.net","asp.net mvc","csharp",".net" ]
draft: false
slug: "HttpClient缺陷引起的 无法连接到远程服务器 通常每个套接字地址只允许使用一次-httpclient缺陷引起的无法连接到远程服务器通常每个套接字地址只允许使用一次"
date: "2018-01-08 11:28:00"
---



上周又遇到了坑爹问题，具体表现为 服务端接口全部调用失败。  
排查日志发现，有大量的 错误日志为

    System.Net.Http.HttpRequestException: 发送请求时出错。 ---> System.Net.WebException: 无法连接到远程服务器 ---> System.Net.Sockets.SocketException: 通常每个套接字地址(协议/网络地址/端口)只允许使用一次。 xxxxx.xx:6666
       在 System.Net.Sockets.Socket.EndConnect(IAsyncResult asyncResult)
       在 System.Net.ServicePoint.ConnectSocketInternal(Boolean connectFailure, Socket s4, Socket s6, Socket& socket, IPAddress& address, ConnectSocketState state, IAsyncResult asyncResult, Exception& exception)
       --- 内部异常堆栈跟踪的结尾 ---
       在 System.Net.HttpWebRequest.EndGetRequestStream(IAsyncResult asyncResult, TransportContext& context)
       在 System.Net.Http.HttpClientHandler.GetRequestStreamCallback(IAsyncResult ar)

同时排查服务器在此时间段内有大量的TIME_WAIT连接，是平时的数倍

![][1] 

平时的数据

![][2] 

## IDisposable 和 using语句

我们首先需要看下另外一个面向连接的类 SqlConnection。在第一次接受如何使用 IDisposable 和 using 语句的培训时，绝大多数开发人员看到的都是类似下面这样的例子：

    
    using (var con = new SqlConnection (connectionString)) {
        con.open ();
        //这里使用连接
    } //这里关闭连接

虽然针对这个示例的说明并不完善，但这个模式是正确的，而且多年来很好地服务了开发人员。然而，如果你试图将这个模式应用到另一个 IDisposable 类 HttpClient 上，则会遇到一些始料未及的问题。

具体来说，它会打开许多套接字，比你实际的需求多许多，这极大地增加了服务器的负载。而且，这些套接字实际上不会被 using 语句关闭。相反，它们是在应用程序停止使用它们几分钟之后才会关闭。

## 连接池

回到 SqlConnection 的例子，多数面向连接的资源都会放入连接池。当你“打开”一个数据库连接时，它首先会检查连接池中是否存在未使用的连接。如果找到了，就重用它，而不是创建一个新的连接。

同样，当你“关闭”一个 SqlConnection 连接时，它只是简单地将连接放回连接池。最后，一个单独的进程可以关闭长期未使用的连接，但通常来说，你可以认为它会正确地执行操作，实现性能和服务器负载的平衡

HttpClient 的工作机制并非如此。当你销毁它时，它就启动一个进程，关闭在它控制之下的套接字。也就是说，你下次请求连接时，必须重复整个连接新建过程。如果网络延迟很高，或者连接是受保护的（需要新一轮的 SSL/TLS 协商），就会非常痛苦。

`关闭一个套接字需要花费 4 分钟`

如上所述，关闭套接字的过程并不快。当“关闭”套接字时，你真正做的是将其状态置为 TIME_WAIT。在一个预先配置好的时间窗口内，Windows 将保持该套接字的状态不变，默认情况下是 4 分钟。这是为了防止有任何剩余的数据包仍在传输。

这大大增加了可用套接字耗尽的可能，导致运行时错误，比如“无法连接到远程服务器。System.Net.Sockets.SocketException：每个套接字地址（协议/网络地址/端口）通常只允许使用一次”

## 存在误导的文档

这将我们带回到了文档存在误导的问题。虽然是基本的样本文件，但官方文档 [v118][3] （当前谷歌和必应搜索返回的结果）指出，HttpClient 不支持跨线程共享。

> 该类型的任何公有静态（在 Visual Basic 中为 Shared）成员都是线程安全的，而任何实例成员都不保证线程安全。

差不多就是这样。当然，如果你看一下官方文档 [v110][4]，就会发现下面这段有用的描述。

> HttpClient is intended to be instantiated once and re-used throughout the life of an application. Instantiating an HttpClient class for every request will exhaust the number of sockets available under heavy loads. This will result in SocketException errors. Below is an example using HttpClient correctly.  
> HttpClient 应该只初始化一次，并在应用程序的整个生存期内重用。在负载很高的情况下，为每个请求初始化一个 HttpClient 类会耗尽可用的套接字数量。这会导致 SocketException 错误。下面的例子展示了 HttpClient 的正确用法

    public class GoodController : ApiController
    {
        // OK
        private static readonly HttpClient HttpClient;
        static GoodController ()
        {
            HttpClient = new HttpClient ();
        }
    }

根据这份文档，以下方法是线程安全的。

  1. [CancelPendingRequests][5]
  2. [DeleteAsync][6]
  3. [GetAsync][7]
  4. [GetByteArrayAsync][8]
  5. [GetStreamAsync][9]
  6. [GetStringAsync][10]
  7. [PostAsync][11]
  8. [PutAsync][12]
  9. [SendAsync][13]
    
    这似乎是 MSDN 文档一直存在的问题。要了解任何类的演进过程，都必须检查每个版本的文档，才能了解到新增或删除的重要段落。

## DNS Bug

如果我们遵循目前为止的建议，则会出现其他的问题。 [Ali Kheyrollahi][14]写道：

> 但事实证明，有一个更严重的问题：HttpClient 不遵循 DNS 变化，它会（通过 HttpClientHandler）独占连接，直到套接字关闭。没有时间限制！那么，DNS 什么时候会发生变化呢？每次你进行蓝绿部署的时候（在 Azure 云服务中，当你部署到过渡槽，然后切换生产/过渡槽）；每次你改变 Azure 流量管理器的设置；故障转移场景；许多 PaaS 服务的内部。
> 
> 在被报道出来之前，这种情况已经存在了两年多……我在想，我们到底使用 .NET 构建了怎样的应用程序？
> 
> 现在，如果 DNS 变化的原因是故障转移，则连接应该是出现了某种形式的故障，因此，这时会打开一个到新服务器的连接。但是，如果变化的原因是蓝绿部署，你切换了过渡环境和生产环境，而调用仍然会转到过渡环境——这是我们见过的一种行为，但已经通过重启从属服务器修复，我们认为这可能是 Azure 的一个怪象。我真是个傻瓜——它就在代码里！谁的代码？好吧，起争执了……

这个问题并不是无法修复。理论上讲，HttpClient 会遵循 DNS TTL（生存期）值，默认为 1 小时。每次过期后，HttpClient 会验证该 DNS 记录是否仍然有效，并在必要时新建一个连接指向更新后的 IP 地址。

但是，由于那种情况可能不会出现，所以 Kheyrollahi 为我们提供了一个更简单的变通方案。借助 ServicePointManager，你可以告诉 HttpClient 自动回收连接。


```cs
 var sp = ServicePointManager.FindServicePoint (new Uri (http://foo.bar));
sp.ConnectionLeaseTimeout = 60*1000; // 1 分钟
```


因此，你会希望只在应用程序启动时做这件事，只做一次，并且是针对应用程序将来会访问的所有端点（如果端点是运行时确定的，就需要在发现那个端点时设置那个值）。记住，路径和查询字符串会被忽略，只有主机、端口和模式是重要的。根据场景的不同，可以将该值设为 1 到 5 分钟。

## 解决

直到最后 我们使用了类似的方法解决这个tcp连接数泄漏的问题

    using System;
    using System.Net.Http;
    namespace ConsoleApplication
    {
        public class Program
        {
            private static HttpClient Client = new HttpClient();
            public static async Task Main(string[] args)
            {
                Console.WriteLine("Starting connections");

 [1]: /uploads/oss/2018-01-08-15154112835055.jpg ""
 [2]: /uploads/oss/2018-01-08-15154112997981.jpg ""
 [3]: https://msdn.microsoft.com/zh-cn/library/system.net.http.httpclient(v=vs.118).aspx
 [4]: https://msdn.microsoft.com/zh-cn/library/system.net.http.httpclient(v=vs.110).aspx#%E5%A4%87%E6%B3%A8
 [5]: https://msdn.microsoft.com/en-us/library/system.net.http.httpclient.cancelpendingrequests%28v=vs.110%29.aspx
 [6]: https://msdn.microsoft.com/en-us/library/system.net.http.httpclient.deleteasync%28v=vs.110%29.aspx
 [7]: https://msdn.microsoft.com/en-us/library/system.net.http.httpclient.getasync%28v=vs.110%29.aspx
 [8]: https://msdn.microsoft.com/en-us/library/system.net.http.httpclient.getbytearrayasync%28v=vs.110%29.aspx
 [9]: https://msdn.microsoft.com/en-us/library/system.net.http.httpclient.getstreamasync%28v=vs.110%29.aspx
 [10]: https://msdn.microsoft.com/en-us/library/system.net.http.httpclient.getstringasync%28v=vs.110%29.aspx
 [11]: https://msdn.microsoft.com/en-us/library/system.net.http.httpclient.postasync%28v=vs.110%29.aspx
 [12]: https://msdn.microsoft.com/en-us/library/system.net.http.httpclient.putasync%28v=vs.110%29.aspx
 [13]: https://msdn.microsoft.com/en-us/library/system.net.http.httpclient.sendasync%28v=vs.110%29.aspx
 [14]: http://byterot.blogspot.co.uk/2016/07/singleton-httpclient-dns.html