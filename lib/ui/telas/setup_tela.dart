import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../../dominio/modelos/config_partida.dart';
import '../../dominio/modelos/dificuldade.dart';
import '../estado_app.dart';
import '../widgets/botao_grande.dart';
import 'partida_tela.dart';

class SetupTela extends StatefulWidget {
  const SetupTela({super.key});

  @override
  State<SetupTela> createState() => _SetupTelaState();
}

class _SetupTelaState extends State<SetupTela> {
  final List<TextEditingController> _nomes = [];
  final Set<String> _pacotes = {};
  TipoVitoria _tipoVitoria = TipoVitoria.pontos;
  int _alvo = 10;
  int _segundos = ConfigPartida.segundosPadrao;
  final Set<Dificuldade> _dificuldades = {};
  bool _comAlternativas = false;
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;

    final estado = EscopoApp.de(context);
    final prefs = estado.preferencias;
    final salvos = prefs?.nomesJogadores ?? const <String>[];
    final quantos = salvos.length.clamp(
      ConfigPartida.minJogadores,
      ConfigPartida.maxJogadores,
    );
    for (var i = 0; i < quantos; i++) {
      _nomes.add(TextEditingController(
        text: i < salvos.length ? salvos[i] : '',
      ));
    }

    final instalados = estado.gerenciador.instalados.map((p) => p.id).toList();
    _pacotes.addAll(prefs?.ativosPara(instalados) ?? instalados);
    prefs?.registrarVistos(instalados);

