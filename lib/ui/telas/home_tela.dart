import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../estado_app.dart';
import '../widgets/botao_grande.dart';
import 'loja_tela.dart';
import 'meus_pacotes_tela.dart';
import 'regras_tela.dart';
import 'setup_tela.dart';

class HomeTela extends StatelessWidget {
  const HomeTela({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = EscopoApp.de(context);

    if (!estado.pronto) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Cores.destaque)),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Row(children: [const _AoVivo(), const Spacer()]),
              const Spacer(flex: 2),
              Text('?!', style: titulo(30, cor: Cores.ciano)),
              const SizedBox(height: 10),
              Text(
                'QUEM\nDISSE\nISSO?',
                style: titulo(44, altura: 0.98).copyWith(
                  shadows: const [
                    Shadow(
                      color: Cores.magenta,
                      offset: Medidas.deslocamentoSombra,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Você conhece a frase. Só não lembra de quem.',
                style: corpo(15, cor: Cores.textoFraco),
              ),
              const Spacer(flex: 3),
              if (estado.falha != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    'Não deu para carregar os canais: ${estado.falha}',
                    style: corpo(13, cor: Cores.magenta),
                  ),
                ),
              BotaoGrande(
                rotulo: 'Jogar',
                aoTocar: estado.gerenciador.instalados.isEmpty
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SetupTela()),
                        ),
              ),
              const SizedBox(height: 10),
              BotaoSecundario(
                rotulo: 'Meus pacotes',
                aoTocar: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MeusPacotesTela()),
                ),
              ),
              const SizedBox(height: 10),
              BotaoSecundario(
                rotulo: 'Loja',
                aoTocar: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LojaTela()),
                ),
              ),
              const SizedBox(height: 10),
              BotaoContorno(
                rotulo: 'Como se joga',
                aoTocar: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegrasTela()),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _AoVivo extends StatelessWidget {
  const _AoVivo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Cores.magenta,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text('AO VIVO', style: etiqueta(cor: Cores.textoFraco)),
      ],
    );
  }
}
