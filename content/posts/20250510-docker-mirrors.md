+++
title = '自建Docker镜像加速服务 mirrors'
date = 2025-05-10T12:46:35+08:00
draft = false
categories = [ "linux","工具" ]
tags = [ "linux", "docker", "caddy" ]
slug = "自建Docker镜像加速服务"
+++

> 使用docker compose部署，就俩文件配置好就可以用了

## 部署镜像仓库代理

### （1）创建账号密码【可选】
配置账号密码：设置密码认证后，我们在进行拉取镜像时就需要先 docker login登入到我们的自建的代理镜像仓库，然后才可以拉取镜像

注意：执行htpasswd命令时，请把username和password修改为你自己的账号和密码


```shell
[root@proxy ~]# mkdir -p /opt/registry-proxy &&  cd $_
[root@proxy registry-proxy]# htpasswd -Bbn username password >  ./htpasswd
```

### （2）添加docker-compose.yml文件

> 如果你要开启Proxy认证的话请把 `#- ./htpasswd:/auth/htpasswd` 注释取消掉

```shell
[root@proxy ~]# mkdir -p /opt/registry-proxy &&  cd $_
[root@proxy registry-proxy]# vi docker-compose.yaml
services:
  ## docker hub
  dockerhub:
    container_name: reg-docker-hub
    image: dqzboy/registry:latest
    restart: always
    environment:
      - OTEL_TRACES_EXPORTER=none
      # 如果需要配置代理，请把下面的注释去掉，并配置你的代理地址
      #- http_proxy=http://host:port
      #- https_proxy=http://host:port
    volumes:
      - ./registry/data:/var/lib/registry
      - ./registry-hub.yml:/etc/distribution/config.yml
      #- ./htpasswd:/auth/htpasswd
    ports:
      - 51000:5000
    networks:
      - registry-net
  ## UI
  registry-ui:
    container_name: registry-ui
    image: dqzboy/docker-registry-ui:latest
    environment:
      # UI所关联的REGISTRY容器服务地址
      - DOCKER_REGISTRY_URL=http://reg-docker-hub:5000
      # [必须]使用 openssl rand -hex 16 生成唯一值
      - SECRET_KEY_BASE=9f18244a1e1179fa5aa4a06a335d01b2
      # 启用Image TAG 的删除按钮
      - ENABLE_DELETE_IMAGES=true
      - NO_SSL_VERIFICATION=true
    restart: always
    ports:
      - 50000:8080
    networks:
      - registry-net
 
networks:
  registry-net:
```

### （3）添加config.yml文件

> 注意：每个容器挂载对应的config.yml，这里名称需要与上面compose.yml文件定义的挂载的名称保持一致（例如上面挂载的配配置文件名称为registry-hub.yml）；下面只是其中一个示例配置，其他的配置也一样，只需要更改 remoteurl 代理的地址即可！

> 如果你上面开启了密码认证，那么下面配置中auth块的内容需要把注释取消掉！！！

```shell

[root@proxy registry-proxy]# vim registry-hub.yml
version: 0.1
log:
  fields:
    service: registry
storage:
  filesystem:
    rootdirectory: /var/lib/registry
  delete:
    enabled: true
  cache:
    blobdescriptor: inmemory   
    blobdescriptorsize: 10000
  maintenance:
    uploadpurging:
      enabled: true
      age: 168h
      interval: 24h
      dryrun: false
    readonly:
      enabled: false
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
    Access-Control-Allow-Origin: ['*']
    Access-Control-Allow-Methods: ['HEAD', 'GET', 'OPTIONS', 'DELETE']
    Access-Control-Allow-Headers: ['Authorization', 'Accept', 'Cache-Control']
    Access-Control-Max-Age: [1728000]
    Access-Control-Allow-Credentials: [true]
    Access-Control-Expose-Headers: ['Docker-Content-Digest']
 
#auth:
#  htpasswd:
#    realm: basic-realm
#    path: /auth/htpasswd
 
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
 
proxy:
  remoteurl: https://registry-1.docker.io
  username: 
  password:
  ttl: 168h
```


### （4）启动容器服务

```shell
[root@proxy registry-proxy]# docker compose up -d
 
# 检查启动容器状态
[root@proxy registry-proxy]# docker ps

```

### （5）修改docker配置

> 在docker的daemon.json配置文件中添加上docker.io的代理域名，然后重启docker程序


```shell
[root@BJ-Cloud ~]# vim /etc/docker/daemon.json
{
    "registry-mirrors": ["https://hub.your_domain_name"],
    "log-opts": {
      "max-size": "100m",
      "max-file": "5"
    }
}
 
#重启docker
systemctl restart docker
```