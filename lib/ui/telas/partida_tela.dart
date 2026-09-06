import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../../dominio/modelos/config_partida.dart';
import '../widgets/balao.dart';
import '../../dominio/modelos/modificadores.dart';
import '../../dominio/motor/motor_partida.dart';
import '../estado_app.dart';
import 'fases/fase_carta.dart';
import 'fases/fase_sorteio.dart';
import 'fases/fase_fim.dart';
import 'fases/fase_placar.dart';
import 'fases/fase_pergunta.dart';
import 'fases/fase_tema.dart';

class PartidaTela extends StatelessWidget {
  const PartidaTela({super.key, required this.controlador});

  final ControladorPartida controlador;

  Future<bool> _confirmarSaida(BuildContext context) async {
    final sair = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Cores.superficie,
        title: const Text('Abandonar a partida?'),
        content: const Text('O placar atual será perdido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continuar jogando'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Abandonar',
                style: corpo(14, cor: Cores.magenta)),
          ),
        ],
      ),
    );
    return sair ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controlador,
      builder: (context, _) {
        final motor = controlador.motor;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (jaSaiu, _) async {
            if (jaSaiu) return;
            if (motor.fase == FaseRodada.fim ||
                await _confirmarSaida(context)) {
              if (context.mounted) Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(_tituloDaFase(motor)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.leaderboard_outlined),
                  tooltip: 'Placar',
                  onPressed: () => _mostrarPlacar(context, motor),
                ),
              ],
            ),
            body: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(
                  key: ValueKey('${motor.fase}-${motor.indiceVez}-'
                      '${motor.perguntaAtual?.idGlobal}'),
                  child: _corpo(context, motor),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _tituloDaFase(MotorPartida motor) {
    if (motor.fase == FaseRodada.fim) return 'Fim de jogo';
    final vitoria = motor.config.vitoria;
    return vitoria.tipo == TipoVitoria.rodadas
        ? 'Rodada ${motor.rodadaAtual} de ${vitoria.alvo}'
        : 'Rodada ${motor.rodadaAtual}';
  }

  Widget _corpo(BuildContext context, MotorPartida motor) {
    return switch (motor.fase) {
      FaseRodada.sortearCanal => FaseSorteio(controlador: controlador),
      FaseRodada.escolherTema => FaseTema(controlador: controlador),
      FaseRodada.pergunta ||
      FaseRodada.revelacao ||
      FaseRodada.revelacaoAjuda =>
        FasePergunta(controlador: controlador),
      FaseRodada.cartaEspecial || FaseRodada.escolherAjudante =>
        FaseCarta(controlador: controlador),
      FaseRodada.placar => FasePlacar(controlador: controlador),
      FaseRodada.fim => FaseFim(controlador: controlador),
    };
  }

  void _mostrarPlacar(BuildContext context, MotorPartida motor) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Cores.superficieAlta,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(Medidas.raioFolha)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('PLACAR', style: titulo(22)),
              const SizedBox(height: 12),
              for (final jogador in motor.ranking)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(jogador.nome.toUpperCase(), style: titulo(15)),
                  trailing:
                      Text('${jogador.pontos}', style: titulo(20, cor: Cores.destaque)),
                ),
              const SizedBox(height: 8),
              Text(
                '${motor.perguntasRestantes} frases ainda no sorteio',
                style: corpo(13, cor: Cores.textoFraco),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cabeçalho comum das fases: de quem é a vez e o que as roletas decidiram.
class FaixaDaVez extends StatelessWidget {
  const FaixaDaVez({super.key, required this.motor});

  final MotorPartida motor;

  @override
  Widget build(BuildContext context) {
    final efeito = motor.modificador?.efeito;
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Cores.destaque,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 9),
        Flexible(
          child: Text(
            motor.jogadorDaVez.nome.toUpperCase(),
            style: titulo(20),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (efeito != null && efeito != EfeitoModificador.normal) ...[
          const SizedBox(width: 9),
          Selo(efeito.rotuloCurto, cor: corDoModificador(efeito)),
        ],
      ],
    );
  }
}

/// A cor diz o que a rodada é antes de o jogador ler o rótulo.
Color corDoModificador(EfeitoModificador efeito) => switch (efeito) {
      // Lavanda clara, não a superfície: o texto da faixa é azul-tubo e
      // sobre superfície escura ele não passa em contraste.
      EfeitoModificador.normal => Cores.textoApagado,
      EfeitoModificador.pontosEmDobro => Cores.destaque,
      EfeitoModificador.rouboLiberado => Cores.magenta,
      EfeitoModificador.coringa => Cores.ciano,
    };
