# Plano — telas que faltam

Estado da aplicação do design do Claude Design (projeto *Quem Disse Isso design*)
tela a tela. Cada arquivo `NN Nome.dc.html` é a fonte da verdade: ele traz os
valores exatos, e é sempre melhor lê-lo do que medir pixel num print.

**Método que funcionou**, e que vale repetir em cada tela:

1. Ler o `.dc.html` da tela pelo MCP do Claude Design.
2. Listar as diferenças concretas contra o código atual — não impressões.
3. Implementar.
4. Renderizar em 320×640 (a caixa do desenho) com um teste descartável de
   golden e **olhar a imagem**. Foi assim que apareceram o balão amarelo em vez
   de ciano, o "✓" virando quadrado e o "ACERTOU" quebrando em duas linhas.
5. Apagar o teste descartável, rodar a suíte, publicar.

---

## Situação

| Tela | Arquivo | Estado |
|---|---|---|
| Home | `01 Home.dc.html` | ✅ fiel |
| Sorteio | `03 Sorteio.dc.html` | ✅ fiel |
| Revelação | `05 Revelacao.dc.html` | ✅ fiel |
| Nova partida | `02 Nova Partida.dc.html` | ⬜ falta |
| Pergunta | `04 Pergunta.dc.html` | 🟨 quase |
| Placar (folha) | `06 Placar.dc.html` | ⬜ falta |
| Entre rodadas | `07 Entre Rodadas.dc.html` | ⬜ falta |
| Fim de jogo | `08 Fim de Jogo.dc.html` | ⬜ falta |

Não lidos ainda: `Identidade Visual.dc.html` e `Sorteador.dc.html`.

---

## 1. Pergunta — `04 Pergunta.dc.html`

O menor esforço da lista: a tela já está quase certa.

- **O balão não tem rabicho aqui.** `BalaoDeFala` sempre desenha o rabicho; na
  tela de pergunta o desenho usa só o retângulo com sombra. Precisa de um
  parâmetro `comRabicho`.
- **Falta o estado "sem alternativas".** Quando a partida roda sem opções, o
  desenho preenche o espaço com um texto centralizado: *"Sem alternativas nesta
  partida. Leonel responde em voz alta e a mesa julga."* Hoje fica um vazio.

Nada mais diverge: barra de tempo, linha do jogador com o selo do modificador,
alternativas e CTA já batem.

## 2. Entre rodadas — `07 Entre Rodadas.dc.html`

- **O líder tem fundo amarelo**, com número, nome e pontos em azul-tubo. Os
  demais ficam em `#1B2ACF`. Hoje todos são iguais.
- Título em duas linhas: `COMO ESTÁ` / `O JOGO`, Archivo Black 26.
- Linhas mais altas (padding 14×13, raio 12), nome 16px peso 700, pontos em
  Archivo Black 22.
- **Rodapé é um cartão**, não um texto solto: círculo colorido de 26px +
  "Agora é a vez de **Clovis**", com o nome em branco no meio da frase.
- **O rótulo do botão volta a ser "PASSAR O CELULAR"** — é o padrão deste
  arquivo. Eu tinha trocado para "Próxima rodada" com base no documento antigo.

## 3. Placar — `06 Placar.dc.html`

É uma folha sobre a rodada, e o desenho mostra dois detalhes que hoje faltam:

- **O fundo escurece**: `rgba(10,15,60,.72)` sobre a tela, que continua visível
  a 35% de opacidade atrás.
- **Alça de arrastar**: 44×4, raio 2, `rgba(242,245,255,.35)`, centralizada.
- Folha em `#1B2ACF` com raio 24 só no topo; linhas em `#0A0F3C` (o inverso da
  tela de entre rodadas).
- Pontos do líder em amarelo; dos demais em branco.
- Rodapé: "Meta: 10 pontos · 87 frases ainda no sorteio".

## 4. Fim de jogo — `08 Fim de Jogo.dc.html`

A segunda tela que troca de canal inteira: **fundo amarelo**, scanlines escuras
a 5%.

