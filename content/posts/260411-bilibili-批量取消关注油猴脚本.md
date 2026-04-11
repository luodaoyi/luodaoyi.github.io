---
title: "Bilibili 批量取消关注油猴脚本：自动刷新继续下一页"
categories: [ "脚本" ]
tags: [ "Tampermonkey", "Bilibili", "油猴脚本" ]
draft: false
slug: "bilibili-批量取消关注油猴脚本-自动刷新继续下一页"
date: "2026-04-11 21:30:00"
---

最近想把 B 站关注列表快速清理一下，手动一页一页点太慢，所以写了个油猴脚本。

脚本下载：[`bilibili-unfollow-simple-refresh.user.js`](/scripts/bilibili-unfollow-simple-refresh.user.js)


这个版本走的是 **B 站网页接口**，不是模拟鼠标疯狂点按钮，整体会稳一些；同时保留了一个很简单的右下角小面板，方便开始和停止。

它的逻辑也很直接：

1. 读取当前页关注列表
2. 逐个取消关注
3. 当前页处理完后自动刷新页面
4. 刷新后自动继续下一页
5. 如果点了停止，就在当前页处理完之后停下来

## 功能说明

- 支持批量取消当前账号的关注
- 支持自动刷新后继续处理下一页
- 支持失败重试
- 支持基础防频控延时
- 支持跳过互粉 / 跳过悄悄关注（默认关闭）
- 页面右下角会显示一个简单状态面板

## 使用方法

### 1. 安装 Tampermonkey

浏览器先装好 Tampermonkey 扩展。

### 2. 新建脚本

打开 Tampermonkey，新建脚本，把下面整段代码粘进去保存。

### 3. 打开自己的关注页

打开：

```text
https://space.bilibili.com/你的UID/relation/follow
```

登录后页面右下角会出现一个小面板。

### 4. 点击开始

脚本会：

- 处理当前页的关注用户
- 每处理一个等待一小段时间
- 每处理一批会额外休息一下
- 当前页处理完后自动刷新
- 刷新后自动继续下一页

### 5. 点击停止

点击“停止”后，不会立刻中断当前操作，而是会在 **当前页处理完之后停止**。

## 可以改的参数

脚本顶部有一段配置：

```javascript
var CONFIG = {
  pageSize: 24,
  delayMin: 1800,
  delayMax: 3200,
  batchRestEvery: 20,
  batchRestMin: 20000,
  batchRestMax: 40000,
  retryTimes: 3,
  retryPauseMin: 60000,
  retryPauseMax: 120000,
  pageReloadDelayMin: 2500,
  pageReloadDelayMax: 5000,
  skipMutual: false,
  skipQuiet: false
};
```

### 常用参数说明

- `delayMin` / `delayMax`
  - 每次取消关注后的随机等待时间
- `batchRestEvery`
  - 每处理多少个用户，额外休息一次
- `batchRestMin` / `batchRestMax`
  - 额外休息时长
- `retryTimes`
  - 请求失败时最多重试几次
- `retryPauseMin` / `retryPauseMax`
  - 触发频控后等待多久再试
- `pageReloadDelayMin` / `pageReloadDelayMax`
  - 当前页处理完后，等多久再刷新
- `skipMutual`
  - 是否跳过互粉用户
- `skipQuiet`
  - 是否跳过悄悄关注

如果你想更稳一点，可以把延时调大，例如：

```javascript
var CONFIG = {
  pageSize: 24,
  delayMin: 2500,
  delayMax: 4500,
  batchRestEvery: 15,
  batchRestMin: 30000,
  batchRestMax: 60000,
  retryTimes: 3,
  retryPauseMin: 60000,
  retryPauseMax: 120000,
  pageReloadDelayMin: 3000,
  pageReloadDelayMax: 6000,
  skipMutual: false,
  skipQuiet: false
};
```

## 完整脚本

