# Saws and Parties - LÖVE2D

Conversão do jogo para Lua usando LÖVE2D 11.5. O jogo usa os sprites, sons e
fontes originais, mas não depende mais do projeto GameMaker.

## Executar

Instale o [LÖVE2D 11.5](https://love2d.org/) e execute na raiz:

```sh
love .
```

## Controles

| Ação | Teclas |
| --- | --- |
| Mover | Setas ou WASD |
| Selecionar personagem | Esquerda/Direita ou A/D |
| Confirmar | Enter ou Espaço |
| Pausar | Esc |
| Reiniciar/voltar à seleção | F5 |
| Tela cheia | F11 |

### Gamepad

O jogo aceita controles reconhecidos pelo LÖVE2D como gamepad e também usa
eixos/botões brutos como fallback para controles genéricos:

| Ação | Gamepad |
| --- | --- |
| Mover | Analógico esquerdo ou D-pad |
| Selecionar personagem | Analógico esquerdo, D-pad ou bumpers |
| Confirmar | A ou Start |
| Voltar | B |
| Pausar | Start ou Back |

Cada fase possui 12 moedas e serras móveis. Colete todas as moedas antes do
tempo acabar para avançar pelas seis fases. Depois da sexta fase, enfrente o
boss final e sobreviva ao padrão coordenado de motosserras.

Antes de cada fase, uma contagem regressiva de 3, 2 e 1 prepara o jogador.
As fases alternam entre as músicas `Final_Quarter_Dash.mp3` e
`Frame_Perfect.mp3`, ambas reproduzidas em loop.

O menu possui opções para ligar/desligar música, alternar tela cheia e ver os
créditos. A música `High_Score_Serenade.mp3` toca em loop no menu.

## Créditos

Vitor Presot, Bruno Nunes, Vinicius Lucena, Rafael Lisboa, Luis Gustavo e
Lucas Mota.
