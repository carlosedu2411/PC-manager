function updateClock() {

    const now = new Date();

    const hours =
        String(now.getHours()).padStart(2, "0");

    const minutes =
        String(now.getMinutes()).padStart(2, "0");

    document.getElementById("clock").textContent =
        `${hours}:${minutes}`;
}

setInterval(updateClock, 1000);

updateClock();

let volumeLevel = 100;
const wallpaperStorageKey = "pc-carplay-wallpaper";

function applyWallpaper(wallpaper) {
    document.body.style.setProperty("--wallpaper", `url("${wallpaper}")`);
}

try {
    const savedWallpaper = localStorage.getItem(wallpaperStorageKey);
    if (savedWallpaper) applyWallpaper(savedWallpaper);
} catch (error) {
    console.warn("Nao foi possivel restaurar o wallpaper.", error);
}

function updateVolumeLabel() {
    document.getElementById("volume").textContent = `${volumeLevel}%`;
}

async function changeVolume(direction) {
    volumeLevel = Math.max(0, Math.min(100, volumeLevel + direction * 2));
    updateVolumeLabel();
    await window.go.main.App[direction > 0 ? "VolumeUp" : "VolumeDown"]();
}

async function toggleMute() {
    await window.go.main.App.ToggleMute();
}

function openNotifications() {
    window.go.main.App.OpenNotifications();
}

function openFocusSettings() {
    window.go.main.App.OpenFocusSettings();
}

async function toggleFullscreen() {
    const isFullscreen = await window.runtime.WindowIsFullscreen();
    if (isFullscreen) {
        window.runtime.WindowUnfullscreen();
        document.getElementById("fullscreen-button").textContent = "Tela cheia";
    } else {
        window.runtime.WindowFullscreen();
        document.getElementById("fullscreen-button").textContent = "Sair da tela cheia";
    }
}

document.getElementById("wallpaper-input").addEventListener("change", event => {
    const file = event.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = () => {
        const wallpaper = reader.result;
        applyWallpaper(wallpaper);

        try {
            localStorage.setItem(wallpaperStorageKey, wallpaper);
        } catch (error) {
            console.warn("Nao foi possivel salvar o wallpaper.", error);
        }
    };
    reader.readAsDataURL(file);
});

document.addEventListener("keydown", event => {
    if (event.key === "F11") {
        event.preventDefault();
        toggleFullscreen();
        return;
    }

    if (!event.ctrlKey || !event.altKey) return;

    if (event.key === "ArrowUp") changeVolume(1);
    if (event.key === "ArrowDown") changeVolume(-1);
    if (event.key.toLowerCase() === "m") toggleMute();
});