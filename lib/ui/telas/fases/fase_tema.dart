import 'package:flutter/material.dart';

import '../../../core/tema.dart';
import '../../estado_app.dart';
import '../partida_tela.dart';

class FaseTema extends StatelessWidget {
  const FaseTema({super.key, required this.controlador});

  final ControladorPartida controlador;

  @override
  Widget build(BuildContext context) {
    final motor = controlador.motor;
    final gerenciador = EscopoApp.de(context).gerenciador;
    final temas = motor.temasDisponiveis.toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FaixaDaVez(motor: motor),
          const SizedBox(height: 24),
          Text(
            'Coringa! Escolha o tema da sua pergunta.',
            style: titulo(22),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: temas.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final pacote = gerenciador.porId(temas[i]);
                return Card(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    title: Text(
                      pacote?.nome ?? temas[i],
                      style: titulo(16),
                    ),
                    subtitle: pacote == null
                        ? null
                        : Text(
                            pacote.descricao,
                            style: corpo(13, cor: Cores.textoFraco),
                          ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => controlador
                        .executar((m) => m.escolherTema(temas[i])),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
