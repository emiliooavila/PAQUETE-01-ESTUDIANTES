import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';

void main() {
  test('Una incidencia antigua puede convertirse desde JSON', () {
    final registro = Incidencia.desdeJson({
      'id': 'INC-DEMO',
      'titulo': 'Prueba',
      'descripcion': 'Caso de ejemplo',
      'cliente': 'Cliente ficticio',
      'categoria': 'Redes',
      'estado': 'Pendiente',
      'fecha': '2026-10-12',
    });
    expect(registro.id, 'INC-DEMO');
    expect(registro.toJson()['estado'], 'Pendiente');
    expect(registro.prioridad, 'Media');
    expect(registro.toJson()['prioridad'], 'Media');
  });

  test('Una prioridad fuera de las aprobadas se normaliza a Media', () {
    final registro = Incidencia.desdeJson({
      'id': 'INC-DEMO-2',
      'titulo': 'Prueba 2',
      'descripcion': 'Otro caso de ejemplo',
      'cliente': 'Cliente ficticio',
      'categoria': 'Hardware',
      'estado': 'Pendiente',
      'fecha': '2026-10-12',
      'prioridad': 'Urgente',
    });
    expect(registro.prioridad, 'Media');
  });

  test('Una prioridad aprobada se conserva tal cual', () {
    expect(normalizarPrioridad('Alta'), 'Alta');
    expect(normalizarPrioridad('Baja'), 'Baja');
    expect(normalizarPrioridad('Media'), 'Media');
    expect(normalizarPrioridad(null), 'Media');
    expect(normalizarPrioridad(''), 'Media');
  });
}
