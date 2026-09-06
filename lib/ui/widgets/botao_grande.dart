import 'package:flutter/material.dart';

import '../../core/tema.dart';

class BotaoGrande extends StatelessWidget {
  const BotaoGrande({
    super.key,
    required this.rotulo,
    required this.aoTocar,
    this.cor = Cores.destaque,
    this.corTexto = Cores.fundo,
    this.icone,
  });

  final String rotulo;
  final VoidCallback? aoTocar;
  final Color cor;
  final Color corTexto;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: FilledButton.icon(
        onPressed: aoTocar,
        icon: icone == null ? const SizedBox.shrink() : Icon(icone),
        label: Text(
          rotulo,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: corTexto,
          disabledBackgroundColor: Cores.superficieAlta,
          disabledForegroundColor: Cores.textoFraco,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class BotaoSecundario extends StatelessWidget {
  const BotaoSecundario({
    super.key,
    required this.rotulo,
    required this.aoTocar,
    this.icone,
  });

  final String rotulo;
  final VoidCallback? aoTocar;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: aoTocar,
        icon: icone == null ? const SizedBox.shrink() : Icon(icone),
        label: Text(rotulo, style: const TextStyle(fontSize: 16)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Cores.texto,
          side: const BorderSide(color: Cores.superficieAlta, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
