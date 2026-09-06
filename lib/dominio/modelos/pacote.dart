import 'pergunta.dart';

class Pacote {
  const Pacote({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.faixaEtaria,
    required this.gratuito,
    required this.versao,
    required this.perguntas,
    this.preco,
  });

  final String id;
  final String nome;
  final String descricao;
  final String faixaEtaria;
  final bool gratuito;
  final String? preco;
  final int versao;
  final List<Pergunta> perguntas;

  int get quantidadePerguntas => perguntas.length;

  factory Pacote.deJson(Map<String, dynamic> json) {
    final id = json['id'];
    final nome = json['nome'];
    if (id is! String || nome is! String) {
      throw const FormatException('Pacote exige "id" e "nome" como texto.');
    }
    final brutas = json['perguntas'];
    if (brutas is! List) {
      throw FormatException('Pacote "$id" não traz a lista "perguntas".');
    }
    return Pacote(
      id: id,
      nome: nome,
      descricao: json['descricao'] as String? ?? '',
      faixaEtaria: json['faixa_etaria'] as String? ?? 'livre',
      gratuito: json['gratuito'] as bool? ?? false,
      preco: json['preco'] as String?,
      versao: json['versao'] as int? ?? 1,
      perguntas: brutas
          .map((p) => Pergunta.deJson(
                p as Map<String, dynamic>,
                idPacote: id,
                nomePacote: nome,
              ))
          .toList(growable: false),
    );
  }
}
