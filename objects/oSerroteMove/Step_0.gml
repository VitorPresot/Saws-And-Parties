// Atualiza as posições X e Y do objeto com a velocidade
x += hsp;
y += vsp;

// Verifica os limites horizontais (para a largura da room)
if (x < 0) {
    hsp = -hsp;  // Inverte a direção horizontal
    x = 0;       // Garante que não ultrapasse a borda esquerda
}

if (x > room_width - sprite_width) {
    hsp = -hsp;  // Inverte a direção horizontal
    x = room_width - sprite_width;  // Garante que não ultrapasse a borda direita
}

// Verifica os limites verticais (para a altura da room)
if (y < 0) {
    vsp = -vsp;  // Inverte a direção vertical
    y = 0;       // Garante que não ultrapasse a borda superior
}

if (y > room_height - sprite_height) {
    vsp = -vsp;  // Inverte a direção vertical
    y = room_height - sprite_height;  // Garante que não ultrapasse a borda inferior
}
