chrome.runtime.onInstalled.addListener(() => {
  chrome.declarativeNetRequest.setExtensionActionOptions?.({});
});

chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
  if (msg && msg.type === "toggle") {
    chrome.storage.local.set({ enabled: !!msg.enabled }, () => sendResponse({ ok: true }));
    return true;
  }
  if (msg && msg.type === "getState") {
    chrome.storage.local.get(["enabled"], (r) => sendResponse({ enabled: r.enabled !== false }));
    return true;
  }
});