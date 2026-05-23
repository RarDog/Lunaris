import '../errors/failure.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onError,
  }) {
    final current = this;
    return switch (current) {
      Success<T>(:final data) => onSuccess(data),
      Error<T>(:final failure) => onError(failure),
    };
  }
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Error<T> extends Result<T> {
  const Error(this.failure);
  final Failure failure;
}
