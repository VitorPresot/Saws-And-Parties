draw_set_font(ft_menu);
draw_set_color(c_white);
var padding = 400;
var dist = 50;
var gui_largura = display_get_gui_width();
var gui_altura = display_get_gui_height();
var x1 = gui_largura / 2;
var y1 = gui_altura / 2;

for (var i = 0; i < op_max; i++) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    if (index == i) {
        draw_set_color(c_yellow);  // Destaca a opção selecionada
    } else {
        draw_set_color(c_white);  // Opção não selecionada
    }

    draw_text(x1, y1 + (dist * i), opcoes[i]); // Desenha o texto das opções
}

draw_set_font(ft_menu);

draw_text(660,605,"Jogar")