import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quem_disse_isso/dados/fonte_pacotes.dart';
import 'package:quem_disse_isso/dados/gerenciador_pacotes.dart';
import 'package:quem_disse_isso/dominio/modelos/dificuldade.dart';
import 'package:quem_disse_isso/dominio/modelos/pacote.dart';

class FonteFalsa implements FontePacotes {
  FonteFalsa(this.pacotes);

  final List<Pacote> pacotes;

  @override
  Future<List<Pacote>> carregar() async => pacotes;
}

Pacote pacoteDeTexto(String json) =>
    Pacote.deJson(jsonDecode(json) as Map<String, dynamic>);

void main() {
  const bruto = '''
  {
    "id": "musica_anos_90",
    "nome": "Música dos Anos 90",
    "descricao": "Trechos marcantes.",
    "faixa_etaria": "14+",
    "gratuito": false,
    "preco": "R\$ 4,90",
    "versao": 1,
    "quantidade_perguntas": 1,
    "perguntas": [
      {"id": "q001", "frase": "trecho", "resposta": "artista", "dificuldade": "dificil"}
    ]
  }
  ''';

  test('lê o formato de pacote do documento', () {
    final pacote = pacoteDeTexto(bruto);
    expect(pacote.id, 'musica_anos_90');
    expect(pacote.gratuito, isFalse);
    expect(pacote.preco, r'R$ 4,90');
    expect(pacote.faixaEtaria, '14+');
    expect(pacote.quantidadePerguntas, 1);
    expect(pacote.perguntas.single.dificuldade, Dificuldade.dificil);
    expect(pacote.perguntas.single.idPacote, 'musica_anos_90');
  });

  test('rejeita pacote sem lista de perguntas', () {
    expect(
      () => pacoteDeTexto('{"id": "x", "nome": "X"}'),
      throwsFormatException,
    );
  });

  test('dificuldade desconhecida vira média', () {
    final pacote = pacoteDeTexto(
      '{"id":"x","nome":"X","perguntas":[{"id":"q","frase":"f","resposta":"r","dificuldade":"impossivel"}]}',
    );
    expect(pacote.perguntas.single.dificuldade, Dificuldade.media);
  });

  test('fonte posterior atualiza pacote de versão mais nova', () async {
    final embutido = pacoteDeTexto(
      '{"id":"p","nome":"Antigo","versao":1,"perguntas":[]}',
    );
    final baixado = pacoteDeTexto(
      '{"id":"p","nome":"Novo","versao":2,"perguntas":[]}',
    );
    final gerenciador =
        GerenciadorPacotes([FonteFalsa([embutido]), FonteFalsa([baixado])]);
    await gerenciador.recarregar();
    expect(gerenciador.porId('p')!.nome, 'Novo');
  });

  test('versão mais antiga não sobrescreve a instalada', () async {
    final novo = pacoteDeTexto(
      '{"id":"p","nome":"Novo","versao":3,"perguntas":[]}',
    );
    final velho = pacoteDeTexto(
      '{"id":"p","nome":"Velho","versao":1,"perguntas":[]}',
    );
    final gerenciador =
        GerenciadorPacotes([FonteFalsa([novo]), FonteFalsa([velho])]);
    await gerenciador.recarregar();
    expect(gerenciador.porId('p')!.nome, 'Novo');
  });

  test('entrega só as perguntas dos pacotes ativos', () async {
    final a = pacoteDeTexto(
      '{"id":"a","nome":"A","perguntas":[{"id":"1","frase":"f","resposta":"r"}]}',
    );
    final b = pacoteDeTexto(
      '{"id":"b","nome":"B","perguntas":[{"id":"1","frase":"f","resposta":"r"}]}',
    );
    final gerenciador = GerenciadorPacotes([FonteFalsa([a, b])]);
    await gerenciador.recarregar();
    expect(gerenciador.perguntasDe(['a']), hasLength(1));
    expect(gerenciador.perguntasDe(['a', 'b']), hasLength(2));
    expect(gerenciador.perguntasDe(['inexistente']), isEmpty);
  });
}
