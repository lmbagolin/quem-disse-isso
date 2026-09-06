import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quem_disse_isso/dominio/motor/motor_partida.dart';
import 'package:quem_disse_isso/dominio/modelos/pacote.dart';

/// Guarda-corpo da regra de ouro: pacote quebrado tem que falhar aqui, não no
/// aparelho do jogador.
void main() {
  test('todo pacote do índice carrega e é consistente', () {
    final indice = (jsonDecode(File('assets/pacotes/index.json').readAsStringSync())
            as List<dynamic>)
        .cast<String>();
    expect(indice, isNotEmpty);

    final ids = <String>{};
    for (final arquivo in indice) {
      final pacote = Pacote.deJson(
        jsonDecode(File('assets/pacotes/$arquivo').readAsStringSync())
            as Map<String, dynamic>,
      );
      expect(ids.add(pacote.id), isTrue, reason: 'id repetido: ${pacote.id}');
      expect(pacote.perguntas, isNotEmpty, reason: pacote.id);

      final idsPerguntas = <String>{};
      for (final pergunta in pacote.perguntas) {
        expect(idsPerguntas.add(pergunta.id), isTrue,
            reason: '${pacote.id}/${pergunta.id} repetido');
        expect(pergunta.frase.trim(), isNotEmpty);
        expect(pergunta.resposta.trim(), isNotEmpty);
      }
    }
  });

  test('todo pacote sustenta as 5 alternativas sozinho', () {
    // Os distratores saem das outras respostas do mesmo pacote. Com poucas
    // respostas distintas o modo com alternativas degrada sem avisar.
    final indice = (jsonDecode(File('assets/pacotes/index.json').readAsStringSync())
            as List<dynamic>)
        .cast<String>();
    for (final arquivo in indice) {
      final pacote = Pacote.deJson(
        jsonDecode(File('assets/pacotes/$arquivo').readAsStringSync())
            as Map<String, dynamic>,
      );
      final distintas = pacote.perguntas.map((p) => p.resposta).toSet();
      expect(
        distintas.length,
        greaterThanOrEqualTo(MotorPartida.totalDeAlternativas),
        reason: '${pacote.id} tem só ${distintas.length} respostas distintas',
      );
    }
  });

  test('os pacotes embutidos são os gratuitos da isca', () {
    final indice = (jsonDecode(File('assets/pacotes/index.json').readAsStringSync())
            as List<dynamic>)
        .cast<String>();
    for (final arquivo in indice) {
      final pacote = Pacote.deJson(
        jsonDecode(File('assets/pacotes/$arquivo').readAsStringSync())
            as Map<String, dynamic>,
      );
      expect(pacote.gratuito, isTrue, reason: pacote.id);
    }
  });
}
