# Decisões

Por que o jogo é assim, e o que mudou desde a especificação.

A especificação original está em
[`quem-disse-isso-regras-e-arquitetura.md`](../quem-disse-isso-regras-e-arquitetura.md)
e continua valendo como documento de produto. **Ela não foi atualizada** desde
que a implementação começou, então onde os dois divergirem, o código é a
verdade e o motivo está registrado aqui.

Tudo abaixo é de setembro de 2026, durante a construção da v1.

---

## O que mudou em relação à especificação

### O dado virou duas roletas

**A especificação dizia:** um dado de seis faces modifica a rodada, e
explicitamente *não* escolhe a categoria — "o número de pacotes é variável".
O tema seria sorteado aleatoriamente entre os pacotes ativos.

**O que existe:** duas roletas. Uma sorteia o tema, a outra o modificador.

**Por quê:** o argumento contra o dado escolher categoria era o número variável
de pacotes — um dado tem seis faces fixas e não se adapta. Uma roleta não tem
esse problema: os setores são desenhados a partir dos pacotes ativos, então dois
pacotes viram duas metades e cinco viram cinco fatias.

Resolvido isso, sobrou um ganho que não estava previsto: **o sorteio de tema era
invisível**. O jogador via a frase aparecer sem saber de onde tinha vindo. Com a
roleta ele vê o tema ser sorteado, o que dá suspense a um passo que antes não
existia na tela.

O coringa continua igual: quando sai, o resultado da roleta de tema é descartado
e o jogador escolhe. Com um pacote só na partida o coringa não tem efeito sobre
o tema, e a tela diz isso em vez de prometer uma escolha que não vai acontecer.

**A probabilidade não mudou de lugar conceitualmente:** era a tabela de faces,
agora é a proporção de setores. Três setores "normal" em seis são os mesmos
50% das faces 1 a 3.

### Cronômetro de resposta

**Não estava na especificação.** Um contador corre enquanto a frase está na tela
e avisa quando o tempo acaba.

A regra que define o recurso: **esgotar o tempo não revela nada.** O aviso
aparece, a frase continua, e revelar segue sendo decisão da mesa. Isso mantém a
coerência com a validação por honra — o app nunca decide nada sozinho, só
informa.

Configurável por partida: sem tempo, 10, 15, 20 ou 30 segundos.

### Filtro de níveis de dificuldade

**Não estava na especificação.** As perguntas sempre tiveram `dificuldade`, mas
o campo só afetava pontuação. Agora a mesa escolhe quais níveis entram no
sorteio, com a contagem real de cada nível visível na tela.

Duas decisões dentro dessa:

**O filtro não mexe na pontuação.** Difícil continua valendo 2 pontos mesmo numa
partida só de difíceis. São dois eixos separados — um escolhe *quais* perguntas
entram, o outro *quanto valem*. Acoplar os dois tornaria o balanceamento
imprevisível.

**Nenhum nível marcado é erro, não é atalho para "todos".** Tratar vazio como
"todos" seria conveniente e esconderia um clique acidental.

### Errar encerra a rodada; roubo virou rodada da roleta

**A especificação dizia:** quando o jogador erra, entra uma carta especial —
Ajuda ou Roubo. Roubo era carta, e o setor 5 do dado apenas antecipava o direito
de roubar.

**O que existe:** errar encerra a rodada, sem ponto e sem segunda chance. Roubo
não é mais carta: é um setor da roleta, e quando ele sai **todos respondem desde
o começo**. A revelação pergunta "quem acertou primeiro?" em vez de julgar só o
jogador da vez, e quem a mesa apontar leva o ponto — inclusive o próprio jogador
da vez.

**Por quê:** decidido no playtest de setembro de 2026, com o jogo na mão. Carta a
cada erro fazia com que praticamente todo erro virasse uma segunda chance para a
mesa. Isso tirava o peso do erro, alongava demais a rodada e tornava a carta
banal — ela deixava de ser evento e virava rotina.

