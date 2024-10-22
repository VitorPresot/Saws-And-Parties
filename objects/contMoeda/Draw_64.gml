
/*// Configurações de espaçamento e posição
var padding = 120;  // Espaçamento entre os elementos
var pos_x = 20;     // Posição no canto superior esquerdo
var pos_y = padding;

// Define a fonte e cor do texto
draw_set_font(ft_menu);  // Certifique-se de usar uma fonte de estilo pixelado
draw_set_color(c_white);

// Desenha o texto "Coins" no canto superior esquerdo
draw_text(pos_x, pos_y - 40, "Coins");  // Ajuste a posição do texto para caber bem

// Desenha o número de moedas ao lado da palavra "Coins"
draw_text(pos_x + 100, pos_y - 40, string(global.moeda));  // 100 px de espaçamento após o texto "Coins"
