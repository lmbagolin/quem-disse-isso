import 'package:flutter/material.dart';

import '../core/tema.dart';
import 'estado_app.dart';

/// Cada pacote é um canal de TV: número, cor e nome. Um pacote novo não precisa
/// de ilustração nenhuma — só entra na fila de cores.
class Canal {
  const Canal({required this.numero, required this.cor, required this.nome});

  final int numero;
  final Color cor;
  final String nome;

  static Canal de(BuildContext context, String idPacote) {
    final gerenciador = EscopoApp.de(context).gerenciador;
    final indice = gerenciador.indiceDe(idPacote);
    final pacote = gerenciador.porId(idPacote);
    return Canal(
      numero: indice + 1,
      cor: Cores.doCanal(indice < 0 ? 0 : indice),
      nome: pacote?.nome ?? idPacote,
    );
  }

  String get rotulo => 'Canal ${numero.toString().padLeft(2, '0')} · $nome';
}
