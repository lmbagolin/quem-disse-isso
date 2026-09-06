import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quem_disse_isso/app.dart';
import 'package:quem_disse_isso/dados/fonte_pacotes.dart';
import 'package:quem_disse_isso/dados/gerenciador_pacotes.dart';
import 'package:quem_disse_isso/dominio/modelos/pacote.dart';
import 'package:quem_disse_isso/ui/estado_app.dart';

import 'apoio.dart';

class FonteEmMemoria implements FontePacotes {
  @override
  Future<List<Pacote>> carregar() async => [
        Pacote.deJson({
          'id': 'pacote_a',
          'nome': 'Pacote de Teste',
          'descricao': 'Só para o teste.',
          'faixa_etaria': 'livre',
          'gratuito': true,
          'versao': 1,
          'perguntas': [
            for (final p in perguntasFalsas(30))
              {'id': p.id, 'frase': p.frase, 'resposta': p.resposta},
          ],
        }),
      ];
}

Future<void> abrirApp(WidgetTester tester) async {
  await tester.pumpWidget(QuemDisseIssoApp(
    estado: EstadoApp(gerenciador: GerenciadorPacotes([FonteEmMemoria()])),
  ));
  await tester.pumpAndSettle();
}

/// O zapping encadeia Future.delayed sem agendar quadro entre um passo e
/// outro, então pumpAndSettle volta antes da hora: é preciso avançar o
/// relógio em fatias.
Future<void> trocarDeCanal(WidgetTester tester) async {
  await tester.tap(find.text('TROCAR DE CANAL'));
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
  await tester.pumpAndSettle();
}

Future<void> tocarEm(WidgetTester tester, String rotulo) async {
  await tester.dragUntilVisible(
    find.text(rotulo),
    find.byType(ListView),
    const Offset(0, -200),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(rotulo));
  await tester.pumpAndSettle();
}

Future<void> tocarEmComecar(WidgetTester tester) async {
  await tester.dragUntilVisible(
    find.text('COMEÇAR'),
    find.byType(ListView),
    const Offset(0, -200),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('COMEÇAR'));
  await tester.pumpAndSettle();
}

Future<void> preencherJogadores(WidgetTester tester) async {
  final campos = find.byType(TextField);
  for (var i = 0; i < 3; i++) {
    await tester.enterText(campos.at(i), 'Jogador ${i + 1}');
  }
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('home lista as ações e abre o setup', (tester) async {
    await abrirApp(tester);
    expect(find.text('JOGAR'), findsOneWidget);

    await tester.tap(find.text('JOGAR'));
    await tester.pumpAndSettle();
    expect(find.text('Nova partida'), findsOneWidget);
    expect(find.text('PACOTE DE TESTE'), findsOneWidget);
  });

  testWidgets('setup barra partida sem nomes', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('JOGAR'));
    await tester.pumpAndSettle();

    await tocarEmComecar(tester);
    expect(find.text('Todo jogador precisa de um nome.'), findsOneWidget);
  });

  testWidgets('uma rodada completa vai do sorteio ao placar', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('JOGAR'));
    await tester.pumpAndSettle();
    await preencherJogadores(tester);

    await tocarEmComecar(tester);
    expect(find.text('JOGADOR 1'), findsOneWidget);

    await trocarDeCanal(tester);
    await tester.tap(find.text('VER A FRASE'));
    await tester.pumpAndSettle();

    expect(find.text('CANAL 01 · PACOTE DE TESTE'), findsOneWidget);
    await tester.tap(find.text('REVELAR RESPOSTA'));
    await tester.pumpAndSettle();

    expect(find.text('ERA ELE O TEMPO TODO'), findsOneWidget);

    // A roleta pode cair em Roubo, e aí a revelação pergunta quem acertou
    // em vez de julgar só o jogador da vez.
    if (find.text('ACERTOU').evaluate().isNotEmpty) {
      await tester.tap(find.text('ACERTOU'));
    } else {
      expect(find.text('QUEM ACERTOU PRIMEIRO?'), findsOneWidget);
      await tester.tap(find.text('JOGADOR 1').last);
    }
    await tester.pumpAndSettle();

    expect(find.text('COMO ESTÁ O JOGO'), findsOneWidget);
    expect(find.textContaining('+'), findsWidgets);

    await tester.tap(find.text('PRÓXIMA RODADA'));
    await tester.pumpAndSettle();
    expect(find.text('JOGADOR 2'), findsOneWidget);
  });

  testWidgets('com alternativas, a frase vem com 5 opções de A a E',
      (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('JOGAR'));
    await tester.pumpAndSettle();
    await preencherJogadores(tester);

    await tocarEm(tester, 'Com alternativas');
    await tocarEmComecar(tester);

    await trocarDeCanal(tester);
    await tester.tap(find.text('VER A FRASE'));
    await tester.pumpAndSettle();

    for (final letra in ['A', 'B', 'C', 'D', 'E']) {
      expect(find.text(letra), findsOneWidget, reason: 'faltou a opção $letra');
    }
    // Antes de revelar, nenhuma opção está marcada como certa.
    expect(find.byIcon(Icons.check_rounded), findsNothing);

    await tester.tap(find.text('REVELAR RESPOSTA'));
    await tester.pumpAndSettle();

    // A revelação troca de tela: a resposta ocupa o lugar das alternativas.
    expect(find.text('ERA ELE O TEMPO TODO'), findsOneWidget);
    for (final letra in ['A', 'B', 'C', 'D', 'E']) {
      expect(find.text(letra), findsNothing, reason: 'a opção $letra ficou');
    }
  });

  testWidgets('sem alternativas, a resposta aparece em destaque',
      (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('JOGAR'));
    await tester.pumpAndSettle();
    await preencherJogadores(tester);

    await tocarEm(tester, 'Sem alternativas');
    await tocarEmComecar(tester);

    await trocarDeCanal(tester);
    await tester.tap(find.text('VER A FRASE'));
    await tester.pumpAndSettle();

    expect(find.text('A'), findsNothing);
    await tester.tap(find.text('REVELAR RESPOSTA'));
    await tester.pumpAndSettle();

    expect(find.text('ERA ELE O TEMPO TODO'), findsOneWidget);
  });

  testWidgets('regras e meus pacotes abrem sem quebrar', (tester) async {
    await abrirApp(tester);

    await tester.tap(find.text('Como se joga'));
    await tester.pumpAndSettle();
    expect(find.text('O SORTEIO'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Meus pacotes'));
    await tester.pumpAndSettle();
    expect(find.text('30 perguntas'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Loja'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum pacote à venda ainda.'), findsOneWidget);
  });
}
