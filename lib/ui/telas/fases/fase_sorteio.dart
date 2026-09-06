import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/tema.dart';
import '../../../dominio/modelos/modificadores.dart';
import '../../../dominio/motor/motor_partida.dart';
import '../../canal.dart';
import '../../estado_app.dart';
import '../../widgets/botao_grande.dart';
import '../partida_tela.dart';

/// Zapping: a TV passa pelos canais e para em um. Substituiu as roletas porque
/// funciona igual com 4 ou 40 pacotes — a roleta ficava ilegível com muitos.
class FaseSorteio extends StatefulWidget {
  const FaseSorteio({super.key, required this.controlador});

  final ControladorPartida controlador;

  @override
  State<FaseSorteio> createState() => _FaseSorteioState();
}

class _FaseSorteioState extends State<FaseSorteio> {
  static const int _piscadas = 16;
  static const Duration _pausaAntesDoModificador = Duration(milliseconds: 300);

  Timer? _proximaPiscada;
  bool _zapeando = false;
  Giro? _resultado;

  String? _canalNaTela;
  bool _chuvisco = false;
  bool _modificadorAVista = false;

  @override
  void dispose() {
    _proximaPiscada?.cancel();
    super.dispose();
  }

  /// Intervalo que cresce com o quadrado do passo: a TV desacelera até parar.
  Duration _intervalo(int passo) =>
      Duration(milliseconds: (34 + passo * passo * 2.2).round());

  Future<void> _zapear() async {
    final motor = widget.controlador.motor;
    final giro = motor.prepararSorteio();
    final temas = motor.temasDisponiveis.toList()..sort();
    if (temas.isEmpty) return;

    final sorte = DateTime.now().millisecondsSinceEpoch;
    final sequencia = [
      for (var i = 0; i < _piscadas; i++) temas[(sorte + i * 7) % temas.length],
      giro.tema ?? temas.first,
    ];

    setState(() {
      _zapeando = true;
      _resultado = null;
      _modificadorAVista = false;
    });

    for (var i = 0; i < sequencia.length; i++) {
      if (!mounted) return;
      setState(() {
        _canalNaTela = sequencia[i];
        _chuvisco = i.isOdd && i < sequencia.length - 1;
      });
      await Future<void>.delayed(_intervalo(i + 1));
    }
    if (!mounted) return;
    setState(() => _chuvisco = false);

    await Future<void>.delayed(_pausaAntesDoModificador);
    if (!mounted) return;
    setState(() {
      _resultado = giro;
      _modificadorAVista = true;
      _zapeando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final motor = widget.controlador.motor;
    final resultado = _resultado;
    final coringa = resultado?.modificador.efeito == EfeitoModificador.coringa;
    final escolheCanal = coringa && motor.temasDisponiveis.length > 1;
    final canal = _canalNaTela == null ? null : Canal.de(context, _canalNaTela!);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CartaoDaVez(nome: motor.jogadorDaVez.nome),
          const Spacer(),
          _Televisao(
            canal: canal,
            chuvisco: _chuvisco,
            modificador: _modificadorAVista ? resultado?.modificador.efeito : null,
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 21),
            child: Text(
              _legenda(canal, resultado, escolheCanal),
              textAlign: TextAlign.center,
              style: corpo(14, cor: Cores.textoFraco),
            ),
          ),
          const Spacer(),
          if (resultado == null)
            BotaoGrande(
              rotulo: _zapeando ? 'Procurando...' : 'Trocar de canal',
              aoTocar: _zapeando ? null : _zapear,
            )
          else
            BotaoGrande(
              rotulo: escolheCanal ? 'Escolher o canal' : 'Ver a frase',
              aoTocar: () =>
                  widget.controlador.executar((m) => m.aplicarSorteio(resultado)),
            ),
        ],
      ),
    );
  }

  String _legenda(Canal? canal, Giro? resultado, bool escolheCanal) {
    if (_zapeando) return 'Procurando sinal…';
    if (resultado == null) {
      return 'Troque de canal para ver de onde vem a frase.';
    }
    if (escolheCanal) return 'Coringa: o canal é escolha sua.';
    final numero = canal?.numero.toString().padLeft(2, '0') ?? '--';
    return 'Canal $numero no ar · ${resultado.modificador.efeito.titulo}.';
  }
}

class _CartaoDaVez extends StatelessWidget {
  const _CartaoDaVez({required this.nome});

  final String nome;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Cores.superficie,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Cores.destaque,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VEZ DE', style: etiqueta(cor: Cores.textoFraco)),
                Text(
                  nome.toUpperCase(),
                  style: titulo(24, altura: 1.1),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A TV: número e nome do canal grandes, chuvisco durante a troca e a faixa do
/// modificador subindo por baixo quando o sinal fixa.
class _Televisao extends StatelessWidget {
  const _Televisao({
    required this.canal,
    required this.chuvisco,
    required this.modificador,
  });

  final Canal? canal;
  final bool chuvisco;
  final EfeitoModificador? modificador;

  @override
  Widget build(BuildContext context) {
    final semSinal = canal == null;
    return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Cores.magenta, offset: Offset(6, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                height: 296,
                width: double.infinity,
                color: semSinal ? Cores.superficie : canal!.cor,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      semSinal
                          ? '--'
                          : canal!.numero.toString().padLeft(2, '0'),
                      style: titulo(82, cor: Cores.sobreClaro, altura: 0.9),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      semSinal ? 'SEM SINAL' : canal!.nome.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: titulo(19, cor: Cores.sobreClaro, altura: 1.15),
                    ),
                  ],
                ),
              ),
              if (chuvisco)
                Positioned.fill(
                  child: CustomPaint(painter: _Chuvisco()),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedSlide(
                  offset: modificador == null ? const Offset(0, 1.2) : Offset.zero,
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutBack,
                  child: Container(
                    color: modificador == null
                        ? Cores.textoApagado
                        : corDoModificador(modificador!),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('MODIFICADOR',
                            style: etiqueta(cor: Cores.sobreClaro)),
                        const SizedBox(width: 10),
                        Text(
                          (modificador ?? EfeitoModificador.normal)
                              .rotuloCurto
                              .toUpperCase(),
                          style: titulo(22, cor: Cores.sobreClaro, altura: 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}

class _Chuvisco extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final claro = Paint()..color = Colors.white.withValues(alpha: 0.55);
    final escuro = Paint()..color = Cores.fundo.withValues(alpha: 0.55);
    for (var y = 0.0; y < size.height; y += 5) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 2), claro);
      canvas.drawRect(Rect.fromLTWH(0, y + 2, size.width, 3), escuro);
    }
  }

  @override
  bool shouldRepaint(_Chuvisco anterior) => false;
}
