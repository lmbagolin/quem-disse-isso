import 'package:flutter_test/flutter_test.dart';
import 'package:quem_disse_isso/dados/fonte_pacotes.dart';
import 'package:quem_disse_isso/dados/gerenciador_pacotes.dart';
import 'package:quem_disse_isso/dominio/modelos/pacote.dart';
import 'package:quem_disse_isso/ui/estado_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FonteQueFalha implements FontePacotes {
  @override
  Future<List<Pacote>> carregar() async => throw UnimplementedError('sem disco');
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('fonte quebrada registra a falha sem deixar o gerenciador indefinido',
      () async {
    final estado = EstadoApp(gerenciador: GerenciadorPacotes([FonteQueFalha()]));
    await estado.iniciar();

    expect(estado.pronto, isTrue);
    expect(estado.falha, isNotNull);
    // A tela inicial lê isto para decidir se o botão Jogar fica ativo.
    expect(estado.gerenciador.instalados, isEmpty);
  });
}
