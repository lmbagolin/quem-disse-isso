import 'dart:math';

enum EfeitoModificador {
  normal(
    'Normal',
    'Rodada normal',
    'Vale o ponto cheio, sem modificador.',
  ),
  pontosEmDobro(
    'Dobro',
    'Pontos em dobro',
    'O ponto desta rodada vale o dobro.',
  ),
  rouboLiberado(
    'Roubo',
    'Roubo liberado',
    'Todos respondem. Quem acertar primeiro leva o ponto.',
  ),
  coringa(
    'Coringa',
    'Coringa',
    'Você escolhe o canal em vez do sorteio.',
  );

  const EfeitoModificador(this.rotuloCurto, this.titulo, this.descricao);

  /// Cabe na faixa do modificador; [titulo] só aparece no resultado.
  final String rotuloCurto;
  final String titulo;
  final String descricao;
}

class ResultadoModificador {
  const ResultadoModificador(this.indice, this.efeito);

  final int indice;
  final EfeitoModificador efeito;
}

/// Tabela de sorteio dos modificadores. Repetir um efeito em mais entradas é o
/// que controla a probabilidade — é o principal ponto calibrável do design.
/// O nome não cita a tela de propósito: a apresentação já foi dado e roleta,
/// e a regra não mudou em nenhuma das vezes.
class Modificadores {
  const Modificadores(this.entradas);

  static const Modificadores padrao = Modificadores([
    EfeitoModificador.normal,
    EfeitoModificador.pontosEmDobro,
    EfeitoModificador.normal,
    EfeitoModificador.rouboLiberado,
    EfeitoModificador.normal,
    EfeitoModificador.coringa,
  ]);

  final List<EfeitoModificador> entradas;

  ResultadoModificador sortear(Random sorte) {
    final indice = sorte.nextInt(entradas.length);
    return ResultadoModificador(indice, entradas[indice]);
  }
}
