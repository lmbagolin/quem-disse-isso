import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quem_disse_isso/core/tema.dart';
import 'package:quem_disse_isso/dominio/modelos/config_partida.dart';
import 'package:quem_disse_isso/ui/widgets/cronometro.dart';

/// Duplo do aviso: o de verdade fala com o áudio do aparelho, que não existe
/// no ambiente de teste.
class AvisoEspiao extends AvisoDeTempo {
  const AvisoEspiao(this.tocou);

  final List<bool> tocou;

  @override
  Future<void> tocar() async => tocou.add(true);
}

Widget comTema(Widget filho) => MaterialApp(
      theme: construirTema(),
      home: Scaffold(body: Center(child: filho)),
    );

void main() {
  testWidgets('conta para trás e avisa ao esgotar', (tester) async {
    final tocou = <bool>[];
    await tester.pumpWidget(
      comTema(Cronometro(segundos: 3, aviso: AvisoEspiao(tocou))),
    );
    expect(find.text('03'), findsOneWidget);
    expect(tocou, isEmpty);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('02'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('TEMPO'), findsOneWidget);
    expect(tocou, hasLength(1), reason: 'o aviso toca uma vez ao esgotar');

    // O aviso não faz mais nada: revelar continua sendo ação dos jogadores.
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('TEMPO'), findsOneWidget);
    expect(tocou, hasLength(1), reason: 'e não repete depois');
  });

  testWidgets('sem cronômetro não desenha nem toca nada', (tester) async {
    final tocou = <bool>[];
    await tester.pumpWidget(
      comTema(Cronometro(
        segundos: ConfigPartida.semCronometro,
        aviso: AvisoEspiao(tocou),
      )),
    );
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('TEMPO'), findsNothing);

    await tester.pump(const Duration(seconds: 30));
    expect(tocou, isEmpty);
  });
}
