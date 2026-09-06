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
    this.tamanho = 18,
  });

  final String rotulo;
  final VoidCallback? aoTocar;
  final Color cor;
  final Color corTexto;
  final IconData? icone;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return _ComSombraSolida(
      aoTocar: aoTocar,
      child: (pressionado) => Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 56),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: aoTocar == null ? Cores.superficieAlta : cor,
          borderRadius: BorderRadius.circular(Medidas.raioBotao),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icone != null) ...[
              Icon(icone, size: 20, color: corTexto),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                rotulo.toUpperCase(),
                textAlign: TextAlign.center,
                // A cor vai no estilo: texto sobre amarelo é sempre azul-tubo,
                // e a cor do botão não vence um TextStyle com cor.
                style: titulo(
                  tamanho,
                  cor: aoTocar == null ? Cores.textoFraco : corTexto,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sombra sólida com o afundar do desenho: ao pressionar, o conteúdo desce
/// 3px e a sombra encolhe para 2px, como se o botão entrasse nela.
class _ComSombraSolida extends StatefulWidget {
  const _ComSombraSolida({required this.aoTocar, required this.child});

  final VoidCallback? aoTocar;
  final Widget Function(bool pressionado) child;

  @override
  State<_ComSombraSolida> createState() => _ComSombraSolidaState();
}

class _ComSombraSolidaState extends State<_ComSombraSolida> {
  bool _pressionado = false;

  @override
  Widget build(BuildContext context) {
    final ligado = widget.aoTocar != null;
    final afundado = ligado && _pressionado;
    return GestureDetector(
      onTap: widget.aoTocar,
      onTapDown: ligado ? (_) => setState(() => _pressionado = true) : null,
      onTapUp: ligado ? (_) => setState(() => _pressionado = false) : null,
      onTapCancel: ligado ? () => setState(() => _pressionado = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        transform: Matrix4.translationValues(
          afundado ? 3 : 0,
          afundado ? 3 : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Medidas.raioBotao),
          boxShadow: ligado
              ? [
                  BoxShadow(
                    color: Cores.magenta,
                    offset: afundado ? const Offset(2, 2) : Medidas.deslocamentoSombra,
                  ),
                ]
              : null,
        ),
        child: widget.child(afundado),
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
      child: FilledButton.icon(
        onPressed: aoTocar,
        icon: icone == null ? const SizedBox.shrink() : Icon(icone, size: 19),
        label: Text(rotulo, style: corpo(14, peso: 700)),
        style: FilledButton.styleFrom(
          backgroundColor: Cores.superficie,
          foregroundColor: Cores.texto,
          padding: const EdgeInsets.symmetric(vertical: 13),
          minimumSize: const Size(0, 44),
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


/// Texto puro: a ação que não deve puxar o olho.
class BotaoTexto extends StatelessWidget {
  const BotaoTexto({super.key, required this.rotulo, required this.aoTocar});

  final String rotulo;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: aoTocar,
      style: TextButton.styleFrom(
        foregroundColor: Cores.textoFraco,
        minimumSize: const Size(0, 44),
      ),
      child: Text(rotulo, style: corpo(14, cor: Cores.textoFraco, peso: 700)),
    );
  }
}
