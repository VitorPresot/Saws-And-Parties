if (keyboard_check_pressed(vk_enter)) {
    if (index == 0) {
        room_goto_next();  // Muda para a próxima sala (Novo Jogo)
    } else if (index == 1) {
        // Lógica para "Carregar jogo"
    } else if (index == 2) {
        // Lógica para "Opções"
    } else if (index == 3) {
        game_end();  // Sai do jogo
    }
}
