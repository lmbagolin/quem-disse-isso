import 'package:flutter/material.dart';

import '../../core/tema.dart';

/// Fundo da tela com a textura de tubo de imagem: linhas de 1px a cada 3px.
/// Cada tela declara o próprio fundo e o tom das linhas — sobre magenta elas
/// precisam ser escuras, senão a textura some. É só atmosfera: em tela pequena
/// desaparece, então nada de conteúdo depende dela.
class Tubo extends StatelessWidget {
  const Tubo({
    super.key,
    required this.child,
    this.fundo = Cores.fundo,
    this.escuro = false,
  });

  final Widget child;
  final Color fundo;
  final bool escuro;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: fundo,
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _Linhas(escuro)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Linhas extends CustomPainter {
  _Linhas(this.escuro);

  final bool escuro;

  @override
  void paint(Canvas canvas, Size size) {
    final tinta = Paint()
      ..color = escuro
          ? Colors.black.withValues(alpha: 0.06)
          : Colors.white.withValues(alpha: 0.045);
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), tinta);
    }
  }

  @override
  bool shouldRepaint(_Linhas anterior) => anterior.escuro != escuro;
}
