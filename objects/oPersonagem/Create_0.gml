window_set_size(1280, 720);
moeda = 0;
player = new personagem_Bruno();   

global.player = 0;

switch(global.player){
	case 0:  player = new personagem_Bruno();
	case 1:	 player = new personagem_Wallace();
}