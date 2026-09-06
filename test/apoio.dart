import 'package:quem_disse_isso/dominio/modelos/dificuldade.dart';
import 'package:quem_disse_isso/dominio/modelos/pergunta.dart';

List<Pergunta> perguntasFalsas(
  int quantas, {
  String idPacote = 'pacote_a',
  Dificuldade dificuldade = Dificuldade.media,
  String? dica,
}) {
  return [
    for (var i = 0; i < quantas; i++)
      Pergunta(
        id: 'q$i',
        frase: 'frase $i do $idPacote',
        resposta: 'resposta $i',
        dificuldade: dificuldade,
        idPacote: idPacote,
        nomePacote: idPacote,
        dica: dica,
      ),
  ];
}
