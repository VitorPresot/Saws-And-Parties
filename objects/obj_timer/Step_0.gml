if (global.mytime > 0) {
    global.mytime -= delta_time * 0.001 / 1000;  // Reduz o tempo com delta_time em segundos
} else {
    room_goto(Menu);  // Vai para a sala de menu (use o nome exato da sala)
}

// Atualiza o valor de tempo mostrado (arredondando para cima)
showTime = ceil(global.mytime);