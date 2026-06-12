import 'package:flutter_test/flutter_test.dart';
import 'package:pico/pico.dart';

void main() {
  group('AsyncValue', () {
    test('when pattern matching works for AsyncData', () {
      const asyncValue = AsyncData<int>(42);

      final result = asyncValue.when(
        data: (data) => 'Data: $data',
        error: (err, stack) => 'Error',
        loading: () => 'Loading',
      );

      expect(result, 'Data: 42');
    });

    test('when pattern matching works for AsyncError', () {
      final stack = StackTrace.current;
      final asyncValue = AsyncError<int>('Oops', stack);

      final result = asyncValue.when(
        data: (data) => 'Data',
        error: (err, s) => 'Error: $err',
        loading: () => 'Loading',
      );

      expect(result, 'Error: Oops');
    });

    test('when pattern matching works for AsyncLoading', () {
      const asyncValue = AsyncLoading<int>();

      final result = asyncValue.when(
        data: (data) => 'Data',
        error: (err, stack) => 'Error',
        loading: () => 'Loading',
      );

      expect(result, 'Loading');
    });
  });

  group('AsyncValueX Extensions', () {
    test('valueOrNull returns value for AsyncData and null otherwise', () {
      expect(const AsyncData<int>(42).valueOrNull, 42);
      expect(const AsyncError<int>('Oops').valueOrNull, isNull);
      expect(const AsyncLoading<int>().valueOrNull, isNull);
    });

    test('requireValue returns value for AsyncData', () {
      expect(const AsyncData<int>(42).requireValue, 42);
    });

    test('requireValue throws StateError for AsyncLoading', () {
      expect(
        () => const AsyncLoading<int>().requireValue,
        throwsA(isA<StateError>()),
      );
    });

    test('requireValue throws original error for AsyncError', () {
      expect(
        () => const AsyncError<int>('Original Error').requireValue,
        throwsA('Original Error'),
      );
    });

    test('map transforms AsyncData', () {
      const asyncValue = AsyncData<int>(42);
      final mapped = asyncValue.map((data) => data.toString());

      expect(mapped, isA<AsyncData<String>>());
      expect(mapped.requireValue, '42');
    });

    test('map retains AsyncError', () {
      const asyncValue = AsyncError<int>('Oops');
      final mapped = asyncValue.map((data) => data.toString());

      expect(mapped, isA<AsyncError<String>>());
      mapped.when(
        data: (_) => fail('Should not be data'),
        error: (err, _) => expect(err, 'Oops'),
        loading: () => fail('Should not be loading'),
      );
    });

    test('map retains AsyncLoading', () {
      const asyncValue = AsyncLoading<int>();
      final mapped = asyncValue.map((data) => data.toString());

      expect(mapped, isA<AsyncLoading<String>>());
    });
  });
}
