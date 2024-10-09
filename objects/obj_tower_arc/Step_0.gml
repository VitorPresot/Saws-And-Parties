// Define a profundidade com base na posição y
depth = -y;

// Define o cálculo da distância um pouco acima da base do sprite
var _target_y = y - 39;

/*
    Esta seção encontra o alvo mais distante
    no caminho (ou seja, mais próximo da vila)
*/

// Declarar variáveis temporárias
var _farthest, _farthest_val;

// Esta variável armazena a id do próximo inimigo correto a ser alvo
_farthest = noone;

// Esta variável armazena a distância para o inimigo mais distante, começando em 0
_farthest_val = 0;

// Loop por todos os inimigos atuais
with (obj_enemy_parent) 
{
    // Valor da equação da elipse para checar a colisão com o range do ataque
    var _check_ellipse_collision = (sqr(x - other.x)/sqr(other.range)) + (sqr(y - _target_y)/sqr(other.range * 0.75));
    
    // Checa se o inimigo está no range com base no valor calculado
    if (_check_ellipse_collision < 1)
    {
        // Verifica se este é o primeiro inimigo ou se está mais adiante no caminho
        if (_farthest == noone || path_position > _farthest_val) 
        {        
            // Salva a id como o inimigo mais distante
            _farthest = id;
        
            // Salva a distância para comparação com o próximo inimigo
            _farthest_val = path_position;
        }
    }
}

/*
    Esta seção usará a id do inimigo mais distante
    e disparará nele, se a torre estiver pronta para atirar.
*/

// Verifica se encontramos um inimigo para mirar e se estamos prontos para atirar
if (_farthest != noone && ready_to_fire)
{
    // Começa o carregamento
    power_level += power_charge;

    // Quando a torre estiver carregada, ela estará pronta para atirar
    if (power_level >= 1) 
    {
        // Causa dano imediatamente
        deal_damage(_farthest, 2);
        
        // Reseta o nível de poder
        power_level = 0;
        
        // Define ready_to_fire como falso para evitar disparos consecutivos
        ready_to_fire = false;
        
        // Define o alarme para o tempo de espera de disparo
        alarm[0] = fire_delay;
        
        // Cria uma nova camada logo acima da atual
        var _layer = layer_create(depth - 1);
        
        // Cria a sequência de fade do tiro
        layer_sequence_create(_layer, x, y, seq_arc_fire_fade);
        
        // Calcula a direção do inimigo, ajustando o valor de y
        var _dir = point_direction(x, y - 122, _farthest.x, _farthest.y - 125);    
        
        // Cria a sequência de tiro e salva a id da sequência
        var _seq = layer_sequence_create(_layer, x, y - 122, seq_arc_fire);
        
        // Define o ângulo da sequência de acordo com a direção calculada
        layer_sequence_angle(_seq, _dir);
        
        // Cria uma nova instância do arco e usa "with" para acessar suas variáveis
        with (instance_create_depth(x, y - 134, depth, obj_arc_new)) 
        {
            // Define o alvo como o inimigo mais distante
            target = _farthest;
            
            // Adiciona a id do inimigo ao array para que não seja atingido novamente
            array_push(targets_hit_array, target);
            
            // Define a quantidade de encadeamentos restantes com base no arco que o criou
            chains_remaining = other.chain_amount;
            
            // Define as coordenadas e profundidade do alvo
            target_x = target.x;
            target_y = target.y;
            target_depth = target.depth;
            
            // Faz o arco apontar para o alvo
            image_angle = point_direction(x, y, target_x, target_y - 125);
            
            // Ajusta a escala do arco com base na distância até o alvo
            image_xscale = point_distance(x, y, target_x, target_y - 125) / sprite_get_width(sprite_index);
            
            // Cria uma nova instância do arco de impacto e define sua escala
            with (instance_create_depth(_farthest.x, _farthest.y - 125, _farthest.depth - 15, obj_arc_hit))
            {
                // Define a escala para o lado correto (direita/esquerda)
                image_xscale = ((_dir > 90) && (_dir < 270)) ? -1 : 1;
            }
        }
    }
} 
else 
{
    // Reduz o nível de poder se não houver alvo ou não estiver pronto para disparar
    power_level -= power_charge;
}

// Mantém o nível de poder entre 0 e 1
power_level = clamp(power_level, 0, 1);

// *** NOVA LÓGICA PARA INVERTER IMAGEM ***

// Se o objeto está no lado negativo do eixo x, inverta a imagem
if (x < 0) 
{
    image_xscale = -abs(image_xscale);  // Inverte a imagem se o x for negativo
}
else 
{
    image_xscale = abs(image_xscale);   // Mantém a imagem normal se o x for positivo
}
