import 'package:flutter/material.dart';

import '../../../core/tema.dart';
import '../../../dominio/motor/motor_partida.dart';
import '../../canal.dart';
import '../../estado_app.dart';
import '../../widgets/alternativa.dart';
import '../../widgets/balao.dart';
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
    final canal = Canal.de(context, pergunta.idPacote);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!revelando)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Cronometro(
                // A chave reinicia a contagem a cada frase nova.
                key: ValueKey('${pergunta.idGlobal}-${motor.dicaRevelada}'),
                segundos: motor.config.segundosParaResponder,
              ),
            ),
          FaixaDaVez(motor: motor),
          const SizedBox(height: 14),
          if (revelando) ...[
            Text('Era ele o tempo todo', style: corpo(13, cor: Cores.textoFraco)),
            const SizedBox(height: 4),
            Text(
              pergunta.resposta.toUpperCase(),
              style: titulo(26, cor: canal.cor, altura: 1.1),
            ),
            const SizedBox(height: 14),
          ],
          BalaoDeFala(
            texto: pergunta.frase,
            canal: canal.rotulo,
            tamanho: motor.alternativas.isEmpty ? 21 : 19,
          ),
          if (motor.dicaRevelada && pergunta.dica != null) ...[
            const SizedBox(height: 12),
            Selo('Dica: ${pergunta.dica}', cor: Cores.superficie,
                corDoTexto: Cores.texto),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < motor.alternativas.length; i++)
                    Alternativa(
                      letra: String.fromCharCode(65 + i),
                      texto: motor.alternativas[i],
                      certa: revelando &&
                          motor.alternativas[i] == pergunta.resposta,
                      descartada: revelando &&
                          motor.alternativas[i] != pergunta.resposta,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
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
      Text(
        'QUEM ACERTOU PRIMEIRO?',
        textAlign: TextAlign.center,
        style: etiqueta(cor: Cores.textoFraco),
      ),
      const SizedBox(height: 10),
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
                foregroundColor: Cores.sobreVerde,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Medidas.raioBotao),
                ),
              ),
              child: Text(
                jogador.nome.toUpperCase(),
                style: titulo(14, cor: Cores.sobreVerde),
              ),
            ),
          OutlinedButton(
            onPressed: () => controlador.executar((m) => m.ninguemAcertou()),
            style: OutlinedButton.styleFrom(
              foregroundColor: Cores.textoFraco,
              side: BorderSide(
                color: Cores.texto.withValues(alpha: 0.35),
                width: 2,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Medidas.raioBotao),
              ),
            ),
            child: Text('Ninguém', style: corpo(14, peso: 700)),
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
        '${quem.toUpperCase()} ACERTOU?',
        textAlign: TextAlign.center,
        style: etiqueta(cor: Cores.textoFraco),
      ),
      const SizedBox(height: 10),
      BotoesDeJulgamento(aoErrar: aoErrar, aoAcertar: aoAcertar),
    ];
  }
}
