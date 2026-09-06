import '../dominio/modelos/pacote.dart';
import '../dominio/modelos/pergunta.dart';
import 'fonte_pacotes.dart';

/// Única porta entre o motor e o conteúdo. Adicionar pacote é adicionar
/// arquivo: nada aqui sabe o que está escrito nas perguntas.
class GerenciadorPacotes {
  GerenciadorPacotes(this.fontes);

  final List<FontePacotes> fontes;

  final Map<String, Pacote> _instalados = {};

  List<Pacote> get instalados {
    final lista = _instalados.values.toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
    return List.unmodifiable(lista);
  }

  Future<void> recarregar() async {
    _instalados.clear();
    for (final fonte in fontes) {
      for (final pacote in await fonte.carregar()) {
        final atual = _instalados[pacote.id];
        // Fontes posteriores (pacote baixado) atualizam versões mais antigas.
        if (atual == null || pacote.versao >= atual.versao) {
          _instalados[pacote.id] = pacote;
        }
      }
    }
  }

  Pacote? porId(String id) => _instalados[id];

  List<Pergunta> perguntasDe(Iterable<String> idsPacotes) => [
        for (final id in idsPacotes)
          ...?_instalados[id]?.perguntas,
      ];
}
