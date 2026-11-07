(() => {
  const SKIP_SELECTORS = [
    ".ad",
    ".advertisement",
    "[class*='ad-']",
    "[id*='ad-']",
    "div[class*='Promoted']",
    "div[class*='promoted']"
  ];

  const removeAds = () => {
    SKIP_SELECTORS.forEach(sel => {
      document.querySelectorAll(sel).forEach(el => el.remove());
    });
  };

  const observer = new MutationObserver(removeAds);
  const start = () => {
    if (document.body) {
      observer.observe(document.body, { childList: true, subtree: true });
      removeAds();
    } else {
      setTimeout(start, 50);
    }
  };
  start();

  // Skip audio ads: detect ad track and click next
  let lastSrc = "";
  const trySkip = () => {
    const audio = document.querySelector("audio");
    if (!audio) return;
    const src = audio.currentSrc || audio.src || "";
    if (src && src !== lastSrc) {
      lastSrc = src;
    }
    // SoundCloud marks ad tracks; if the play button area shows "Advertisement", skip
    const adIndicator = document.querySelector("[class*='adBadge'], [class*='AdBadge'], [aria-label*='Advertisement']");
    if (adIndicator) {
      const nextBtn = document.querySelector("button[aria-label*='Next'], button[title*='Next'], .skipControl, [class*='skip']");
      if (nextBtn) nextBtn.click();
    }
  };
  setInterval(trySkip, 1000);
})();