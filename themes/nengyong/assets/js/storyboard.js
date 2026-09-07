(function () {
  "use strict";

  var root = document.querySelector("[data-storyboard]");
  if (!root) return;

  var anchors = Array.from(root.querySelectorAll("[data-story-scene]"));
  var sections = Array.from(root.querySelectorAll("[data-story-section]"));
  var nav = root.querySelector(".section-nav");
  var links = Array.from(nav.querySelectorAll('.section-links a[href^="#"]'));
  var progress = nav.querySelector(".story-progress");
  var desktop = window.matchMedia("(min-width: 1000px)");
  var reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  var stage = document.createElement("div");
  stage.className = "story-stage";
  stage.setAttribute("aria-hidden", "true");

  var shots = anchors.map(function (anchor) {
    var shot = anchor.querySelector(".story-shot").cloneNode(true);
    shot.querySelector("img").loading = "eager";
    stage.appendChild(shot);
    return shot;
  });
  root.appendChild(stage);

  var points = [];
  var sectionTops = [];
  var restingY = 0;
  var stageHeight = 0;
  var rootBottom = 0;
  var maxScroll = 0;
  var enabled = false;
  var imageReady = false;
  var measureNeeded = true;
  var frame = 0;
  var activeName = null;

  function clamp(value, min, max) {
    return Math.min(max, Math.max(min, value));
  }

  function measure() {
    var scrollY = window.scrollY;
    var headerHeight = document.querySelector(".site-header").offsetHeight;
    restingY = headerHeight + nav.offsetHeight + 20;
    maxScroll = Math.max(0, document.documentElement.scrollHeight - window.innerHeight);
    rootBottom = root.getBoundingClientRect().bottom + scrollY;
    sectionTops = sections.map(function (section) {
      return section.getBoundingClientRect().top + scrollY;
    });

    enabled = desktop.matches && !reducedMotion.matches && imageReady;
    root.classList.toggle("storyboard-enhanced", enabled);
    if (!enabled) return;

    var rects = anchors.map(function (anchor) { return anchor.getBoundingClientRect(); });
    // Leave room below the illustration for its caption on shorter screens.
    var width = Math.min(380, window.innerHeight - restingY - 145,
      ...rects.map(function (rect) { return rect.width; }));
    if (width < 220) {
      enabled = false;
      root.classList.remove("storyboard-enhanced");
      return;
    }
    stage.style.width = width + "px";
    stageHeight = Math.max(...shots.map(function (shot) { return shot.offsetHeight; }));
    points = rects.map(function (rect, index) {
      return {
        x: rect.left + (rect.width - width) / 2,
        top: rect.top + scrollY,
        stop: index === 0 ? 0 : clamp(rect.top + scrollY - restingY, 0, maxScroll)
      };
    });
  }

  function render() {
    frame = 0;
    if (measureNeeded) {
      measureNeeded = false;
      measure();
    }
    var scrollY = window.scrollY;
    var chapter = 0;
    sectionTops.forEach(function (top, index) {
      if (top <= scrollY + restingY + 64) chapter = index;
    });
    if (scrollY >= maxScroll - 2) chapter = sections.length - 1;
    var name = sections[chapter].dataset.storySection;
    if (name !== activeName) {
      activeName = name;
      links.forEach(function (link) {
        if (link.hash === "#" + name) link.setAttribute("aria-current", "location");
        else link.removeAttribute("aria-current");
      });
    }
    var start = sectionTops[1] - restingY;
    var end = Math.min(sectionTops[sectionTops.length - 1] - restingY, maxScroll);
    progress.style.transform = "scaleX(" + clamp((scrollY - start) / Math.max(1, end - start), 0, 1) + ")";
    if (!enabled) return;

    var current = 0;
    while (current < points.length - 1 && scrollY >= points[current + 1].stop) current++;
    var next = Math.min(current + 1, points.length - 1);
    var from = points[current];
    var to = points[next];
    var travel = Math.min(520, (to.stop - from.stop) * .65);
    var fraction = travel > 0 ? clamp((scrollY - to.stop + travel) / travel, 0, 1) : 0;
    var eased = fraction * fraction * (3 - 2 * fraction);
    var x = from.x + (to.x - from.x) * eased;
    var y = current === 0 ? Math.max(restingY, from.top - scrollY) : restingY;
    y -= Math.sin(fraction * Math.PI) * 18;
    y = Math.min(y, rootBottom - scrollY - stageHeight - 36);
    stage.style.transform = "translate3d(" + x.toFixed(2) + "px," + y.toFixed(2) + "px,0)";
    shots.forEach(function (shot, index) {
      var opacity = index === current ? 1 - eased : index === next ? eased : 0;
      shot.style.opacity = opacity;
      shot.style.visibility = opacity > 0 ? "visible" : "hidden";
      shot.style.transform = "rotate(" + ((index === current ? -1 : 1) * Math.sin(fraction * Math.PI) * 3).toFixed(2) + "deg)";
    });
  }

  function schedule(needsMeasure) {
    measureNeeded = measureNeeded || needsMeasure;
    if (!frame) frame = window.requestAnimationFrame(render);
  }

  window.addEventListener("scroll", function () { schedule(false); }, { passive: true });
  window.addEventListener("resize", function () { schedule(true); });
  desktop.addEventListener("change", function () { schedule(true); });
  reducedMotion.addEventListener("change", function () { schedule(true); });
  if ("ResizeObserver" in window) new ResizeObserver(function () { schedule(true); }).observe(root);
  if (document.fonts) document.fonts.ready.then(function () { schedule(true); });

  var firstImage = anchors[0].querySelector("img");
  function enableImages() {
    imageReady = firstImage.naturalWidth > 0;
    schedule(true);
  }
  if (firstImage.complete) enableImages();
  else firstImage.addEventListener("load", enableImages, { once: true });
  schedule(true);
})();
