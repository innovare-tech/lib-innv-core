// ========================================
// async_result.dart
// ========================================

/// Abstract base class for async operation results
/// Provides type-safe handling of success and failure states
abstract class AsyncResult<T> {
  const AsyncResult();

  /// Returns true if this is a success result
  bool get isSuccess => this is AsyncSuccess<T>;

  /// Returns true if this is a failure result
  bool get isFailure => this is AsyncFailure<T>;

  /// Gets the data if success, null if failure
  T? get data => isSuccess ? (this as AsyncSuccess<T>).data : null;

  /// Gets the error message if failure, null if success
  String? get error => isFailure ? (this as AsyncFailure<T>).error : null;

  /// Gets the exception if failure, null if success
  Exception? get exception => isFailure ? (this as AsyncFailure<T>).exception : null;

  /// Gets the stack trace if failure, null if success
  StackTrace? get stackTrace => isFailure ? (this as AsyncFailure<T>).stackTrace : null;

  /// Pattern matching for handling success and failure cases
  ///
  /// Example:
  /// ```dart
  /// final result = await AsyncOperations.wrap(() => apiCall());
  /// final message = result.when(
  ///   success: (data) => 'Success: $data',
  ///   failure: (error, exception) => 'Error: $error',
  /// );
  /// ```
  R when<R>({
    required R Function(T data) success,
    required R Function(String error, Exception? exception) failure,
  }) {
    if (isSuccess) {
      return success((this as AsyncSuccess<T>).data);
    } else {
      final failureResult = this as AsyncFailure<T>;
      return failure(failureResult.error, failureResult.exception);
    }
  }

  /// Maps the data if success, keeps failure unchanged
  ///
  /// Example:
  /// ```dart
  /// final userResult = await AsyncOperations.wrap(() => getUser());
  /// final nameResult = userResult.map((user) => user.name);
  /// ```
  AsyncResult<R> map<R>(R Function(T) mapper) {
    return when(
      success: (data) => AsyncSuccess(mapper(data)),
      failure: (error, exception) => AsyncFailure(error, exception),
    );
  }

  /// Flat maps the result, useful for chaining async operations
  ///
  /// Example:
  /// ```dart
  /// final userResult = await AsyncOperations.wrap(() => getUser());
  /// final postsResult = userResult.flatMap((user) =>
  ///   AsyncOperations.wrap(() => getUserPosts(user.id))
  /// );
  /// ```
  AsyncResult<R> flatMap<R>(AsyncResult<R> Function(T) mapper) {
    return when(
      success: mapper,
      failure: (error, exception) => AsyncFailure(error, exception),
    );
  }

  /// Returns the data if success, or the fallback value if failure
  ///
  /// Example:
  /// ```dart
  /// final result = await AsyncOperations.wrap(() => apiCall());
  /// final data = result.getOrElse(() => defaultValue);
  /// ```
  T getOrElse(T Function() fallback) {
    return when(
      success: (data) => data,
      failure: (_, __) => fallback(),
    );
  }

  /// Returns this result if success, or the fallback result if failure
  ///
  /// Example:
  /// ```dart
  /// final result = await AsyncOperations.wrap(() => apiCall());
  /// final finalResult = result.orElse(() => AsyncSuccess(defaultValue));
  /// ```
  AsyncResult<T> orElse(AsyncResult<T> Function() fallback) {
    return when(
      success: (_) => this,
      failure: (_, __) => fallback(),
    );
  }

  /// Filters the result based on a predicate
  /// If success but predicate fails, converts to failure
  ///
  /// Example:
  /// ```dart
  /// final result = await AsyncOperations.wrap(() => getNumber());
  /// final positiveResult = result.filter(
  ///   (number) => number > 0,
  ///   errorMessage: 'Number must be positive'
  /// );
  /// ```
  AsyncResult<T> filter(bool Function(T) predicate, {String errorMessage = 'Filter failed'}) {
    return when(
      success: (data) => predicate(data)
          ? this
          : AsyncFailure<T>(errorMessage),
      failure: (_, __) => this,
    );
  }

  /// Extracts the value directly or throws the exception
  /// Perfect for when you want to work with the value directly
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final user = await AsyncOperations.wrap(() => getUser()).orThrows();
  ///   print('User: ${user.name}');
  /// } catch (e) {
  ///   print('Failed to get user: $e');
  /// }
  /// ```
  T orThrows() {
    return when(
      success: (data) => data,
      failure: (error, exception) => throw exception ?? Exception(error),
    );
  }

