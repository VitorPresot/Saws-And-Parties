/// @description Inserir descrição aqui
// Você pode escrever seu código neste editor
var padding = 80;  // Espaçamento entre os elementos

// Calcula a posição central da tela para o timer
var pos_x = display_get_width() / 2;
var pos_y = padding;

// Desenha o sprite do relógio
draw_sprite(relogio, 0, pos_x - sprite_get_width(relogio) - 700, pos_y);

// Desenha o texto do tempo ao lado do sprite do relógio
draw_set_font(ft_menu);
draw_set_color(c_white);
draw_text(100,115, string(showTime));