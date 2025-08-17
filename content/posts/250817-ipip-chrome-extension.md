---
title: "IPIP 网站 IP 信息查询 Chrome插件 Manifest V3版本升级指南"
categories: ["chrome", "extension", "web-development"]
tags: ["ip", "website", "manifest-v3", "chrome-extension", "migration"]
draft: false
slug: "ipip-chrome-extension-manifest-v3-migration"
date: "2025-08-17 03:00:00"
---

## 前言

随着Chrome浏览器对Manifest V3的强制要求，许多基于Manifest V2的Chrome扩展都面临着升级的挑战。本文将详细介绍如何将IPIP网站IP信息查询Chrome插件从Manifest V2升级到V3版本，包括遇到的问题、解决方案以及最佳实践。

## 项目背景

IPIP网站IP信息查询插件是一个专业的网络工具，主要功能包括：

- 🌍 自动显示当前网站的真实服务器IP地址
- 🏳️ 在扩展图标上显示对应国家旗帜
- 📊 提供详细的IP地理位置信息（国家、省份、城市）
- 🖱️ 支持右键菜单快速查询选中的IP地址
- 🌐 多语言支持（中文/英文）

## Manifest V3 主要变更

### 1. 基础配置变更

#### manifest.json 核心修改

```json
{
  "manifest_version": 3,  // V2 → V3
  "action": {             // browser_action → action
    "default_icon": {
      "19": "images/icon_19.png",
      "38": "images/icon_38.png"
    },
    "default_title": "WebSite IP Information query Powered by IPIP.net",
    "default_popup": "popup.html"
  },
  "background": {
    "service_worker": "js/background.js"  // scripts → service_worker
  },
  "permissions": [
    "contextMenus",
    "activeTab", 
    "storage",
    "tabs",
    "webRequest"
  ],
  "host_permissions": [    // 新增独立的主机权限声明
    "http://*/*",
    "https://*/*"
  ]
}
```

#### 关键变更点

1. **manifest_version**: `2` → `3`
2. **browser_action** → **action**: 统一的操作API
3. **background.scripts** → **background.service_worker**: 使用Service Worker
4. **权限分离**: 将主机权限独立到 `host_permissions`

### 2. Background Script 重构

#### Service Worker 适配

Manifest V3最大的变化是将Background Page改为Service Worker，这带来了以下挑战：

```javascript
// V2 中的 XMLHttpRequest
var xhr = new XMLHttpRequest();
xhr.open("GET", url, true);
xhr.send();

// V3 中使用 fetch API
var ajaxGet = async function(url, callback) {
    try {
        const response = await fetch(url);
        if (!response.ok) {
            callback({ ret: -1, msg: "Network Error" });
            return;
        }
        const resp = await response.json();
        callback(resp);
    } catch (e) {
        callback({ ret: 100, msg: "Server Response Error" });
    }
};
```

#### API 更新

```javascript
// V2 API
chrome.browserAction.setTitle({title: "..."});
chrome.browserAction.setIcon({path: "..."});
chrome.browserAction.enable(tabId);

// V3 API  
chrome.action.setTitle({title: "..."});
chrome.action.setIcon({path: chrome.runtime.getURL("...")});
chrome.action.enable(tabId);
```

#### 图标路径修复

在Service Worker中，相对路径需要使用 `chrome.runtime.getURL()` 转换：

```javascript
// V2 中的相对路径
chrome.browserAction.setIcon({path: "icons/CN.png"});

// V3 中需要绝对路径
chrome.action.setIcon({
    path: chrome.runtime.getURL("icons/CN.png")
});
```

### 3. 核心功能保持 - webRequest API

#### 重要发现

经过深入研究Chrome官方文档，我们发现：

- ✅ **webRequest API在V3中仍然可用**
- ✅ **可以观察和分析网络请求**  
- ✅ **可以获取真实的IP地址** (`details.ip`)
- ❌ **不能使用blocking模式**（除非是企业策略安装的扩展）

#### 正确的实现方式

```javascript
// V3中使用webRequest API（只观察模式，不阻塞）
chrome.webRequest.onCompleted.addListener(function(details) {
    if (details.ip && details.tabId >= 0) {
        var domain = new URL(details.url).hostname;
        tabsDomainMap[details.tabId] = domain;
        tabsIPMap[details.tabId] = details.ip;

        // 使用真实IP查询地理位置信息
        const apiUrl = "https://clientapi.ipip.net/browser/chrome?ip=" + 
                      details.ip + '&l=' + navigator.language + '&domain=' + domain;
        
        ajaxGet(apiUrl, function(info){
            if (info.ret == 0) {
                ipData[details.ip] = info.data;
                dnsData[details.ip] = info.dns;
                renderIcon(info.data);
                chrome.action.enable(details.tabId);
            }
        });
    }
}, {
    urls: ["http://*/*", "https://*/*"],
    types: ["main_frame"]
});
```

### 4. Popup 脚本适配

