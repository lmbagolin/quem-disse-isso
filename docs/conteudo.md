# Conteúdo

Como escrever, validar e publicar pacotes de perguntas.

**A regra de ouro:** o motor do jogo não conhece nenhuma pergunta. Adicionar
conteúdo é adicionar arquivo. Se você precisou editar Dart para colocar uma
pergunta nova, algo está errado.

---

## 1. Formato

Um pacote é um JSON em `assets/pacotes/`:

```json
{
  "id": "slogans_famosos",
  "nome": "Slogans Famosos",
  "descricao": "Você repete sem pensar. Agora diz de qual marca é.",
  "faixa_etaria": "livre",
  "gratuito": true,
  "preco": "R$ 4,90",
  "versao": 1,
  "quantidade_perguntas": 33,
  "perguntas": [
    {
      "id": "q001",
      "frase": "Mil e uma utilidades.",
      "resposta": "Bombril",
      "dificuldade": "facil",
      "dica": "Começa com B."
    }
  ]
}
```

### Campos do pacote

| Campo | Obrigatório | Observação |
|---|---|---|
| `id` | sim | Único entre todos os pacotes. É a chave de tudo; nunca mude depois de publicado. |
| `nome` | sim | Aparece na roleta de tema — **curto**, senão não cabe no setor. |
| `descricao` | não | Vazio se ausente. |
| `faixa_etaria` | não | `"livre"` se ausente. Texto livre: `"livre"`, `"12+"`, `"18+"`. |
| `gratuito` | não | `false` se ausente. |
| `preco` | não | Só exibição; a cobrança real virá da loja. |
| `versao` | não | `1` se ausente. Ver seção 4. |
| `quantidade_perguntas` | não | Informativo. O app conta a lista de verdade. |
| `perguntas` | sim | Lista não vazia. |

### Campos da pergunta

| Campo | Obrigatório | Observação |
|---|---|---|
| `id` | sim | Único **dentro do pacote**. |
| `frase` | sim | O que aparece na tela, entre aspas. |
| `resposta` | sim | O que é revelado. |
| `dificuldade` | não | `facil`, `media` ou `dificil`. Valor desconhecido vira `media` em silêncio. |
| `dica` | não | Só usado se a carta Dica for ligada. Sem ele, a carta não sai para essa pergunta. |

### Alternativas são automáticas

Não existe campo de alternativas. No modo "com alternativas" o app monta as 5
opções sozinho: a resposta certa mais quatro respostas de outras perguntas,
preferindo as do mesmo pacote.

Isso tem uma consequência ao escrever: **respostas do mesmo pacote precisam ser
comparáveis entre si.** Se um pacote mistura "Roberto Carlos" com "O Poderoso
Chefão (1972)", o distrator entrega qual é a certa pelo formato. Mantenha o
mesmo padrão de resposta dentro de um pacote.

Um pacote com menos de 5 respostas distintas mostra as que existem, sem
quebrar.

## 2. Publicar um pacote embutido

1. Escreva `assets/pacotes/<id>.json`.
2. Acrescente o nome do arquivo em `assets/pacotes/index.json`.
3. `flutter test` — `pacotes_embutidos_test.dart` valida id repetido, pergunta
   sem id único, campo obrigatório faltando e frase ou resposta vazia.

O `index.json` é a lista explícita do que entra no app. Um arquivo esquecido
fora dele simplesmente não carrega, sem erro — se um pacote novo não aparece,
é o primeiro lugar para olhar.

## 3. Escrever boas perguntas

**A frase tem que ser reconhecível sem contexto.** O jogador vê só ela, em voz
alta, numa mesa barulhenta. Se precisar de explicação, não serve.

**Nunca entregue a resposta na frase.** Slogan que contém a marca não é
pergunta. Prefira "Te dá asas" a "Red Bull te dá asas" — a menos que a frase
fique irreconhecível sem o nome, como no caso do Melhoral.

**Resposta tolerante, não exata.** Quem julga é a mesa, não o app. Escreva o que
ajuda a decidir: "Vito Corleone — O Poderoso Chefão" é melhor que só o nome do
filme, porque aceita as duas respostas que alguém daria.

**Dificuldade é sobre reconhecimento, não sobre erudição.** `facil` é o que a
mesa inteira grita junto; `dificil` é o que uma pessoa sabe e as outras acham
injusto. Se você hesitou ao classificar, é `media`.

**Trechos curtos.** Decisão registrada na especificação: nunca a obra inteira,
nem letra de música completa.

**Cuidado com direito autoral.** Fala de filme, frase histórica e slogan são
citação curta com finalidade de identificação — uso normal. Letra de música é
outra história: é obra protegida, e trecho de refrão em app pago é exatamente o
que editoras musicais fiscalizam. Se for por esse caminho, consulte alguém que
entenda do assunto antes de publicar.

## 4. Versões e atualização

O `GerenciadorPacotes` consulta as fontes em ordem e mantém a de **maior
`versao`**. É isso que permitirá corrigir um pacote já comprado: publique o
mesmo `id` com `versao` maior, e a cópia baixada vence a embutida.

Consequência prática: **suba a `versao` sempre que editar um pacote publicado.**
Sem isso o aparelho pode continuar com a versão antiga.

## 5. Pacotes pagos

Um pacote pago é igual, com `"gratuito": false` e um `preco`. A diferença é
onde ele mora: em vez de `assets/`, ele chega pela pasta de downloads que
`FontePacotesArquivos` lê.

Enquanto a loja não existe essa pasta fica vazia e nada muda para o jogador. A
interface que a loja vai implementar já está definida em
`lib/loja/catalogo_loja.dart`.

## 6. Acervo atual

120 perguntas em quatro pacotes gratuitos:

| Pacote | Total | Fácil | Média | Difícil |
|---|---:|---:|---:|---:|
| Frases de Cinema | 30 | 16 | 10 | 4 |
| Frases Históricas | 30 | 9 | 11 | 10 |
| Slogans Famosos | 33 | 13 | 15 | 5 |
| Bordões da TV | 27 | 11 | 10 | 6 |
| **Total** | **120** | **49** | **46** | **25** |

**Isso dá cerca de duas partidas.** Uma partida de 4 jogadores até 10 pontos
consome de 40 a 60 perguntas contando erros e rodadas de roubo. Na terceira
partida seguida as frases começam a repetir.

Filtrar só por Difícil deixa 25 perguntas — pode acabar no meio da partida. O
motor encerra corretamente, mas o jogo termina por falta de conteúdo em vez de
vitória.
