// Evento de colisão com o objeto oPersonagem 

// Verifica se o outro objeto é o personagem
if (other.object_index == oPersonagem) {
    // Incrementa o contador de moedas no objeto global
    global.moeda += 1;  // Incrementa o contador global de moedas

    // Toca o som da moeda ao coletar
    audio_play_sound(somMoeda, 1, false);  // 'somMoeda' é o nome do som, volume 1, não em loop

    // Destrói a moeda após ser coletada
    instance_destroy();
}
