window_set_size(1280, 720);
moeda = 0;
player = new personagem_Wallace();

switch(global.player){

	case 0: player = new personagem_Bruno(); break;
	case 1: player = new personagem_Wallace(); break;
}
