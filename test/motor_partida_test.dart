import 'package:flutter_test/flutter_test.dart';
import 'package:quem_disse_isso/dominio/modelos/carta_especial.dart';
import 'package:quem_disse_isso/dominio/modelos/config_partida.dart';
import 'package:quem_disse_isso/dominio/modelos/roleta.dart';
import 'package:quem_disse_isso/dominio/modelos/dificuldade.dart';
import 'package:quem_disse_isso/dominio/modelos/pergunta.dart';
import 'package:quem_disse_isso/dominio/motor/motor_partida.dart';

import 'apoio.dart';

MotorPartida motorCom({
  RoletaModificadores roleta =
      const RoletaModificadores([EfeitoModificador.normal]),
  CondicaoVitoria vitoria = const CondicaoVitoria.porPontos(3),
  Set<CartaEspecial> cartas = CartaEspecial.nenhuma,
  int perguntas = 40,
  Dificuldade dificuldade = Dificuldade.media,
}) {
  return MotorPartida(
    config: ConfigPartida(
      nomesJogadores: const ['Ana', 'Beto', 'Cida'],
      idsPacotesAtivos: const {'pacote_a'},
      vitoria: vitoria,
      cartasAtivas: cartas,
      roleta: roleta,
      semente: 42,
    ),
    perguntas: perguntasFalsas(perguntas, dificuldade: dificuldade),
  );
}

