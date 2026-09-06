import 'package:flutter/material.dart';

import '../../../core/tema.dart';
import '../../../dominio/modelos/carta_especial.dart';
import '../../../dominio/motor/motor_partida.dart';
import '../../estado_app.dart';
import '../../widgets/botao_grande.dart';

class FaseCarta extends StatelessWidget {
  const FaseCarta({super.key, required this.controlador});

  final ControladorPartida controlador;

  @override
  Widget build(BuildContext context) {
    final motor = controlador.motor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: motor.fase == FaseRodada.cartaEspecial
          ? _CartaSorteada(controlador: controlador)
          : _EscolhaDeJogador(controlador: controlador),
    );
  }
}

class _CartaSorteada extends StatelessWidget {
  const _CartaSorteada({required this.controlador});

  final ControladorPartida controlador;

  @override
  Widget build(BuildContext context) {
    final motor = controlador.motor;
    final carta = motor.cartaAtual!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${motor.jogadorDaVez.nome} errou.',
          style: const TextStyle(fontSize: 18, color: Cores.textoFraco),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Cores.roxo, Cores.superficieAlta],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Icon(_icone(carta), size: 56, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'CARTA ${carta.titulo.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                carta.descricao,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
            ],
          ),
        ),
        const Spacer(),
        BotaoGrande(
          rotulo: 'Aplicar carta',
          icone: Icons.bolt_rounded,
          aoTocar: () => controlador.executar((m) => m.aplicarCarta()),
        ),
      ],
    );
  }

  IconData _icone(CartaEspecial carta) => switch (carta) {
        CartaEspecial.ajuda => Icons.volunteer_activism_outlined,
        CartaEspecial.dica => Icons.lightbulb_outline,
        CartaEspecial.pulo => Icons.skip_next_outlined,
      };
}

class _EscolhaDeJogador extends StatelessWidget {
  const _EscolhaDeJogador({required this.controlador});

  final ControladorPartida controlador;

  @override
  Widget build(BuildContext context) {
    final motor = controlador.motor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Carta Ajuda',
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w800,
            color: Cores.roxo,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${motor.jogadorDaVez.nome}, quem vai te ajudar?',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            itemCount: motor.outrosJogadores.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final jogador = motor.outrosJogadores[i];
              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Cores.superficieAlta,
                    child: Text(jogador.nome.characters.first.toUpperCase()),
                  ),
                  title: Text(
                    jogador.nome,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  trailing: Text(
                    '${jogador.pontos} pts',
                    style: const TextStyle(color: Cores.textoFraco),
                  ),
                  onTap: () =>
                      controlador.executar((m) => m.escolherAjudante(jogador)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
