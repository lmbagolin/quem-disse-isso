# Quem Disse Isso? — Documento de Regras e Arquitetura (Fase 1)

> Este é o documento de referência do projeto. Ele define **como o jogo funciona no app** e **como o conteúdo é estruturado**, antes de qualquer programação. A Fase 2 (design visual) e a Fase 3 (implementação com o Claude Code) partem daqui.

---

## 1. Visão geral

App mobile de party game de trivia baseado em dedução e memória. Uma frase é apresentada e os jogadores precisam descobrir **quem disse** ou **de onde vem**. A graça está na sensação de "eu sei essa frase, mas não lembro de quem".

- **Jogadores:** 3 a 8
- **Duração alvo:** ~15 min por partida
- **Modo:** pass-and-play (um único aparelho passado de mão em mão)
- **Conexão:** 100% offline para jogar (internet só para baixar/comprar pacotes)
- **Modelo de negócio:** app grátis + pacotes de perguntas pagos

---

## 2. Decisões já travadas

Estas decisões estão fechadas e orientam todo o resto:

1. **Pass-and-play.** Sem servidor de jogo, sem multiplayer online, sem custo de hospedagem para partidas. Um aparelho, jogadores se revezam.
2. **Validação por honra.** O app **revela a resposta** e pergunta aos jogadores "Acertou?". Os próprios jogadores decidem certo/errado, como no jogo de cartas. O app não tenta corrigir texto.
3. **Conteúdo 100% data-driven.** Nenhuma pergunta é escrita dentro da lógica do jogo. O app é um motor; cada pacote é um arquivo de dados.
4. **Pacote = categoria selecionável.** O jogador escolhe, antes da partida, quais pacotes instalados/comprados quer usar. Só aparecem os que ele possui.
5. **Freemium.** O app baixa grátis com 1–2 pacotes iniciais embutidos (a isca). Pacotes extras são pagos.
6. **Conteúdo de músicas liberado** (decisão do produto). Contrapartida de design: guardar **trechos curtos**, nunca letras completas.

---

## 3. Regras do jogo

### 3.1 Setup da partida

1. Definir número de jogadores (3–8) e digitar os nomes.
2. Selecionar quais **pacotes** entram na partida (mínimo 1). Só aparecem os instalados/comprados.
3. Definir a condição de vitória:
   - **Por pontos:** primeiro a chegar em X pontos (padrão sugerido: 10), ou
   - **Por rodadas:** N rodadas completas; vence quem tiver mais pontos.
4. Iniciar.

### 3.2 Loop de uma rodada

```
        INÍCIO DA VEZ
             │
             ▼
     Jogador da vez rola o DADO
             │
             ▼
   App sorteia uma frase (respeitando
   o dado e os pacotes ativos)
             │
             ▼
     Jogador tenta descobrir
        "Quem disse isso?"
             │
             ▼
     App REVELA a resposta
             │
             ▼
   "Acertou?"  →  jogadores decidem
             │
        ┌────┴────┐
        │         │
      ACERTO    ERRO
        │         │
        ▼         ▼
   Pontua     Carta especial
                  │
                  ▼
        Interação (ajuda/roubo)
                  │
                  ▼
          Próximo jogador
```

Fim da partida quando a condição de vitória é atingida → tela de resultado/ranking.

### 3.3 O dado (dado de modificador)

O dado **não** escolhe categoria (o número de pacotes é variável). Ele modifica a rodada. Mapeamento **inicial e ajustável**:

| Face | Efeito |
|------|--------|
| 1–3  | Rodada normal |
| 4    | Pontos em dobro nesta rodada |
| 5    | Roubo liberado desde o início (todos podem tentar) |
| 6    | Coringa: o jogador escolhe o tema da própria pergunta |

O **tema** de cada pergunta é sorteado aleatoriamente entre os pacotes ativos (exceto na face 6). *(Essa tabela é o principal ponto ainda calibrável do design — fácil de mudar depois de testar.)*

### 3.4 Cartas especiais (disparam no erro)

Quando o jogador **erra**, entra uma carta especial. Conjunto inicial:

- **Ajuda** — o jogador que errou escolhe outro para responder. Se acertar, o ponto é dividido (ou o ajudante fica com metade — a definir no balanceamento).
- **Roubo** — os demais jogadores podem tentar "roubar"; o primeiro a se habilitar responde e, se acertar, leva o ponto.
- **Dica** *(nativa de app)* — revela uma pista ou elimina uma alternativa, mas o acerto vale menos.
- **Pulo** *(nativa de app)* — troca a frase sem pontuar.

As duas primeiras são fiéis ao jogo de mesa; as duas últimas são opcionais e podem entrar ou não na v1.

### 3.5 Pontuação e vitória

- Acerto = ponto base (padrão: 1). Pode variar por dificuldade da pergunta.
- Dado face 4 dobra o ponto da rodada.
- Roubo transfere o ponto para quem roubou.
- Ajuda gera ponto parcial.
- Vence quem atinge a meta de pontos **ou** lidera ao fim das rodadas.