- "FIM DE JOGO" centralizado no topo, 12px, espaçamento largo, azul-tubo.
- **Selo "!!"** — o mesmo balão da marca, invertido: caixa azul-tubo 66×54 com
  o texto em amarelo e rabicho de 12px. Dá para reaproveitar `SeloDaMarca` com
  cores por parâmetro.
- Nome do vencedor em Archivo Black **46px**, azul-tubo, sombra magenta.
- **Linha de estatística**: *"10 pontos, 3 roubos e nenhuma vergonha na cara."*
  O app não conta roubos. É preciso somar um contador no motor, ou trocar a
  frase por algo que já se saiba.
- Ranking do 2º para baixo: o segundo lugar tem fundo azul-tubo cheio; os
  demais, `rgba(10,15,60,.14)` com texto escuro.
- "REVANCHE" é azul-tubo com texto amarelo (não o amarelo padrão), e "Voltar ao
  início" é texto em `#3B3208`.

## 5. Nova partida — `02 Nova Partida.dc.html`

A maior da lista, e a que mais diverge. Vale quebrar em partes.

**Cabeçalho** — "NOVA PARTIDA" em Archivo Black 15 branco, seta à esquerda e um
vão de 19px à direita para centralizar. Hoje usa a barra padrão.

**Jogadores** — cada linha ganha um **ponto colorido de 14px** com a cor do
canal na ordem (amarelo, ciano, magenta, verde…). Fundo `#1B2ACF`, raio 10,
padding 11×13, nome 14px, "✕" em `#8290DE`. O botão de adicionar tem **borda
tracejada** de 1,5px, não é um `TextButton` com ícone.

**Canais** — hoje são blocos de 156px em duas colunas. No desenho são **quatro
lajotas numa linha só**, cada uma `flex:1`: número em Archivo Black 20 e nome em
11px, ambos azul-tubo sobre a cor do canal. Desligado vira `#1B2ACF` a 60% de
opacidade com texto `#A9B4F0`.

Isso obriga a **encurtar o nome do canal**: o desenho usa "Bordões", "Cinema",
"História", "Slogans". Duas saídas — um campo `nome_curto` no pacote, ou cortar
na primeira palavra útil. O campo é mais honesto e serve à loja depois.

Com muitos canais a linha única não cabe; a regra precisa ser: até 4 numa linha,
acima disso quebra em duas.

**Como termina / Alternativas** — os dois usam o mesmo componente: uma pílula
`#1B2ACF` com padding 4, e a opção ativa vira um retângulo amarelo de raio 7 com
texto azul-tubo. Hoje é o `SegmentedButton` do Material, que não tem essa cara.

**O alvo de pontos não é um `Slider`** — é uma **barra de progresso** de 6px com
o número ao lado em Archivo Black 16 amarelo. O ajuste precisa virar toque na
barra ou arraste, não o controle padrão.

**Dificuldade e Tempo ficam lado a lado**, duas colunas de largura igual. As
fichas de dificuldade são **coloridas quando ligadas** — Fácil verde, Média
amarela, Difícil magenta — e não a cor única de hoje. As de tempo ligam em
amarelo.

**Rodapé** — "COMEÇAR" fixo embaixo com padding 20, fora da área rolável.

---

## Ordem sugerida

1. **Pergunta** — duas correções pequenas, fecha uma tela.
2. **Entre rodadas** — média, e devolve o rótulo certo ao botão.
3. **Fim de jogo** — média; decidir antes o que fazer com "3 roubos".
4. **Placar** — média, depende de mexer na folha modal.
5. **Nova partida** — a maior; provavelmente vale um dia só para ela.

## Decisões que precisam de você

- **Nome curto de canal.** Criar `nome_curto` no formato do pacote, ou derivar
  cortando? Afeta o arquivo de conteúdo e a loja.
- **Contador de roubos.** Somar ao motor para a frase do fim de jogo, ou trocar
  a frase?
- **"Passar o celular" ou "Próxima rodada"?** O arquivo tem os dois; o padrão é
  o primeiro.
- **Continuar partida.** O `01 Home.dc.html` prevê o botão, mas o app não salva
  partida em andamento. É funcionalidade nova, não visual.
