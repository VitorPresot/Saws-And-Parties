if (keyboard_check_pressed(vk_f11)) {
    // Alterna entre fullscreen e janela
    if (window_get_fullscreen()) {
        window_set_fullscreen(false); // Muda para janela
    } else {
        window_set_fullscreen(true);  // Muda para fullscreen
    }
}
