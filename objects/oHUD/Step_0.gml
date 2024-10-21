// Atualiza o temporizador
/*if (time > 0) {
    time -= delta_time * 0.001 / 1000;  // Diminui o tempo considerando o delta_time em segundos
} else {
    room_goto(Menu);  // Vai para a sala de menu se o tempo acabar
}

// Atualiza o valor de tempo mostrado (arredondando para cima)
showTime = ceil(time);
