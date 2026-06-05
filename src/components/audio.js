window.addEventListener("click", (e) => {
  if (e.target.matches(".audio-clip + button")) {
    const clip = e.target.previousElementSibling;
    if (clip.paused) {
      clip.play();
    } else {
      clip.load();
    }
  }
});
