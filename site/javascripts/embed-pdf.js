// <iframe src="./test.pdf" height="900px;" width="100%"></iframe>
document.addEventListener("DOMContentLoaded", function () {
  // Find all embedded PDF elements
  var embedElements = document.querySelectorAll(
    'embed[type="application/pdf"]'
  );

  // Loop through each element and add 'data-src' attribute
  embedElements.forEach(function (embedElement) {
    var src = embedElement.getAttribute("src");
    if (src) {
      embedElement.setAttribute("data-src", src);
      embedElement.removeAttribute("src");
    }
  });
});