  /// Extracts the value directly or returns null
  /// Useful for optional operations
  ///
  /// Example:
  /// ```dart
  /// final user = await AsyncOperations.silent(() => getUser()).orNull();
  /// if (user != null) {
  ///   print('User: ${user.name}');
  /// }
  /// ```
  T? orNull() {
    return when(
      success: (data) => data,
      failure: (_, __) => null,
    );
  }
}

/// Represents a successful async operation result
class AsyncSuccess<T> extends AsyncResult<T> {
  /// The successful data
  @override
  final T data;

  const AsyncSuccess(this.data);

  @override
  String toString() => 'AsyncSuccess($data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AsyncSuccess<T> &&
              runtimeType == other.runtimeType &&
              data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// Represents a failed async operation result
class AsyncFailure<T> extends AsyncResult<T> {
  /// The error message
  @override
  final String error;

  /// The original exception (if any)
  @override
  final Exception? exception;

  /// The stack trace (if any)
  @override
  final StackTrace? stackTrace;

  const AsyncFailure(this.error, [this.exception, this.stackTrace]);

  /// Creates a failure from an exception
  factory AsyncFailure.fromException(Exception exception, [StackTrace? stackTrace]) {
    return AsyncFailure<T>(
      exception.toString(),
      exception,
      stackTrace,
    );
  }

  /// Creates a failure with just an error message
  factory AsyncFailure.message(String message) {
    return AsyncFailure<T>(message);
  }

  @override
  String toString() => 'AsyncFailure($error)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AsyncFailure<T> &&
              runtimeType == other.runtimeType &&
              error == other.error &&
              exception == other.exception;

  @override
  int get hashCode => Object.hash(error, exception);
}

/// Utility methods for working with AsyncResult
class AsyncResultUtils {
  /// Combines multiple AsyncResults into a single result
  /// Returns success only if all results are successful
  ///
  /// Example:
  /// ```dart
  /// final result1 = await AsyncOperations.wrap(() => getUser());
  /// final result2 = await AsyncOperations.wrap(() => getPosts());
  /// final combined = AsyncResultUtils.combine([result1, result2]);
  /// ```
  static AsyncResult<List<T>> combine<T>(List<AsyncResult<T>> results) {
    final List<T> successData = [];

    for (final result in results) {
      if (result.isFailure) {
        return AsyncFailure<List<T>>(result.error!, result.exception);
      }

      successData.add(result.data as T);
    }

    return AsyncSuccess(successData);
  }

  /// Combines multiple AsyncResults of different types into a single result
  ///
  /// Example:
  /// ```dart
  /// final userResult = await AsyncOperations.wrap(() => getUser());
  /// final postsResult = await AsyncOperations.wrap(() => getPosts());
  /// final combined = AsyncResultUtils.combine2(
  ///   userResult,
  ///   postsResult,
  ///   (user, posts) => UserWithPosts(user, posts)
  /// );
  /// ```
  static AsyncResult<R> combine2<T1, T2, R>(
      AsyncResult<T1> result1,
      AsyncResult<T2> result2,
      R Function(T1, T2) combiner,
      ) {
    return result1.flatMap((data1) =>
        result2.map((data2) => combiner(data1, data2))
    );
  }

  /// Combines three AsyncResults into a single result
  static AsyncResult<R> combine3<T1, T2, T3, R>(
      AsyncResult<T1> result1,
      AsyncResult<T2> result2,
      AsyncResult<T3> result3,
      R Function(T1, T2, T3) combiner,
      ) {
    return result1.flatMap((data1) =>
        result2.flatMap((data2) =>
            result3.map((data3) => combiner(data1, data2, data3))
        )
    );
  }

  /// Creates a successful result
  static AsyncResult<T> success<T>(T data) => AsyncSuccess(data);

  /// Creates a failed result
  static AsyncResult<T> failure<T>(String error, [Exception? exception]) =>
      AsyncFailure(error, exception);

  /// Wraps a nullable value into an AsyncResult
  static AsyncResult<T> fromNullable<T>(T? value, {String errorMessage = 'Value is null'}) {
    return value != null
        ? AsyncSuccess(value)
        : AsyncFailure<T>(errorMessage);
  }

  /// Safely executes a function and wraps the result
  static AsyncResult<T> tryCatch<T>(T Function() fn, {String? errorMessage}) {
    try {
      return AsyncSuccess(fn());
    } catch (e, stackTrace) {
      final error = errorMessage ?? e.toString();
      final exception = e is Exception ? e : Exception(e.toString());
      return AsyncFailure<T>(error, exception, stackTrace);
    }
  }
}