const container = document.getElementById("nameplates");

window.addEventListener("message", function (event) {
    if (event.data.action !== "updateNameplates") return;

    container.innerHTML = "";

    for (const plate of event.data.nameplates) {
        const div = document.createElement("div");

        div.className = "nameplate";
        div.style.left = (plate.x * 100) + "vw";
        div.style.top = (plate.y * 100) + "vh";
        div.style.opacity = plate.opacity;
        div.textContent = plate.text;

        container.appendChild(div);
    }
});