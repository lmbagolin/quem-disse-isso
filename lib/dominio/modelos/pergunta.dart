import 'dificuldade.dart';

class Pergunta {
  const Pergunta({
    required this.id,
    required this.frase,
    required this.resposta,
    required this.dificuldade,
    required this.idPacote,
    required this.nomePacote,
    this.dica,
  });

  final String id;
  final String frase;
  final String resposta;
  final Dificuldade dificuldade;
  final String? dica;

  /// Origem da pergunta: preenchida pelo carregador, nunca vem no arquivo.
  final String idPacote;
  final String nomePacote;

  factory Pergunta.deJson(
    Map<String, dynamic> json, {
    required String idPacote,
    required String nomePacote,
  }) {
    final id = json['id'];
    final frase = json['frase'];
    final resposta = json['resposta'];
    if (id is! String || frase is! String || resposta is! String) {
      throw FormatException(
        'Pergunta do pacote "$idPacote" exige id, frase e resposta como texto.',
      );
    }
    return Pergunta(
      id: id,
      frase: frase,
      resposta: resposta,
      dificuldade: Dificuldade.daChave(json['dificuldade'] as String?),
      dica: json['dica'] as String?,
      idPacote: idPacote,
      nomePacote: nomePacote,
    );
  }

  String get idGlobal => '$idPacote/$id';
}
