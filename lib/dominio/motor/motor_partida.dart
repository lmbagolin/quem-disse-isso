import 'dart:math';

import '../modelos/carta_especial.dart';
import '../modelos/config_partida.dart';
import '../modelos/modificadores.dart';
import '../modelos/jogador.dart';
import '../modelos/pergunta.dart';
import 'sorteador.dart';

typedef Giro = ({ResultadoModificador modificador, String? tema});

enum FaseRodada {
  sortearCanal,
  escolherTema,
  pergunta,
  revelacao,
  cartaEspecial,
  escolherAjudante,
  revelacaoAjuda,
  placar,
  fim,
}

/// Máquina de estados de uma partida. Não conhece nenhuma pergunta: recebe o
/// conteúdo pronto e só aplica as regras.
class MotorPartida {
  MotorPartida({
    required this.config,
    required List<Pergunta> perguntas,
  })  : _sorte = Random(config.semente),
        _acervo = List.unmodifiable(config.filtrar(perguntas)),
        jogadores = List.unmodifiable([
          for (var i = 0; i < config.nomesJogadores.length; i++)
            Jogador(id: 'j$i', nome: config.nomesJogadores[i].trim()),
        ]) {
    assert(config.problema == null, config.problema);
    _sorteador = Sorteador(_acervo.toList(), _sorte);
  }

  final ConfigPartida config;
  final List<Jogador> jogadores;
  final Random _sorte;

  /// Acervo completo da partida, inclusive o que já saiu: as respostas das
  /// outras perguntas é que viram alternativas.
  final List<Pergunta> _acervo;
  late final Sorteador _sorteador;

  static const int totalDeAlternativas = 5;

  FaseRodada fase = FaseRodada.sortearCanal;
  int indiceVez = 0;
  int rodadaAtual = 1;

  ResultadoModificador? modificador;
  Pergunta? perguntaAtual;
  CartaEspecial? cartaAtual;
  bool dicaRevelada = false;

  /// Opções da pergunta atual, embaralhadas. Vazio quando a partida roda sem
  /// alternativas. Montadas uma vez por pergunta, nunca no build da tela.
  List<String> alternativas = const [];
  Jogador? envolvido;

  /// Pontos ganhos na última rodada resolvida, para a tela de placar.
  final Map<String, int> ganhosDaRodada = {};

  Jogador get jogadorDaVez => jogadores[indiceVez];

  /// Quem recebe o celular ao fim desta rodada.
  Jogador get proximoJogador => jogadores[(indiceVez + 1) % jogadores.length];

  bool get temPerguntas => !_sorteador.vazio;

  int get perguntasRestantes => _sorteador.restantes;

  Set<String> get temasDisponiveis => _sorteador.pacotesComPerguntas;

  List<Jogador> get ranking {
    final ordenado = List.of(jogadores)
      ..sort((a, b) => b.pontos.compareTo(a.pontos));
    return List.unmodifiable(ordenado);
  }

  List<Jogador> get vencedores {
    final melhor = ranking.first.pontos;
    return List.unmodifiable(jogadores.where((j) => j.pontos == melhor));
  }

  /// Na rodada de roubo todos respondem desde o início, então a revelação
  /// pergunta quem acertou em vez de julgar só o jogador da vez.
  bool get rodadaDeRoubo =>
      modificador?.efeito == EfeitoModificador.rouboLiberado;

  List<Jogador> get outrosJogadores =>
      List.unmodifiable(jogadores.where((j) => j.id != jogadorDaVez.id));

  // --- Transições -----------------------------------------------------------

  /// Sorteia o giro sem aplicá-lo: a tela precisa do resultado antes de animar
  /// as roletas, para elas pararem no setor certo.
  Giro prepararSorteio() => (
        modificador: config.modificadores.sortear(_sorte),
        tema: sortearTema(),
      );

  String? sortearTema() {
    final temas = temasDisponiveis.toList()..sort();
    if (temas.isEmpty) return null;
    return temas[_sorte.nextInt(temas.length)];
  }

  Giro sortearCanal() {
    final giro = prepararSorteio();
    aplicarSorteio(giro);
    return giro;
  }

  void aplicarSorteio(Giro giro) {
    _exigir(FaseRodada.sortearCanal);
    modificador = giro.modificador;
    // No coringa o tema da roleta é descartado: quem escolhe é o jogador.
    if (giro.modificador.efeito == EfeitoModificador.coringa &&
        temasDisponiveis.length > 1) {
      fase = FaseRodada.escolherTema;
    } else {
      _puxarPergunta(idPacote: giro.tema);
    }
  }

  void escolherTema(String idPacote) {
    _exigir(FaseRodada.escolherTema);
    _puxarPergunta(idPacote: idPacote);
  }

  void revelarResposta() {
    _exigir(FaseRodada.pergunta);
    fase = FaseRodada.revelacao;
  }

  void registrarAcerto() {
    _exigir(FaseRodada.revelacao);
    _pontuar(jogadorDaVez, _pontosDaRodada());
    _irParaPlacar();
  }

  /// Sem carta ativa, errar encerra a rodada sem ponto para ninguém.
  void registrarErro() {
    _exigir(FaseRodada.revelacao);
    cartaAtual = _sortearCarta();
    if (cartaAtual == null) {
      _irParaPlacar();
      return;
    }
    fase = FaseRodada.cartaEspecial;
  }

