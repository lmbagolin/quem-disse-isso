import 'dart:math';

import '../modelos/pergunta.dart';

/// Entrega perguntas sem repetir dentro da mesma partida.
class Sorteador {
  Sorteador(List<Pergunta> disponiveis, Random sorte)
      : _restantes = List.of(disponiveis) {
    _restantes.shuffle(sorte);
  }

  final List<Pergunta> _restantes;

  bool get vazio => _restantes.isEmpty;

  int get restantes => _restantes.length;

  Set<String> get pacotesComPerguntas =>
      _restantes.map((p) => p.idPacote).toSet();

  /// Com [idPacote] atende o coringa do dado; sem tema disponível, cai no
  /// sorteio livre para a rodada não travar.
  Pergunta? proxima({String? idPacote}) {
    if (_restantes.isEmpty) return null;
    var indice = 0;
    if (idPacote != null) {
      final doTema = _restantes.indexWhere((p) => p.idPacote == idPacote);
      if (doTema >= 0) indice = doTema;
    }
    return _restantes.removeAt(indice);
  }
}
