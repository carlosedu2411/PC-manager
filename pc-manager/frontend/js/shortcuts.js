async function loadShortcuts() {

    const shortcuts =
        await window.go.main.App.GetShortcuts();

    const container =
        document.getElementById("shortcut-grid");

    container.innerHTML = "";

    shortcuts.forEach(shortcut => {

        const button = document.createElement("button");

        button.className = "shortcut";

        button.innerHTML = `
            <div class="shortcut-icon">
                <img src="${getIcon(shortcut.icon)}" alt="" aria-hidden="true">
            </div>

            <span>
                ${shortcut.name}
            </span>
        `;

        button.onclick = () => {
            window.go.main.App.OpenShortcut(shortcut.id);
        };

        container.appendChild(button);
    });
}

function getIcon(icon) {
    const icons = new Set(["discord", "chrome", "whatsapp", "league-of-legends"]);
    const selectedIcon = icons.has(icon) ? icon : "discord";

    return `/assets/icons/${selectedIcon}.svg`;
}

loadShortcuts();