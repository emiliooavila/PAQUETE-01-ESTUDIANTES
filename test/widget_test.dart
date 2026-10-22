import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

GestorIncidencias gestorDePrueba() {
  final g = GestorIncidencias();
  g.incidencias = [
    Incidencia.desdeJson({
      'id': 'INC-1',
      'titulo': 'WiFi intermitente en recepción',
      'descripcion': 'La red inalámbrica se desconecta.',
      'cliente': 'Clínica del Prado',
      'categoria': 'Redes',
      'estado': 'En proceso',
      'fecha': '2026-10-01',
      'prioridad': 'Alta',
    }),
    Incidencia.desdeJson({
      'id': 'INC-2',
      'titulo': 'Pantalla azul al iniciar',
      'descripcion': 'Equipo de contabilidad.',
      'cliente': 'Servicios del Norte',
      'categoria': 'Hardware',
      'estado': 'Pendiente',
      'fecha': '2026-10-02',
      'prioridad': 'Baja',
    }),
    Incidencia.desdeJson({
      'id': 'INC-3',
      'titulo': 'Impresora atascada',
      'descripcion': 'Documentos en cola de impresión.',
      'cliente': 'Almacenes del Centro',
      'categoria': 'Hardware',
      'estado': 'Pendiente',
      'fecha': '2026-10-03',
      'prioridad': 'Alta',
    }),
  ];
  return g;
}

void main() {
  SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
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

  group('FEAT-002 filtros combinados', () {
    test('Sin filtros devuelve todo', () {
      final g = gestorDePrueba();
      expect(g.buscar('').length, 3);
      expect(g.buscar('  ', estado: 'Todos', prioridad: 'Todas').length, 3);
    });

    test('Busca en titulo y en descripcion, ignorando mayusculas', () {
      final g = gestorDePrueba();
      expect(g.buscar('wifi').map((x) => x.id), ['INC-1']);
      expect(g.buscar('desconecta').map((x) => x.id), ['INC-1']);
      expect(g.buscar('cola').map((x) => x.id), ['INC-3']);
    });

    test('Filtra por estado con el literal exacto', () {
      final g = gestorDePrueba();
      expect(g.buscar('', estado: 'Pendiente').map((x) => x.id),
          ['INC-2', 'INC-3']);
      expect(g.buscar('', estado: 'En proceso').map((x) => x.id), ['INC-1']);
      expect(g.buscar('', estado: 'Resuelta'), isEmpty);
    });

    test('Filtra por prioridad', () {
      final g = gestorDePrueba();
      expect(g.buscar('', prioridad: 'Alta').map((x) => x.id),
          ['INC-1', 'INC-3']);
      expect(g.buscar('', prioridad: 'Baja').map((x) => x.id), ['INC-2']);
      expect(g.buscar('', prioridad: 'Media'), isEmpty);
    });

    test('Texto, estado y prioridad se aplican a la vez (AND)', () {
      final g = gestorDePrueba();
      expect(g.buscar('impresora', estado: 'Pendiente', prioridad: 'Alta')
          .map((x) => x.id), ['INC-3']);
      expect(
          g.buscar('wifi', estado: 'Pendiente', prioridad: 'Alta'), isEmpty);
      expect(g.buscar('wifi', estado: 'En proceso', prioridad: 'Alta')
          .map((x) => x.id), ['INC-1']);
    });

    test('Cero resultados devuelve lista vacia y no falla', () {
      final g = gestorDePrueba();
      expect(g.buscar('texto-que-no-existe', estado: 'Resuelta',
          prioridad: 'Media'), isEmpty);
    });
  });
}
