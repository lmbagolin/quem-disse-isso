import 'package:flutter_test/flutter_test.dart';
import 'package:quem_disse_isso/dados/preferencias.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Preferencias> abrir(Map<String, Object> valores) async {
  SharedPreferences.setMockInitialValues(valores);
  return Preferencias.abrir();
}

void main() {
  test('primeira partida liga todos os pacotes instalados', () async {
    final prefs = await abrir({});
    expect(prefs.ativosPara(['a', 'b']), {'a', 'b'});
  });

  test('respeita o que o jogador desligou', () async {
    final prefs = await abrir({
      'pacotes_ativos': ['a'],
      'pacotes_vistos': ['a', 'b'],
    });
    expect(prefs.ativosPara(['a', 'b']), {'a'});
  });

  test('pacote novo entra ligado sem reativar o que foi desligado', () async {
    final prefs = await abrir({
      'pacotes_ativos': ['a'],
      'pacotes_vistos': ['a', 'b'],
    });
    expect(prefs.ativosPara(['a', 'b', 'c']), {'a', 'c'});
  });

  test('pacote desinstalado some da seleção', () async {
    final prefs = await abrir({
      'pacotes_ativos': ['a', 'b'],
      'pacotes_vistos': ['a', 'b'],
    });
    expect(prefs.ativosPara(['a']), {'a'});
  });
}
