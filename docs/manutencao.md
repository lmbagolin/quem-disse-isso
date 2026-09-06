# Manutenção

Como mexer neste código sem quebrar o que já funciona.

---

## 1. Ambiente

O projeto não exige nada de exótico, mas o Android precisa de **JDK 17 ou
superior** — o Java 11 do sistema não compila com o Gradle desta versão.

Nesta máquina o ambiente está instalado na home, sem `sudo` e sem interferir no
Java do sistema:

| Ferramenta | Caminho | Como o Flutter acha |
|---|---|---|
| Flutter SDK | `~/development/flutter` | precisa estar no `PATH` |
| JDK 17 | `~/development/jdk17` | `flutter config --jdk-dir` |
| Android SDK | `~/Android/Sdk` | `flutter config --android-sdk` |

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
flutter doctor          # Android toolchain tem que dar ✓
```

O toolchain de Linux desktop aparece com ✗ no doctor. É esperado e não atrapalha
— faltam pacotes de sistema (`clang`, `cmake`, `ninja`) que só servem para rodar
o app como aplicativo de desktop, algo que não fazemos.

## 2. Rodar e verificar

```bash
flutter analyze         # tem que terminar em "No issues found!"
flutter test            # 66 testes, ~2s
flutter run -d chrome   # jeito mais rápido de ver a UI sem celular
```

**Sempre rode os dois antes de dar um trabalho por encerrado.** O `analyze` pega
erro de tipo e lint; o `test` pega regra de jogo quebrada. Eles são rápidos de
propósito: nenhum teste depende de rede, disco ou aparelho.

### Ver no navegador

```bash
flutter build web --release
cd build/web && python3 -m http.server 8731
```

Abra `http://localhost:8731` e **estreite bastante a janela** — a tela é
desenhada para retrato de celular e em janela larga dá uma impressão errada.

Duas diferenças em relação ao aparelho: as preferências ficam no armazenamento do
site em vez do aparelho, e a pasta de pacotes baixados não existe na web (ver
`_fontesDeBaixados` em `lib/ui/estado_app.dart`, que degrada em silêncio).

## 3. Arquitetura

Três camadas, com uma regra de dependência: **`dominio` não importa nada de
`ui`, `dados` ou `loja`.** O domínio é Dart puro — dá para testá-lo sem Flutter,
e é por isso que os testes do motor rodam em milissegundos.

```
lib/
  dominio/          regras do jogo, Dart puro, sem Flutter
    modelos/        Pacote, Pergunta, Jogador, Roleta, Cartas, ConfigPartida
    motor/          MotorPartida (máquina de estados) e Sorteador
  dados/            carrega pacotes e preferências (fala com o mundo externo)
  loja/             fronteira da monetização — só interface, sem implementação
  ui/               telas e widgets
  core/             tema visual
```

### O motor é uma máquina de estados

`MotorPartida` (`lib/dominio/motor/motor_partida.dart`) tem uma `FaseRodada` e
métodos que só valem em uma fase. Chamar fora de hora lança `StateError` — é
proposital: a UI não consegue corromper o estado por engano, e o erro aparece no
teste em vez de virar bug silencioso em produção.

```
girarRoletas ──┬─→ escolherTema ─→ pergunta        (coringa com 2+ temas)
               └─────────────────→ pergunta

pergunta ─→ revelacao ─┬─ rodada normal ─┬─ acertou ──→ placar
                       │                 └─ errou ────→ placar
                       └─ rodada de roubo ─┬─ acertou X ─→ placar
                                           └─ ninguém ──→ placar
placar ─→ girarRoletas  |  fim
```

Com as cartas ligadas na `ConfigPartida` (nenhuma vem ligada por padrão), o erro
abre um ramo a mais:

```
errou ─→ cartaEspecial ─┬─→ escolherAjudante ─→ revelacaoAjuda ─→ placar
                        ├─→ pergunta   (carta Dica)
                        └─→ pergunta   (carta Pulo)
```

