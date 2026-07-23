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
  }

  function cycle(pref) {
    if (pref === "auto") return "light";
    if (pref === "light") return "dark";
    return "auto";
  }

  var toggle = document.getElementById("theme-toggle");
  if (toggle) {
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
    navToggle.addEventListener("click", function () {
      var open = document.body.classList.toggle("nav-open");
      navToggle.setAttribute("aria-expanded", open ? "true" : "false");
    });
    nav.querySelectorAll("a").forEach(function (a) {
      a.addEventListener("click", function () {
        document.body.classList.remove("nav-open");
        navToggle.setAttribute("aria-expanded", "false");
      });
    });
  }

  // Highlight TOC current section
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
              if (active) active.classList.remove("is-active");
              hit.link.classList.add("is-active");
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
      var code = block.querySelector("code");
      var text = code ? code.innerText : block.innerText;
      navigator.clipboard.writeText(text).then(function () {
        btn.textContent = "已复制";
        setTimeout(function () {
          btn.textContent = "复制";
        }, 1500);
      });
    });
    block.style.position = "relative";
    block.appendChild(btn);
  });
})();
