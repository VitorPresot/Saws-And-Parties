// Definindo o texto a ser desenhado
var texto = "Olá, Mundo!";

// Definindo a fonte
draw_set_font(ft_menu);

// Calculando a largura do texto
var largura_texto = string_width(texto);

// Desenhando o texto no centro superior da tela
draw_text((display_get_width() - largura_texto) / 2, 10, texto);
