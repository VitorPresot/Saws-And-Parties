if (mytime5 > 0) {
    mytime5 -= delta_time * 0.001 / 1000;  // Reduz o tempo com delta_time em segundos
} else {
	global.escolhe_player = true;
	room_goto(personagemSelect);
}

// Atualiza o valor de tempo mostrado (arredondando para cima)
showTime = ceil(mytime5);