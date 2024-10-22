var _mouse_sobre = position_meeting(mouse_x, mouse_y, id);
var _mouse_click = mouse_check_button_pressed(mb_left);

if(global.escolhe_player)
{
	if(_mouse_sobre){
		image_speed = .6;
	
		if(_mouse_click){
			global.player = player;	
		
			global.escolhe_player = false;
		}
	
	}else{
		image_speed = lerp(image_speed, 0, .1); 
	}
}else{
		room_goto_next();
}