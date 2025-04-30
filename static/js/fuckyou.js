// ==UserScript==
// @name     Remove target="_blank"
// @version  1
// @grant    none
// @match    *://*/*
// @run-at   document-end
// ==/UserScript==
(function (window) {
    "use strict";
    let base = document.querySelector('base');
    if (base) removeAttribute('target');
  
    document.addEventListener('mousedown', function (event) {
      var a = event.target, depth = 3;
  
      while (a && a.tagName != 'A' && depth-- > 0) {
        a = a.parentNode;
      }
      
      if (a && a.tagName == 'A') {
        a.removeAttribute('target');
        a.removeAttribute('onclick');
        a.onclick = (e) => e.stopImmediatePropagation();
        
        var u = new URL(a.href);
        var p = u.searchParams
        var t = p.get("target")||p.get("to");
        if (t) { a.href = t; }
      }
    }, true);
  })(window);