    if (prefs != null) {
      _tipoVitoria = prefs.vitoria.tipo;
      _alvo = prefs.vitoria.alvo;
      _segundos = prefs.segundosParaResponder;
      _dificuldades.addAll(prefs.dificuldadesAtivas);
      _comAlternativas = prefs.comAlternativas;
    }
    if (_dificuldades.isEmpty) {
      _dificuldades.addAll(ConfigPartida.todasAsDificuldades);
    }
  }

  @override
  void dispose() {
    for (final c in _nomes) {
      c.dispose();
    }
    super.dispose();
  }

  ConfigPartida _montarConfig() => ConfigPartida(
        nomesJogadores: _nomes.map((c) => c.text.trim()).toList(),
        idsPacotesAtivos: _pacotes,
        vitoria: _tipoVitoria == TipoVitoria.pontos
            ? CondicaoVitoria.porPontos(_alvo)
            : CondicaoVitoria.porRodadas(_alvo),
        segundosParaResponder: _segundos,
        dificuldadesAtivas: _dificuldades,
        comAlternativas: _comAlternativas,
      );

  void _comecar() {
    final config = _montarConfig();
    final problema = config.problema;
    if (problema != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(problema)));
      return;
    }
    final estado = EscopoApp.de(context);
    final perguntas = config
        .filtrar(estado.gerenciador.perguntasDe(config.idsPacotesAtivos));
    if (perguntas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma pergunta com os pacotes e níveis escolhidos.'),
        ),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PartidaTela(controlador: estado.criarPartida(config)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gerenciador = EscopoApp.de(context).gerenciador;
    final pacotes = gerenciador.instalados;

    final porNivel = <Dificuldade, int>{};
    for (final pergunta in gerenciador.perguntasDe(_pacotes)) {
      porNivel[pergunta.dificuldade] =
          (porNivel[pergunta.dificuldade] ?? 0) + 1;
    }
    final totalEscolhido = _dificuldades.fold<int>(
      0,
      (soma, nivel) => soma + (porNivel[nivel] ?? 0),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Nova partida')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const _Secao('Jogadores'),
            for (var i = 0; i < _nomes.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nomes[i],
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'Jogador ${i + 1}',
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                      ),
                    ),
                    if (_nomes.length > ConfigPartida.minJogadores)
                      IconButton(
                        icon: const Icon(Icons.close, color: Cores.textoFraco),
                        onPressed: () => setState(() {
                          _nomes.removeAt(i).dispose();
                        }),
                      ),
                  ],
                ),
              ),
            if (_nomes.length < ConfigPartida.maxJogadores)
              TextButton.icon(
                onPressed: () =>
                    setState(() => _nomes.add(TextEditingController())),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar jogador'),
              ),
            const SizedBox(height: 16),
            const _Secao('Pacotes na partida'),
            for (final pacote in pacotes)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: CheckboxListTile(
                  value: _pacotes.contains(pacote.id),
                  onChanged: (marcado) => setState(() {
                    marcado == true
                        ? _pacotes.add(pacote.id)
                        : _pacotes.remove(pacote.id);
                  }),
                  title: Text(pacote.nome),
                  subtitle: Text(
                    '${pacote.quantidadePerguntas} perguntas · ${pacote.faixaEtaria}',
                    style: const TextStyle(color: Cores.textoFraco),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const _Secao('Como termina'),
            SegmentedButton<TipoVitoria>(
              segments: const [
                ButtonSegment(
                  value: TipoVitoria.pontos,
                  label: Text('Por pontos'),
                ),
                ButtonSegment(
                  value: TipoVitoria.rodadas,
                  label: Text('Por rodadas'),
                ),
              ],
              selected: {_tipoVitoria},
              onSelectionChanged: (s) => setState(() {
                _tipoVitoria = s.first;
                _alvo = _tipoVitoria == TipoVitoria.pontos ? 10 : 5;
              }),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  _tipoVitoria == TipoVitoria.pontos
                      ? 'Vence com $_alvo pontos'
                      : '$_alvo rodadas',
                  style: const TextStyle(fontSize: 16),
                ),
                Expanded(
                  child: Slider(
                    value: _alvo.toDouble(),
                    min: 3,
                    max: 20,
                    divisions: 17,
                    onChanged: (v) => setState(() => _alvo = v.round()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _Secao('Alternativas'),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Sem alternativas')),
                ButtonSegment(value: true, label: Text('Com alternativas')),
              ],
              selected: {_comAlternativas},
              onSelectionChanged: (s) =>
                  setState(() => _comAlternativas = s.first),
            ),
            const SizedBox(height: 8),
            Text(
              _comAlternativas
                  ? 'A frase vem com 5 opções de A a E. Quem julga o acerto '
                      'continua sendo a mesa.'
                  : 'A frase aparece sozinha. Modo original, mais difícil.',
              style: const TextStyle(color: Cores.textoFraco, fontSize: 13),
            ),
            const SizedBox(height: 20),
            const _Secao('Níveis de dificuldade'),
            Wrap(
              spacing: 8,
              children: [
                for (final nivel in Dificuldade.values)
                  ChoiceChip(
                    label: Text('${nivel.rotulo} (${porNivel[nivel] ?? 0})'),
                    selected: _dificuldades.contains(nivel),
                    onSelected: (marcado) => setState(() {
                      marcado
                          ? _dificuldades.add(nivel)
                          : _dificuldades.remove(nivel);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _dificuldades.isEmpty
                  ? 'Escolha pelo menos um nível.'
                  : '$totalEscolhido perguntas entram no sorteio.',
              style: TextStyle(
                color: _dificuldades.isEmpty ? Cores.erro : Cores.textoFraco,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            const _Secao('Tempo para responder'),
            Wrap(
              spacing: 8,
              children: [
                for (final opcao in const [
                  ConfigPartida.semCronometro,
                  10,
                  15,
                  20,
                  30,
                ])
                  ChoiceChip(
                    label: Text(
                      opcao == ConfigPartida.semCronometro
                          ? 'Sem tempo'
                          : '$opcao s',
                    ),
                    selected: _segundos == opcao,
                    onSelected: (_) => setState(() => _segundos = opcao),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'O aviso de tempo esgotado não revela a resposta — quem decide '
              'isso é a mesa.',
              style: TextStyle(color: Cores.textoFraco, fontSize: 13),
            ),
            const SizedBox(height: 20),
            BotaoGrande(
              rotulo: 'Começar',
              icone: Icons.play_arrow_rounded,
              aoTocar: _comecar,
            ),
          ],
        ),
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao(this.titulo);

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        titulo.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: Cores.destaque,
        ),
      ),
    );
  }
}
