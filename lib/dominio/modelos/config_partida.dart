import 'carta_especial.dart';
import 'modificadores.dart';
import 'dificuldade.dart';
import 'pergunta.dart';

enum TipoVitoria { pontos, rodadas }

class CondicaoVitoria {
  const CondicaoVitoria.porPontos(this.alvo) : tipo = TipoVitoria.pontos;
  const CondicaoVitoria.porRodadas(this.alvo) : tipo = TipoVitoria.rodadas;

  final TipoVitoria tipo;
  final int alvo;

  String get descricao => switch (tipo) {
        TipoVitoria.pontos => 'Primeiro a $alvo pontos',
        TipoVitoria.rodadas => '$alvo rodadas',
      };
}

class RegrasPontuacao {
  const RegrasPontuacao({
    this.pontosPorDificuldade = const {
      Dificuldade.facil: 1,
      Dificuldade.media: 1,
      Dificuldade.dificil: 2,
    },
    this.fatorDobro = 2,
    this.descontoDaDica = 1,
  });

  final Map<Dificuldade, int> pontosPorDificuldade;
  final int fatorDobro;

  /// Quanto o acerto perde quando a carta Dica foi usada (mínimo de 1 ponto).
  final int descontoDaDica;

  int pontoBase(Dificuldade dificuldade) =>
      pontosPorDificuldade[dificuldade] ?? 1;

  /// Divisão do ponto na carta Ajuda. Com ponto base 1 o ajudante fica com ele
  /// inteiro — é o desempate mais simples e está aberto a rebalanceamento.
  (int paraJogador, int paraAjudante) dividirAjuda(int pontos) {
    final metade = pontos ~/ 2;
    return (metade, pontos - metade);
  }
}

class ConfigPartida {
  ConfigPartida({
    required this.nomesJogadores,
    required this.idsPacotesAtivos,
    required this.vitoria,
    this.cartasAtivas = CartaEspecial.nenhuma,
    this.modificadores = Modificadores.padrao,
    this.regras = const RegrasPontuacao(),
    this.segundosParaResponder = segundosPadrao,
    this.dificuldadesAtivas = todasAsDificuldades,
    this.comAlternativas = false,
    this.semente,
  });

  static const Set<Dificuldade> todasAsDificuldades = {
    Dificuldade.facil,
    Dificuldade.media,
    Dificuldade.dificil,
  };

  static const int segundosPadrao = 10;
  static const int semCronometro = 0;

  static const int minJogadores = 3;
  static const int maxJogadores = 8;

  final List<String> nomesJogadores;
  final Set<String> idsPacotesAtivos;
  final CondicaoVitoria vitoria;
  final Set<CartaEspecial> cartasAtivas;
  final Modificadores modificadores;
  final RegrasPontuacao regras;

  /// Tempo de resposta antes do aviso de "tempo esgotado". Esgotar não revela
  /// nada: a decisão de revelar continua sendo dos jogadores.
  /// [semCronometro] desliga a contagem.
  final int segundosParaResponder;

  /// Níveis que entram no sorteio. Só filtra o que já vem classificado no
  /// pacote; não muda a pontuação, que segue [RegrasPontuacao].
  final Set<Dificuldade> dificuldadesAtivas;

  /// Mostra a frase acompanhada de alternativas. Continua sendo a mesa que
  /// julga o acerto: as opções ajudam a lembrar, não corrigem ninguém.
  final bool comAlternativas;

  /// Semente fixa deixa a partida reproduzível nos testes.
  final int? semente;

  Iterable<Pergunta> filtrar(Iterable<Pergunta> perguntas) =>
      perguntas.where((p) => dificuldadesAtivas.contains(p.dificuldade));

  String? get problema {
    if (nomesJogadores.length < minJogadores) {
      return 'A partida precisa de pelo menos $minJogadores jogadores.';
    }
    if (nomesJogadores.length > maxJogadores) {
      return 'A partida aceita no máximo $maxJogadores jogadores.';
    }
    if (nomesJogadores.any((n) => n.trim().isEmpty)) {
      return 'Todo jogador precisa de um nome.';
    }
    final unicos = nomesJogadores.map((n) => n.trim().toLowerCase()).toSet();
    if (unicos.length != nomesJogadores.length) {
      return 'Os nomes dos jogadores precisam ser diferentes.';
    }
    if (idsPacotesAtivos.isEmpty) {
      return 'Escolha pelo menos um pacote.';
    }
    if (vitoria.alvo < 1) {
      return 'A condição de vitória precisa de um alvo maior que zero.';
    }
    if (segundosParaResponder < 0) {
      return 'O tempo de resposta não pode ser negativo.';
    }
    if (dificuldadesAtivas.isEmpty) {
      return 'Escolha pelo menos um nível de dificuldade.';
    }
    return null;
  }
}
