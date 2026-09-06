import 'package:flutter/material.dart';

import '../../../core/tema.dart';
import '../../../dominio/motor/motor_partida.dart';
import '../../canal.dart';
import '../../estado_app.dart';
import '../../widgets/botao_grande.dart';

/// A tela troca de canal inteira: fundo magenta, texto em azul-tubo. É o único
/// momento do jogo em que o app grita — a resposta é o clímax da rodada.
class FaseRevelacao extends StatelessWidget {
  const FaseRevelacao({super.key, required this.controlador});

  final ControladorPartida controlador;

  @override
  Widget build(BuildContext context) {
    final motor = controlador.motor;
    final pergunta = motor.perguntaAtual!;
    final canal = Canal.de(context, pergunta.idPacote);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Center(
              child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ERA ELE O TEMPO TODO',
                    style: corpo(12,
                        cor: Cores.sobreClaro, peso: 700, espacamento: 2.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pergunta.resposta.toUpperCase(),
                    style: titulo(44, altura: 0.98).copyWith(
                      shadows: const [
                        Shadow(
                          color: Cores.sobreClaro,
                          offset: Medidas.deslocamentoSombra,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      color: Cores.fundo,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CANAL ${canal.numero.toString().padLeft(2, '0')}',
                          style: corpo(11,
                              cor: Cores.ciano, peso: 700, espacamento: 1.5),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '“${pergunta.frase}”',
                          style: corpo(14,
                              cor: Cores.textoApagado, altura: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _acoes(motor),
          ),
        ),
      ],
    );
  }

  List<Widget> _acoes(MotorPartida motor) {
    if (motor.fase == FaseRodada.revelacao && motor.rodadaDeRoubo) {
      return [
        Text(
          'QUEM ACERTOU PRIMEIRO?',
          textAlign: TextAlign.center,
          style: titulo(18, cor: Cores.sobreClaro),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final jogador in motor.jogadores)
              _Ficha(
                rotulo: jogador.nome,
                fundo: Cores.fundo,
                texto: Cores.texto,
                aoTocar: () =>
                    controlador.executar((m) => m.registrarAcertoDe(jogador)),
              ),
            _Ficha(
              rotulo: 'Ninguém',
              fundo: Cores.magenta,
              texto: Cores.sobreClaro,
              contorno: true,
              aoTocar: () => controlador.executar((m) => m.ninguemAcertou()),
            ),
          ],
        ),
      ];
    }

    final quem = motor.fase == FaseRodada.revelacaoAjuda
        ? motor.envolvido!.nome
        : motor.jogadorDaVez.nome;
    final acertou = motor.fase == FaseRodada.revelacaoAjuda
        ? () => controlador.executar((m) => m.resolverAjuda(true))
        : () => controlador.executar((m) => m.registrarAcerto());
    final errou = motor.fase == FaseRodada.revelacaoAjuda
        ? () => controlador.executar((m) => m.resolverAjuda(false))
        : () => controlador.executar((m) => m.registrarErro());

    return [
      Text(
        '${quem.toUpperCase()} ACERTOU?',
        textAlign: TextAlign.center,
        style: titulo(18, cor: Cores.sobreClaro),
      ),
      const SizedBox(height: 12),
      BotoesDeJulgamento(
        aoErrar: errou,
        aoAcertar: acertou,
        // Sobre magenta o "errou" não pode ser magenta: vira azul-tubo.
        corErro: Cores.fundo,
        corTextoErro: Cores.texto,
      ),
    ];
  }
}

class _Ficha extends StatelessWidget {
  const _Ficha({
    required this.rotulo,
    required this.fundo,
    required this.texto,
    required this.aoTocar,
    this.contorno = false,
  });

  final String rotulo;
  final Color fundo;
  final Color texto;
  final VoidCallback aoTocar;
  final bool contorno;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.circular(Medidas.raioBotao),
          border: contorno
              ? Border.all(color: Cores.fundo.withValues(alpha: 0.4), width: 2)
              : null,
        ),
        child: Text(rotulo.toUpperCase(), style: titulo(14, cor: texto)),
      ),
    );
  }
}
