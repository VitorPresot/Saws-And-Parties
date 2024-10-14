if (keyboard_check_pressed(vk_up)) {
    index--;
    if (index < 0) {
        index = op_max - 1;  // Vai para o último item se for menor que 0
    }
}