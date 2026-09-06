import 'package:flutter/material.dart';

class Cores {
  static const fundo = Color(0xFF141130);
  static const superficie = Color(0xFF221E4A);
  static const superficieAlta = Color(0xFF2E2963);
  static const destaque = Color(0xFFFFC24B);
  static const roxo = Color(0xFF8B6BFF);
  static const acerto = Color(0xFF3DD68C);
  static const erro = Color(0xFFFF6B6B);
  static const texto = Color(0xFFF3F0FF);
  static const textoFraco = Color(0xFFA9A2D6);
}

ThemeData construirTema() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: Cores.fundo,
    colorScheme: base.colorScheme.copyWith(
      primary: Cores.destaque,
      onPrimary: Cores.fundo,
      secondary: Cores.roxo,
      surface: Cores.superficie,
      onSurface: Cores.texto,
      error: Cores.erro,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: Cores.texto,
      displayColor: Cores.texto,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: Cores.texto,
    ),
    cardTheme: CardThemeData(
      color: Cores.superficie,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Cores.superficie,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Cores.superficieAlta,
      contentTextStyle: TextStyle(color: Cores.texto),
    ),
  );
}