Regras propositalmente simples — é party game, não jogo de estratégia.

---

## 4. Modelo de conteúdo (o núcleo da arquitetura)

Esta é a parte mais importante para não quebrar a monetização. **Toda pergunta vive em um pacote; o motor nunca contém perguntas.**

### 4.1 Estrutura de um pacote

Cada pacote é um arquivo de dados (ex.: JSON) com metadados + lista de perguntas:

```json
{
  "id": "musica_anos_90",
  "nome": "Música dos Anos 90",
  "descricao": "Trechos marcantes que tocaram nas rádios dos anos 90.",
  "faixa_etaria": "14+",
  "gratuito": false,
  "preco": "R$ 4,90",
  "versao": 1,
  "quantidade_perguntas": 100,
  "perguntas": [
    {
      "id": "q001",
      "frase": "...trecho curto e reconhecível...",
      "resposta": "Nome da música / artista",
      "dificuldade": "media"
    }
  ]
}
```

Campos que sustentam suas estratégias:

- **`faixa_etaria`** → permite vender e filtrar por idade ("Desenhos", "Turma da Mônica" para crianças; conteúdo adulto separado).
- **`gratuito` / `preco`** → separam a isca do que é vendido.
- **`versao`** → permite atualizar um pacote já baixado no futuro.
- **`frase` curta** → decisão de design registrada na seção de músicas.

### 4.2 Regras de ouro do conteúdo

1. O motor do jogo **não conhece nenhuma pergunta em tempo de compilação** — ele só sabe carregar pacotes.
2. Adicionar um pacote novo = adicionar um arquivo de dados. Nunca mexer no código do jogo.
3. O app grátis embarca 1–2 pacotes gratuitos; todos os demais são carregados/baixados dinamicamente.

---

## 5. Monetização

- **App grátis** com pacote(s) inicial(is) embutido(s).
- **Pacotes pagos** por tema ("Bíblico", "Rock Nacional", "Turma da Mônica", etc.), organizáveis por faixa etária.
- **Loja in-app** onde o usuário navega, compra e baixa pacotes.
- **Servidor de pacotes** (definido depois): hospeda os arquivos dos pacotes para download após a compra.

**Custo/alerta honesto:** vender dentro de um app mobile obriga o uso do sistema de pagamento das lojas (App Store / Play Store), que cobram taxa de conta de desenvolvedor e comissão por venda. Isso é o único custo real além do desenvolvimento, e só aparece na fase de monetização — não na de jogar. A loja e o pagamento podem ficar para uma fase posterior, com todo o resto já preparado para recebê-los.

---

## 6. Arquitetura técnica (alto nível)

- **App = motor de jogo + carregador de pacotes.** Sem lógica de conteúdo embutida.
- **Camada de dados:** um "gerenciador de pacotes" que lista pacotes instalados, lê seus arquivos e entrega perguntas ao motor conforme os pacotes ativos e o dado.
- **Persistência local:** pacotes baixados, compras e preferências ficam salvos no aparelho (offline).
- **Loja / servidor:** módulo separado e plugável, adicionado numa fase posterior sem tocar no motor.

Essa separação (motor ↔ conteúdo ↔ loja) é o que garante que "vender mais pacotes" seja sempre só publicar um arquivo novo.

---

## 7. Fluxo de telas (ponte para a Fase 2 — design)

1. **Home** — jogar, loja de pacotes, meus pacotes, regras.
2. **Setup da partida** — jogadores, seleção de pacotes ativos, condição de vitória.
3. **Rodada** — nome do jogador da vez, dado, frase, botão "revelar".
4. **Revelação** — resposta + "Acertou? / Errou?".
5. **Carta especial** — aparece no erro (ajuda / roubo / etc.).
6. **Placar** — pontuação corrente entre rodadas.
7. **Resultado final** — ranking + revanche.
8. **Loja de pacotes** — navegar/comprar/baixar (fase posterior).
9. **Meus pacotes** — ativar/desativar, ver faixa etária.

---

## 8. Fora de escopo da v1 (roadmap futuro)

- Multiplayer online (cada jogador no seu aparelho).
- Modo múltipla escolha (o app corrige sozinho).
- Modo solo.
- Rankings/estatísticas em nuvem.

---

## 9. Decisões ainda em aberto (antes de programar)

1. **Calibragem do dado** (tabela da seção 3.3) — decidir na prática/teste.
2. **Cartas "Dica" e "Pulo"** — entram na v1 ou ficam para depois?
3. **Balanceamento de pontos** de ajuda/roubo/dobro.
4. **Stack de desenvolvimento** — a definir para o Claude Code. Para um app mobile cross-platform, offline, com compras futuras, uma escolha comum é **Flutter** (um código para Android e iOS). É a principal decisão técnica pendente.
