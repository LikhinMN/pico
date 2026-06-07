/// Represents an asynchronous value which can be in one of three states:
/// data, error, or loading.
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

/// Represents a successful data state containing a [value].
class AsyncData<T> extends AsyncValue<T> {
  /// Creates an [AsyncData] state with the given [value].
  const AsyncData(this.value);

  /// The underlying value in this data state.
  final T value;
}

/// Represents an error state containing an [error] and an optional [stackTrace].
class AsyncError<T> extends AsyncValue<T> {
  /// Creates an [AsyncError] state with the given [error] and [stackTrace].
  const AsyncError(this.error, [this.stackTrace]);

  /// The error object.
  final Object error;

  /// The optional stack trace associated with the error.
  final StackTrace? stackTrace;
}

/// Represents a loading state, indicating that an asynchronous operation is in progress.
class AsyncLoading<T> extends AsyncValue<T> {
  /// Creates an [AsyncLoading] state.
  const AsyncLoading();
}
