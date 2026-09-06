import 'dart:convert';

import 'package:flutter/services.dart';

import '../dominio/modelos/pacote.dart';
import 'fonte_pacotes.dart';

/// Pacotes gratuitos que vêm dentro do app (a isca do freemium).
class FontePacotesAssets implements FontePacotes {
  const FontePacotesAssets({this.pasta = 'assets/pacotes'});

  final String pasta;

  @override
  Future<List<Pacote>> carregar() async {
    final indice = jsonDecode(await rootBundle.loadString('$pasta/index.json'))
        as List<dynamic>;
    final pacotes = <Pacote>[];
    for (final arquivo in indice.cast<String>()) {
      final bruto = jsonDecode(await rootBundle.loadString('$pasta/$arquivo'));
      pacotes.add(Pacote.deJson(bruto as Map<String, dynamic>));
    }
    return pacotes;
  }
}
