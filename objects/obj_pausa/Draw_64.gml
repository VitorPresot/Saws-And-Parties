// Verifica se o jogo está pausado
if (global.jogo_pausado) {
    draw_set_font(ft_menu);  // Define a fonte como ft_menu
    draw_set_color(c_white);  // Define a cor do texto

    var text = "Game Paused";  // Mensagem de pausa
    var gui_width = display_get_gui_width();  // Largura da GUI
    var gui_height = display_get_gui_height();  // Altura da GUI

    // Desenha o texto "Game Paused" no centro da tela
    draw_text(gui_width / 2, gui_height / 2, text);
    
    draw_set_halign(fa_center);  // Centraliza o alinhamento horizontal
    draw_set_valign(fa_middle);  // Centraliza o alinhamento vertical
}
