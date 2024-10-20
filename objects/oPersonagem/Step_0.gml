// Step Event
/// @description Movimentação do personagem e controle de sprites

// Movimentação

if keyboard_check(vk_up) {
    y -= 1.2;
}

if keyboard_check(vk_down) {
    y += 1.2;
}

if keyboard_check(vk_left) {
    x -= 1.2;
    image_xscale = -0.35; // Inverter sprite ao ir para a esquerda
}

if keyboard_check(vk_right) {
    x += 1.2;
    image_xscale = 0.35;  // Manter sprite na direção original
}

// Limitar o movimento do personagem dentro da sala com ajustes nas bordas

// Aumentar o limite superior (mais espaço no teto)
if y < -50 {  // O valor -50 aumenta a "parede" do teto
    y = -50;
}

// Aumentar o limite da esquerda (mais espaço à esquerda)
if x < -50 {  // O valor -50 aumenta a "parede" da esquerda
    x = -50;
}

// Diminuir o limite inferior (menos espaço na parte de baixo)
if y > room_height - sprite_height + 25 {  // O valor +20 diminui a "parede" inferior
    y = room_height - sprite_height + 25;
}

// Diminuir o limite da direita (menos espaço à direita)
if x > room_width - sprite_width + 43 // O valor +20 diminui a "parede" da direita
    x = room_width - sprite_width + 43;


// Mudar de sala ao pegar 16 moedas


// Verifica se alguma tecla de movimento está pressionada
if keyboard_check(vk_up) || keyboard_check(vk_down) || keyboard_check(vk_left) || keyboard_check(vk_right) {
    sprite_index = sPersonagemCorre; // Sprite de correr
} else {
    sprite_index = sPersonagem; // Sprite de parada
}
