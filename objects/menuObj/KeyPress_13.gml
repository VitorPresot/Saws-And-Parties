if (keyboard_check_pressed(vk_enter)) {
    if (index == 0) {
        room_goto_next();  // Muda para a próxima sala (Jogar)
    } else if (index == 1) {
        // Lógica para "Opções" (Aqui você pode abrir uma nova sala ou uma interface de opções)
        room_goto(rOpcoes);  // Exemplo de mudança de sala para o menu de opções
    }
}

/*
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

*/