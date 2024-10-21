// Definir espaçamento e posição inicial
/*var padding = 20;  // Espaçamento entre os elementos
var right_x = display_get_width() - padding;  // Posição X no canto direito da tela
var top_y = padding;  // Posição Y no canto superior

// --- Desenhar o Timer ---
var timer_sprite_size = 60;  // Tamanho do sprite do timer

// Desenhar o sprite do relógio
draw_sprite_ext(relogio, 0, right_x - timer_sprite_size, top_y, timer_sprite_size / sprite_get_width(relogio), timer_sprite_size / sprite_get_height(relogio), 0, c_white, 1);

// Desenhar o texto do tempo ao lado do sprite do relógio
draw_set_font(ft_menu);
draw_set_color(c_white);
draw_text(right_x - timer_sprite_size - padding * 2, top_y + (timer_sprite_size / 2) - 10, string(showTime));  // Ajusta para centralizar o texto verticalmente

// --- Desenhar a Contagem de Moedas ---
var moeda_sprite_size = 100;  // Tamanho do sprite de moedas
var moeda_y = top_y + timer_sprite_size + padding;  // Posição Y abaixo do timer

// Desenhar o sprite da moeda
draw_sprite_ext(sMoeda, 0, right_x - moeda_sprite_size, moeda_y, moeda_sprite_size / sprite_get_width(sMoeda), moeda_sprite_size / sprite_get_height(sMoeda), 0, c_white, 1);

// Desenhar o texto das moedas ao lado do sprite da moeda
draw_set_color(c_white);
draw_text(right_x - moeda_sprite_size - padding * 2, moeda_y + (moeda_sprite_size / 2) - 10, string(global.moeda));  // Ajusta para centralizar o texto verticalmente
