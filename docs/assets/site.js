/* Vidrado promotional site — interactive blur demo + scroll reveals. */
(function () {
  "use strict";

  document.documentElement.classList.add("js");

  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var $ = function (sel, ctx) { return (ctx || document).querySelector(sel); };
  var $$ = function (sel, ctx) { return Array.prototype.slice.call((ctx || document).querySelectorAll(sel)); };

  /* Live clock in the demo menu bar ("Mon. 09:41"). */
  (function clock() {
    var el = $("#clock");
    if (!el) return;
    try {
      var now = new Date();
      var day = now.toLocaleDateString("en-US", { weekday: "short" });
      var hh = String(now.getHours()).padStart(2, "0");
      var mm = String(now.getMinutes()).padStart(2, "0");
      el.textContent = day + ". " + hh + ":" + mm;
    } catch (e) { /* keep design fallback text */ }
  })();

  /* Scroll reveals with stagger. */
  (function reveals() {
    var items = $$(".rv");
    if (!items.length) return;
    if (!("IntersectionObserver" in window) || reduceMotion) {
      items.forEach(function (el) { el.classList.add("in"); });
      return;
    }
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add("in");
          io.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: "0px 0px -6% 0px" });
    items.forEach(function (el) { io.observe(el); });
  })();

  /* Interactive blur demo. */
  var desktop = $("#desktop");
  if (!desktop) return;

  var MODES = { light: 30, balanced: 65, deep: 92 };
  var state = { value: 65, mode: "balanced", paused: false };

  var slider = $("#intensity");
  var val = $("#intensityVal");
  var pauseBtn = $("#pauseBtn");
  var pauseLabel = $("#pauseLabel");
  var eyebrow = $("#focusEyebrow");
  var headline = $("#focusHeadline");
  var liveBadge = $("#liveBadge");
  var liveText = $("#liveText");
  var activeApp = $("#activeApp");
  var modeBtns = $$(".p-modes button");
  var wins = $$(".win[data-app]", desktop);

  function render() {
    var v = state.value;
    if (state.paused) {
      desktop.style.setProperty("--b", "0px");
      desktop.style.setProperty("--dim", "0");
      desktop.style.setProperty("--brt", "1");
    } else {
      desktop.style.setProperty("--b", (v / 100 * 22).toFixed(1) + "px");
      desktop.style.setProperty("--dim", (v / 100 * 0.6).toFixed(3));
      desktop.style.setProperty("--brt", (1 - v / 100 * 0.25).toFixed(3));
    }
    if (slider) {
      slider.value = String(v);
      slider.style.setProperty("--p", v + "%");
      slider.setAttribute("aria-valuenow", String(v));
    }
    if (val) val.textContent = v + "%";
    modeBtns.forEach(function (b) {
      b.setAttribute("aria-pressed", b.getAttribute("data-mode") === state.mode ? "true" : "false");
    });
    desktop.classList.toggle("paused", state.paused);
    if (pauseBtn) pauseBtn.setAttribute("aria-pressed", state.paused ? "true" : "false");
    if (pauseLabel) pauseLabel.textContent = state.paused ? "Resume focus" : "Pause focus";
    if (eyebrow) eyebrow.textContent = state.paused ? "Focus paused" : "Distractions, out of sight";
    if (headline) headline.textContent = state.paused ? "Everything is visible." : "You’re in the clear.";
    if (liveBadge) liveBadge.classList.toggle("is-paused", state.paused);
    if (liveText) liveText.textContent = state.paused ? "Paused" : "Focus active";
  }

  if (slider) {
    slider.addEventListener("input", function () {
      state.value = Number(slider.value);
      state.mode = "";
      render();
    });
  }

  modeBtns.forEach(function (b) {
    b.addEventListener("click", function () {
      var m = b.getAttribute("data-mode");
      state.mode = m;
      state.value = MODES[m];
      if (state.paused) state.paused = false;
      render();
    });
  });

  if (pauseBtn) {
    pauseBtn.addEventListener("click", function () {
      state.paused = !state.paused;
      render();
    });
  }

  /* Click a background window to bring it into focus. */
  function setActive(win) {
    wins.forEach(function (w, i) {
      var on = w === win;
      w.classList.toggle("is-active", on);
      w.setAttribute("aria-pressed", on ? "true" : "false");
      w.setAttribute("aria-label", on ? w.getAttribute("data-app") + " is in focus" : "Bring " + w.getAttribute("data-app") + " to focus");
      w.style.zIndex = on ? "3" : String(1 + (i % 2));
    });
    if (activeApp) activeApp.textContent = win.getAttribute("data-app");
    if (state.paused) { state.paused = false; render(); }
  }

  wins.forEach(function (w) {
    w.addEventListener("click", function () { setActive(w); });
    w.addEventListener("keydown", function (ev) {
      if (ev.key === "Enter" || ev.key === " ") { ev.preventDefault(); setActive(w); }
    });
  });

  /* Gentle parallax on the background windows (desktop pointers only). */
  (function parallax() {
    if (reduceMotion) return;
    if (!window.matchMedia("(pointer: fine)").matches) return;
    var stage = $(".stage");
    if (!stage) return;
    var raf = 0;
    stage.addEventListener("mousemove", function (ev) {
      if (raf) return;
      raf = requestAnimationFrame(function () {
        raf = 0;
        var r = stage.getBoundingClientRect();
        var x = ((ev.clientX - r.left) / r.width - 0.5) * 2;
        var y = ((ev.clientY - r.top) / r.height - 0.5) * 2;
        desktop.style.setProperty("--px", x.toFixed(3));
        desktop.style.setProperty("--py", y.toFixed(3));
      });
    });
    stage.addEventListener("mouseleave", function () {
      desktop.style.setProperty("--px", "0");
      desktop.style.setProperty("--py", "0");
    });
  })();

  render();
})();
