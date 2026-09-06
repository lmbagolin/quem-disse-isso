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
            body: SafeArea(
              child: Column(
                children: [
                  BarraDaRodada(
                    rotulo: _tituloDaFase(motor),
                    aoVoltar: () => Navigator.of(context).maybePop(),
                    aoAbrirPlacar: () => _mostrarPlacar(context, motor),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: KeyedSubtree(
                        key: ValueKey('${motor.fase}-${motor.indiceVez}-'
                            '${motor.perguntaAtual?.idGlobal}'),
                        child: _corpo(context, motor),
                      ),
                    ),
                  ),
                ],
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


/// Cabeçalho das telas de partida: voltar, o número da rodada em amarelo e as
/// barras de sinal, que abrem o placar sem virar um ícone estranho à marca.
class BarraDaRodada extends StatelessWidget {
  const BarraDaRodada({
    super.key,
    required this.rotulo,
    required this.aoVoltar,
    required this.aoAbrirPlacar,
  });

  final String rotulo;
  final VoidCallback aoVoltar;
  final VoidCallback aoAbrirPlacar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: aoVoltar,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 32,
              height: 32,
              child: Icon(Icons.arrow_back, size: 19, color: Cores.textoFraco),
            ),
          ),
          Text(
            rotulo.toUpperCase(),
            style: corpo(12, cor: Cores.destaque, peso: 700, espacamento: 2.2),
          ),
          GestureDetector(
            onTap: aoAbrirPlacar,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 32,
              height: 32,
              child: Center(child: BarrasDeSinal()),
            ),
          ),
        ],
      ),
    );
  }
}

class BarrasDeSinal extends StatelessWidget {
  const BarrasDeSinal({super.key, this.cor = Cores.textoFraco});

  final Color cor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 15,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final altura in const [8.0, 15.0, 11.0]) ...[
            Container(width: 4, height: altura, color: cor),
            if (altura != 11.0) const SizedBox(width: 3),
          ],
        ],
      ),
    );
  }
}
