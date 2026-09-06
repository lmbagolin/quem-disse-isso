import 'package:flutter/material.dart';

import '../../../core/tema.dart';
import '../../../dominio/modelos/roleta.dart';
import '../../../dominio/motor/motor_partida.dart';
import '../../canal.dart';
import '../../estado_app.dart';
import '../../widgets/botao_grande.dart';
import '../../widgets/roleta_widget.dart';
import '../partida_tela.dart';

class FaseRoletas extends StatefulWidget {
  const FaseRoletas({super.key, required this.controlador});

  final ControladorPartida controlador;

  @override
  State<FaseRoletas> createState() => _FaseRoletasState();
}

class _FaseRoletasState extends State<FaseRoletas>
    with TickerProviderStateMixin {
  static const _duracaoTema = Duration(milliseconds: 2600);
  // O modificador para por último: é o resultado que muda a rodada.
  static const _duracaoModificador = Duration(milliseconds: 3400);

  late final _animaTema = AnimationController(
    vsync: this,
    duration: _duracaoTema,
  );
  late final _animaModificador = AnimationController(
    vsync: this,
    duration: _duracaoModificador,
  );

  late Animation<double> _anguloTema = const AlwaysStoppedAnimation(0);
  late Animation<double> _anguloModificador = const AlwaysStoppedAnimation(0);

  double _repousoTema = 0;
  double _repousoModificador = 0;
  bool _girando = false;
  Giro? _resultado;

  List<String> get _temas =>
      widget.controlador.motor.temasDisponiveis.toList()..sort();

  @override
  void dispose() {
    _animaTema.dispose();
    _animaModificador.dispose();
    super.dispose();
  }

  Future<void> _girar() async {
    final motor = widget.controlador.motor;
    final giro = motor.sortearGiro();
    final temas = _temas;
    final indiceTema = giro.tema == null ? 0 : temas.indexOf(giro.tema!);

    final alvoTema = RoletaWidget.alvoDoGiro(
      _repousoTema,
      indiceTema < 0 ? 0 : indiceTema,
      temas.isEmpty ? 1 : temas.length,
      voltas: 4,
    );
    final alvoModificador = RoletaWidget.alvoDoGiro(
      _repousoModificador,
      giro.modificador.setor,
      motor.config.roleta.setores.length,
      voltas: 5,
    );

    setState(() {
      _girando = true;
      _resultado = null;
      _anguloTema = Tween(begin: _repousoTema, end: alvoTema).animate(
        CurvedAnimation(parent: _animaTema, curve: Curves.easeOutQuart),
      );
      _anguloModificador =
          Tween(begin: _repousoModificador, end: alvoModificador).animate(
        CurvedAnimation(parent: _animaModificador, curve: Curves.easeOutQuart),
      );
    });

    await Future.wait([
      _animaTema.forward(from: 0),
      _animaModificador.forward(from: 0),
    ]);
    if (!mounted) return;

    setState(() {
      _repousoTema = alvoTema;
      _repousoModificador = alvoModificador;
      _girando = false;
      _resultado = giro;
    });
  }

  @override
  Widget build(BuildContext context) {
    final motor = widget.controlador.motor;
    final temas = _temas;
    final resultado = _resultado;
    final coringa = resultado?.modificador.efeito == EfeitoModificador.coringa;
    // Com um pacote só não há o que escolher: o coringa não muda o tema.
    final escolheTema = coringa && temas.length > 1;

    // A cor do setor é a do canal, não a da posição na roleta: o jogador
    // reconhece o pacote pela mesma cor que viu no setup.
    final setoresTema = [
      for (final id in temas)
        () {
          final canal = Canal.de(context, id);
          return SetorRoleta(rotulo: canal.nome, cor: canal.cor);
        }(),
    ];
    final setoresModificador = [
      for (final efeito in motor.config.roleta.setores)
        SetorRoleta(rotulo: efeito.rotuloCurto, cor: _corDoEfeito(efeito)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FaixaDaVez(motor: motor),
          Expanded(
            child: LayoutBuilder(
              builder: (context, limites) {
                final lado =
                    ((limites.maxHeight - 40) / 2).clamp(110.0, 180.0);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _LinhaDeRoleta(
                      rotulo: 'Tema',
                      lado: lado,
                      setores: setoresTema.isEmpty
                          ? const [
                              SetorRoleta(
                                rotulo: '—',
                                cor: Cores.superficieAlta,
                              )
                            ]
                          : setoresTema,
                      angulo: _anguloTema,
                      acesa: resultado != null && !escolheTema,
                      resultado: resultado == null
                          ? null
                          : escolheTema
                              ? 'Você escolhe'
                              : setoresTema.isEmpty
                                  ? '—'
                                  : setoresTema[
                                          temas.indexOf(resultado.tema ?? '')
                                              .clamp(0, setoresTema.length - 1)]
                                      .rotulo,
                      detalhe: escolheTema
                          ? 'O coringa passou a escolha para você.'
                          : coringa
                              ? 'Só um pacote na partida: o tema já estava '
                                  'decidido.'
                              : 'De onde vem a frase desta rodada.',
                    ),
                    _LinhaDeRoleta(
                      rotulo: 'Modificador',
                      lado: lado,
                      setores: setoresModificador,
                      angulo: _anguloModificador,
                      acesa: resultado != null,
                      resultado: resultado?.modificador.efeito.titulo,
                      detalhe: resultado?.modificador.efeito.descricao ??
                          'O que muda nesta rodada.',
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          if (resultado == null)
            BotaoGrande(
              rotulo: _girando ? 'Girando...' : 'Girar as roletas',
              icone: Icons.rotate_right_rounded,
              aoTocar: _girando ? null : _girar,
            )
          else
            BotaoGrande(
              rotulo: escolheTema ? 'Escolher o tema' : 'Ver a frase',
              icone: Icons.arrow_forward_rounded,
              aoTocar: () =>
                  widget.controlador.executar((m) => m.aplicarGiro(resultado)),
            ),
        ],
      ),
    );
  }

  Color _corDoEfeito(EfeitoModificador efeito) => switch (efeito) {
        EfeitoModificador.normal => Cores.superficieAlta,
        EfeitoModificador.pontosEmDobro => Cores.destaque,
        EfeitoModificador.rouboLiberado => Cores.erro,
        EfeitoModificador.coringa => Cores.acerto,
      };
}

class _LinhaDeRoleta extends StatelessWidget {
  const _LinhaDeRoleta({
    required this.rotulo,
    required this.lado,
    required this.setores,
    required this.angulo,
    required this.acesa,
    required this.resultado,
    required this.detalhe,
  });

  final String rotulo;
  final double lado;
  final List<SetorRoleta> setores;
  final Animation<double> angulo;
  final bool acesa;
  final String? resultado;
  final String detalhe;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: angulo,
          builder: (context, _) => RoletaWidget(
            setores: setores,
            angulo: angulo.value,
            tamanho: lado,
            acesa: acesa,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rotulo.toUpperCase(),
                style: etiqueta(cor: Cores.textoFraco),
              ),
              const SizedBox(height: 6),
              Text(
                resultado ?? '—',
                style: titulo(20,
                    cor: resultado == null ? Cores.textoFraco : Cores.destaque,
                    altura: 1.15),
              ),
              const SizedBox(height: 6),
              Text(
                detalhe,
                style: corpo(12, cor: Cores.textoFraco, altura: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
