import 'package:flutter/material.dart';

import '../../../core/tema.dart';
import '../../estado_app.dart';
import '../../widgets/botao_grande.dart';
import '../partida_tela.dart';

class FaseFim extends StatelessWidget {
  const FaseFim({super.key, required this.controlador});

  final ControladorPartida controlador;

  @override
  Widget build(BuildContext context) {
    final motor = controlador.motor;
    final vencedores = motor.vencedores;
    final empate = vencedores.length > 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          const Icon(Icons.emoji_events_rounded,
              size: 72, color: Cores.destaque),
          const SizedBox(height: 12),
          Text(
            empate ? 'Empate!' : 'Vitória de ${vencedores.first.nome}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          if (empate) ...[
            const SizedBox(height: 6),
            Text(
              vencedores.map((j) => j.nome).join(' e '),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Cores.textoFraco, fontSize: 16),
            ),
          ],
          if (!motor.temPerguntas) ...[
            const SizedBox(height: 10),
            const Text(
              'As perguntas dos pacotes ativos acabaram.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Cores.textoFraco, fontSize: 14),
            ),
          ],
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: motor.ranking.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final jogador = motor.ranking[i];
                return Card(
                  child: ListTile(
                    leading: Text(
                      '${i + 1}º',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Cores.textoFraco,
                      ),
                    ),
                    title: Text(jogador.nome),
                    trailing: Text(
                      '${jogador.pontos} pts',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Cores.destaque,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          BotaoGrande(
            rotulo: 'Revanche',
            icone: Icons.replay_rounded,
            aoTocar: () {
              final estado = EscopoApp.de(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => PartidaTela(
                    controlador: estado.criarPartida(motor.config),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          BotaoSecundario(
            rotulo: 'Voltar ao início',
            aoTocar: () =>
                Navigator.of(context).popUntil((rota) => rota.isFirst),
          ),
        ],
      ),
    );
  }
}
