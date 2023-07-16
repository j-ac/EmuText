window.addEventListener("DOMContentLoaded", () => {
  // Create style
  var style = document.createElement('style');
  style.innerHTML = ".main-font { font-family:'Yu Gothic', 'Courier New'; font-size: 30px; white-space: pre-line; list-style-type: none;}";
  document.head.appendChild(style);

  // ====================
  // === FONT BUTTONS ===
  // ====================

  var decreaseButton = document.createElement('button');
  decreaseButton.textContent = 'Decrease Font Size';
  decreaseButton.onclick = function() {
    var styleBlock = document.querySelector("style");
	var mainFontRule = styleBlock.sheet.cssRules[0];
	currentFontSize = parseInt(mainFontRule.style.fontSize);
	mainFontRule.style.fontSize = currentFontSize - 2 + 'px';
  };
  
  var increaseButton = document.createElement('button');
  increaseButton.textContent = 'Increase Font Size';
  increaseButton.onclick = function() {
    var styleBlock = document.querySelector("style");
	var mainFontRule = styleBlock.sheet.cssRules[0];
	currentFontSize = parseInt(mainFontRule.style.fontSize);
	mainFontRule.style.fontSize = currentFontSize + 2 + 'px';
  };

  //Button Container
  var container = document.createElement("div");
  container.setAttribute("style", "display: flex; justify-content: center;")
  document.body.appendChild(container)

  container.appendChild(increaseButton)
  container.appendChild(decreaseButton)  
  //=========================

  // Divider that holds the text
  const divider = document.createElement("div")
  divider.setAttribute("style", "justify-content: center; margin: 5%; border: 0.3em solid black; background-color:#ffffee")
  document.body.appendChild(divider)

  const messages = document.createElement("ul");
  divider.appendChild(messages);

  // Socket things
  const websocket = new WebSocket("ws://localhost:5678/");
  websocket.onmessage = ({ data }) => {
    const message = document.createElement("li");
	message.classList.add('main-font');
    const content = document.createTextNode(data);
    message.appendChild(content);
    messages.prepend(message);
  };
});
