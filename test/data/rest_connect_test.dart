import 'package:flutter_test/flutter_test.dart';
import 'package:innovare_core/data/rest_connect.dart';

void main() {
  group('RestConnect session state', () {
    setUp(() {
      // Garante estado limpo entre testes, dado que `_sessionDead` é estático
      // e compartilhado por todas as instâncias do app.
      RestConnect.resetSessionState();
    });

    test('isSessionDead starts false', () {
      expect(RestConnect.isSessionDead, isFalse);
    });

    test('debugForceSessionDead flips the flag to true', () {
      RestConnect.debugForceSessionDead();
      expect(RestConnect.isSessionDead, isTrue);
    });

    test('resetSessionState clears the dead flag', () {
      RestConnect.debugForceSessionDead();
      expect(RestConnect.isSessionDead, isTrue);

      RestConnect.resetSessionState();
      expect(RestConnect.isSessionDead, isFalse);
    });

    test('resetSessionState is idempotent when already clean', () {
      // Já está clean via setUp
      RestConnect.resetSessionState();
      RestConnect.resetSessionState();
      expect(RestConnect.isSessionDead, isFalse);
    });
  });
}
