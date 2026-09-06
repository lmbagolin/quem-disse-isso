import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:quem_disse_isso/dominio/motor/sorteador.dart';

import 'apoio.dart';

void main() {
  test('não repete pergunta dentro da partida', () {
    final sorteador = Sorteador(perguntasFalsas(20), Random(1));
    final vistas = <String>{};
    while (!sorteador.vazio) {
      expect(vistas.add(sorteador.proxima()!.id), isTrue);
    }
    expect(vistas, hasLength(20));
  });

  test('respeita o tema pedido pelo coringa', () {
    final sorteador = Sorteador(
      [...perguntasFalsas(5), ...perguntasFalsas(5, idPacote: 'pacote_b')],
      Random(7),
    );
    for (var i = 0; i < 5; i++) {
      expect(sorteador.proxima(idPacote: 'pacote_b')!.idPacote, 'pacote_b');
    }
    expect(sorteador.restantes, 5);
  });

  test('cai no sorteio livre quando o tema pedido acabou', () {
    final sorteador = Sorteador(perguntasFalsas(2), Random(3));
    expect(sorteador.proxima(idPacote: 'inexistente')!.idPacote, 'pacote_a');
  });

  test('devolve nulo quando esgota', () {
    final sorteador = Sorteador(perguntasFalsas(1), Random(0));
    expect(sorteador.proxima(), isNotNull);
    expect(sorteador.proxima(), isNull);
  });
}
