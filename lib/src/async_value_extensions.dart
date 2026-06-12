import 'async_value.dart';

/// A set of helpful extension methods for [AsyncValue] to unwrap or transform data.
extension AsyncValueX<T> on AsyncValue<T> {
  /// Returns the underlying data if present, otherwise returns null.
  T? get valueOrNull => when(
    data: (data) => data,
    error: (err, stack) => null,
    loading: () => null,
  );

  /// Returns the underlying data, throwing an error if it is not in the data state.
  T get requireValue => when(
    data: (data) => data,
    error: (err, stack) {
      Error.throwWithStackTrace(err, stack ?? StackTrace.current);
    },
    loading: () => throw StateError(
      'Tried to call requireValue on an AsyncLoading state.',
    ),
  );

  /// Maps the underlying data to a new type [R] if it is in the data state.
  AsyncValue<R> map<R>(R Function(T data) mapper) {
    return when(
      data: (data) => AsyncData<R>(mapper(data)),
      error: (err, stack) => AsyncError<R>(err, stack),
      loading: () => AsyncLoading<R>(),
    );
  }
}
