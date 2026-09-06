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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text('FIM DE JOGO', style: etiqueta(cor: Cores.textoFraco)),
          const SizedBox(height: 10),
          Text('!!', style: titulo(30, cor: Cores.magenta)),
          const SizedBox(height: 6),
          Text(
            empate
                ? 'EMPATE!'
                : '${vencedores.first.nome.toUpperCase()} VENCEU',
            style: titulo(44, altura: 0.98).copyWith(
              shadows: const [
                Shadow(color: Cores.magenta, offset: Medidas.deslocamentoSombra),
              ],
            ),
          ),
          if (empate) ...[
            const SizedBox(height: 6),
            Text(
              vencedores.map((j) => j.nome).join(' e '),
              style: corpo(15, cor: Cores.textoFraco),
            ),
          ],
          if (!motor.temPerguntas) ...[
            const SizedBox(height: 10),
            Text(
              'As frases dos canais no ar acabaram.',
              style: corpo(14, cor: Cores.textoFraco),
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
                    leading: Text('${i + 1}º',
                        style: titulo(15, cor: Cores.textoFraco)),
                    title: Text(jogador.nome.toUpperCase(), style: titulo(16)),
                    trailing: Text('${jogador.pontos}',
                        style: titulo(20, cor: Cores.destaque)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          BotaoGrande(
            rotulo: 'Revanche',
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
          BotaoContorno(
            rotulo: 'Voltar ao início',
            aoTocar: () =>
                Navigator.of(context).popUntil((rota) => rota.isFirst),
          ),
        ],
      ),
    );
  }
}
