window.addEventListener("DOMContentLoaded", () => {
  const messages = document.createElement("ul");
  document.body.appendChild(messages);


  const websocket = new WebSocket("ws://localhost:5678/");
  websocket.onmessage = ({ data }) => {
    const message = document.createElement("li");
	message.setAttribute("style", "font-family:'Courier New'; white-space: pre-line")
    const content = document.createTextNode(data);
    message.appendChild(content);
    messages.prepend(message);
  };
});