#### 消息传递机制

V3中移除了直接访问background页面的能力，需要使用消息传递：

```javascript
// V2 中直接访问
var background = chrome.extension.getBackgroundPage();
var ipData = background.ipData[ip];

// V3 中使用消息传递
chrome.runtime.sendMessage({action: 'getIPData', ip: ip}, function(response) {
    if (response && response.ipData) {
        render(response.ipData);
    }
});
```

#### Background 消息处理

```javascript
chrome.runtime.onMessage.addListener(function(request, sender, sendResponse){
    if (request.action === 'getIPData') {
        sendResponse({
            ipData: ipData[request.ip],
            dnsData: dnsData[request.ip]
        });
        return true;
    }
    // ... 其他消息处理
});
```

### 5. Context Menu 优化

#### 重复创建问题修复

```javascript
// 避免重复创建contextMenu
chrome.runtime.onStartup.addListener(createContextMenu);
chrome.runtime.onInstalled.addListener(createContextMenu);

function createContextMenu() {
    chrome.contextMenus.removeAll(() => {
        chrome.contextMenus.create({
            id: "ipip",
            contexts: ["selection"],
            title: "使用IPIP.NET搜索 \"%s\""
        });
    });
}

// V3中使用onClicked事件监听器
chrome.contextMenus.onClicked.addListener(function(info, tab) {
    if (info.menuItemId === "ipip") {
        getSelection(info, tab);
    }
});
```

## 遇到的主要问题及解决方案

### 1. 内容安全策略(CSP)错误

**问题**: 外部脚本加载被阻止
```
Refused to load the script 'https://ajs.ipip.net/chrome.js' because it violates the following Content Security Policy directive
```

**解决方案**: 移除外部脚本加载
```javascript
// 移除这行代码
// $.getScript('https://ajs.ipip.net/chrome.js');
```

### 2. Service Worker 图标路径问题

**问题**: 
```
Uncaught (in promise) Error: Failed to set icon 'images/icon_gray_38.png': Failed to fetch
```

**解决方案**: 使用绝对路径
```javascript
chrome.action.setIcon({
    path: chrome.runtime.getURL("images/icon_gray_38.png")
});
```

### 3. ContextMenu 重复创建错误

**问题**:
```
Unchecked runtime.lastError: Cannot create item with duplicate id ipip
```

**解决方案**: 创建前先清理
```javascript
chrome.contextMenus.removeAll(() => {
    // 然后创建新的菜单项
});
```

## Chrome商店发布注意事项

### 权限审核说明

由于使用了广泛的主机权限，需要向Chrome商店提供详细的权限使用说明：

#### webRequest + 所有网站权限
- **技术原因**: 必须监听所有网站的网络请求才能获取真实服务器IP
- **无法替代**: activeTab权限无法提供网络请求详情
- **安全保证**: 仅观察模式，不修改或阻塞任何请求

#### 单一用途说明
```
本扩展专门用于查询和显示网站的IP地理位置信息，帮助用户了解所访问网站的服务器位置。
所有功能都围绕IP地理位置查询这一核心目的，不包含其他无关功能。
```

## 性能优化

### 1. 调试日志系统

为了便于问题排查，添加了详细的调试日志：

```javascript
console.log('🚀 IPIP Extension Service Worker 启动');
console.log('📡 发起API请求:', url);
console.log('🌐 WebRequest完成:', details.url, 'IP:', details.ip);
console.log('🎨 渲染图标，IP信息:', info);
```

### 2. 数据缓存机制

```javascript
// 缓存IP数据，避免重复查询
var ipData = {};
var dnsData = {};
var tabsIPMap = {};
var tabsDomainMap = {};
```

## 总结

Manifest V3的升级虽然带来了挑战，但也提供了更好的安全性和性能。关键要点：

1. **Service Worker适配**: 使用fetch替代XMLHttpRequest
2. **API更新**: browserAction → action
3. **权限分离**: host_permissions独立声明
4. **消息传递**: 替代直接访问background页面
5. **路径处理**: Service Worker中使用绝对路径
6. **webRequest保留**: 核心IP获取功能得以保持

通过这次升级，我们不仅保持了原有的所有功能，还提升了扩展的安全性和稳定性。希望这个升级指南能帮助其他开发者顺利完成Manifest V3的迁移。

## 参考资源

- [Chrome Extensions Manifest V3](https://developer.chrome.com/docs/extensions/mv3/intro/)
- [Migrating to Manifest V3](https://developer.chrome.com/docs/extensions/migrating/)
- [webRequest API Documentation](https://developer.chrome.com/docs/extensions/reference/webRequest/)
- [项目源码](https://github.com/luodaoyi/ChromeIpAddress)
- [商店发布的Manifest V3新版本](https://chromewebstore.google.com/detail/kieokbjcmnpjmnmingdapalnjbmifccc)

---

*本文基于实际项目升级经验编写，如有问题欢迎交流讨论。*
