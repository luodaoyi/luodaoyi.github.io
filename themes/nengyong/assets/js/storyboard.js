(function () {
  "use strict";

  var root = document.querySelector("[data-storyboard]");
  if (!root || !root.dataset.storyTransitions) return;

  var anchors = Array.from(root.querySelectorAll("[data-story-scene]"));
  var sections = Array.from(root.querySelectorAll("[data-story-section]"));
  var nav = root.querySelector(".section-nav");
  var links = Array.from(nav.querySelectorAll('.section-links a[href^="#"]'));
  var progress = nav.querySelector(".story-progress");
  var desktop = window.matchMedia("(min-width: 1000px)");
  var reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  var firstImage = anchors[0].querySelector("img");
  var transitionImage = new Image();
  var transitionLayout = JSON.parse(root.dataset.storyTransitionLayout);
  var tileSize = transitionLayout.width / transitionLayout.columns;
  var transitionsRequested = false;
  var stage = document.createElement("div");
  stage.className = "story-stage";
  stage.setAttribute("aria-hidden", "true");

  // A single opaque picture avoids double exposures of people, paper and captions.
  var shot = anchors[0].querySelector(".story-shot").cloneNode(true);
  var sprite = shot.querySelector(".story-sprite");
  var picture = sprite.querySelector("img");
  var caption = shot.querySelector(".story-caption");
  var captions = anchors.map(function (anchor) {
    return anchor.querySelector(".story-caption").innerHTML;
  });
  var poses = [];
  anchors.forEach(function (anchor, index) {
    var original = anchor.querySelector(".story-sprite");
    poses.push({
      src: firstImage.src,
      x: original.style.getPropertyValue("--sprite-x"),
      y: original.style.getPropertyValue("--sprite-y"),
      transition: false
    });
    if (index < anchors.length - 1) {
      // Use the measured row edges, clipping out dividers without stretching the art.
      var top = transitionLayout.row_edges[index];
      var bottom = transitionLayout.row_edges[index + 1];
      for (var column = 0; column < 3; column++) {
        poses.push({
          src: root.dataset.storyTransitions,
          x: column,
          y: (top + bottom - tileSize) / (2 * tileSize),
          clipTop: (top + 2) / transitionLayout.height * 100,
          clipBottom: (transitionLayout.height - bottom + 2) / transitionLayout.height * 100,
          transition: true
        });
      }
    }
  });
  stage.appendChild(shot);
  root.appendChild(stage);

  var points = [];
  var sectionTops = [];
  var restingY = 0;
  var stageHeight = 0;
  var rootBottom = 0;
  var maxScroll = 0;
  var enabled = false;
  var measureNeeded = true;
  var frame = 0;
  var activeName = null;
  var phase = null;
  var lastFrameAt = 0;
  var shownPose = -1;
  var shownSource = picture.getAttribute("src");
  var shownCaption = 0;

  function clamp(value, min, max) {
    return Math.min(max, Math.max(min, value));
  }

  function smoothstep(value) {
    return value * value * (3 - 2 * value);
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

    var animated = desktop.matches && !reducedMotion.matches;
    if (animated && !transitionsRequested) {
      transitionsRequested = true;
      transitionImage.src = root.dataset.storyTransitions;
    }
    enabled = animated && firstImage.complete && firstImage.naturalWidth > 0 &&
      transitionImage.complete && transitionImage.naturalWidth > 0;
    root.classList.toggle("storyboard-enhanced", enabled);
    if (!enabled) {
      phase = null;
      return;
    }

    var rects = anchors.map(function (anchor) { return anchor.getBoundingClientRect(); });
    // Leave room below the illustration for its caption on shorter screens.
    var width = Math.min(380, window.innerHeight - restingY - 145,
      ...rects.map(function (rect) { return rect.width; }));
    if (width < 220) {
      enabled = false;
      phase = null;
      root.classList.remove("storyboard-enhanced");
      return;
    }
    stage.style.width = width + "px";
    stageHeight = shot.offsetHeight;
    points = rects.map(function (rect, index) {
      return {
        x: rect.left + (rect.width - width) / 2,
        top: rect.top + scrollY,
        stop: index === 0 ? 0 : clamp(rect.top + scrollY - restingY, 0, maxScroll)
      };
    });
  }

  function render(timestamp) {
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

    var targetChapter = 0;
    while (targetChapter < points.length - 1 && scrollY >= points[targetChapter + 1].stop) targetChapter++;
    var nextChapter = Math.min(targetChapter + 1, points.length - 1);
    var travel = Math.min(600, (points[nextChapter].stop - points[targetChapter].stop) * .75);
    var target = targetChapter + (travel > 0 ? clamp((scrollY - points[nextChapter].stop + travel) / travel, 0, 1) : 0);

    // Brief, rate-limited catch-up shows the in-betweens even when the scrollbar jumps.
    var elapsed = Math.min(32, timestamp - lastFrameAt || 16);
    lastFrameAt = timestamp;
    if (phase === null || Math.abs(target - phase) < .002) phase = target;
    else phase += clamp((target - phase) * (1 - Math.exp(-elapsed / 75)), -elapsed / 160, elapsed / 160);

    var current = Math.floor(phase);
    var next = Math.min(current + 1, points.length - 1);
    var fraction = phase - current;
    var eased = smoothstep(fraction);
    var x = points[current].x + (points[next].x - points[current].x) * eased;
    var y = current === 0 ? Math.max(restingY, points[0].top - scrollY) : restingY;
    y -= Math.sin(fraction * Math.PI) * 18;

    var poseIndex = Math.round(phase * 4);
    if (poseIndex !== shownPose) {
      shownPose = poseIndex;
      var pose = poses[poseIndex];
      if (pose.src !== shownSource) {
        shownSource = pose.src;
        picture.src = pose.src;
      }
      sprite.style.setProperty("--sprite-x", pose.x);
      sprite.style.setProperty("--sprite-y", pose.y);
      if (pose.transition) {
        sprite.style.setProperty("--sprite-clip-top", pose.clipTop + "%");
        sprite.style.setProperty("--sprite-clip-bottom", pose.clipBottom + "%");
      }
      sprite.classList.toggle("is-transition", pose.transition);
    }

    var captionIndex = Math.round(phase);
    if (captionIndex !== shownCaption) {
      shownCaption = captionIndex;
      caption.innerHTML = captions[captionIndex];
      stageHeight = shot.offsetHeight;
    }
    // Hide the outgoing caption before changing its text; only one can be visible.
    caption.style.opacity = 1 - smoothstep(clamp(Math.abs(phase - captionIndex) / .2, 0, 1));
    y = Math.min(y, rootBottom - scrollY - stageHeight - 36);
    stage.style.transform = "translate3d(" + x.toFixed(2) + "px," + y.toFixed(2) + "px,0)";

    if (Math.abs(target - phase) >= .002) schedule(false);
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

  firstImage.addEventListener("load", function () { schedule(true); }, { once: true });
  transitionImage.addEventListener("load", function () { schedule(true); }, { once: true });
  schedule(true);
})();
