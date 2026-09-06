import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:quem_disse_isso/dominio/modelos/modificadores.dart';

void main() {
  test('o índice sorteado corresponde ao efeito devolvido', () {
    const tabela = Modificadores.padrao;
    final sorte = Random(3);
    for (var i = 0; i < 50; i++) {
      final resultado = tabela.sortear(sorte);
      expect(tabela.entradas[resultado.indice], resultado.efeito);
    }
  });

  test('a proporção de entradas é a probabilidade', () {
    const tabela = Modificadores.padrao;
    expect(tabela.entradas.length, 6);
    expect(
      tabela.entradas.where((e) => e == EfeitoModificador.normal).length,
      3,
    );
    for (final efeito in [
      EfeitoModificador.pontosEmDobro,
      EfeitoModificador.rouboLiberado,
      EfeitoModificador.coringa,
    ]) {
      expect(tabela.entradas.where((e) => e == efeito).length, 1);
    }
  });

  test('todo rótulo curto cabe na faixa da TV', () {
    for (final efeito in EfeitoModificador.values) {
      expect(efeito.rotuloCurto.length, lessThanOrEqualTo(8));
    }
  });
}
