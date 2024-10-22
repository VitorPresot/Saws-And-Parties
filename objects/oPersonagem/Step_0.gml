// Step Event
/// @description Movimentação do personagem e controle de sprites

// Movimentação

if keyboard_check(vk_up) {
    y -= 2;
}

if keyboard_check(vk_down) {
    y += 2;
}

if (global.player == 1) {
    // Inverter as funções quando global.player é igual a 1
    if keyboard_check(vk_left) {
        x -= 2; // Move para a direita ao pressionar a seta esquerda
        image_xscale = 0.35; // Mantém o sprite na direção original
    }
    
    if keyboard_check(vk_right) {
        x += 2; // Move para a esquerda ao pressionar a seta direita
        image_xscale = -0.35; // Inverte o sprite ao ir para a direita
    }
} else {
    // Comportamento normal (sem inversão)
    if keyboard_check(vk_left) {
        x -= 2; // Move para a esquerda
        image_xscale = -0.35; // Inverte o sprite ao ir para a esquerda
    }
    
    if keyboard_check(vk_right) {
        x += 2; // Move para a direita
        image_xscale = 0.35; // Mantém o sprite na direção original
    }
}

// Limitar o movimento do personagem dentro da sala com ajustes nas bordas

// Aumentar o limite superior (mais espaço no teto)
if y < 15 {  // O valor -50 aumenta a "parede" do teto
    y = 15;
}

// Aumentar o limite da esquerda (mais espaço à esquerda)
if x < 7 {  // O valor -50 aumenta a "parede" da esquerda
    x = 7;
}

// Diminuir o limite inferior (menos espaço na parte de baixo)
if y > room_height - sprite_height + 50 {  // O valor +20 diminui a "parede" inferior
    y = room_height - sprite_height + 50;
}

// Diminuir o limite da direita (menos espaço à direita)
if x > room_width - sprite_width + 50 // O valor +20 diminui a "parede" da direita
    x = room_width - sprite_width + 50;


// Mudar de sala ao pegar 16 moedas


// Verifica se alguma tecla de movimento está pressionada
if keyboard_check(vk_up) || keyboard_check(vk_down) || keyboard_check(vk_left) || keyboard_check(vk_right) {
    sprite_index = player.sprite_walk; // Sprite de correr
} else {
    sprite_index = player.sprite_idle;// Sprite de parada
}


