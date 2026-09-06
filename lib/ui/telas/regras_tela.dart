import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../widgets/tubo.dart';
import '../../dominio/modelos/config_partida.dart';
import '../../dominio/modelos/modificadores.dart';

class RegrasTela extends StatelessWidget {
  const RegrasTela({super.key});

  @override
  Widget build(BuildContext context) {
    const tabela = Modificadores.padrao;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Como se joga')),
      body: Tubo(child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            const _Titulo('A rodada'),
            const _Passo(1, 'O jogador da vez troca de canal.'),
            const _Passo(
                2, 'A TV para num canal e mostra o que muda na rodada.'),
            const _Passo(3, 'Ele tenta descobrir quem disse — em voz alta.'),
            const _Passo(4, 'O app revela a resposta.'),
            const _Passo(
                5, 'A mesa decide se valeu. Acertou pontua; errou encerra.'),
            const SizedBox(height: 24),
            const _Titulo('O sorteio'),
            Text(
              'A TV passa pelos canais e para num deles: é dali que vem a '
              'frase. Junto sobe o modificador, que diz o que muda na rodada:',
              style: corpo(14, cor: Cores.textoFraco, altura: 1.5),
            ),
            const SizedBox(height: 14),
            for (final efeito in EfeitoModificador.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          efeito.titulo,
                          style: titulo(15),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${tabela.entradas.where((e) => e == efeito).length} '
                          'de ${tabela.entradas.length} chances',
                          style: corpo(12, cor: Cores.textoFraco),
                        ),
                      ],
                    ),
                    Text(
                      efeito.descricao,
                      style: corpo(13, cor: Cores.textoFraco),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            const _Titulo('Alternativas'),
            Text(
              'A partida pode rodar com 5 alternativas de A a E abaixo da '
              'frase, montadas com respostas de outras perguntas do mesmo '
              'pacote. Elas ajudam a lembrar, mas não corrigem: quem decide se '
              'valeu continua sendo a mesa. Escolha no início da partida.',
              style: corpo(14, cor: Cores.textoFraco, altura: 1.5),
            ),
            const SizedBox(height: 24),
            const _Titulo('O tempo'),
            Text(
              'Um cronômetro corre enquanto a frase está na tela e avisa '
              'quando o tempo acaba. Ele não revela nada: quem decide quando '
              'revelar a resposta é a mesa. Dá para mudar a duração, ou '
              'desligar, no início da partida.',
              style: corpo(14, cor: Cores.textoFraco, altura: 1.5),
            ),
            const SizedBox(height: 24),
            const _Titulo('Errar e roubar'),
            Text(
              'Errar encerra a rodada: sem ponto, passa a vez. A única chance '
              'de disputar o ponto de outro jogador é a roleta cair em Roubo — '
              'aí todos respondem desde o começo e quem acertar primeiro leva.',
              style: corpo(14, cor: Cores.textoFraco, altura: 1.5),
            ),
            const SizedBox(height: 24),
            const _Titulo('Vitória'),
            Text(
              'A partida acaba quando alguém chega à meta de pontos ou quando '
              'as rodadas combinadas terminam. Em caso de empate, todos os '
              'líderes dividem o título.',
              style: corpo(14, cor: Cores.textoFraco, altura: 1.5),
            ),
            const SizedBox(height: 16),
            Text(
              'De ${ConfigPartida.minJogadores} a ${ConfigPartida.maxJogadores} '
              'jogadores, um aparelho só, sem internet.',
              style: const TextStyle(color: Cores.textoFraco, height: 1.5),
            ),
          ],
        ),
      )),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        texto.toUpperCase(),
        style: etiqueta(cor: Cores.destaque),
      ),
    );
  }
}

class _Passo extends StatelessWidget {
  const _Passo(this.numero, this.texto);

  final int numero;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Cores.superficieAlta,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$numero',
              style: titulo(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(texto, style: corpo(14, altura: 1.4)),
          ),
        ],
      ),
    );
  }
}
