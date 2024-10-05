// Decrease the image_alpha of the arc, ensuring it doesn't go below 0
image_alpha = max(0, image_alpha - 0.03);

// Check if the image_alpha is equal to or less than zero
if (image_alpha <= 0) 
{
    // Play a random arc attack impact sound
    audio_play_sound(choose(snd_impact_arc_01, snd_impact_arc_02), 1, false);
    
    // Destroy this arc
    instance_destroy(id);
} 
// Check if the image_alpha is less than or equal to 0.7 and make sure it hasn't already chained
else if (image_alpha <= 0.7 && !chained)
{
    // Check whether any chains remain, if none remain, exit.
    if (chains_remaining <= 0) 
    {
        exit;
    }

    /*
        Esta seção busca o inimigo mais próximo correto, se houver.
    */

    // Variáveis temporárias
    var _dist, _lowest, _lowest_val;
    
    // Armazena a id da instância do próximo inimigo correto a ser alvo
    _lowest = noone;
    
    // Armazena o valor de distância mais baixo a ser comparado
    _lowest_val = infinity;
    
    // Loop por todos os inimigos
    with (obj_enemy_parent) 
    {
        // Diz se o inimigo já foi alvo
        var _prev_target = false;
        
        // Loop por todos os inimigos já atingidos armazenados no array
        for (var i = 0; i < array_length(other.targets_hit_array); i += 1)
        {
            // Verifica se o inimigo já foi atingido
            if (other.targets_hit_array[i] == id) 
            {
                _prev_target = true;
                break;
            }
        }
        
        // Se já foi alvo, vai para o próximo inimigo
        if (_prev_target) continue;
        
        // Calcula a distância ao inimigo
        _dist = point_distance(x, y, other.target_x, other.target_y);
        
        // Verifica se está dentro do raio de 250px para encadear
        if (_dist > 250) continue;
        
        // Se for um inimigo novo e mais próximo que o último, salva a distância
        if (_lowest == noone || _dist < _lowest_val) 
        {        
            _lowest = id;
            _lowest_val = _dist;
        }
    }

    /*
        Esta seção dispara um arco se houver um alvo viável.
    */
    
    if (_lowest != noone) 
    {
        // Marca como encadeado para evitar encadeamento duplo
        chained = true;
        
        // Diminui o número de encadeamentos restantes
        chains_remaining -= 1;
        
        // Chama uma função customizada para causar dano ao inimigo
        deal_damage(_lowest, 2);
        
        // Cria uma instância de obj_arc_chain
        with (instance_create_depth(target_x, target_y - 125, target_depth, obj_arc_chain)) 
        {
            target = _lowest;
            
            // Copia o array de inimigos atingidos
            array_copy(targets_hit_array, 0, other.targets_hit_array, 0, array_length(other.targets_hit_array));
            
            // Adiciona o novo inimigo ao array para evitar que seja atingido novamente
            array_push(targets_hit_array, target);
            
            // Define os encadeamentos restantes para a nova instância
            chains_remaining = other.chains_remaining;
            
            // Define as coordenadas e profundidade do alvo
            target_x = target.x;
            target_y = target.y;
            target_depth = target.depth;
            
            // Define a direção do arco para o alvo
            image_angle = point_direction(x, y, target_x, target_y - 125);
            
            // Escala o arco com base na distância ao alvo
            image_xscale = point_distance(x, y, target_x, target_y - 125) / sprite_get_width(sprite_index);
        }
    }
}

// Inicialização das variáveis se necessário
target = noone;
chains_remaining = 0;
targets_hit_array = [];
chained = false;
target_x = x;
target_y = y;
target_depth = depth;

// Play a random arc attack sound
audio_play_sound(choose(snd_attack_arc_01, snd_attack_arc_02, snd_attack_arc_03), 10, false);