A regra nova concentra a disputa num lugar só: uma rodada em seis é aberta a
todos, anunciada antes de a frase aparecer. As outras cinco são do jogador da
vez, e errar tem consequência.

**A Ajuda ficou sem gatilho** e está desligada junto com Dica e Pulo, em
`CartaEspecial.nenhuma`. As três seguem implementadas e testadas; ligar é passar
um conjunto em `ConfigPartida.cartasAtivas`.

### As roletas viraram zapping de canais

**O que existia:** duas roletas — uma sorteava o tema, outra o modificador.

**O que existe:** uma TV que passa pelos canais e para em um, com a faixa do
modificador subindo por baixo quando o sinal fixa.

**Por quê:** está na legenda do próprio sistema visual — *"funciona igual com 4
ou 40 pacotes"*. A roleta tinha um teto: com quatro canais os setores já ficavam
apertados, e com dez o rótulo não caberia. O zapping não tem esse limite, e
ainda casa melhor com a marca, que é uma TV.

Ganho de lado: o sorteio ficou num gesto só em vez de dois, e o modificador
aparece como consequência do canal parar, não como um segundo evento.

**A tabela de modificadores mudou de nome, não de regra.** Já foi `Dado`, depois
`RoletaModificadores`; agora é `Modificadores`, com `entradas` em vez de
`setores`. O nome deixou de citar a tela de propósito: a apresentação mudou três
vezes e a regra nenhuma. A probabilidade continua sendo a proporção de entradas.

### Identidade visual: a TV é o balão de fala

A identidade veio pronta do Claude Design (projeto "Quem Disse Isso design",
arquivo `Sistema Visual Tubo.dc.html`) e foi aplicada como está. Duas ideias
sustentam tudo:

**A tela de TV é o balão de fala.** Todo conteúdo do jogo aparece dentro de um
retângulo com rabicho embaixo à esquerda. É o que faz o app ser reconhecível
numa miniatura de 48px.

**Cada pacote é um canal**, com número e cor próprios. Um pacote novo não
precisa de ilustração — só entra na fila de cores (`Cores.canais`). A mesma cor
aparece no bloco do setup, no setor da roleta de tema e no rótulo do balão, e
isso é o que permite o jogador reconhecer o pacote sem ler.

**A paleta tem papéis, não é uma lista de cores.** Amarelo é a ação principal e
só aparece uma vez por tela; ciano é o conteúdo do jogo; magenta é urgência,
erro e a sombra sólida; verde é acerto e mais nada. Trocar uma cor de papel
desmonta a leitura das telas — por isso `Cores` documenta cada uma.

**Texto sobre amarelo, magenta e ciano é sempre azul-tubo.** Branco nessas três
não passa em contraste. Foi o primeiro bug que apareceu na aplicação: o estilo
de título trazia cor branca por padrão e vencia o `foregroundColor` do botão.

**Tipografia embarcada, não baixada.** Archivo Black e Space Grotesk vão como
arquivo no APK (223 KB somados, com as licenças OFL). O app é offline: fonte de
CDN não é opção.

### Modo com alternativas

**A especificação dizia:** "modo múltipla escolha (o app corrige sozinho)" está
fora do escopo da v1.

**O que existe:** um interruptor no setup. Ligado, a frase vem com 5 opções de A
a E. **O app continua não corrigindo nada** — quem julga o acerto segue sendo a
mesa. As alternativas ajudam a lembrar, não substituem o julgamento.

Foi essa distinção que permitiu antecipar o recurso sem quebrar a validação por
honra nem a rodada de roubo, onde todos respondem em voz alta.

**As alternativas não são escritas à mão.** São montadas do próprio acervo: a
resposta certa mais quatro respostas de outras perguntas, **preferindo as do
mesmo pacote**. Num pacote de cinema os distratores são outros filmes; em
slogans, outras marcas. Isso significa que todo pacote existente e futuro ganha
o modo de graça, sem uma linha de conteúdo a mais.

