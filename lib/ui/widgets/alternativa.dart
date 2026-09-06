import 'package:flutter/material.dart';

import '../../core/tema.dart';

/// Três estados: normal, certa e descartada. A certa é a única coisa verde na
/// tela, então não precisa de mais nenhum reforço além do ✓.
class Alternativa extends StatelessWidget {
  const Alternativa({
    super.key,
    required this.letra,
    required this.texto,
    this.certa = false,
    this.descartada = false,
  });

  final String letra;
  final String texto;
  final bool certa;
  final bool descartada;

  @override
  Widget build(BuildContext context) {
    final fundo = certa
        ? Cores.acerto
        : descartada
            ? Cores.superficie.withValues(alpha: 0.4)
            : Cores.superficie;
    final corLetra = certa
        ? Cores.sobreVerde
        : descartada
            ? Cores.textoFraco
            : Cores.destaque;
    final corTexto = certa
        ? Cores.sobreVerde
        : descartada
            ? Cores.textoApagado
            : Cores.texto;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: descartada ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.circular(Medidas.raioAlternativa),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 15,
              child: Text(letra, style: titulo(13, cor: corLetra)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                texto,
                style: corpo(15, cor: corTexto, peso: certa ? 700 : 500),
              ),
            ),
            // Ícone, não o caractere ✓: a Space Grotesk não tem esse glifo e
            // ele saía como quadrado vazio.
            if (certa)
              const Icon(Icons.check_rounded, size: 20, color: Cores.sobreVerde),
          ],
        ),
      ),
    );
  }
}
