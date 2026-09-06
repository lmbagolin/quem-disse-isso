import 'package:flutter/material.dart';

import '../../core/tema.dart';

/// Ação principal: amarelo, caixa-alta e a sombra sólida magenta. Uma por
/// tela — duas competindo destroem a hierarquia do sistema.
class BotaoGrande extends StatelessWidget {
  const BotaoGrande({
    super.key,
    required this.rotulo,
    required this.aoTocar,
    this.cor = Cores.destaque,
    this.corTexto = Cores.sobreClaro,
    this.icone,
  });

  final String rotulo;
  final VoidCallback? aoTocar;
  final Color cor;
  final Color corTexto;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    final desligado = aoTocar == null;
    return Padding(
      // A sombra sólida vive fora da caixa: sem esta margem ela é cortada.
      padding: const EdgeInsets.only(right: 5, bottom: 5),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Medidas.raioBotao),
          boxShadow: desligado ? null : Medidas.sombraSolida,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: FilledButton.icon(
            onPressed: aoTocar,
            icon: icone == null ? const SizedBox.shrink() : Icon(icone, size: 20),
            // A cor vai no estilo: texto sobre amarelo é sempre azul-tubo,
            // e o foregroundColor do botão não vence um TextStyle com cor.
            label: Text(
              rotulo.toUpperCase(),
              style: titulo(17, cor: desligado ? Cores.textoFraco : corTexto),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: cor,
              foregroundColor: corTexto,
              disabledBackgroundColor: Cores.superficieAlta,
              disabledForegroundColor: Cores.textoFraco,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Medidas.raioBotao),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ação secundária: superfície cheia, sem sombra e sem caixa-alta.
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
      height: 52,
      child: FilledButton.icon(
        onPressed: aoTocar,
        icon: icone == null ? const SizedBox.shrink() : Icon(icone, size: 19),
        label: Text(rotulo, style: corpo(15, peso: 700)),
        style: FilledButton.styleFrom(
          backgroundColor: Cores.superficie,
          foregroundColor: Cores.texto,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Medidas.raioBotao),
          ),
        ),
      ),
    );
  }
}

/// Contorno: para o que não deve puxar o olho, como sair ou desistir.
class BotaoContorno extends StatelessWidget {
  const BotaoContorno({super.key, required this.rotulo, required this.aoTocar});

  final String rotulo;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: aoTocar,
        style: OutlinedButton.styleFrom(
          foregroundColor: Cores.texto,
          side: BorderSide(color: Cores.texto.withValues(alpha: 0.35), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Medidas.raioBotao),
          ),
        ),
        child: Text(rotulo, style: corpo(15, peso: 700)),
      ),
    );
  }
}

/// O par de julgamento. Magenta é urgência, verde é acerto — nunca invertidos.
class BotoesDeJulgamento extends StatelessWidget {
  const BotoesDeJulgamento({
    super.key,
    required this.aoErrar,
    required this.aoAcertar,
    this.rotuloErro = 'Errou',
    this.rotuloAcerto = 'Acertou',
  });

  final VoidCallback aoErrar;
  final VoidCallback aoAcertar;
  final String rotuloErro;
  final String rotuloAcerto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Julgamento(
            rotulo: rotuloErro,
            fundo: Cores.magenta,
            texto: Cores.sobreClaro,
            aoTocar: aoErrar,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _Julgamento(
            rotulo: rotuloAcerto,
            fundo: Cores.acerto,
            texto: Cores.sobreVerde,
            aoTocar: aoAcertar,
          ),
        ),
      ],
    );
  }
}

class _Julgamento extends StatelessWidget {
  const _Julgamento({
    required this.rotulo,
    required this.fundo,
    required this.texto,
    required this.aoTocar,
  });

  final String rotulo;
  final Color fundo;
  final Color texto;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: FilledButton(
        onPressed: aoTocar,
        style: FilledButton.styleFrom(
          backgroundColor: fundo,
          foregroundColor: texto,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Medidas.raioBotao),
          ),
        ),
        child: Text(rotulo.toUpperCase(), style: titulo(15, cor: texto)),
      ),
    );
  }
}
