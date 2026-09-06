import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../widgets/tubo.dart';
import '../estado_app.dart';
import '../widgets/balao.dart';
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
      body: Tubo(child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: SeloAoVivo(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SeloDaMarca(),
                    const SizedBox(height: 18),
                    Text(
                      'QUEM\nDISSE\nISSO?',
                      style: titulo(44, altura: 0.96).copyWith(
                        shadows: const [
                          Shadow(
                            color: Cores.magenta,
                            offset: Medidas.deslocamentoSombra,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 250),
                      child: Text(
                        'Você conhece a frase. Só não lembra de quem.',
                        style: corpo(15, cor: Cores.textoFraco, altura: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (estado.falha != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Não deu para carregar os canais: ${estado.falha}',
                        style: corpo(13, cor: Cores.magenta),
                      ),
                    ),
                  BotaoGrande(
                    rotulo: 'Jogar',
                    tamanho: 20,
                    aoTocar: estado.gerenciador.instalados.isEmpty
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const SetupTela()),
                            ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: BotaoSecundario(
                          rotulo: 'Meus pacotes',
                          aoTocar: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const MeusPacotesTela()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: BotaoSecundario(
                          rotulo: 'Loja',
                          aoTocar: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LojaTela()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  BotaoTexto(
                    rotulo: 'Como se joga',
                    aoTocar: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegrasTela()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
