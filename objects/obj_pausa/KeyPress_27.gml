// Alterna o estado de pausa do jogo quando a tecla ESC é pressionada
global.jogo_pausado = !global.jogo_pausado;

// Pausa ou retoma todos os sons (opcional)
if (global.jogo_pausado) {
    audio_pause_all();
} else {
    audio_resume_all();
}
