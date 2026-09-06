import 'package:flutter/material.dart';

import '../../core/tema.dart';

/// A ideia central da marca: a tela de TV é o balão de fala. Todo conteúdo do
/// jogo aparece aqui dentro, em ciano, com a sombra sólida magenta e o rabicho
/// embaixo à esquerda.
class BalaoDeFala extends StatelessWidget {
  const BalaoDeFala({
    super.key,
    required this.texto,
    this.canal,
    this.cor = Cores.ciano,
    this.corDoTexto = Cores.sobreClaro,
    this.corDoCanal = Cores.sobreCiano,
    this.tamanho = 19,
  });

  final String texto;
  final String? canal;
  final Color cor;
  final Color corDoTexto;
  final Color corDoCanal;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(Medidas.raioBalao),
              boxShadow: Medidas.sombraSolida,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (canal != null) ...[
                  Text(canal!.toUpperCase(), style: etiqueta(cor: corDoCanal)),
                  const SizedBox(height: 6),
                ],
                Text(
                  '“${texto.toUpperCase()}”',
                  style: titulo(tamanho, cor: corDoTexto, altura: 1.22),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 26),
          child: CustomPaint(size: const Size(20, 14), painter: _Rabicho(cor)),
        ),
      ],
    );
  }
}

class _Rabicho extends CustomPainter {
  _Rabicho(this.cor);

  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final caminho = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      caminho.shift(Medidas.deslocamentoSombra),
      Paint()..color = Cores.magenta,
    );
    canvas.drawPath(caminho, Paint()..color = cor);
  }

  @override
  bool shouldRepaint(_Rabicho anterior) => anterior.cor != cor;
}

/// Número do canal em Archivo Black sobre a cor cheia, com as duas antenas.
/// Legível a 48px, que é o tamanho da prateleira da loja.
class SeloDeCanal extends StatelessWidget {
  const SeloDeCanal({
    super.key,
    required this.numero,
    required this.cor,
    this.lado = 44,
  });

  final int numero;
  final Color cor;
  final double lado;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: lado,
      height: lado * 1.18,
      child: Column(
        children: [
          SizedBox(
            height: lado * 0.18,
            child: CustomPaint(
              size: Size(lado * 0.6, lado * 0.18),
              painter: _Antenas(cor),
            ),
          ),
          Expanded(
            child: Container(
              width: lado,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cor,
                borderRadius: BorderRadius.circular(lado * 0.22),
              ),
              child: Text(
                numero.toString().padLeft(2, '0'),
                style: titulo(lado * 0.38, cor: Cores.sobreClaro),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Antenas extends CustomPainter {
  _Antenas(this.cor);

  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final tinta = Paint()
      ..color = cor
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final base = Offset(size.width / 2, size.height);
    canvas.drawLine(base, Offset(size.width * 0.1, 0), tinta);
    canvas.drawLine(base, Offset(size.width * 0.9, 0), tinta);
  }

  @override
  bool shouldRepaint(_Antenas anterior) => anterior.cor != cor;
}

/// Etiqueta curta e cheia — modificador da rodada, faixa etária, preço.
class Selo extends StatelessWidget {
  const Selo(this.texto, {super.key, required this.cor, this.corDoTexto});

  final String texto;
  final Color cor;
  final Color? corDoTexto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        texto.toUpperCase(),
        style: corpo(11, cor: corDoTexto ?? Cores.sobreClaro, peso: 700,
            espacamento: 0.6),
      ),
    );
  }
}


/// A marca: o "?!" dentro do balão, com o rabicho embaixo à esquerda. É o
/// ícone do app reduzido — mesma forma em 48px e na tela inicial.
class SeloDaMarca extends StatelessWidget {
  const SeloDaMarca({super.key, this.largura = 74, this.altura = 60});

  final double largura;
  final double altura;

  static const double _rabicho = 13;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largura + 5,
      height: altura + _rabicho,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: largura,
            height: altura,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Cores.ciano,
              borderRadius: BorderRadius.circular(14),
              boxShadow: Medidas.sombraSolida,
            ),
            child: Text(
              '?!',
              style: titulo(30, cor: Cores.sobreClaro, altura: 1),
            ),
          ),
          Positioned(
            top: altura,
            left: 18,
            child: CustomPaint(
              size: const Size(_rabicho, _rabicho),
              painter: _RabichoSimples(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rabicho sem sombra: no selo da marca a sombra é só do balão.
class _RabichoSimples extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final caminho = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(caminho, Paint()..color = Cores.ciano);
  }

  @override
  bool shouldRepaint(_RabichoSimples anterior) => false;
}

/// Etiqueta "AO VIVO": pílula magenta com o ponto, no alto à direita.
class SeloAoVivo extends StatelessWidget {
  const SeloAoVivo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Cores.magenta,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Cores.sobreClaro,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text('AO VIVO', style: etiqueta(cor: Cores.sobreClaro)),
        ],
      ),
    );
  }
}
