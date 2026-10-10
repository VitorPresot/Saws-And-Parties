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
tempo acabar para avançar pelas quatro fases. Colidir com uma serra ou deixar
o cronômetro terminar retorna à seleção.
