(function () {
  "use strict";

  var KEY = "nengyong-theme";

  function preferred() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches
      ? "dark"
      : "light";
  }

  function resolve(pref) {
    return pref === "auto" ? preferred() : pref;
  }

  function apply(pref) {
    var theme = resolve(pref);
    document.documentElement.setAttribute("data-theme", theme);
    document.documentElement.setAttribute("data-theme-pref", pref);
    updateThemeLabel(pref);
  }

  function updateThemeLabel(pref) {
    if (!toggle) return;
    var labels = { auto: "跟随系统", light: "浅色", dark: "深色" };
    var label = "当前主题：" + labels[pref] + "；切换为" + labels[cycle(pref)];
    toggle.setAttribute("aria-label", label);
    toggle.title = label;
  }

  function cycle(pref) {
    if (pref === "auto") return "light";
    if (pref === "light") return "dark";
    return "auto";
  }

  var toggle = document.getElementById("theme-toggle");
  if (toggle) {
    updateThemeLabel(document.documentElement.getAttribute("data-theme-pref") || "auto");
    toggle.addEventListener("click", function () {
      var cur =
        document.documentElement.getAttribute("data-theme-pref") || "auto";
      var next = cycle(cur);
      localStorage.setItem(KEY, next);
      apply(next);
    });
  }

  window
    .matchMedia("(prefers-color-scheme: dark)")
    .addEventListener("change", function () {
      var pref = localStorage.getItem(KEY) || "auto";
      if (pref === "auto") apply("auto");
    });

  var navToggle = document.getElementById("nav-toggle");
  var nav = document.querySelector(".nav");
  if (navToggle && nav) {
    function closeNav() {
      document.body.classList.remove("nav-open");
      navToggle.setAttribute("aria-expanded", "false");
    }
    navToggle.addEventListener("click", function () {
      var open = document.body.classList.toggle("nav-open");
      navToggle.setAttribute("aria-expanded", open ? "true" : "false");
    });
    nav.querySelectorAll("a").forEach(function (a) {
      a.addEventListener("click", function () {
        closeNav();
      });
    });
    document.addEventListener("keydown", function (event) {
      if (event.key === "Escape" && document.body.classList.contains("nav-open")) {
        closeNav();
        navToggle.focus();
      }
    });
    document.addEventListener("click", function (event) {
      if (!event.target.closest(".site-header")) closeNav();
    });
  }

  // The homepage storyboard manages its own chapter navigation.
  var toc = document.querySelector(".toc");
  if (toc) {
    var links = toc.querySelectorAll('a[href^="#"]');
    var map = [];
    links.forEach(function (link) {
      var id = decodeURIComponent(link.getAttribute("href").slice(1));
      var el = document.getElementById(id);
      if (el) map.push({ el: el, link: link });
    });
    if (map.length && "IntersectionObserver" in window) {
      var active = null;
      var io = new IntersectionObserver(
        function (entries) {
          entries.forEach(function (entry) {
            if (entry.isIntersecting) {
              var hit = map.find(function (m) {
                return m.el === entry.target;
              });
              if (!hit) return;
              if (active) {
                active.classList.remove("is-active");
                active.removeAttribute("aria-current");
              }
              hit.link.classList.add("is-active");
              hit.link.setAttribute("aria-current", "location");
              active = hit.link;
            }
          });
        },
        { rootMargin: "-20% 0px -70% 0px", threshold: 0 }
      );
      map.forEach(function (m) {
        io.observe(m.el);
      });
    }
  }

  // Copy code button
  document.querySelectorAll(".highlight").forEach(function (block) {
    var btn = document.createElement("button");
    btn.type = "button";
    btn.className = "code-copy";
    btn.textContent = "复制";
    btn.addEventListener("click", function () {
      // Hugo's table layout puts line numbers in the first code element.
      var code = block.querySelector(".lntd:last-child code") || block.querySelector("code");
      if (!code) return;
      var text = code.innerText;
      navigator.clipboard.writeText(text).then(function () {
        btn.textContent = "已复制";
        setTimeout(function () {
          btn.textContent = "复制";
        }, 1500);
      }).catch(function () {
        btn.textContent = "复制失败，请手动选择";
      });
    });
    block.style.position = "relative";
    block.appendChild(btn);
  });
})();
