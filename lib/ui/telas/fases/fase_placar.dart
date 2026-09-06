import 'package:flutter/material.dart';

import '../../../core/tema.dart';
import '../../estado_app.dart';
import '../../widgets/botao_grande.dart';

class FasePlacar extends StatelessWidget {
  const FasePlacar({super.key, required this.controlador});

  final ControladorPartida controlador;

  @override
  Widget build(BuildContext context) {
    final motor = controlador.motor;
    final ganhos = motor.ganhosDaRodada;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('COMO ESTÁ O JOGO', style: titulo(26)),
          const SizedBox(height: 6),
          Text(
            ganhos.isEmpty
                ? 'Ninguém pontuou nesta rodada.'
                : 'Ponto na conta de quem acertou.',
            style: corpo(14, cor: Cores.textoFraco),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: motor.ranking.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final jogador = motor.ranking[i];
                final ganho = ganhos[jogador.id] ?? 0;
                return Card(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Text('${i + 1}º',
                        style: titulo(15, cor: Cores.textoFraco)),
                    title: Text(jogador.nome.toUpperCase(), style: titulo(17)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (ganho > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Cores.acerto,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text('+$ganho',
                                style: titulo(13, cor: Cores.sobreVerde)),
                          ),
                        Text('${jogador.pontos}',
                            style: titulo(22, cor: Cores.destaque)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Agora é a vez de ${motor.proximoJogador.nome}',
            textAlign: TextAlign.center,
            style: corpo(14, cor: Cores.textoFraco),
          ),
          const SizedBox(height: 10),
          BotaoGrande(
            rotulo: 'Próxima rodada',
            aoTocar: () => controlador.executar((m) => m.proximaVez()),
          ),
        ],
      ),
    );
  }
}
