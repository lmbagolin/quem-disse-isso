import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/tema.dart';

class SetorRoleta {
  const SetorRoleta({required this.rotulo, required this.cor});

  final String rotulo;
  final Color cor;
}

/// Roleta com ponteiro fixo no topo. O setor de índice 0 nasce centrado sob o
/// ponteiro, então parar no índice i é girar -i * setor.
class RoletaWidget extends StatelessWidget {
  const RoletaWidget({
    super.key,
    required this.setores,
    required this.angulo,
    required this.tamanho,
    this.acesa = false,
  });

  final List<SetorRoleta> setores;
  final double angulo;
  final double tamanho;

  /// Realça a roleta quando ela é a que decidiu a rodada.
  final bool acesa;

  /// Ângulo de repouso que deixa [indice] sob o ponteiro.
  static double anguloDeRepouso(int indice, int total) =>
      -indice * (2 * pi / total);

  /// Direção, em radianos, do centro do setor [indice] com a roleta parada.
  static double direcaoDoSetor(int indice, int total) =>
      -pi / 2 + indice * (2 * pi / total);

  /// Quanto girar o canvas para escrever o rótulo apontando para fora no
  /// setor cuja direção é [anguloDoCentro]. O texto é desenhado para cima, em
  /// -pi/2, então a rotação precisa levar -pi/2 até [anguloDoCentro].
  static double rotacaoDoRotulo(double anguloDoCentro) =>
      anguloDoCentro + pi / 2;

  /// Menor ângulo acima de [atual] + [voltas] que para em [indice].
  static double alvoDoGiro(
    double atual,
    int indice,
    int total, {
    required int voltas,
  }) {
    var alvo = anguloDeRepouso(indice, total);
    final minimo = atual + voltas * 2 * pi;
    while (alvo < minimo) {
      alvo += 2 * pi;
    }
    return alvo;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: tamanho,
            height: tamanho,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: acesa
                      ? Cores.destaque.withValues(alpha: 0.35)
                      : const Color(0x66000000),
                  blurRadius: acesa ? 28 : 16,
                  spreadRadius: acesa ? 2 : 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
          Transform.rotate(
            angle: angulo,
            child: CustomPaint(
              size: Size.square(tamanho),
              painter: _PinturaRoleta(setores),
            ),
          ),
          Container(
            width: tamanho * 0.2,
            height: tamanho * 0.2,
            decoration: BoxDecoration(
              color: Cores.superficieAlta,
              shape: BoxShape.circle,
              border: Border.all(color: Cores.fundo, width: 3),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: Offset(0, -tamanho * 0.03),
              child: CustomPaint(
                size: Size(tamanho * 0.13, tamanho * 0.13),
                painter: _PinturaPonteiro(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinturaRoleta extends CustomPainter {
  _PinturaRoleta(this.setores);

  final List<SetorRoleta> setores;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final raio = size.width / 2 - 3;
    final fatia = 2 * pi / setores.length;
    // Setor 0 nasce centrado no topo, por isso o meio-passo para trás.
    final inicio = RoletaWidget.direcaoDoSetor(0, setores.length) - fatia / 2;

    for (var i = 0; i < setores.length; i++) {
      final pintura = Paint()
        ..color = setores[i].cor
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: centro, radius: raio),
        inicio + i * fatia,
        fatia,
        true,
        pintura,
      );
      if (setores.length > 1) {
        canvas.drawArc(
          Rect.fromCircle(center: centro, radius: raio),
          inicio + i * fatia,
          fatia,
          true,
          Paint()
            ..color = Cores.fundo
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
      _desenharRotulo(
        canvas,
        centro,
        raio,
        RoletaWidget.direcaoDoSetor(i, setores.length),
        setores[i],
      );
    }

    canvas.drawCircle(
      centro,
      raio,
      Paint()
        ..color = Cores.fundo
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  void _desenharRotulo(
    Canvas canvas,
    Offset centro,
    double raio,
    double anguloDoCentro,
    SetorRoleta setor,
  ) {
    final texto = TextPainter(
      text: TextSpan(
        text: setor.rotulo,
        style: TextStyle(
          color: _corDoTexto(setor.cor),
          fontSize: raio * 0.13,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: raio * 0.78);

    canvas.save();
    canvas.translate(centro.dx, centro.dy);
    // Gira o canvas até o setor apontar para cima e escreve na vertical.
    canvas.rotate(RoletaWidget.rotacaoDoRotulo(anguloDoCentro));
    texto.paint(
      canvas,
      Offset(-texto.width / 2, -raio * 0.82),
    );
    canvas.restore();
  }

  /// Texto escuro sobre setor claro, claro sobre escuro.
  Color _corDoTexto(Color fundo) =>
      fundo.computeLuminance() > 0.45 ? Cores.fundo : Colors.white;

  @override
  bool shouldRepaint(_PinturaRoleta anterior) =>
      anterior.setores != setores;
}

class _PinturaPonteiro extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final caminho = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(
      caminho,
      Paint()..color = Cores.fundo..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      caminho.shift(const Offset(0, -2)),
      Paint()..color = Cores.destaque..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_PinturaPonteiro anterior) => false;
}

/// Paleta dos setores de tema: estável por posição, para o mesmo pacote manter
/// a cor durante a partida inteira.
const List<Color> coresDeTema = [
  Color(0xFF8B6BFF),
  Color(0xFF3DD68C),
  Color(0xFFFF8FB1),
  Color(0xFF4FC3F7),
  Color(0xFFFFC24B),
  Color(0xFFFF8A65),
  Color(0xFFB388FF),
  Color(0xFF80CBC4),
];
