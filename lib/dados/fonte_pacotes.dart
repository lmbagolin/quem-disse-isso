import '../dominio/modelos/pacote.dart';

abstract class FontePacotes {
  Future<List<Pacote>> carregar();
}