O sorteio é feito pelo motor (`sortearGiro`), não pela tela. A tela pede o
resultado **antes** de animar, para as roletas pararem no setor certo, e só
depois chama `aplicarGiro`. Com `ConfigPartida.semente` preenchida a partida
inteira é reproduzível — é assim que o teste "mesma semente produz a mesma
partida" funciona.

### O gerenciador de pacotes é a única porta

`GerenciadorPacotes` recebe uma lista de `FontePacotes` e as consulta em ordem.
Hoje são duas: assets embutidos e uma pasta de arquivos baixados. **Fonte
posterior com `versao` maior ou igual substitui a anterior** — é isso que vai
permitir atualizar um pacote já comprado.

Adicionar uma terceira fonte (download da loja, por exemplo) é implementar a
interface e acrescentar à lista em `EstadoApp.iniciar`. O motor não percebe.

### Estado da UI

Sem pacote de gerência de estado. `EstadoApp` e `ControladorPartida` são
`ChangeNotifier`, expostos por um `InheritedNotifier` (`EscopoApp`). Para uma
tela nova, `EscopoApp.de(context)` dá acesso ao gerenciador e às preferências.

`ControladorPartida.executar` embrulha uma ação do motor e notifica a tela:

```dart
controlador.executar((m) => m.registrarAcerto());
```

## 4. Tarefas comuns

### Adicionar um pacote de perguntas
Ver [`conteudo.md`](conteudo.md). Resumo: escreva o JSON, cite no `index.json`,
rode `flutter test`.

### Calibrar o jogo

Tudo o que é ajuste de balanceamento está isolado, em um lugar só:

| O quê | Onde |
|---|---|
| Probabilidade dos modificadores | `RoletaModificadores.padrao` em `dominio/modelos/roleta.dart` |
| Pontos por dificuldade, fator do dobro, divisão da Ajuda, desconto da Dica | `RegrasPontuacao` em `dominio/modelos/config_partida.dart` |
| Cartas no erro (nenhuma por padrão) | `CartaEspecial.nenhuma` em `dominio/modelos/carta_especial.dart` |
| Tempo padrão de resposta | `ConfigPartida.segundosPadrao` |
| Cores, tipografia e medidas | `Cores`, `Medidas`, `titulo`, `corpo` em `core/tema.dart` |
| Cor e número de cada canal | `Cores.canais` e `GerenciadorPacotes.indiceDe` |
| Mínimo e máximo de jogadores | `ConfigPartida.minJogadores` / `maxJogadores` |

**A probabilidade é a proporção de setores da roleta.** Para o coringa sair
menos, troque um setor de coringa por normal; para sair mais, o contrário. Não
existe tabela de pesos em outro lugar.

### Ligar as cartas Ajuda, Dica e Pulo

As três funcionam no motor e têm teste, mas o padrão é `CartaEspecial.nenhuma`:
errar encerra a rodada. Ligá-las é passar um conjunto em
`ConfigPartida.cartasAtivas`. Atenção: a carta Dica
só é sorteada para perguntas que tenham o campo `dica` preenchido — sem isso ela
é descartada em `_sortearCarta`, e o jogador não vê carta nenhuma.

### Mexer na identidade visual

Tudo está em `lib/core/tema.dart`: paleta com papéis, medidas e as funções de
texto. As fontes ficam em `assets/fontes/` e são declaradas no `pubspec.yaml`.

Duas armadilhas já pegas em produção:

- **Cor no `TextStyle` vence o `foregroundColor` do botão.** Ao usar `titulo()`
  dentro de um botão colorido, passe a cor: `titulo(17, cor: corTexto)`.
- **A Space Grotesk não tem todos os glifos.** O caractere ✓ saía como quadrado
  vazio; use `Icon(Icons.check_rounded)`. Vale para qualquer símbolo fora do
  alfabeto latino.

### Mexer nas roletas

`RoletaWidget` (`ui/widgets/roleta_widget.dart`) pinta em canvas. Duas funções
puras carregam a geometria e têm teste próprio:

- `anguloDeRepouso(indice, total)` — onde a roleta para para o setor cair sob o
  ponteiro.
- `alvoDoGiro(atual, indice, total, voltas:)` — o ângulo do giro, sempre para a
  frente.
