---
title: "mjj折腾常用脚本"
categories: [ "linux","工具" ]
tags: [  ]
draft: false
slug: "mjj折腾常用脚本-mjj-zhe-teng-chang-yong-jiao-ben"
date: "2022-04-21 08:26:00"
---




# 性能测试
```shell
curl -sL yabs.sh | bash
wget -qO- bench.sh | bash
```
# 三网测试
```shell
bash <(curl -Lso- https://git.io/Jlkmw)
```

# 回程路由测速
```shell
curl https://raw.githubusercontent.com/zhucaidan/mtr_trace/main/mtr_trace.sh|bash
 ```
 
# 更改时区
 
 ```shell
 sudo cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime  
 ```

# Docker安装
```shell
sudo curl -sSL https://get.docker.com/ | sh 
```

# SpeedTest面板部署
```shell
docker run -d -p 8888:80 -e MAX_LOG_COUNT=100 -e IP_SERVICE=ip.sb -it badapple9/speedtest-x
```

# bbr安装
```shell
wget -N --no-check-certificate -c -t3 -T60 -O ss-plugins.sh https://git.io/fjlbl
chmod +x ss-plugins.sh
./ss-plugins.sh
```

# 路由追踪
```shell
apt install -y traceroute
wget https://github.com/zu1k/nali/releases/download/v0.3.9/nali-linux-amd64-v0.3.9.gz
#https://github.com/zu1k/nali/releases/download/v0.3.9/nali-linux-armv8-v0.3.9.gz
gunzip nali-*.gz
mv nali-* /bin/nali
chmod +x /bin/nali

traceroute 1.1.1.1|nali

traceroute 2001:4860:4860::8888|nali
```
