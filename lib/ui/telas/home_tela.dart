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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              const Text(
                'QUEM\nDISSE\nISSO?',
                style: TextStyle(
                  fontSize: 56,
                  height: 0.95,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                  color: Cores.destaque,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Você conhece a frase. Só não lembra de quem.',
                style: TextStyle(fontSize: 16, color: Cores.textoFraco),
              ),
              const Spacer(flex: 3),
              if (estado.falha != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Não deu para carregar os pacotes: ${estado.falha}',
                    style: const TextStyle(color: Cores.erro),
                  ),
                ),
              BotaoGrande(
                rotulo: 'Jogar',
                icone: Icons.play_arrow_rounded,
                aoTocar: estado.gerenciador.instalados.isEmpty
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SetupTela()),
                        ),
              ),
              const SizedBox(height: 12),
              BotaoSecundario(
                rotulo: 'Meus pacotes',
                icone: Icons.inventory_2_outlined,
                aoTocar: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MeusPacotesTela()),
                ),
              ),
              const SizedBox(height: 12),
              BotaoSecundario(
                rotulo: 'Loja de pacotes',
                icone: Icons.storefront_outlined,
                aoTocar: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LojaTela()),
                ),
              ),
              const SizedBox(height: 12),
              BotaoSecundario(
                rotulo: 'Como se joga',
                icone: Icons.menu_book_outlined,
                aoTocar: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegrasTela()),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
