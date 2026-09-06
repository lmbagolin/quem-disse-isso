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
    find.text('Começar'),
    find.byType(ListView),
    const Offset(0, -200),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Começar'));
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
    expect(find.text('Jogar'), findsOneWidget);

    await tester.tap(find.text('Jogar'));
    await tester.pumpAndSettle();
    expect(find.text('Nova partida'), findsOneWidget);
    expect(find.text('Pacote de Teste'), findsOneWidget);
  });

  testWidgets('setup barra partida sem nomes', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('Jogar'));
    await tester.pumpAndSettle();

    await tocarEmComecar(tester);
    expect(find.text('Todo jogador precisa de um nome.'), findsOneWidget);
  });

  testWidgets('uma rodada completa vai das roletas ao placar', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('Jogar'));
    await tester.pumpAndSettle();
    await preencherJogadores(tester);

    await tocarEmComecar(tester);
    expect(find.text('Jogador 1'), findsOneWidget);

    await tester.tap(find.text('Girar as roletas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver a frase'));
    await tester.pumpAndSettle();

    expect(find.text('PACOTE DE TESTE'), findsOneWidget);
    await tester.tap(find.text('Revelar resposta'));
    await tester.pumpAndSettle();

    expect(find.text('A RESPOSTA É'), findsOneWidget);

    // A roleta pode cair em Roubo, e aí a revelação pergunta quem acertou
    // em vez de julgar só o jogador da vez.
    if (find.text('Acertou').evaluate().isNotEmpty) {
      await tester.tap(find.text('Acertou'));
    } else {
      expect(find.text('Quem acertou primeiro?'), findsOneWidget);
      await tester.tap(find.text('Jogador 1').last);
    }
    await tester.pumpAndSettle();

    expect(find.text('Como está o jogo'), findsOneWidget);
    expect(find.textContaining('+'), findsWidgets);

    await tester.tap(find.text('Próximo jogador'));
    await tester.pumpAndSettle();
    expect(find.text('Jogador 2'), findsOneWidget);
  });

  testWidgets('com alternativas, a frase vem com 5 opções de A a E',
      (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('Jogar'));
    await tester.pumpAndSettle();
    await preencherJogadores(tester);

    await tocarEm(tester, 'Com alternativas');
    await tocarEmComecar(tester);

    await tester.tap(find.text('Girar as roletas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver a frase'));
    await tester.pumpAndSettle();

    for (final letra in ['A', 'B', 'C', 'D', 'E']) {
      expect(find.text(letra), findsOneWidget, reason: 'faltou a opção $letra');
    }
    // Antes de revelar, nenhuma opção está marcada como certa.
    expect(find.byIcon(Icons.check_circle), findsNothing);

    await tester.tap(find.text('Revelar resposta'));
    await tester.pumpAndSettle();

    // Exatamente uma opção é apontada como a certa.
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('sem alternativas, a resposta aparece em destaque',
      (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('Jogar'));
    await tester.pumpAndSettle();
    await preencherJogadores(tester);

    await tocarEm(tester, 'Sem alternativas');
    await tocarEmComecar(tester);

    await tester.tap(find.text('Girar as roletas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver a frase'));
    await tester.pumpAndSettle();

    expect(find.text('A'), findsNothing);
    await tester.tap(find.text('Revelar resposta'));
    await tester.pumpAndSettle();

    expect(find.text('A RESPOSTA É'), findsOneWidget);
  });

  testWidgets('regras e meus pacotes abrem sem quebrar', (tester) async {
    await abrirApp(tester);

    await tester.tap(find.text('Como se joga'));
    await tester.pumpAndSettle();
    expect(find.text('As roletas'.toUpperCase()), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Meus pacotes'));
    await tester.pumpAndSettle();
    expect(find.text('30 perguntas'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Loja de pacotes'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum pacote à venda ainda.'), findsOneWidget);
  });
}
