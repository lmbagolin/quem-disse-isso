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
    'Você escolhe o tema em vez da roleta.',
  );

  const EfeitoModificador(this.rotuloCurto, this.titulo, this.descricao);

  /// Cabe dentro de um setor da roleta; [titulo] só aparece no resultado.
  final String rotuloCurto;
  final String titulo;
  final String descricao;
}

class ResultadoModificador {
  const ResultadoModificador(this.setor, this.efeito);

  final int setor;
  final EfeitoModificador efeito;
}

/// Roleta de modificadores. Repetir um efeito em mais setores é o que controla
/// a probabilidade — é o principal ponto calibrável do design (seção 3.3 do
/// documento). Os "normal" ficam alternados para a roleta parecer equilibrada.
class RoletaModificadores {
  const RoletaModificadores(this.setores);

  static const RoletaModificadores padrao = RoletaModificadores([
    EfeitoModificador.normal,
    EfeitoModificador.pontosEmDobro,
    EfeitoModificador.normal,
    EfeitoModificador.rouboLiberado,
    EfeitoModificador.normal,
    EfeitoModificador.coringa,
  ]);

  final List<EfeitoModificador> setores;

  ResultadoModificador girar(Random sorte) {
    final indice = sorte.nextInt(setores.length);
    return ResultadoModificador(indice, setores[indice]);
  }
}
