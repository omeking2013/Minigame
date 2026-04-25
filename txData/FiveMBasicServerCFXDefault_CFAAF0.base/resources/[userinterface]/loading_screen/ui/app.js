let resourceName = '';
let loadedCount = 0;
let isLoaded = false;
let audioPlayer;

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.eventName === 'onDataFileEntry') {
        resourceName = data.name;
        loadedCount++;
        $(".load-text2").text(`${resourceName} : ${loadedCount}`);
    }

    if (data.eventName === 'loadProgress') {
        const percent = (data.loadFraction * 100).toFixed(0);
        $(".load-progress").css("width", percent + "%");
        $(".load-text").text(`Loading ${percent}%`);

        if (data.loadFraction >= 1 && !isLoaded) {
            isLoaded = true;
            $(".load-text2").text(`Loading assets Complete! ${loadedCount} files loaded.`);
            $(".start-game_button").fadeIn(500);
        }
    }
});

function initJs() {
    $(".logo").css("background-image", `url('assets/images/${LOGO_IMAGE}')`);
    playMusic(INTRO_SOUND, INTRO_VOLUME);

    $(".start-game_button").on('click', () => {
        $.post(`https://${GetParentResourceName()}/shutdownScreen`, {});
    });

    $(".mute_music").on('click', () => {
        if (audioPlayer) {
            if (audioPlayer.playing()) {
                audioPlayer.pause();
                $(".mute_music").text("Unmute Music");
            } else {
                audioPlayer.play();
                $(".mute_music").text("Mute Music");
            }
        }
    });
}

function playMusic(name, volume) {
    var vol = volume || 0.5;
    if (audioPlayer === undefined) {
        audioPlayer = new Howl({
            src: ["assets/sounds/" + name + ".mp3"],
            autoplay: false,
            loop: true,
            volume: vol,
            html5: true
        });
        audioPlayer.play();
    }
}

initJs();