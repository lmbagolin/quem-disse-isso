# Quem Disse Isso?

Party game de trivia por dedução e memória. Pass-and-play, 3 a 8 jogadores,
100% offline. Uma frase aparece na tela e a mesa tenta descobrir quem disse.

- **App:** Flutter (Android e iOS), sem backend.
- **Conteúdo:** pacotes JSON. O motor do jogo não conhece nenhuma pergunta.
- **Modelo:** grátis com pacotes embutidos; loja de pacotes pagos numa fase
  posterior.

## Começar

```bash
flutter pub get
flutter test      # 66 testes: motor, conteúdo, widgets e fluxo de telas
flutter run       # aparelho, emulador ou -d chrome
```

## Documentação

| Documento | Para quê |
|---|---|
| [`docs/manutencao.md`](docs/manutencao.md) | Como mexer no código: arquitetura, tarefas comuns, build e publicação |
| [`docs/conteudo.md`](docs/conteudo.md) | Como escrever e publicar pacotes de perguntas |
| [`docs/decisoes.md`](docs/decisoes.md) | Por que o jogo é assim, e o que mudou desde a especificação |
| [`quem-disse-isso-regras-e-arquitetura.md`](quem-disse-isso-regras-e-arquitetura.md) | Especificação original do produto (ver divergências em `decisoes.md`) |

## A separação que sustenta a monetização

```
motor de jogo  ←  gerenciador de pacotes  ←  fontes de conteúdo
   (regras)          (a única porta)         assets / arquivos baixados
                                                      ↑
                                              loja (fase posterior)
```

O motor recebe uma `List<Pergunta>` pronta e não sabe de onde veio. Publicar um
pacote novo é publicar um arquivo JSON — nada de código muda. Essa é a regra
mais importante do projeto: se um dia for preciso editar Dart para adicionar
conteúdo, algo saiu errado.
