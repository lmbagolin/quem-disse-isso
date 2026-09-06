import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../widgets/tubo.dart';
import '../estado_app.dart';

class MeusPacotesTela extends StatelessWidget {
  const MeusPacotesTela({super.key});

  @override
  Widget build(BuildContext context) {
    final pacotes = EscopoApp.de(context).gerenciador.instalados;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Meus pacotes')),
      body: Tubo(child: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          itemCount: pacotes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final pacote = pacotes[i];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pacote.nome,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                        ),
                        _Selo(
                          pacote.gratuito ? 'GRÁTIS' : (pacote.preco ?? 'PAGO'),
                          cor: pacote.gratuito ? Cores.acerto : Cores.destaque,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pacote.descricao,
                      style: const TextStyle(color: Cores.textoFraco),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _Selo(pacote.faixaEtaria, cor: Cores.ciano),
                        const SizedBox(width: 8),
                        _Selo('${pacote.quantidadePerguntas} perguntas',
                            cor: Cores.textoFraco),
                        const SizedBox(width: 8),
                        _Selo('v${pacote.versao}', cor: Cores.textoFraco),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      )),
    );
  }
}

class _Selo extends StatelessWidget {
  const _Selo(this.texto, {required this.cor});

  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: cor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
