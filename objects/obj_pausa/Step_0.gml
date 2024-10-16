// Se o jogo estiver pausado, desativa todas as instâncias, exceto o objeto de pausa
if (global.jogo_pausado) {
    instance_deactivate_all(true);  // Desativa todas as instâncias
    instance_activate_object(obj_pausa);  // Mantém o controle da pausa ativo
} else {
    instance_activate_all();  // Reativa todas as instâncias
}
