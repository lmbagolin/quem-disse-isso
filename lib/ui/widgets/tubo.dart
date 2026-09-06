import 'package:flutter/material.dart';

/// Textura de tubo de imagem: linhas claras de 1px a cada 3px, a 4,5%. É só
/// atmosfera — some em tela pequena, então nada de conteúdo depende dela.
class Tubo extends StatelessWidget {
  const Tubo({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _Linhas()),
          ),
        ),
      ],
    );
  }
}

class _Linhas extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tinta = Paint()..color = Colors.white.withValues(alpha: 0.045);
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), tinta);
    }
  }

  @override
  bool shouldRepaint(_Linhas anterior) => false;
}
