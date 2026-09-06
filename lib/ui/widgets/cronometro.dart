import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/tema.dart';

/// Toca o aviso de tempo esgotado. Numa mesa barulhenta o som chega antes da
/// tela, então ele vem acompanhado de vibração.
class AvisoDeTempo {
  const AvisoDeTempo();

  static const String arquivo = 'som/tempo-esgotado.wav';

  Future<void> tocar() async {
    // Falhar aqui nunca pode derrubar a rodada: sem áudio o jogo continua.
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
    try {
      final tocador = AudioPlayer();
      await tocador.play(AssetSource(arquivo));
      tocador.onPlayerComplete.first.then((_) => tocador.dispose());
    } catch (_) {}
  }
}

/// Barra no topo da pergunta, para ler de longe com o celular no meio da mesa.
/// Conta o tempo e avisa quando esgota; não decide nada — revelar a resposta
/// continua sendo ação dos jogadores.
class Cronometro extends StatefulWidget {
  const Cronometro({
    super.key,
    required this.segundos,
    this.aviso = const AvisoDeTempo(),
  });

  final int segundos;
  final AvisoDeTempo aviso;

  /// Abaixo disso a barra vira magenta.
  static const int limiteDeUrgencia = 3;

  @override
  State<Cronometro> createState() => _CronometroState();
}

class _CronometroState extends State<Cronometro> {
  Timer? _relogio;
  late int _restantes = widget.segundos;

  @override
  void initState() {
    super.initState();
    _iniciarContagem();
  }

  @override
  void didUpdateWidget(Cronometro anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.segundos != widget.segundos) {
      _restantes = widget.segundos;
      _iniciarContagem();
    }
  }

  @override
  void dispose() {
    _relogio?.cancel();
    super.dispose();
  }

  void _iniciarContagem() {
    _relogio?.cancel();
    if (widget.segundos <= 0) return;
    _relogio = Timer.periodic(const Duration(seconds: 1), (relogio) {
      if (_restantes <= 1) {
        relogio.cancel();
        widget.aviso.tocar();
      }
      setState(() => _restantes = _restantes - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.segundos <= 0) return const SizedBox.shrink();

    final esgotou = _restantes <= 0;
    final urgente = _restantes <= Cronometro.limiteDeUrgencia;
    final cor = urgente ? Cores.magenta : Cores.destaque;
    final fracao = esgotou ? 0.0 : _restantes / widget.segundos;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: fracao),
              duration: const Duration(milliseconds: 900),
              builder: (context, valor, _) => LinearProgressIndicator(
                value: valor,
                minHeight: 6,
                backgroundColor: Cores.superficie,
                valueColor: AlwaysStoppedAnimation(cor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          esgotou ? 'TEMPO' : _restantes.toString().padLeft(2, '0'),
          style: titulo(16, cor: cor),
        ),
      ],
    );
  }
}