As opções são montadas **uma vez, quando a pergunta é puxada**, e guardadas no
motor. Montá-las na tela faria a lista reembaralhar a cada rebuild — e a tela
reconstrói a cada segundo por causa do cronômetro.

As letras A a E existem porque o aparelho fica na mão de uma pessoa: sem elas,
ninguém consegue dizer em voz alta qual opção escolheu.

**Ponto de calibragem em aberto:** acertar com alternativa é bem mais fácil que
acertar sem, e hoje vale o mesmo. Se o modo virar o padrão da mesa, vale
considerar valer menos.

### Aviso sonoro no fim do tempo

O cronômetro passou a tocar um som e vibrar quando esgota. Numa mesa barulhenta
a barra na tela não chega a quem não está olhando o celular.

O som é sintetizado (duas notas descendentes, 0,5s) e mora em
`assets/som/tempo-esgotado.wav`. Ser gerado em vez de baixado evita qualquer
questão de licença.

**Falhar no áudio nunca derruba a rodada:** `AvisoDeTempo.tocar` engole a
exceção. Um aparelho no silencioso, sem permissão ou com o plugin indisponível
segue jogando normalmente — o aviso visual continua lá.

Isso não muda a regra: esgotar o tempo continua não revelando nada.

### Todos os pacotes gratuitos — por enquanto

A especificação previa "1–2 pacotes iniciais embutidos (a isca)". Hoje são
quatro, todos com `"gratuito": true`: Frases de Cinema, Frases Históricas,
Slogans Famosos e Bordões da TV, somando 120 perguntas.

**Isso é decisão de teste, não de produto.** Durante o playtest todo conteúdo
precisa estar disponível: variedade curta esconde problemas de balanceamento e
faz as frases repetirem antes de a partida terminar.

**A divisão entre grátis e pago fica para o lançamento**, quando houver dados de
quais pacotes a mesa mais pede. Quatro pacotes grátis é uma isca generosa demais
para vender — quem já tem 120 perguntas tem pouco motivo para comprar a
primeira.

Mudar de ideia é trocar `"gratuito": false` e acrescentar um `preco` no JSON do
pacote. Nenhuma linha de código muda, e o teste `pacotes_embutidos_test.dart`
tem uma checagem que assume todos gratuitos — ela vai falhar de propósito,
lembrando de revisar essa decisão.

---

## Perguntas que a especificação deixou em aberto

A seção 9 do documento listava quatro pendências. Três foram decididas:

**Stack.** Flutter, um código para Android e iOS. Era a opção que o próprio
documento apontava.

**Cartas Dica e Pulo na v1?** Não — e o playtest depois derrubou também Ajuda e
Roubo (ver acima). A v1 sai sem carta nenhuma. As três continuam implementadas e
testadas, desligadas em `CartaEspecial.nenhuma`.

**Balanceamento de pontos.** Decidido provisoriamente, à espera do playtest:

| Situação | Regra hoje |
|---|---|
| Acerto fácil ou médio | 1 ponto |
| Acerto difícil | 2 pontos |
| Modificador "dobro" | multiplica por 2 |
| Acerto em rodada de roubo | ponto integral para quem acertou primeiro |
| Ajuda certa (carta desligada) | ponto dividido; com base 1 o ajudante leva tudo |
| Dica usada | desconta 1, mínimo de 1 ponto |

A divisão da Ajuda é a mais arbitrária: com ponto base 1, a divisão inteira dá
zero para quem errou e um para quem ajudou. É o desempate mais simples, não o
mais justo. Ficou em suspenso junto com a carta.

**Calibragem da roleta** continua aberta — é a única que só se resolve jogando.

---

## Decisões de implementação que valem registro

**O roubo não tem corrida no app.** Não existe "quem aperta primeiro": a mesa
decide quem chegou antes e aponta na tela, como faria numa mesa de cartas. O app
continua sem arbitrar nada — coerente com a validação por honra.

