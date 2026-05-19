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

  group('RestConnect.normalizeQueryParams', () {
    test('returns null when input is null', () {
      expect(RestConnect.normalizeQueryParams(null), isNull);
    });

    test('returns the same empty map without allocating a copy', () {
      final input = <String, dynamic>{};
      expect(RestConnect.normalizeQueryParams(input), same(input));
    });

    test('coerces ints, doubles and bools to String', () {
      // Regression: `Uri.replace(queryParameters: {'page': 1})` lança
      // `TypeError: 1: type 'int' is not a subtype of type
      // 'Iterable<dynamic>'`. Garantir que todo primitivo vire String.
      final result = RestConnect.normalizeQueryParams(<String, dynamic>{
        'page': 1,
        'pageSize': 20,
        'rate': 0.75,
        'active': true,
      });

      expect(result, {
        'page': '1',
        'pageSize': '20',
        'rate': '0.75',
        'active': 'true',
      });
    });

    test('keeps Strings untouched', () {
      final result = RestConnect.normalizeQueryParams(<String, dynamic>{
        'search': 'foo bar',
        'status': '',
      });

      expect(result, {'search': 'foo bar', 'status': ''});
    });

    test('drops keys whose value is null', () {
      final result = RestConnect.normalizeQueryParams(<String, dynamic>{
        'page': 1,
        'search': null,
        'status': 'ACTIVE',
      });

      expect(result, {'page': '1', 'status': 'ACTIVE'});
      expect(result!.containsKey('search'), isFalse);
    });

    test('maps Iterables of primitives to List<String>', () {
      // Preserva semântica de multi-value query params:
      // `?tag=a&tag=b&tag=c`.
      final result = RestConnect.normalizeQueryParams(<String, dynamic>{
        'tag': ['a', 'b', 'c'],
        'ids': [1, 2, 3],
      });

      expect(result!['tag'], ['a', 'b', 'c']);
      expect(result['ids'], ['1', '2', '3']);
    });

    test('filters null elements out of Iterable values', () {
      final result = RestConnect.normalizeQueryParams(<String, dynamic>{
        'tag': ['a', null, 'b'],
      });

      expect(result!['tag'], ['a', 'b']);
    });
  });
}
