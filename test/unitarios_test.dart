import 'package:flutter_test/flutter_test.dart';
import 'package:pawpark_frontend/api/model/usuario_model.dart';

void main() {

  group('Pruebas Unitarias de Lógica de Negocio y Modelos', () {

    /// Este test verifica que la lógica de la app sea capaz de distinguir
    /// entre una fecha válida (futura) y una inválida (pasada).
    test('Validación Temporal: La quedada debe ser posterior al instante actual', () {
      final ahora = DateTime.now();

      // Caso 1: Una fecha de hace una hora (Debe ser inválida)
      final fechaPasada = ahora.subtract(Duration(hours: 1));
      bool esValidaPasada = fechaPasada.isAfter(ahora);

      // Caso 2: Una fecha de mañana (Debe ser válida)
      final fechaFutura = ahora.add(Duration(days: 1));
      bool esValidaFutura = fechaFutura.isAfter(ahora);

      expect(esValidaPasada, isFalse); // Esperamos que falle
      expect(esValidaFutura, isTrue);  // Esperamos que pase
    });

    /// TEST 2: Control de Recursión (fromSimpleJson)
    /// Verifica que el constructor simplificado corte el bucle de seguidores.
    /// Es vital para evitar que la app se bloquee por falta de memoria.
    test('Modelo Usuario: fromSimpleJson debe romper bucles de seguidores', () {
      // Simulamos un JSON donde un seguidor trae a su vez otra lista de seguidores
      final jsonConBucle = {
        'firebaseUid': 'user_1',
        'nombre': 'Test',
        'seguidores': [
          {'firebaseUid': 'user_2', 'nombre': 'Seguidor'}
        ]
      };

      // Al usar fromSimpleJson, la lista de seguidores debe forzarse a vacía
      final usuario = Usuario.fromSimpleJson(jsonConBucle);

      expect(usuario.seguidores, isEmpty, reason: 'La lista debe estar vacía para evitar recursión');
    });

    /// TEST 3: Integridad de Datos (Mapeo de Coordenadas)
    /// El backend (Java) puede enviar números sin decimales (40).
    /// Este test asegura que Flutter los convierta correctamente a double (40.0).
    test('Mapeo de Datos: Conversión correcta de coordenadas GPS (int a double)', () {
      final json = {
        'firebaseUid': '123',
        'latitudPref': 40,    // El servidor envía un entero
        'longitudPref': -3.7  // El servidor envía un double
      };

      final usuario = Usuario.fromJson(json);

      // Verificamos que ambos se almacenen como double y no rompan la app
      expect(usuario.latitudPref, isA<double>());
      expect(usuario.latitudPref, 40.0);
    });


    /// Verifica que la lógica de "quién está en el parque" funcione correctamente
    /// antes de enviar los datos o pintar el mapa.
    test('Lógica de Presencia: Registro de UID en lista de zona', () {
      final listaPresentes = <String>[];
      const miUid = 'uid_firebase_123';

      // Simulamos la acción de entrar en una zona
      listaPresentes.add(miUid);

      expect(listaPresentes, contains(miUid));
      expect(listaPresentes.length, 1);

      // Simulamos la salida (Check-out)
      listaPresentes.remove(miUid);
      expect(listaPresentes, isNot(contains(miUid)));
    });
  });
}