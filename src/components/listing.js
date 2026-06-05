const crossIcon = `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>`;

const listing = document.querySelector(".listing");
const listingOriginalHTML = listing.innerHTML;

const filterElem = document.querySelector("#filter");
const filterElemOriginalHTML = filterElem.innerHTML;

const filter = new URLSearchParams(location.search).get("tag");
if (filter) {
  applyFilter(filter);
}

window.addEventListener("click", (e) => {
  if (e.target.matches(".meta a")) {
    e.preventDefault();
    const filter = e.target.textContent.slice(1);
    history.pushState(null, "", `?tag=${filter}#filter`);
    applyFilter(filter);
  } else if (e.target.matches("#filter *")) {
    e.preventDefault();
    history.pushState(null, "", ".#filter");
    listing.innerHTML = listingOriginalHTML;
    filterElem.innerHTML = filterElemOriginalHTML;
  }
});

/** @param {string} filter */
function applyFilter(filter) {
  const items = listing.querySelectorAll(".listing > li");
  listing.replaceChildren(
    ...Array.prototype.filter.call(items, (el) =>
      el.dataset.tags?.split(" ").includes(filter),
    ),
  );

  filterElem.innerHTML = `
    正在筛选标签：#${filter}
    <a href=".#filter" aria-label="取消筛选">${crossIcon}</a>
  `;
}
