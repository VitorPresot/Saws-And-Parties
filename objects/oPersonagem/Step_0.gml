/// @description Movimentação do personagem e controle de sprites

// Movimentação
if keyboard_check(vk_up){
    y -= 1;
}

if keyboard_check(vk_down) {
    y += 1;
}

if keyboard_check(vk_left) {
    x -= 1;
    image_xscale = -0.35; // Inverter sprite ao ir para a esquerda
}

if keyboard_check(vk_right) {
    x += 1;
    image_xscale = 0.35;  // Manter sprite na direção original
}

// Mudar de sala ao pegar 12 moedas
if moeda >= 16 {
    room_goto_next();
}

// Verifica se alguma tecla de movimento está pressionada
if keyboard_check(vk_up) || keyboard_check(vk_down) || keyboard_check(vk_left) || keyboard_check(vk_right) {
    sprite_index = sPersonagemCorre; // Sprite de correr
} else {
    sprite_index = sPersonagem; // Sprite de parada
}