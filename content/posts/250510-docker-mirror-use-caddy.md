+++
title = '用Caddy搭建Docker加速服务'
date = 2025-05-10T00:06:24+08:00
draft = false
categories = [ "linux","工具" ]
tags = [ "linux", "docker", "caddy" ]
slug = "用Caddy搭建Docker加速服务"
+++


```shell

# Edit this domain to yours
DOMAIN="example.com"

cat << EOF > /etc/caddy/Caddyfile
hub.docker.${DOMAIN} {
  encode gzip
  reverse_proxy * https://registry-1.docker.io {
    header_up Host registry-1.docker.io
    header_up X-Real-IP {http.request.remote.host}
    header_up X-Forwarded-For {http.request.remote.host}
    header_up X-Forwarded-Port {http.request.port}
    header_up X-Forwarded-Proto {http.request.scheme}
    header_down Set-Cookie registry-1.docker.io docker.${DOMAIN}
    header_down Www-Authenticate "Bearer realm=\"https://auth.docker.${DOMAIN}/token\",service=\"registry.docker.io\""
    header_down Location "https://production.cloudflare.docker.com" "https://production.cloudflare.docker.${DOMAIN}"
  }
}

auth.docker.${DOMAIN} {
  encode gzip
  reverse_proxy * https://auth.docker.io {
    header_up Host auth.docker.io
    header_up X-Real-IP {http.request.remote.host}
    header_up X-Forwarded-For {http.request.remote.host}
    header_up X-Forwarded-Port {http.request.port}
    header_up X-Forwarded-Proto {http.request.scheme}
    header_down Set-Cookie auth.docker.io docker.${DOMAIN}
  }
}

production.cloudflare.docker.${DOMAIN} {
  encode gzip
  reverse_proxy * https://production.cloudflare.docker.com {
    header_up Host production.cloudflare.docker.com
    header_up X-Real-IP {http.request.remote.host}
    header_up X-Forwarded-For {http.request.remote.host}
    header_up X-Forwarded-Port {http.request.port}
    header_up X-Forwarded-Proto {http.request.scheme}
    header_down Set-Cookie production.cloudflare.docker.com docker.${DOMAIN}
  }
}

hub.quay.${DOMAIN} {
  encode gzip
  reverse_proxy * https://quay.io {
    header_up Host quay.io
    header_up X-Real-IP {http.request.remote.host}
    header_up X-Forwarded-For {http.request.remote.host}
    header_up X-Forwarded-Port {http.request.port}
    header_up X-Forwarded-Proto {http.request.scheme}
    header_down Set-Cookie quay.io quay.${DOMAIN}
    header_down Www-Authenticate "Bearer realm=\"https://hub.quay.${DOMAIN}/v2/auth\",service=\"quay.io\""
  }
}

hub.gcr.${DOMAIN} {
  encode gzip
  reverse_proxy * https://gcr.io {
    header_up Host gcr.io
    header_up X-Real-IP {http.request.remote.host}
    header_up X-Forwarded-For {http.request.remote.host}
    header_up X-Forwarded-Port {http.request.port}
    header_up X-Forwarded-Proto {http.request.scheme}
    header_down Set-Cookie k8s.gcr.io gcr.${DOMAIN}
    header_down Www-Authenticate "Bearer realm=\"https://hub.gcr.${DOMAIN}/v2/token\",service=\"gcr.io\""
  }
}

hub.k8s.${DOMAIN} {
  encode gzip
  reverse_proxy * https://k8s.gcr.io {
    header_up Host k8s.gcr.io
    header_up X-Real-IP {http.request.remote.host}
    header_up X-Forwarded-For {http.request.remote.host}
    header_up X-Forwarded-Port {http.request.port}
    header_up X-Forwarded-Proto {http.request.scheme}
    header_down Set-Cookie k8s.gcr.io gcr.${DOMAIN}
    header_down Www-Authenticate "Bearer realm=\"https://hub.k8s.${DOMAIN}/v2/token\",service=\"k8s.gcr.io\""
    header_down Location "https://storage.googleapis.com" "https://storage.googleapis.${DOMAIN}"
  }
}

storage.googleapis.${DOMAIN} {
  encode gzip
  reverse_proxy * https://storage.googleapis.com {
    header_up Host storage.googleapis.com
    header_up X-Real-IP {http.request.remote.host}
    header_up X-Forwarded-For {http.request.remote.host}
    header_up X-Forwarded-Port {http.request.port}
    header_up X-Forwarded-Proto {http.request.scheme}
    header_down Set-Cookie storage.googleapis.com storage.googleapis.${DOMAIN}
  }
}
EOF

systemctl restart caddy
```