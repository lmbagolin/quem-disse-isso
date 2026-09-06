enum CartaEspecial {
  ajuda(
    'Ajuda',
    'Escolha outro jogador para responder. Se ele acertar, o ponto é dividido.',
  ),
  dica(
    'Dica',
    'Uma pista é revelada, mas o acerto vale menos.',
  ),
  pulo(
    'Pulo',
    'Troca a frase sem pontuar.',
  );

  const CartaEspecial(this.titulo, this.descricao);

  final String titulo;
  final String descricao;

  /// Padrão da v1: errar encerra a rodada, sem segunda chance. O playtest
  /// mostrou que carta a cada erro tirava o peso do erro e alongava a rodada.
  /// As três seguem implementadas para quem quiser ligá-las na ConfigPartida.
  static const Set<CartaEspecial> nenhuma = {};
}
