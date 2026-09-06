import '../dominio/modelos/pacote.dart';

class ItemLoja {
  const ItemLoja({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.faixaEtaria,
    required this.preco,
    required this.quantidadePerguntas,
  });

  final String id;
  final String nome;
  final String descricao;
  final String faixaEtaria;
  final String preco;
  final int quantidadePerguntas;
}

/// Fronteira da monetização. O motor nunca fala com a loja; a loja só entrega
/// arquivos de pacote para o gerenciador. Implementação real (IAP + servidor
/// de pacotes) entra numa fase posterior sem tocar em mais nada.
abstract class CatalogoLoja {
  Future<List<ItemLoja>> listarDisponiveis();
  Future<Pacote> comprarEBaixar(String idPacote);
}

class LojaIndisponivel implements CatalogoLoja {
  const LojaIndisponivel();

  @override
  Future<List<ItemLoja>> listarDisponiveis() async => const [];

  @override
  Future<Pacote> comprarEBaixar(String idPacote) =>
      throw UnimplementedError('A loja de pacotes ainda não foi publicada.');
}
