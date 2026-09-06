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
          const Text(
            'Como está o jogo',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            ganhos.isEmpty
                ? 'Ninguém pontuou nesta rodada.'
                : 'Ponto na conta de quem acertou.',
            style: const TextStyle(color: Cores.textoFraco),
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
                    leading: Text(
                      '${i + 1}º',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Cores.textoFraco,
                      ),
                    ),
                    title: Text(
                      jogador.nome,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (ganho > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Cores.acerto.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '+$ganho',
                              style: const TextStyle(
                                color: Cores.acerto,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        Text(
                          '${jogador.pontos}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Cores.destaque,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          BotaoGrande(
            rotulo: 'Próximo jogador',
            icone: Icons.arrow_forward_rounded,
            aoTocar: () => controlador.executar((m) => m.proximaVez()),
          ),
        ],
      ),
    );
  }
}
