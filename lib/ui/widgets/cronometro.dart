import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/tema.dart';

/// Conta o tempo de resposta e avisa quando esgota. Não decide nada: revelar a
/// resposta continua sendo ação dos jogadores.
class Cronometro extends StatefulWidget {
  const Cronometro({super.key, required this.segundos});

  final int segundos;

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
      if (_restantes <= 1) relogio.cancel();
      setState(() => _restantes = _restantes - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.segundos <= 0) return const SizedBox.shrink();

    final esgotou = _restantes <= 0;
    final fracao = esgotou ? 0.0 : _restantes / widget.segundos;
    final cor = esgotou
        ? Cores.erro
        : fracao <= 0.34
            ? Cores.destaque
            : Cores.roxo;

    if (esgotou) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Cores.erro.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_off_outlined, size: 18, color: Cores.erro),
            SizedBox(width: 8),
            Text(
              'Tempo esgotado',
              style: TextStyle(
                color: Cores.erro,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(end: fracao),
            duration: const Duration(milliseconds: 900),
            builder: (context, valor, _) => SizedBox.expand(
              child: CircularProgressIndicator(
                value: valor,
                strokeWidth: 4,
                backgroundColor: Cores.superficieAlta,
                valueColor: AlwaysStoppedAnimation(cor),
              ),
            ),
          ),
          Text(
            '$_restantes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}
