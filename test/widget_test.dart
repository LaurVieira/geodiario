import 'package:flutter_test/flutter_test.dart';
import 'package:geodiario/models/registro.dart';
import 'package:geodiario/utils/formatters.dart';

void main() {
  test('Registro converte para Map e volta sem perder dados', () {
    final original = Registro(
      id: 1,
      titulo: 'Praça da Liberdade',
      descricao: 'Passeio de domingo',
      caminhoFoto: '/data/fotos/geo_1.jpg',
      dataHora: DateTime(2026, 11, 17, 14, 5, 32),
      latitude: -19.932,
      longitude: -43.938,
    );

    final copia = Registro.fromMap(original.toMap());

    expect(copia.id, original.id);
    expect(copia.titulo, original.titulo);
    expect(copia.descricao, original.descricao);
    expect(copia.caminhoFoto, original.caminhoFoto);
    expect(copia.dataHora, original.dataHora);
    expect(copia.latitude, original.latitude);
    expect(copia.longitude, original.longitude);
  });

  test('Formatadores de data e hora', () {
    final d = DateTime(2026, 1, 5, 9, 3, 7);
    expect(formatarData(d), '05/01/2026');
    expect(formatarHora(d), '09:03:07');
    expect(formatarCoordenada(-19.9320001), '-19.932000');
  });
}
