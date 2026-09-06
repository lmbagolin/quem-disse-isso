import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:quem_disse_isso/dominio/modelos/roleta.dart';
import 'package:quem_disse_isso/ui/widgets/roleta_widget.dart';

void main() {
  group('roleta de modificadores', () {
    test('o setor sorteado corresponde ao efeito devolvido', () {
      const roleta = RoletaModificadores.padrao;
      final sorte = Random(3);
      for (var i = 0; i < 50; i++) {
        final resultado = roleta.girar(sorte);
        expect(roleta.setores[resultado.setor], resultado.efeito);
      }
    });

    test('a proporção de setores é a probabilidade', () {
      const roleta = RoletaModificadores.padrao;
      expect(roleta.setores.length, 6);
      expect(
        roleta.setores.where((e) => e == EfeitoModificador.normal).length,
        3,
      );
      for (final efeito in [
        EfeitoModificador.pontosEmDobro,
        EfeitoModificador.rouboLiberado,
        EfeitoModificador.coringa,
      ]) {
        expect(roleta.setores.where((e) => e == efeito).length, 1);
      }
    });

    test('todo rótulo curto cabe num setor', () {
      for (final efeito in EfeitoModificador.values) {
        expect(efeito.rotuloCurto.length, lessThanOrEqualTo(8));
      }
    });
  });

  group('geometria do giro', () {
    test('o repouso do índice 0 é o topo', () {
      expect(RoletaWidget.anguloDeRepouso(0, 6), 0);
    });

    test('cada índice recua uma fatia', () {
      expect(RoletaWidget.anguloDeRepouso(1, 4), closeTo(-pi / 2, 1e-9));
      expect(RoletaWidget.anguloDeRepouso(3, 4), closeTo(-3 * pi / 2, 1e-9));
    });

    test('o rótulo é escrito na direção do próprio setor', () {
      // O texto é desenhado para cima; girado, tem que cair sobre o setor.
      for (final total in [2, 4, 6]) {
        for (var i = 0; i < total; i++) {
          final direcao = RoletaWidget.direcaoDoSetor(i, total);
          final ondeCai = -pi / 2 + RoletaWidget.rotacaoDoRotulo(direcao);
          expect(
            (ondeCai - direcao) % (2 * pi),
            closeTo(0, 1e-9),
            reason: 'setor $i de $total',
          );
        }
      }
    });

    test('o alvo sempre gira para a frente e para no setor pedido', () {
      const total = 6;
      var atual = 0.0;
      for (final indice in [4, 1, 5, 0, 2]) {
        final alvo = RoletaWidget.alvoDoGiro(atual, indice, total, voltas: 4);
        expect(alvo, greaterThanOrEqualTo(atual + 4 * 2 * pi));

        final repouso = RoletaWidget.anguloDeRepouso(indice, total);
        final sobra = (alvo - repouso) % (2 * pi);
        expect(min(sobra, 2 * pi - sobra), closeTo(0, 1e-9));
        atual = alvo;
      }
    });
  });
}
