# **Documentação do Jogo: Projeto Tower Defense**

### **Índice**
1. [Introdução](#introdução)
2. [Objetivo do Jogo](#objetivo-do-jogo)
3. [Mecânicas e Controles](#mecânicas-e-controles)
4. [Estrutura do Jogo](#estrutura-do-jogo)
5. [Objetos Principais e Código](#objetos-principais-e-código)
6. [Sons e Música](#sons-e-música)
7. [Fontes e Interface](#fontes-e-interface)
8. [Assets](#assets)
9. [Plano de Expansão e Melhorias Futuras](#plano-de-expansão-e-melhorias-futuras)

---

### **1. Introdução**
Esse projeto é um jogo de sobrevivencia ao estilo dos antigos fliperamas, onde o jogador controla personagens e coleta moedas enquanto foge de serras. O jogo está sendo desenvolvido em **GameMaker Studio 2** e visa aplicar conceitos básicos de movimentação, controle de variáveis globais, interface gráfica (HUD) e sons, além de funcionalidades específicas como pause de música, tela cheia, e reinício de jogo.

---

### **2. Objetivo do Jogo**
O objetivo é proteger o "core" do mapa (área central ou ponto de defesa) usando diferentes personagens e recursos, evitando que os inimigos cheguem a essa área. O jogador ganha pontos (ou moedas) conforme elimina inimigos, que podem ser usados para melhorar personagens ou comprar novos itens de defesa.

---

### **3. Mecânicas e Controles**
- **Movimentação do Personagem**: Controlada pelas setas direcionais `←` e `→`. Se o valor de `global.player` for `1`, as direções serão invertidas.
- **Reiniciar o Jogo**: Pressionar `F5` para reiniciar o jogo e restaurar todos os assets e variáveis.
- **Pause da Música e Reinício de Sala**: A música é pausada ao entrar em uma nova sala, e o jogo reinicia automaticamente após 5 segundos.
- **Tela Cheia**: Ativada ao pressionar `F11`.

---

### **4. Estrutura do Jogo**
O jogo é dividido nas seguintes salas (rooms):
- **Menu**: Tela de seleção de personagem e configuração inicial do jogo.
- **Sala de Seleção (personagemSelect)**: Permite ao jogador escolher o personagem desejado.
- **Salas de Jogo (Room1, Room2, Room3, Room4)**: Onde ocorrem as batalhas. Cada sala representa uma fase do jogo com nível de dificuldade crescente.
- **Room6**: Sala especial onde o jogo verifica condições de progresso ou término.

---

### **5. Objetos Principais e Código**

#### **Objetos**
- **`oPersonagem`**: Objeto que representa o personagem do jogador. Contém código de movimentação e de interação.
- **`contMoedas`**: Controla a contagem de moedas adquiridas pelo jogador e exibe no HUD.
- **`obj_timer`**: Cronômetro que exibe o tempo de jogo no HUD.

#### **Códigos Importantes**
- **Movimentação e Inversão de Direção**:
  ```gml
  if keyboard_check(vk_left) {
      x -= 2;
      image_xscale = global.player == 1 ? 0.35 : -0.35;
  }
  if keyboard_check(vk_right) {
      x += 2;
      image_xscale = global.player == 1 ? -0.35 : 0.35;
  }
  ```
- **Pause e Reinício de Sala**:
  ```gml
  audio_pause_sound(musicaJogo);
  alarm[0] = 5 * room_speed;  // Reinicia após 5 segundos
  ```

- **Desenho de HUD (Tempo e Moedas)**:
  ```gml
  // HUD para Tempo
  draw_set_font(ft_pixel);
  draw_set_color(c_white);
  draw_text(50, 50, "Time");
  draw_text(120, 50, string(showTime));

  // HUD para Moedas
  draw_text(50, 80, "Coins");
  draw_text(120, 80, string(global.moeda));
  ```

---

### **6. Sons e Música**
- **`musicaJogo`**: Música de fundo para as salas de jogo.
  - **Comandos**:
    - `audio_play_sound(musicaJogo,10,10,true);` - Inicia a música de fundo.
    - `audio_pause_sound(musicaJogo);` - Pausa a música ao mudar de sala.
- **Efeitos Sonoros (FX)**: Sons de ataque, moeda coletada, e fim de jogo (ainda em desenvolvimento).

---

### **7. Fontes e Interface**
- **Fontes**:
  - **ft_menu** e **ft_pixel** são usadas no HUD e nos textos do jogo.
  - **Instruções para Adicionar Fonte**: Fonte personalizada deve ser importada pelo painel de recursos do GameMaker e referenciada no código.
- **Interface HUD**:
  - Exibe informações de **"Time"** e **"Coins"** no canto superior esquerdo da tela.
  - Textos aplicam efeito de pixelização usando a fonte **ft_pixel** para dar um estilo retrô.

---

### **8. Assets**
- **Sprites**:
  - `moneda`: Ícone de moeda exibido no HUD.
  - `relogio`: Ícone de tempo exibido no HUD.
- **Configurações**:
  - Todos os sprites são configurados para escala de 0.35 para manter o estilo visual consistente.
  - A interface é desenhada usando o **Draw GUI** para garantir que ela seja redimensionada automaticamente em resoluções diferentes.

---

### **9. Plano de Expansão e Melhorias Futuras**
- **Novos Personagens e Habilidades**: Implementação de habilidades especiais e novos personagens jogáveis.
- **Sistema de Upgrade**: Permitir ao jogador usar moedas para melhorar atributos dos personagens.
- **Mais Níveis**: Adicionar novas salas com variações de dificuldade e mecânicas de defesa.
- **Sistema de Pontuação Global**: Adicionar tabela de classificação com pontuações dos jogadores.
- **Modo Multijogador**: Planejamento para implementar uma funcionalidade multiplayer.
