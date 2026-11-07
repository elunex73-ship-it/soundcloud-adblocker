const btn = document.getElementById("toggle");
let enabled = true;
chrome.runtime.sendMessage({ type: "getState" }, (r) => {
  enabled = r && r.enabled !== false;
  btn.textContent = enabled ? "On" : "Off";
});
btn.addEventListener("click", () => {
  enabled = !enabled;
  chrome.runtime.sendMessage({ type: "toggle", enabled }, () => {
    btn.textContent = enabled ? "On" : "Off";
  });
});