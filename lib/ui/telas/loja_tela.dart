import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../widgets/tubo.dart';
import '../../loja/catalogo_loja.dart';

class LojaTela extends StatelessWidget {
  const LojaTela({super.key, this.catalogo = const LojaIndisponivel()});

  final CatalogoLoja catalogo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Loja de pacotes')),
      body: Tubo(child: SafeArea(
        child: FutureBuilder<List<ItemLoja>>(
          future: catalogo.listarDisponiveis(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: Cores.destaque),
              );
            }
            final itens = snapshot.data ?? const <ItemLoja>[];
            if (itens.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.storefront_outlined,
                          size: 64, color: Cores.textoFraco),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum pacote à venda ainda.',
                        style: titulo(18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Novos temas aparecem aqui assim que a loja for ligada.',
                        textAlign: TextAlign.center,
                        style: corpo(14, cor: Cores.textoFraco),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: itens.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => Card(
                child: ListTile(
                  title: Text(itens[i].nome),
                  subtitle: Text(itens[i].descricao),
                  trailing: Text(itens[i].preco),
                ),
              ),
            );
          },
        ),
      )),
    );
  }
}
