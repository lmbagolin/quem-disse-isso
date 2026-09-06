import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../dados/fonte_pacotes.dart';
import '../dados/fonte_pacotes_arquivos.dart';
import '../dados/fonte_pacotes_assets.dart';
import '../dados/gerenciador_pacotes.dart';
import '../dados/preferencias.dart';
import '../dominio/modelos/config_partida.dart';
import '../dominio/motor/motor_partida.dart';

class EstadoApp extends ChangeNotifier {
  EstadoApp({GerenciadorPacotes? gerenciador, Preferencias? preferencias})
      : gerenciador = gerenciador ?? GerenciadorPacotes([]),
        _gerenciadorInjetado = gerenciador != null,
        _preferenciasInjetadas = preferencias;

  final bool _gerenciadorInjetado;
  final Preferencias? _preferenciasInjetadas;

  /// Nunca `late`: uma falha na inicialização precisa deixar a tela inicial
  /// de pé para mostrar o erro, não estourar ao ler o gerenciador.
  GerenciadorPacotes gerenciador;
  Preferencias? preferencias;
  bool pronto = false;
  Object? falha;

  Future<void> iniciar() async {
    try {
      if (!_gerenciadorInjetado) {
        gerenciador = GerenciadorPacotes([
          const FontePacotesAssets(),
          ...await _fontesDeBaixados(),
        ]);
      }
      preferencias = _preferenciasInjetadas ?? await Preferencias.abrir();
      await gerenciador.recarregar();
      falha = null;
    } catch (e) {
      falha = e;
    }
    pronto = true;
    notifyListeners();
  }

  /// A pasta de pacotes baixados não existe em toda plataforma (a web não tem
  /// diretório de suporte). Sem loja publicada, ficar sem ela não muda nada.
  Future<List<FontePacotes>> _fontesDeBaixados() async {
    try {
      final base = await getApplicationSupportDirectory();
      return [FontePacotesArquivos(Directory('${base.path}/pacotes'))];
    } catch (_) {
      // Inclui UnimplementedError, que é Error e não Exception.
      return const [];
    }
  }

  ControladorPartida criarPartida(ConfigPartida config) {
    preferencias?.salvar(config);
    return ControladorPartida(
      MotorPartida(
        config: config,
        perguntas: gerenciador.perguntasDe(config.idsPacotesAtivos),
      ),
    );
  }
}

/// Adapta a máquina de estados do motor ao ciclo de rebuild do Flutter.
class ControladorPartida extends ChangeNotifier {
  ControladorPartida(this.motor);

  final MotorPartida motor;

  void executar(void Function(MotorPartida m) acao) {
    acao(motor);
    notifyListeners();
  }
}

class EscopoApp extends InheritedNotifier<EstadoApp> {
  const EscopoApp({super.key, required EstadoApp estado, required super.child})
      : super(notifier: estado);

  static EstadoApp de(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EscopoApp>()!.notifier!;
}