**O motor lança `StateError` em ação fora de fase.** Poderia ignorar em silêncio.
Falhar alto faz o erro aparecer no teste em vez de virar bug silencioso.

**A tela sorteia antes de animar.** `sortearGiro` devolve o resultado, a tela
anima até ele e só então chama `aplicarGiro`. O contrário faria a roleta parar
num setor e o jogo aplicar outro.

**Sem pacote de gerência de estado.** `ChangeNotifier` e `InheritedNotifier` da
biblioteca padrão bastam para um app com uma máquina de estados e seis telas.

**Sem golden tests.** Quebram a cada ajuste de padding e o custo supera o
benefício num app deste tamanho. A UI é coberta por teste de fluxo, que verifica
comportamento e não aparência.

---

## Tentativas que não vingaram

**Pacote de música por título.** Chegou a existir um pacote de 40 músicas
brasileiras em que a frase era o título e a resposta o artista. Foi removido: o
título não é uma coisa que alguém "disse", e o jogo perdia a graça. A alternativa
óbvia — trechos de refrão — esbarra em direito autoral (ver
[`conteudo.md`](conteudo.md), seção 3). Slogans famosos ocuparam esse espaço e
funcionam melhor, porque slogan é feito para ser memorizado e repetido.

Se o tema música voltar, o caminho que não passa por letra nem por título é
descrever a canção — "a música que abre com um trem apitando". Muda o raciocínio
de reconhecimento para memória.

---

## Bugs que ensinaram algo

Registrados porque cada um revela uma armadilha que pode voltar.

**Tela cinza na inicialização.** `EstadoApp.gerenciador` era `late`. Quando a
busca pela pasta de downloads falhava — o que sempre acontece na web —, o campo
ficava sem valor e a tela inicial estourava ao lê-lo, escondendo justamente a
mensagem de erro que existia para esse caso. *Lição: campo `late` lido por uma
tela de erro é contradição. Hoje ele nasce com um gerenciador vazio.*

O `catch` também precisou virar `catch (_)`: `UnimplementedError` é `Error`, não
`Exception`, e escapava de `on Exception`.

**Rótulos espelhados na roleta.** A rotação do canvas usava `-π/2 − ângulo` em
vez de `ângulo + π/2`. Como um é o negativo do outro, os setores trocavam em
pares e **só o topo e a base ficavam certos, por acaso** — exatamente o que se
olha primeiro ao conferir na tela. *Lição: geometria merece função pura com
teste; conferir no olho não pega erro simétrico.*

**Coringa prometendo escolha inexistente.** Com um pacote só, o botão dizia
"Escolher o tema" e o motor ia direto para a frase. Apareceu como teste
intermitente, falhando em 1 de 6 execuções. *Lição: teste que falha às vezes
costuma ser bug de verdade num caminho raro, não flake.*

**Pacote novo vindo desmarcado.** As preferências guardavam os pacotes da partida
anterior, e qualquer pacote instalado depois ficava de fora. Num app freemium
isso é o pior caso possível: o jogador compra e não encontra. Hoje a regra
distingue "o jogador desligou" de "é novo". *Lição: preferência salva precisa
saber o que o usuário decidiu e o que ele nunca viu.*

---

## O que ainda não existe

- **Loja e compra no app.** Só a interface `CatalogoLoja` está definida. Exige
  conta de desenvolvedor e comissão das lojas — é o único custo real do projeto
  além do desenvolvimento.
- **Servidor de pacotes** para hospedar o que for comprado.
- **Chave de publicação.** O APK sai assinado com chave de debug; serve para
  testar, não para publicar.
- **Ícone e identidade visual.** O app usa o ícone padrão do Flutter.
- **Som e vibração.**
- Do roadmap da especificação: multiplayer online, múltipla escolha, modo solo e
  estatísticas em nuvem seguem fora de escopo.
