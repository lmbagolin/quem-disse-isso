enum Dificuldade {
  facil('facil', 'Fácil'),
  media('media', 'Média'),
  dificil('dificil', 'Difícil');

  const Dificuldade(this.chave, this.rotulo);

  /// Como aparece no arquivo do pacote.
  final String chave;
  final String rotulo;

  static Dificuldade daChave(String? valor) {
    return Dificuldade.values.firstWhere(
      (d) => d.chave == valor,
      orElse: () => Dificuldade.media,
    );
  }
}
