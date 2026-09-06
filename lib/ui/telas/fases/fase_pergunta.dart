import 'package:flutter/material.dart';

import '../../../core/tema.dart';
import '../../../dominio/motor/motor_partida.dart';
import '../../estado_app.dart';
import '../../widgets/botao_grande.dart';
import '../../widgets/cronometro.dart';
import '../partida_tela.dart';

class FasePergunta extends StatelessWidget {
  const FasePergunta({super.key, required this.controlador});

  final ControladorPartida controlador;

  @override
  Widget build(BuildContext context) {
    final motor = controlador.motor;
    final pergunta = motor.perguntaAtual!;
    final revelando = motor.fase != FaseRodada.pergunta;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: FaixaDaVez(motor: motor)),
              if (!revelando)
                Cronometro(
                  // A chave reinicia a contagem a cada frase nova.
                  key: ValueKey('${pergunta.idGlobal}-${motor.dicaRevelada}'),
                  segundos: motor.config.segundosParaResponder,
                ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      pergunta.nomePacote.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w800,
                        color: Cores.textoFraco,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '“${pergunta.frase}”',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: motor.alternativas.isEmpty ? 28 : 22,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (motor.alternativas.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      for (var i = 0; i < motor.alternativas.length; i++)
                        _Alternativa(
                          letra: String.fromCharCode(65 + i),
                          texto: motor.alternativas[i],
                          certa: revelando &&
                              motor.alternativas[i] == pergunta.resposta,
                          apagada: revelando &&
                              motor.alternativas[i] != pergunta.resposta,
                        ),
                    ],
                    if (motor.dicaRevelada && pergunta.dica != null) ...[
                      const SizedBox(height: 20),
                      _Etiqueta('Dica: ${pergunta.dica}', cor: Cores.roxo),
                    ],
                    if (revelando && motor.alternativas.isEmpty) ...[
                      const SizedBox(height: 28),
                      const Divider(color: Cores.superficieAlta),
                      const SizedBox(height: 20),
                      const Text(
                        'A RESPOSTA É',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w800,
                          color: Cores.textoFraco,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        pergunta.resposta,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Cores.destaque,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._acoes(motor),
        ],
      ),
    );
  }

  List<Widget> _acoes(MotorPartida motor) {
    switch (motor.fase) {
      case FaseRodada.pergunta:
        return [
          BotaoGrande(
            rotulo: 'Revelar resposta',
            icone: Icons.visibility_outlined,
            aoTocar: () => controlador.executar((m) => m.revelarResposta()),
          ),
        ];
      case FaseRodada.revelacao:
        if (motor.rodadaDeRoubo) return _quemAcertou(motor);
        return _julgamento(
          quem: motor.jogadorDaVez.nome,
          aoAcertar: () => controlador.executar((m) => m.registrarAcerto()),
          aoErrar: () => controlador.executar((m) => m.registrarErro()),
        );
      case FaseRodada.revelacaoAjuda:
        return _julgamento(
          quem: motor.envolvido!.nome,
          aoAcertar: () => controlador.executar((m) => m.resolverAjuda(true)),
          aoErrar: () => controlador.executar((m) => m.resolverAjuda(false)),
        );
      default:
        return const [];
    }
  }

  /// Rodada de roubo: todos concorrem, então a mesa aponta quem chegou antes.
  List<Widget> _quemAcertou(MotorPartida motor) {
    return [
      const Text(
        'Quem acertou primeiro?',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Cores.textoFraco),
      ),
      const SizedBox(height: 12),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final jogador in motor.jogadores)
            FilledButton(
              onPressed: () =>
                  controlador.executar((m) => m.registrarAcertoDe(jogador)),
              style: FilledButton.styleFrom(
                backgroundColor: Cores.acerto,
                foregroundColor: Cores.fundo,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                jogador.nome,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          OutlinedButton(
            onPressed: () => controlador.executar((m) => m.ninguemAcertou()),
            style: OutlinedButton.styleFrom(
              foregroundColor: Cores.textoFraco,
              side: const BorderSide(color: Cores.superficieAlta, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Ninguém'),
          ),
        ],
      ),
    ];
  }

  List<Widget> _julgamento({
    required String quem,
    required VoidCallback aoAcertar,
    required VoidCallback aoErrar,
  }) {
    return [
      Text(
        '$quem acertou?',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, color: Cores.textoFraco),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: BotaoGrande(
              rotulo: 'Errou',
              cor: Cores.erro,
              corTexto: Colors.white,
              aoTocar: aoErrar,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: BotaoGrande(
              rotulo: 'Acertou',
              cor: Cores.acerto,
              aoTocar: aoAcertar,
            ),
          ),
        ],
      ),
    ];
  }
}

class _Alternativa extends StatelessWidget {
  const _Alternativa({
    required this.letra,
    required this.texto,
    required this.certa,
    required this.apagada,
  });

  final String letra;
  final String texto;
  final bool certa;
  final bool apagada;

  @override
  Widget build(BuildContext context) {
    final cor = certa ? Cores.acerto : Cores.texto;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: apagada ? 0.35 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: certa
              ? Cores.acerto.withValues(alpha: 0.16)
              : Cores.superficie,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: certa ? Cores.acerto : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                letra,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: certa ? Cores.acerto : Cores.textoFraco,
                ),
              ),
            ),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.25,
                  fontWeight: certa ? FontWeight.w800 : FontWeight.w500,
                  color: cor,
                ),
              ),
            ),
            if (certa)
              const Icon(Icons.check_circle, color: Cores.acerto, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto, {required this.cor});

  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(texto, style: TextStyle(color: cor, fontSize: 15)),
    );
  }
}
