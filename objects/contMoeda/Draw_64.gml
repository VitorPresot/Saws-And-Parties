// Draw GUI (contMoeda)

var padding = 10;  // Espaçamento entre os elementos

// Calcula a posição central da tela para o contador de moedas, logo abaixo do timer
var pos_x = display_get_width() / 2;
var pos_y = padding + 50;  // Um pouco abaixo do timer

// Desenha o sprite da moeda
draw_sprite(sMoeda, 0, pos_x - sprite_get_width(sMoeda) - 50, pos_y);

// Desenha o texto das moedas ao lado do sprite da moeda
draw_set_color(c_white);
draw_text(pos_x, pos_y, string(global.moeda));  // Exibe o contador de moedas
