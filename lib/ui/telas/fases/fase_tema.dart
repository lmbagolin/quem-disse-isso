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
          const Text(
            'Coringa! Escolha o tema da sua pergunta.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
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
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    subtitle: pacote == null
                        ? null
                        : Text(
                            pacote.descricao,
                            style: const TextStyle(color: Cores.textoFraco),
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
