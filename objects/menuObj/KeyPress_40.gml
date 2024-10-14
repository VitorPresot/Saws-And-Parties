if (keyboard_check_pressed(vk_down)) {
    index++;
    if (index > op_max - 1) {
        index = 0;  // Volta para o primeiro item se exceder o último
    }
}