import 'dart:convert';
import 'dart:io';

import '../dominio/modelos/pacote.dart';
import 'fonte_pacotes.dart';

/// Pacotes comprados e baixados, gravados no aparelho. Enquanto a loja não
/// existe a pasta fica vazia — e o motor não percebe diferença.
class FontePacotesArquivos implements FontePacotes {
  const FontePacotesArquivos(this.pasta);

  final Directory pasta;

  @override
  Future<List<Pacote>> carregar() async {
    if (!await pasta.exists()) return const [];
    final pacotes = <Pacote>[];
    await for (final item in pasta.list()) {
      if (item is! File || !item.path.endsWith('.json')) continue;
      try {
        final bruto = jsonDecode(await item.readAsString());
        pacotes.add(Pacote.deJson(bruto as Map<String, dynamic>));
      } on Exception {
        // Um arquivo corrompido não pode derrubar os pacotes que estão sãos.
        continue;
      }
    }
    return pacotes;
  }
}