- `direcaoDoSetor` e `rotacaoDoRotulo` — posicionam o texto.

Se mexer no desenho, **rode `roleta_test.dart`**. Já houve um bug em que os
rótulos saíam espelhados e só o topo e a base ficavam certos, por acaso — é
exatamente o tipo de erro que passa numa olhada rápida na tela.

### Adicionar uma tela nova de fase

1. Acrescente o valor em `FaseRodada`.
2. O `switch` em `PartidaTela._corpo` vai parar de compilar — o Dart exige que
   todos os casos sejam tratados. Isso é a rede de segurança, não um estorvo.
3. Crie o widget em `ui/telas/fases/`.

## 5. Testes

916 linhas de teste para 3.343 de código. A divisão:

| Arquivo | Cobre |
|---|---|
| `motor_partida_test.dart` | regras do jogo: pontuação, erro, rodada de roubo, fim de partida, níveis |
| `sorteador_test.dart` | sorteio sem repetição e escolha de tema |
| `roleta_test.dart` | probabilidade dos setores e geometria do giro |
| `gerenciador_pacotes_test.dart` | leitura do formato e resolução de versões |
| `pacotes_embutidos_test.dart` | valida os JSON de verdade que vão no app |
| `preferencias_test.dart` | quais pacotes entram ligados numa partida |
| `cronometro_test.dart` | contagem e aviso de tempo esgotado |
| `estado_app_test.dart` | falha na inicialização não derruba a tela inicial |
| `fluxo_ui_test.dart` | percorre home → setup → roletas → frase → placar |

`test/apoio.dart` tem `perguntasFalsas(n)`, que gera conteúdo sintético — use-o
em vez de depender dos pacotes reais, senão editar uma pergunta quebra teste de
motor.

**O que sempre merece teste novo:** regra de jogo, formato de pacote e função de
geometria. **O que não vale a pena:** aparência. Não temos golden tests, de
propósito — eles quebram a cada ajuste de padding e o custo supera o benefício
num app deste tamanho.

## 6. Gerar o app

```bash
flutter build apk --release     # build/app/outputs/flutter-apk/app-release.apk
```

**Atenção antes de publicar:** hoje o APK sai assinado com a chave de *debug*
padrão do Android. Serve para instalar e testar, **não serve para a Play Store**.

Publicar exige gerar uma keystore própria e configurá-la em
`android/app/build.gradle.kts`. Essa chave é insubstituível: perdê-la significa
nunca mais conseguir atualizar o app publicado. Guarde-a fora do repositório e
com backup.

### Distribuir para teste

```bash
cp build/app/outputs/flutter-apk/app-release.apk build/web/quem-disse-isso.apk
cd build/web && python3 -m http.server 8731
```

No celular, na mesma rede: `http://<ip-da-máquina>:8731/quem-disse-isso.apk`.
O Android vai pedir permissão de "fontes desconhecidas" e o Play Protect vai
avisar que não reconhece o desenvolvedor — os dois são esperados para APK
assinado com chave de debug.

## 7. Convenções

- **Tudo em português**, inclusive nomes de classe, método e variável. O código
  fala a mesma língua do jogo e do documento de regras.
- **Cedilha e acento não valem em identificador Dart.** `_começar` não compila;
  em comentário e string, sim.
- **Comentário só para o que o código não diz**: o motivo de uma decisão não
  óbvia, uma armadilha, uma regra externa. Nada de descrever o que a linha faz.
- **Sem dependência nova sem necessidade real.** São quatro hoje
  (`shared_preferences`, `path_provider`, `audioplayers`, `cupertino_icons`). O
  app é offline; cada pacote a mais é superfície para quebrar em build de
  release.
- **A identidade visual vive em `core/tema.dart`.** Nenhuma tela declara cor ou
  tamanho de fonte solto: use `Cores`, `Medidas`, `titulo()`, `corpo()` e
  `etiqueta()`. Se precisar de um valor novo, ele entra no tema primeiro.
- **Archivo Black é sempre caixa-alta** — títulos, nomes de jogador e botões.
  Todo o resto é Space Grotesk.
