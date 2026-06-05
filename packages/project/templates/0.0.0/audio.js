for (const clip of document.querySelectorAll(".audio-clip")) {
  const btn = document.createElement("a");
  btn.className = "audio-clip-btn";
  btn.textContent = "▶";
  btn.addEventListener("click", () => {
    if (clip.paused) {
      clip.play();
      btn.textContent = "⏸";
    } else {
      clip.load();
      btn.textContent = "▶";
    }
  });
  clip.addEventListener("ended", () => {
    btn.textContent = "▶";
  });
  clip.insertAdjacentElement("afterend", btn);
}
