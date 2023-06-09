window.addEventListener("DOMContentLoaded", () => {
  const divider = document.createElement("div")
  divider.setAttribute("style", "justify-content: center; margin: 5%; border: 0.3em solid black; background-color:#ffffee")
  document.body.appendChild(divider)


  const messages = document.createElement("ul");
  //messages.setAttribute()
  divider.appendChild(messages);


  const websocket = new WebSocket("ws://localhost:5678/");
  websocket.onmessage = ({ data }) => {
    const message = document.createElement("li");
	message.setAttribute("style", "font-family:'Yu Gothic', 'Courier New'; font-size: 30px; white-space: pre-line; list-style-type: none;")
    const content = document.createTextNode(data);
    message.appendChild(content);
    messages.prepend(message);
  };
});