void main() {
  group('configuração', () {
    test('recusa menos de 3 jogadores', () {
      final config = ConfigPartida(
        nomesJogadores: const ['Ana', 'Beto'],
        idsPacotesAtivos: const {'pacote_a'},
        vitoria: const CondicaoVitoria.porPontos(10),
      );
      expect(config.problema, contains('3 jogadores'));
    });

    test('recusa nomes repetidos e pacote vazio', () {
      expect(
        ConfigPartida(
          nomesJogadores: const ['Ana', 'ana', 'Beto'],
          idsPacotesAtivos: const {'pacote_a'},
          vitoria: const CondicaoVitoria.porPontos(10),
        ).problema,
        contains('diferentes'),
      );
      expect(
        ConfigPartida(
          nomesJogadores: const ['Ana', 'Beto', 'Cida'],
          idsPacotesAtivos: const {},
          vitoria: const CondicaoVitoria.porPontos(10),
        ).problema,
        contains('pacote'),
      );
    });
  });

  group('fluxo da rodada', () {
    test('acerto pontua o jogador da vez e vai ao placar', () {
      final motor = motorCom();
      motor.girarRoletas();
      expect(motor.fase, FaseRodada.pergunta);
      motor.revelarResposta();
      motor.registrarAcerto();

      expect(motor.jogadores.first.pontos, 1);
      expect(motor.ganhosDaRodada['j0'], 1);
      expect(motor.fase, FaseRodada.placar);
    });

    test('a vez circula e a rodada só vira quando a volta fecha', () {
      final motor = motorCom(vitoria: const CondicaoVitoria.porPontos(99));
      for (var i = 0; i < 3; i++) {
        expect(motor.indiceVez, i);
        expect(motor.rodadaAtual, 1);
        motor.girarRoletas();
        motor.revelarResposta();
        motor.registrarAcerto();
        motor.proximaVez();
      }
      expect(motor.indiceVez, 0);
      expect(motor.rodadaAtual, 2);
    });

    test('ação fora de fase é erro de estado', () {
      final motor = motorCom();
      expect(motor.registrarAcerto, throwsStateError);
    });
  });

  group('dado', () {
    test('face de dobro dobra o ponto da rodada', () {
      final motor = motorCom(roleta: const RoletaModificadores([EfeitoModificador.pontosEmDobro]));
      motor.girarRoletas();
      motor.revelarResposta();
      motor.registrarAcerto();
      expect(motor.jogadores.first.pontos, 2);
    });

    test('dificuldade difícil vale mais e ainda dobra', () {
      final motor = motorCom(
        roleta: const RoletaModificadores([EfeitoModificador.pontosEmDobro]),
        dificuldade: Dificuldade.dificil,
      );
      motor.girarRoletas();
      motor.revelarResposta();
      motor.registrarAcerto();
      expect(motor.jogadores.first.pontos, 4);
    });

    test('coringa com um só tema não pede escolha', () {
      final motor = motorCom(roleta: const RoletaModificadores([EfeitoModificador.coringa]));
      motor.girarRoletas();
      expect(motor.fase, FaseRodada.pergunta);
    });

    test('coringa com vários temas deixa o jogador escolher', () {
      final motor = MotorPartida(
        config: ConfigPartida(
          nomesJogadores: const ['Ana', 'Beto', 'Cida'],
          idsPacotesAtivos: const {'pacote_a', 'pacote_b'},
          vitoria: const CondicaoVitoria.porPontos(10),
          roleta: const RoletaModificadores([EfeitoModificador.coringa]),
          semente: 1,
        ),
        perguntas: [
          ...perguntasFalsas(5),
          ...perguntasFalsas(5, idPacote: 'pacote_b'),
        ],
      );
      motor.girarRoletas();
      expect(motor.fase, FaseRodada.escolherTema);
      motor.escolherTema('pacote_b');
      expect(motor.perguntaAtual!.idPacote, 'pacote_b');
      expect(motor.fase, FaseRodada.pergunta);
    });

    test('a roleta de tema decide de qual pacote vem a frase', () {
      final motor = MotorPartida(
        config: ConfigPartida(
          nomesJogadores: const ['Ana', 'Beto', 'Cida'],
          idsPacotesAtivos: const {'pacote_a', 'pacote_b'},
          vitoria: const CondicaoVitoria.porPontos(10),
          roleta: const RoletaModificadores([EfeitoModificador.normal]),
          semente: 9,
        ),
        perguntas: [
          ...perguntasFalsas(5),
          ...perguntasFalsas(5, idPacote: 'pacote_b'),
        ],
      );
      motor.aplicarGiro((
        modificador: const ResultadoModificador(0, EfeitoModificador.normal),
        tema: 'pacote_b',
      ));
      expect(motor.perguntaAtual!.idPacote, 'pacote_b');
    });

    test('sortearGiro devolve um tema que ainda tem pergunta', () {
      final motor = motorCom(perguntas: 3);
      final giro = motor.sortearGiro();
      expect(motor.temasDisponiveis, contains(giro.tema));
    });

  });

  group('erro encerra a rodada', () {
    test('errar não dá ponto a ninguém e vai direto ao placar', () {
      final motor = motorCom();
      motor.girarRoletas();
      motor.revelarResposta();
      motor.registrarErro();

      expect(motor.fase, FaseRodada.placar);
      expect(motor.cartaAtual, isNull);
      expect(motor.jogadores.every((j) => j.pontos == 0), isTrue);
    });
  });

  group('rodada de roubo', () {
    MotorPartida motorDeRoubo() => motorCom(
          roleta:
              const RoletaModificadores([EfeitoModificador.rouboLiberado]),
        );

    test('a revelação pergunta quem acertou, não se o da vez acertou', () {
      final motor = motorDeRoubo();
      motor.girarRoletas();
      expect(motor.rodadaDeRoubo, isTrue);
      motor.revelarResposta();
      expect(motor.fase, FaseRodada.revelacao);
    });

    test('quem acertou primeiro leva o ponto, mesmo não sendo o da vez', () {
      final motor = motorDeRoubo();
      motor.girarRoletas();
      motor.revelarResposta();
      motor.registrarAcertoDe(motor.jogadores[2]);

      expect(motor.jogadores[2].pontos, 1);
      expect(motor.jogadores[0].pontos, 0);
      expect(motor.fase, FaseRodada.placar);
    });

    test('o jogador da vez também pode levar o ponto', () {
      final motor = motorDeRoubo();
      motor.girarRoletas();
      motor.revelarResposta();
      motor.registrarAcertoDe(motor.jogadorDaVez);
      expect(motor.jogadores.first.pontos, 1);
    });

    test('ninguém acertando encerra sem ponto', () {
      final motor = motorDeRoubo();
      motor.girarRoletas();
      motor.revelarResposta();
      motor.ninguemAcertou();

      expect(motor.fase, FaseRodada.placar);
      expect(motor.ganhosDaRodada, isEmpty);
    });

    test('o dobro não se acumula com o roubo: são setores diferentes', () {
      final motor = motorDeRoubo();
      motor.girarRoletas();
      motor.revelarResposta();
      motor.registrarAcertoDe(motor.jogadores[1]);
      expect(motor.jogadores[1].pontos, 1);
    });
  });

  group('cartas opcionais (desligadas por padrão)', () {
    test('sem carta ativa o erro não sorteia nada', () {
      final motor = motorCom();
      motor.girarRoletas();
      motor.revelarResposta();
      motor.registrarErro();
      expect(motor.cartaAtual, isNull);
    });

    test('ligar a Ajuda devolve a segunda chance no erro', () {
      final motor = motorCom(cartas: const {CartaEspecial.ajuda});
      motor.girarRoletas();
      motor.revelarResposta();
      motor.registrarErro();
      expect(motor.fase, FaseRodada.cartaEspecial);

      motor.aplicarCarta();
      motor.escolherAjudante(motor.jogadores[1]);
      motor.resolverAjuda(true);

      expect(motor.jogadores[0].pontos, 0);
      expect(motor.jogadores[1].pontos, 1);
    });

    test('ligar o Pulo troca a frase sem pontuar', () {
      final motor = motorCom(cartas: const {CartaEspecial.pulo});
      motor.girarRoletas();
      final antes = motor.perguntaAtual!.id;
      motor.revelarResposta();
      motor.registrarErro();
      motor.aplicarCarta();
      expect(motor.fase, FaseRodada.pergunta);
      expect(motor.perguntaAtual!.id, isNot(antes));
      expect(motor.jogadores.every((j) => j.pontos == 0), isTrue);
    });
  });

  group('alternativas', () {
    MotorPartida motorComAlternativas({
      bool ligado = true,
      List<Pergunta>? perguntas,
    }) =>
        MotorPartida(
          config: ConfigPartida(
            nomesJogadores: const ['Ana', 'Beto', 'Cida'],
            idsPacotesAtivos: const {'pacote_a'},
            vitoria: const CondicaoVitoria.porPontos(99),
            roleta: const RoletaModificadores([EfeitoModificador.normal]),
            comAlternativas: ligado,
            semente: 4,
          ),
          perguntas: perguntas ?? perguntasFalsas(20),
        );

    test('desligado não monta alternativa nenhuma', () {
      final motor = motorComAlternativas(ligado: false);
      motor.girarRoletas();
      expect(motor.alternativas, isEmpty);
    });

    test('ligado monta cinco opções sem repetir', () {
      final motor = motorComAlternativas();
      motor.girarRoletas();
      expect(motor.alternativas, hasLength(MotorPartida.totalDeAlternativas));
      expect(motor.alternativas.toSet(), hasLength(motor.alternativas.length));
    });

    test('a resposta certa está sempre entre elas', () {
      final motor = motorComAlternativas();
      for (var i = 0; i < 8; i++) {
        motor.girarRoletas();
        expect(motor.alternativas, contains(motor.perguntaAtual!.resposta));
        motor.revelarResposta();
        motor.registrarAcerto();
        motor.proximaVez();
      }
    });

    test('os distratores vêm do mesmo pacote quando dá', () {
      final motor = MotorPartida(
        config: ConfigPartida(
          nomesJogadores: const ['Ana', 'Beto', 'Cida'],
          idsPacotesAtivos: const {'pacote_a', 'pacote_b'},
          vitoria: const CondicaoVitoria.porPontos(99),
          roleta: const RoletaModificadores([EfeitoModificador.normal]),
          comAlternativas: true,
          semente: 2,
        ),
        perguntas: [
          ...perguntasFalsas(10),
          ...perguntasFalsas(10, idPacote: 'pacote_b'),
        ],
      );
      motor.girarRoletas();
      final doPacote = perguntasFalsas(10, idPacote: motor.perguntaAtual!.idPacote)
          .map((p) => p.resposta)
          .toSet();
      expect(motor.alternativas.every(doPacote.contains), isTrue);
    });

    test('acervo pequeno devolve o que existe, sem quebrar', () {
      final motor = motorComAlternativas(perguntas: perguntasFalsas(3));
      motor.girarRoletas();
      expect(motor.alternativas, hasLength(3));
      expect(motor.alternativas, contains(motor.perguntaAtual!.resposta));
    });

    test('a lista não muda entre leituras da mesma pergunta', () {
      final motor = motorComAlternativas();
      motor.girarRoletas();
      final primeira = motor.alternativas;
      expect(motor.alternativas, same(primeira));
      motor.revelarResposta();
      expect(motor.alternativas, same(primeira));
    });
  });

  group('níveis de dificuldade', () {
    MotorPartida motorComNiveis(Set<Dificuldade> niveis) => MotorPartida(
          config: ConfigPartida(
            nomesJogadores: const ['Ana', 'Beto', 'Cida'],
            idsPacotesAtivos: const {'pacote_a'},
            vitoria: const CondicaoVitoria.porPontos(99),
            roleta: const RoletaModificadores([EfeitoModificador.normal]),
            dificuldadesAtivas: niveis,
            semente: 11,
          ),
          perguntas: [
            ...perguntasFalsas(4, dificuldade: Dificuldade.facil),
            ...perguntasFalsas(4, dificuldade: Dificuldade.media),
            ...perguntasFalsas(4, dificuldade: Dificuldade.dificil),
          ],
        );

    test('só sorteia perguntas dos níveis escolhidos', () {
      final motor = motorComNiveis({Dificuldade.dificil});
      var vistas = 0;
      while (motor.temPerguntas) {
        motor.girarRoletas();
        expect(motor.perguntaAtual!.dificuldade, Dificuldade.dificil);
        vistas++;
        motor.revelarResposta();
        motor.registrarAcerto();
        motor.proximaVez();
        if (motor.fase == FaseRodada.fim) break;
      }
      expect(vistas, 4);
    });

    test('dois níveis somam os dois acervos', () {
      final motor = motorComNiveis({Dificuldade.facil, Dificuldade.media});
      expect(motor.perguntasRestantes, 8);
    });

    test('sem nível escolhido a configuração é inválida', () {
      final config = ConfigPartida(
        nomesJogadores: const ['Ana', 'Beto', 'Cida'],
        idsPacotesAtivos: const {'pacote_a'},
        vitoria: const CondicaoVitoria.porPontos(10),
        dificuldadesAtivas: const {},
      );
      expect(config.problema, contains('nível'));
    });

    test('o filtro não mexe na pontuação por dificuldade', () {
      final motor = motorComNiveis({Dificuldade.dificil});
      motor.girarRoletas();
      motor.revelarResposta();
      motor.registrarAcerto();
      expect(motor.jogadores.first.pontos, 2);
    });
  });

  group('fim de partida', () {
    test('termina assim que alguém atinge a meta de pontos', () {
      final motor = motorCom(vitoria: const CondicaoVitoria.porPontos(2));
      for (var volta = 0; volta < 2; volta++) {
        motor.girarRoletas();
        motor.revelarResposta();
        motor.registrarAcerto();
        motor.proximaVez();
        if (motor.fase == FaseRodada.fim) break;
        motor.girarRoletas();
        motor.revelarResposta();
        motor.registrarErro();
        motor.fase = FaseRodada.placar;
        motor.proximaVez();
        motor.girarRoletas();
        motor.revelarResposta();
        motor.registrarErro();
        motor.fase = FaseRodada.placar;
        motor.proximaVez();
      }
      expect(motor.fase, FaseRodada.fim);
      expect(motor.vencedores.single.nome, 'Ana');
    });

    test('termina ao fechar o número de rodadas combinado', () {
      final motor = motorCom(vitoria: const CondicaoVitoria.porRodadas(2));
      var jogadas = 0;
      while (motor.fase != FaseRodada.fim && jogadas < 20) {
        motor.girarRoletas();
        motor.revelarResposta();
        motor.registrarAcerto();
        motor.proximaVez();
        jogadas++;
      }
      expect(jogadas, 6);
      expect(motor.rodadaAtual, 3);
      expect(motor.vencedores, hasLength(3));
    });

    test('acabar as perguntas encerra a partida', () {
      final motor = motorCom(
        vitoria: const CondicaoVitoria.porPontos(999),
        perguntas: 2,
      );
      motor.girarRoletas();
      motor.revelarResposta();
      motor.registrarAcerto();
      motor.proximaVez();
      motor.girarRoletas();
      motor.revelarResposta();
      motor.registrarAcerto();
      motor.proximaVez();
      expect(motor.fase, FaseRodada.fim);
    });

    test('mesma semente produz a mesma partida', () {
      List<String> roteiro() {
        final motor = motorCom(vitoria: const CondicaoVitoria.porPontos(99));
        final frases = <String>[];
        for (var i = 0; i < 6; i++) {
          motor.girarRoletas();
          frases.add(motor.perguntaAtual!.id);
          motor.revelarResposta();
          motor.registrarAcerto();
          motor.proximaVez();
        }
        return frases;
      }

      expect(roteiro(), roteiro());
    });
  });
}