```javascript
// ==UserScript==
// @name         Bilibili 批量取消关注（简化刷新版）
// @namespace    https://space.bilibili.com/
// @version      0.1.1
// @description  右下角开始/停止；每处理完当前页后自动刷新继续下一页
// @match        https://space.bilibili.com/*/relation/follow*
// @grant        none
// ==/UserScript==

(function () {
  'use strict';

  var STORAGE_KEY = '__bili_unfollow_simple_state_v1__';
  var CONFIG = {
    pageSize: 24,
    delayMin: 1800,
    delayMax: 3200,
    batchRestEvery: 20,
    batchRestMin: 20000,
    batchRestMax: 40000,
    retryTimes: 3,
    retryPauseMin: 60000,
    retryPauseMax: 120000,
    pageReloadDelayMin: 2500,
    pageReloadDelayMax: 5000,
    skipMutual: false,
    skipQuiet: false
  };

  var running = false;
  var stopRequested = false;
  var btnStart;
  var btnStop;
  var statusEl;
  var panel;
  var runnerStarted = false;

  function loadState() {
    try {
      var raw = localStorage.getItem(STORAGE_KEY);
      if (!raw) return null;
      return JSON.parse(raw);
    } catch (e) {
      return null;
    }
  }

  function saveState(state) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  }

  function clearState() {
    localStorage.removeItem(STORAGE_KEY);
  }

  function getState() {
    return loadState() || {
      running: false,
      stopRequested: false,
      processed: 0,
      success: 0,
      failed: 0,
      round: 0,
      logs: []
    };
  }

  function appendLog(text) {
    var state = getState();
    var logs = Array.isArray(state.logs) ? state.logs : [];
    logs.push('[' + new Date().toLocaleTimeString('zh-CN', { hour12: false }) + '] ' + text);
    if (logs.length > 80) logs = logs.slice(logs.length - 80);
    state.logs = logs;
    saveState(state);
    renderStatus();
    console.log('[B站批量取关]', text);
  }

  function cookie(name) {
    var m = document.cookie.match(new RegExp('(?:^|;\\s*)' + name + '=([^;]*)'));
    return m ? decodeURIComponent(m[1]) : '';
  }

  function getCsrf() {
    return cookie('bili_jct');
  }

  function getMyUid() {
    return cookie('DedeUserID');
  }

  function getSpmid() {
    var meta = document.querySelector('meta[name="spm_prefix"]');
    return meta ? meta.content : '333.1387.0.0';
  }

  function sleep(ms) {
    return new Promise(function (resolve) {
      setTimeout(resolve, ms);
    });
  }

  function rand(min, max) {
    return Math.floor(min + Math.random() * (max - min + 1));
  }

  function shouldSkip(item) {
    if (CONFIG.skipMutual && item.attribute === 6) return true;
    if (CONFIG.skipQuiet && item.attribute === 1) return true;
    return false;
  }

  async function fetchPage1() {
    var url = new URL('https://api.bilibili.com/x/relation/followings');
    url.search = new URLSearchParams({
      vmid: getMyUid(),
      pn: '1',
      ps: String(CONFIG.pageSize),
      order: 'desc',
      order_type: '',
      gaia_source: 'main_web',
      web_location: '333.1387'
    }).toString();

    var resp = await fetch(url.toString(), {
      credentials: 'include',
      mode: 'cors'
    });
    var json = await resp.json();
    if (json.code !== 0) {
      throw new Error(json.message || ('拉取关注列表失败(code=' + json.code + ')'));
    }
    return json.data && json.data.list ? json.data.list : [];
  }

  async function unfollowOne(item) {
    var act = item.attribute === 1 ? 4 : 2;
    var csrf = getCsrf();

    var body = new URLSearchParams({
      fid: String(item.mid),
      act: String(act),
      re_src: '11',
      gaia_source: 'web_main',
      spmid: getSpmid(),
      extend_content: JSON.stringify({ entity: 'user', entity_id: item.mid }),
      is_from_frontend_component: 'true',
      csrf: csrf,
      csrf_token: csrf
    });

    var url = new URL('https://api.bilibili.com/x/relation/modify');
    url.search = new URLSearchParams({
      statistics: JSON.stringify({ appId: 100, platform: 5 })
    }).toString();

    var resp = await fetch(url.toString(), {
      method: 'POST',
      credentials: 'include',
      mode: 'cors',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
      },
      body: body.toString()
    });
    return await resp.json();
  }

  async function unfollowWithRetry(item) {
    for (var attempt = 1; attempt <= CONFIG.retryTimes; attempt++) {
      var res = await unfollowOne(item);
      if (res.code === 0) return res;

      var msg = res.message || ('code=' + res.code);
      if (/频繁|过快|稍后|异常|风险|验证码/i.test(msg) && attempt < CONFIG.retryTimes) {
        var pause = rand(CONFIG.retryPauseMin, CONFIG.retryPauseMax);
        appendLog('触发频控：' + item.uname + '，' + Math.round(pause / 1000) + ' 秒后重试（' + attempt + '/' + CONFIG.retryTimes + '）');
        await sleep(pause);
        continue;
      }
      throw new Error(msg);
    }
  }

  function renderStatus() {
    if (!statusEl) return;
    var state = getState();
    var lines = [];
    lines.push('状态：' + (state.running ? (state.stopRequested ? '停止中（本页结束后停）' : '运行中') : '待开始'));
    lines.push('轮次：' + (state.round || 0));
    lines.push('累计成功：' + (state.success || 0));
    lines.push('累计失败：' + (state.failed || 0));
    lines.push('累计处理：' + (state.processed || 0));
    lines.push('');
    var logs = state.logs || [];
    for (var i = Math.max(0, logs.length - 8); i < logs.length; i++) {
      lines.push(logs[i]);
    }
    statusEl.textContent = lines.join('\n');

    if (btnStart) btnStart.disabled = !!state.running;
    if (btnStop) btnStop.disabled = !state.running;
  }

  function createPanel() {
    panel = document.createElement('div');
    panel.id = '__bili_unfollow_simple_panel__';
    panel.style.position = 'fixed';
    panel.style.right = '20px';
    panel.style.bottom = '20px';
    panel.style.zIndex = '999999';
    panel.style.background = 'rgba(255,255,255,.96)';
    panel.style.color = '#222';
    panel.style.border = '1px solid #ddd';
    panel.style.borderRadius = '10px';
    panel.style.boxShadow = '0 8px 30px rgba(0,0,0,.12)';
    panel.style.padding = '12px';
    panel.style.fontSize = '14px';
    panel.style.width = '320px';

    var title = document.createElement('div');
    title.textContent = '批量取消关注（简化刷新版）';
    title.style.fontWeight = '700';
    title.style.marginBottom = '8px';
    panel.appendChild(title);

    var desc = document.createElement('div');
    desc.textContent = '每页处理完后自动刷新，刷新后自动继续。';
    desc.style.fontSize = '12px';
    desc.style.color = '#666';
    desc.style.marginBottom = '8px';
    panel.appendChild(desc);

    var btnWrap = document.createElement('div');
    btnWrap.style.display = 'flex';
    btnWrap.style.gap = '8px';
    btnWrap.style.marginBottom = '8px';

    btnStart = document.createElement('button');
    btnStart.textContent = '开始';
    btnStart.style.padding = '6px 10px';
    btnStart.style.border = '1px solid #00AEEC';
    btnStart.style.borderRadius = '6px';
    btnStart.style.cursor = 'pointer';
    btnStart.style.background = '#00AEEC';
    btnStart.style.color = '#fff';
    btnStart.addEventListener('click', start);

    btnStop = document.createElement('button');
    btnStop.textContent = '停止';
    btnStop.style.padding = '6px 10px';
    btnStop.style.border = '1px solid #ccc';
    btnStop.style.borderRadius = '6px';
    btnStop.style.cursor = 'pointer';
    btnStop.style.background = '#fff';
    btnStop.disabled = true;
    btnStop.addEventListener('click', stop);

    btnWrap.appendChild(btnStart);
    btnWrap.appendChild(btnStop);
    panel.appendChild(btnWrap);

    statusEl = document.createElement('pre');
    statusEl.style.fontSize = '12px';
    statusEl.style.lineHeight = '1.5';
    statusEl.style.maxHeight = '260px';
    statusEl.style.overflow = 'auto';
    statusEl.style.whiteSpace = 'pre-wrap';
    statusEl.style.margin = '0';
    panel.appendChild(statusEl);

    document.body.appendChild(panel);
    renderStatus();
  }

  async function start() {
    if (running) return;

    if (!getMyUid() || !getCsrf()) {
      alert('未检测到登录态，请先登录 B 站后再运行。');
      return;
    }

    if (!confirm('确认开始批量取消关注？脚本会处理完当前页后自动刷新并继续。')) {
      return;
    }

    running = true;
    stopRequested = false;
    saveState({
      running: true,
      stopRequested: false,
      processed: 0,
      success: 0,
      failed: 0,
      round: 0,
      logs: []
    });
    appendLog('任务已启动。');
    await runCurrentPage();
  }

  function stop() {
    stopRequested = true;
    var state = getState();
    state.stopRequested = true;
    state.running = true;
    saveState(state);
    appendLog('已请求停止，本页处理完后停止。');
  }

  async function runCurrentPage() {
    if (runnerStarted) return;
    runnerStarted = true;
    try {
      var state = getState();
      if (!state.running) return;

      state.round += 1;
      saveState(state);
      appendLog('开始第 ' + state.round + ' 轮，读取当前页关注列表。');

      var list = await fetchPage1();
      var candidates = list.filter(function (item) {
        return item && !shouldSkip(item);
      });

      if (!candidates.length) {
        appendLog(list.length ? '当前页都被跳过，任务结束。' : '已没有可处理的关注，任务完成。');
        clearState();
        running = false;
        stopRequested = false;
        renderStatus();
        return;
      }

      appendLog('本轮待处理：' + candidates.length + ' 个。');

      for (var i = 0; i < candidates.length; i++) {
        var item = candidates[i];
        state = getState();
        if (state.stopRequested) {
          appendLog('收到停止请求，当前页结束后停止。');
          break;
        }

        try {
          appendLog('正在取消：' + item.uname + ' (' + item.mid + ')');
          await unfollowWithRetry(item);
          state = getState();
          state.processed += 1;
          state.success += 1;
          saveState(state);
          appendLog('成功：' + item.uname);
        } catch (err) {
          state = getState();
          state.processed += 1;
          state.failed += 1;
          saveState(state);
          appendLog('失败：' + item.uname + ' -> ' + (err && err.message ? err.message : err));
        }

        await sleep(rand(CONFIG.delayMin, CONFIG.delayMax));

        if ((i + 1) % CONFIG.batchRestEvery === 0 && i + 1 < candidates.length) {
          var restMs = rand(CONFIG.batchRestMin, CONFIG.batchRestMax);
          appendLog('已处理本页 ' + (i + 1) + ' 个，休息 ' + Math.round(restMs / 1000) + ' 秒。');
          await sleep(restMs);
        }
      }

      state = getState();
      if (state.stopRequested) {
        appendLog('本页处理结束，停止任务。');
        clearState();
        running = false;
        stopRequested = false;
        renderStatus();
        return;
      }

      var reloadMs = rand(CONFIG.pageReloadDelayMin, CONFIG.pageReloadDelayMax);
      appendLog('本页处理完成，' + Math.round(reloadMs / 1000) + ' 秒后刷新继续。');
      await sleep(reloadMs);
      location.reload();
    } finally {
      runnerStarted = false;
    }
  }

  function boot() {
    createPanel();
    var state = getState();
    if (state.running) {
      running = true;
      stopRequested = !!state.stopRequested;
      appendLog('检测到上次任务未结束，刷新后自动继续。');
      setTimeout(function () {
        runCurrentPage();
      }, 1200);
    }
  }

  if (document.body) boot();
  else window.addEventListener('DOMContentLoaded', boot);
})();
```

## 注意事项

- 建议先少量测试一下再长时间跑
- 如果出现操作频繁，可以把延时调大
- 这个脚本只适合登录自己的账号后使用
- 刷新续跑依赖 `localStorage` 保存状态，所以不要在运行过程中手动清浏览器站点数据

目前这个版本追求的是简单够用，没有做复杂 UI，也没有做特别多的筛选选项。如果后面想继续改，可以再加：

- 模态框日志面板
- 白名单 / 黑名单用户过滤
- 只取消互粉以外的关注
- 导出处理日志


