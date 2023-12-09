window.addEventListener("DOMContentLoaded", () => {

  // Divider that holds the text
  const divider = document.createElement("div")
  divider.setAttribute("style", "justify-content: center; line-height: 1; margin: 2%; border: 0.3em solid black; background-color:#ffffee")
  document.body.appendChild(divider)

  const messages = document.createElement("ul");
  divider.appendChild(messages);

  // Socket things
  const websocket = new WebSocket("ws://localhost:5678/");
  websocket.onmessage = ({ data }) => {
	const jsonData = JSON.parse(data)

	const imageBase64 = jsonData.image
	const text = jsonData.message

	document.getElementById('screenshot').src = imageBase64
	const message = document.createElement("li");
    const content = document.createTextNode(text);
    message.appendChild(content);

	// Icon
	const icon = document.createElement("i");
	icon.className = "fas fa-solid fa-copy";
	icon.style.display = "none";
	message.appendChild(icon);
	
	message.addEventListener("mouseover", () => {
		icon.style.display = "inline-block";
	});

	message.addEventListener("mouseout", () => {
		icon.style.display = "none";
	});

	// On click copy the text, ignoring border characters
	icon.addEventListener("click", async () => {
		const clean_text = text.replaceAll(/[━┏┓┃┛┗─]/g, "");
		await navigator.clipboard.writeText(clean_text)

		// Change the icon for 1 second to indicate success
		.then(() => {
			icon.className = "fas fa-check";
			setTimeout(() => {
			icon.className = "fas fa-copy"
		}, 500);

		})
	});




    messages.prepend(message);
  };
});
