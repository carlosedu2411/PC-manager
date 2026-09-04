async function updateMedia() {
    try {
        const media = await window.go.main.App.GetMedia();

        const titleEl = document.getElementById("title");
        const artistEl = document.getElementById("artist");
        const coverEl = document.getElementById("cover");

        // Se houver título válido (não vazio), exibe os dados. Se não, exibe o estado padrão.
        if (media && media.title && media.title.trim() !== "") {
            if (titleEl) titleEl.textContent = media.title;
            if (artistEl) artistEl.textContent = media.artist && media.artist.trim() !== "" ? media.artist : "Artista desconhecido";
            
            if (coverEl) {
                // Trata a imagem: valida se é URL/Path local ou Base64 vindo do Go
                if (media.cover && media.cover.trim() !== "") {
                    coverEl.src = media.cover.startsWith("data:") 
                        ? media.cover 
                        : `data:image/png;base64,${media.cover}`;
                } else {
                    coverEl.src = "/assets/default-cover.png";
                }
            }
        } else {
            if (titleEl) titleEl.textContent = "Nenhuma música";
            if (artistEl) artistEl.textContent = "Artista desconhecido";
            if (coverEl) coverEl.src = "/assets/default-cover.png";
        }
    } catch (err) {
        console.error("Erro ao atualizar mídia:", err);
        const titleEl = document.getElementById("title");
        const artistEl = document.getElementById("artist");
        if (titleEl) titleEl.textContent = "Erro ao carregar";
        if (artistEl) artistEl.textContent = "Tente recarregar a página";
    }
}

async function playPause() {
    try {
        await window.go.main.App.PlayPause();
        setTimeout(updateMedia, 500); // Pequeno delay para o sistema atualizar
    } catch (err) {
        console.error("Erro no Play/Pause:", err);
    }
}

async function next() {
    try {
        await window.go.main.App.Next();
        setTimeout(updateMedia, 500); // Pequeno delay pro Windows trocar de faixa antes de buscar
    } catch (err) {
        console.error("Erro no Next:", err);
    }
}

async function previous() {
    try {
        await window.go.main.App.Previous();
        setTimeout(updateMedia, 500);
    } catch (err) {
        console.error("Erro no Previous:", err);
    }
}

// Inicia o polling a cada 1 segundo e faz a primeira chamada
setInterval(updateMedia, 1000);
updateMedia();