import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../../dominio/modelos/config_partida.dart';
import '../../dominio/modelos/roleta.dart';
import '../../dominio/motor/motor_partida.dart';
import '../estado_app.dart';
import 'fases/fase_carta.dart';
import 'fases/fase_roletas.dart';
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
            child: const Text('Abandonar',
                style: TextStyle(color: Cores.erro)),
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
      FaseRodada.girarRoletas => FaseRoletas(controlador: controlador),
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
      backgroundColor: Cores.superficie,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Placar',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              for (final jogador in motor.ranking)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(jogador.nome),
                  trailing: Text(
                    '${jogador.pontos}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Cores.destaque,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'Perguntas restantes nos pacotes: ${motor.temPerguntas ? "sim" : "acabaram"}',
                style: const TextStyle(color: Cores.textoFraco, fontSize: 13),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vez de',
          style: const TextStyle(color: Cores.textoFraco, fontSize: 14),
        ),
        Text(
          motor.jogadorDaVez.nome,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        if (efeito != null && efeito != EfeitoModificador.normal)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Cores.roxo.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              efeito.titulo.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Cores.roxo,
              ),
            ),
          ),
      ],
    );
  }
}
