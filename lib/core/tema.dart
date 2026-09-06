import 'package:flutter/material.dart';

/// Paleta com papéis fixos. Cada cor tem uma função e só ela — trocar de papel
/// desmonta a leitura das telas.
class Cores {
  /// Fundo de todas as telas. Nunca muda.
  static const fundo = Color(0xFF0A0F3C);

  /// Superfícies: cartões, alternativas, campos.
  static const superficie = Color(0xFF1B2ACF);

  /// Superfície recuada, para agrupar sem competir com a superfície viva.
  static const superficieAlta = Color(0xFF111862);

  /// Ação principal. Uma por tela, nunca duas.
  static const destaque = Color(0xFFFFE45E);

  /// Sombra sólida da marca, urgência e erro.
  static const magenta = Color(0xFFFF2E9A);

  /// Reservado ao conteúdo do jogo: a frase aparece sempre nesta cor.
  static const ciano = Color(0xFF00E5FF);

  /// Acerto e pontos ganhos, só isso.
  static const acerto = Color(0xFF4BE38A);

  static const erro = magenta;
  static const texto = Color(0xFFF2F5FF);
  static const textoFraco = Color(0xFFA9B4F0);
  static const textoApagado = Color(0xFFC3CCFF);
  static const rotulo = Color(0xFF8290DE);

  /// Texto sobre amarelo, magenta e ciano é sempre azul-tubo: branco nessas
  /// três não passa em contraste.
  static const sobreClaro = fundo;

  /// Escuros de apoio, para texto sobre verde e dentro do balão ciano.
  static const sobreVerde = Color(0xFF062E1C);
  static const sobreCiano = Color(0xFF0A5A66);

  /// Cor de cada canal (pacote), na ordem em que aparecem.
  static const canais = [
    destaque,
    ciano,
    magenta,
    acerto,
    Color(0xFFB57BFF),
    Color(0xFFFF8A3D),
    Color(0xFF7CE7D6),
    Color(0xFFFF6B6B),
  ];

  static Color doCanal(int indice) => canais[indice % canais.length];
}

/// Medidas do sistema: raio 12 em botões e alternativas, 16 no balão da frase,
/// 24 na folha; sombra sólida de 5px só na marca e na ação principal.
class Medidas {
  static const raioBotao = 12.0;
  static const raioAlternativa = 10.0;
  static const raioBalao = 16.0;
  static const raioFolha = 24.0;
  static const deslocamentoSombra = Offset(5, 5);

  static const List<BoxShadow> sombraSolida = [
    BoxShadow(color: Cores.magenta, offset: deslocamentoSombra, blurRadius: 0),
  ];
}

/// Archivo Black: só caixa-alta, só em títulos, nomes de jogador e botões.
const String fonteTitulo = 'ArchivoBlack';

/// Space Grotesk: todo o resto da interface.
const String fonteCorpo = 'SpaceGrotesk';

/// A variável só existe na Space Grotesk, que é uma fonte de peso contínuo.
List<FontVariation> _peso(int valor) => [FontVariation('wght', valor.toDouble())];

TextStyle titulo(double tamanho, {Color cor = Cores.texto, double altura = 1.05}) =>
    TextStyle(
      fontFamily: fonteTitulo,
      fontSize: tamanho,
      height: altura,
      color: cor,
    );

TextStyle corpo(
  double tamanho, {
  Color cor = Cores.texto,
  int peso = 500,
  double altura = 1.35,
  double espacamento = 0,
}) =>
    TextStyle(
      fontFamily: fonteCorpo,
      fontSize: tamanho,
      height: altura,
      color: cor,
      fontVariations: _peso(peso),
      letterSpacing: espacamento,
    );

/// Rótulo caixa-alta de 11px que abre as seções.
TextStyle etiqueta({Color cor = Cores.rotulo}) =>
    corpo(11, cor: cor, peso: 700, espacamento: 1.8);

ThemeData construirTema() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: Cores.fundo,
    colorScheme: base.colorScheme.copyWith(
      primary: Cores.destaque,
      onPrimary: Cores.sobreClaro,
      secondary: Cores.ciano,
      surface: Cores.superficie,
      onSurface: Cores.texto,
      error: Cores.magenta,
    ),
    textTheme: base.textTheme.apply(
      fontFamily: fonteCorpo,
      bodyColor: Cores.texto,
      displayColor: Cores.texto,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: Cores.texto,
      titleTextStyle: titulo(15).copyWith(letterSpacing: 1),
    ),
    cardTheme: CardThemeData(
      color: Cores.superficieAlta,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Medidas.raioBotao),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Cores.superficie,
      hintStyle: corpo(15, cor: Cores.textoFraco),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Medidas.raioBotao),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Cores.superficieAlta,
      contentTextStyle: corpo(14),
    ),
  );
}
