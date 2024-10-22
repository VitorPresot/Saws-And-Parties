// Configurações de espaçamento e posição
/*
var padding = 80;   // Espaçamento entre os elementos
var pos_x = 20;     // Posição no canto superior esquerdo
var pos_y = padding;

// Define a fonte e cor do texto
draw_set_font(ft_menu);  // Usando a mesma fonte estilo pixelado
draw_set_color(c_white);

// Desenha o texto "Time" no canto superior esquerdo
draw_text(pos_x, pos_y, "Time");  // Ajuste a posição do texto "Time"

// Desenha o tempo ao lado da palavra "Time"
draw_text(pos_x + 100, pos_y, string(showTime));  // 100 px de espaçamento após o texto "Time"
