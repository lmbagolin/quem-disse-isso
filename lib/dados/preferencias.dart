import 'package:shared_preferences/shared_preferences.dart';

import '../dominio/modelos/config_partida.dart';
import '../dominio/modelos/dificuldade.dart';

/// Guarda a última configuração de partida para não redigitar tudo a cada jogo.
class Preferencias {
  Preferencias(this._prefs);

  static Future<Preferencias> abrir() async =>
      Preferencias(await SharedPreferences.getInstance());

  static const _kNomes = 'jogadores';
  static const _kPacotes = 'pacotes_ativos';
  static const _kTipoVitoria = 'vitoria_tipo';
  static const _kAlvoVitoria = 'vitoria_alvo';
  static const _kSegundos = 'segundos_resposta';
  static const _kPacotesVistos = 'pacotes_vistos';
  static const _kDificuldades = 'dificuldades';
  static const _kAlternativas = 'com_alternativas';

  final SharedPreferences _prefs;

  List<String> get nomesJogadores => _prefs.getStringList(_kNomes) ?? const [];

  Set<String> get pacotesAtivos =>
      (_prefs.getStringList(_kPacotes) ?? const []).toSet();

  /// Pacotes que o jogador já viu na tela de setup ao menos uma vez.
  Set<String> get pacotesVistos =>
      (_prefs.getStringList(_kPacotesVistos) ?? const []).toSet();

  /// Pacote recém-instalado entra ligado: quem acabou de comprar um pacote
  /// espera achá-lo na partida, não desmarcado.
  Set<String> ativosPara(Iterable<String> instalados) {
    final vistos = pacotesVistos;
    if (vistos.isEmpty) return instalados.toSet();
    final novos = instalados.where((id) => !vistos.contains(id));
    return {...pacotesAtivos.where(instalados.contains), ...novos};
  }

  Future<void> registrarVistos(Iterable<String> instalados) =>
      _prefs.setStringList(_kPacotesVistos, instalados.toList());

  CondicaoVitoria get vitoria {
    final alvo = _prefs.getInt(_kAlvoVitoria) ?? 10;
    final tipo = _prefs.getString(_kTipoVitoria);
    return tipo == TipoVitoria.rodadas.name
        ? CondicaoVitoria.porRodadas(alvo)
        : CondicaoVitoria.porPontos(alvo);
  }

  int get segundosParaResponder =>
      _prefs.getInt(_kSegundos) ?? ConfigPartida.segundosPadrao;

  Set<Dificuldade> get dificuldadesAtivas {
    final chaves = _prefs.getStringList(_kDificuldades);
    if (chaves == null || chaves.isEmpty) {
      return ConfigPartida.todasAsDificuldades;
    }
    return chaves.map(Dificuldade.daChave).toSet();
  }

  bool get comAlternativas => _prefs.getBool(_kAlternativas) ?? false;

  Future<void> salvar(ConfigPartida config) async {
    await _prefs.setStringList(_kNomes, config.nomesJogadores);
    await _prefs.setStringList(_kPacotes, config.idsPacotesAtivos.toList());
    await _prefs.setString(_kTipoVitoria, config.vitoria.tipo.name);
    await _prefs.setInt(_kAlvoVitoria, config.vitoria.alvo);
    await _prefs.setInt(_kSegundos, config.segundosParaResponder);
    await _prefs.setStringList(
      _kDificuldades,
      config.dificuldadesAtivas.map((d) => d.chave).toList(),
    );
    await _prefs.setBool(_kAlternativas, config.comAlternativas);
  }
}
