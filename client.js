window.addEventListener("DOMContentLoaded", () => {
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
	//message.classList.add('main-font');
    const content = document.createTextNode(data);
    message.appendChild(content);
    messages.prepend(message);
  };
});
