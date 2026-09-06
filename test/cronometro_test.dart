import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quem_disse_isso/core/tema.dart';
import 'package:quem_disse_isso/dominio/modelos/config_partida.dart';
import 'package:quem_disse_isso/ui/widgets/cronometro.dart';

Widget comTema(Widget filho) => MaterialApp(
      theme: construirTema(),
      home: Scaffold(body: Center(child: filho)),
    );

void main() {
  testWidgets('conta para trás e avisa ao esgotar', (tester) async {
    await tester.pumpWidget(comTema(const Cronometro(segundos: 3)));
    expect(find.text('3'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('2'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Tempo esgotado'), findsOneWidget);

    // O aviso não faz mais nada: revelar continua sendo ação dos jogadores.
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Tempo esgotado'), findsOneWidget);
  });

  testWidgets('sem cronômetro não desenha nada', (tester) async {
    await tester.pumpWidget(
      comTema(const Cronometro(segundos: ConfigPartida.semCronometro)),
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Tempo esgotado'), findsNothing);
  });
}
