const container = document.getElementById("nameplates");

const BASE_HEIGHT = 1080;
const BASE_FONT_SIZE = 26;
const MIN_FONT_SIZE = 18;
const MAX_FONT_SIZE = 40;

function getResolutionScaledFontSize() {
    const safeHeight = Math.max(window.innerHeight || BASE_HEIGHT, 1);
    const scaledSize = BASE_FONT_SIZE * (safeHeight / BASE_HEIGHT);

    return Math.max(MIN_FONT_SIZE, Math.min(MAX_FONT_SIZE, scaledSize));
}

window.addEventListener("message", function (event) {
    if (event.data.action !== "updateNameplates") return;

    container.innerHTML = "";

    const fontSize = getResolutionScaledFontSize();

    for (const plate of event.data.nameplates) {
        const div = document.createElement("div");

        div.className = "nameplate";
        if (plate.isAfk) {
            div.classList.add("afk");
        }
        div.style.left = (plate.x * 100) + "vw";
        div.style.top = (plate.y * 100) + "vh";
        div.style.opacity = plate.opacity;
        const nameLine = document.createElement("div");
        nameLine.className = "name-line";
        nameLine.textContent = plate.text;
        div.appendChild(nameLine);

        if (plate.isTyping) {
            const typingLine = document.createElement("div");
            typingLine.className = "typing-indicator";
            typingLine.textContent = "[...]";
            div.appendChild(typingLine);
        }

        container.appendChild(div);
    }
});