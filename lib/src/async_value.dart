sealed class AsyncValue<T> {
  const AsyncValue();

  /// Maps the different states of [AsyncValue] to a return type [R] using Dart 3 pattern matching.
  R when<R>({
    required R Function(T data) data,
    required R Function(Object error, StackTrace? stackTrace) error,
    required R Function() loading,
  }) {
    return switch (this) {
      AsyncData<T> d => data(d.value),
      AsyncError<T> e => error(e.error, e.stackTrace),
      AsyncLoading<T> _ => loading(),
    };
  }
}

class AsyncData<T> extends AsyncValue<T> {
  const AsyncData(this.value);
  final T value;
}

class AsyncError<T> extends AsyncValue<T> {
  const AsyncError(this.error, [this.stackTrace]);
  final Object error;
  final StackTrace? stackTrace;
}

class AsyncLoading<T> extends AsyncValue<T> {
  const AsyncLoading();
}
