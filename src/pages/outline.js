function isWideScreen() {
  return (
    window.getComputedStyle(document.body).getPropertyValue("--widescreen") ===
    "true"
  );
}

let previousValue = undefined;
function autoSetOutlineOpen() {
  const newValue = isWideScreen();
  if (newValue !== previousValue) {
    document.querySelector("#outline details").open = newValue;
    previousValue = newValue;
  }
}

autoSetOutlineOpen();
window.addEventListener("resize", autoSetOutlineOpen);
window.addEventListener("click", (e) => {
  if (!previousValue && e.target.matches("#outline details a")) {
    document.querySelector("#outline details").open = false;
  }
});