  /// Rodada de roubo: quem a mesa apontar como primeiro a acertar leva o ponto.
  void registrarAcertoDe(Jogador jogador) {
    _exigir(FaseRodada.revelacao);
    _pontuar(jogador, _pontosDaRodada());
    envolvido = jogador;
    _irParaPlacar();
  }

  void ninguemAcertou() {
    _exigir(FaseRodada.revelacao);
    _irParaPlacar();
  }

  void aplicarCarta() {
    _exigir(FaseRodada.cartaEspecial);
    switch (cartaAtual!) {
      case CartaEspecial.ajuda:
        fase = FaseRodada.escolherAjudante;
      case CartaEspecial.dica:
        dicaRevelada = true;
        fase = FaseRodada.pergunta;
      case CartaEspecial.pulo:
        _puxarPergunta();
    }
  }

  void escolherAjudante(Jogador ajudante) {
    _exigir(FaseRodada.escolherAjudante);
    envolvido = ajudante;
    fase = FaseRodada.revelacaoAjuda;
  }

  void resolverAjuda(bool acertou) {
    _exigir(FaseRodada.revelacaoAjuda);
    if (acertou) {
      final (paraJogador, paraAjudante) =
          config.regras.dividirAjuda(_pontosDaRodada());
      _pontuar(jogadorDaVez, paraJogador);
      _pontuar(envolvido!, paraAjudante);
    }
    _irParaPlacar();
  }

  void proximaVez() {
    _exigir(FaseRodada.placar);
    if (_partidaAcabou()) {
      fase = FaseRodada.fim;
      return;
    }
    indiceVez = (indiceVez + 1) % jogadores.length;
    if (indiceVez == 0) rodadaAtual++;
    if (_partidaAcabou()) {
      fase = FaseRodada.fim;
      return;
    }
    _limparRodada();
    fase = FaseRodada.sortearCanal;
  }

  // --- Regras internas ------------------------------------------------------

  void _puxarPergunta({String? idPacote}) {
    final proxima = _sorteador.proxima(idPacote: idPacote);
    if (proxima == null) {
      perguntaAtual = null;
      fase = FaseRodada.fim;
      return;
    }
    perguntaAtual = proxima;
    dicaRevelada = false;
    alternativas = _montarAlternativas(proxima);
    fase = FaseRodada.pergunta;
  }

  List<String> _montarAlternativas(Pergunta pergunta) {
    if (!config.comAlternativas) return const [];
    final opcoes = [
      pergunta.resposta,
      ..._distratores(pergunta).take(totalDeAlternativas - 1),
    ]..shuffle(_sorte);
    return List.unmodifiable(opcoes);
  }

  /// Respostas de outras perguntas viram alternativas erradas. As do mesmo
  /// pacote vêm primeiro: entre filmes, outro filme engana; um slogan, não.
  List<String> _distratores(Pergunta pergunta) {
    final vistas = {pergunta.resposta};
    final doPacote = <String>[];
    final deOutros = <String>[];
    for (final candidata in _acervo) {
      if (!vistas.add(candidata.resposta)) continue;
      (candidata.idPacote == pergunta.idPacote ? doPacote : deOutros)
          .add(candidata.resposta);
    }
    doPacote.shuffle(_sorte);
    deOutros.shuffle(_sorte);
    return [...doPacote, ...deOutros];
  }

  int _pontosDaRodada() {
    var pontos = config.regras.pontoBase(perguntaAtual!.dificuldade);
    if (modificador?.efeito == EfeitoModificador.pontosEmDobro) {
      pontos *= config.regras.fatorDobro;
    }
    if (dicaRevelada) {
      pontos = max(1, pontos - config.regras.descontoDaDica);
    }
    return pontos;
  }

  CartaEspecial? _sortearCarta() {
    final disponiveis = config.cartasAtivas.toList()
      ..removeWhere((c) => c == CartaEspecial.dica && perguntaAtual?.dica == null)
      ..removeWhere((c) => c == CartaEspecial.pulo && !temPerguntas);
    if (disponiveis.isEmpty) return null;
    return disponiveis[_sorte.nextInt(disponiveis.length)];
  }

  void _pontuar(Jogador jogador, int pontos) {
    if (pontos <= 0) return;
    jogador.pontos += pontos;
    ganhosDaRodada[jogador.id] = (ganhosDaRodada[jogador.id] ?? 0) + pontos;
  }

  void _irParaPlacar() {
    fase = FaseRodada.placar;
  }

  void _limparRodada() {
    ganhosDaRodada.clear();
    modificador = null;
    perguntaAtual = null;
    cartaAtual = null;
    envolvido = null;
    dicaRevelada = false;
    alternativas = const [];
  }

  bool _partidaAcabou() {
    if (!temPerguntas) return true;
    return switch (config.vitoria.tipo) {
      TipoVitoria.pontos =>
        jogadores.any((j) => j.pontos >= config.vitoria.alvo),
      // Só termina quando a volta fecha, para todo mundo jogar o mesmo tanto.
      TipoVitoria.rodadas =>
        rodadaAtual > config.vitoria.alvo && indiceVez == 0,
    };
  }

  void _exigir(FaseRodada esperada) {
    if (fase != esperada) {
      throw StateError('Ação inválida na fase $fase (esperava $esperada).');
    }
  }
}
