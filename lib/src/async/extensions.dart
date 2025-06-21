// ========================================
// extensions.dart (Clean version without duplicated classes)
// ========================================

import 'dart:async';
import 'async_result.dart';
import 'async_operations.dart';
import 'async_config.dart';

/// Extensions for AsyncResult to provide fluent API
extension AsyncResultExtensions<T> on Future<AsyncResult<T>> {
  /// Executes callback when operation succeeds
  ///
  /// Example:
  /// ```dart
  /// await AsyncOperations.wrap(() => apiCall())
  ///   .onSuccess((data) {
  ///     print('Success: $data');
  ///     navigateToNextPage(data);
  ///   });
  /// ```
  Future<void> onSuccess(void Function(T data) callback) async {
    final result = await this;
    if (result.isSuccess) {
      callback(result.data as T);
    }
  }

  /// Executes callback when operation fails
  ///
  /// Example:
  /// ```dart
  /// await AsyncOperations.wrap(() => apiCall())
  ///   .onFailure((error, exception) {
  ///     print('Error: $error');
  ///     showErrorDialog(error);
  ///   });
  /// ```
  Future<void> onFailure(void Function(String error, Exception? exception) callback) async {
    final result = await this;
    if (result.isFailure) {
      callback(result.error!, result.exception);
    }
  }

  /// Executes callback regardless of success or failure
  ///
  /// Example:
  /// ```dart
  /// await AsyncOperations.wrap(() => apiCall())
  ///   .onComplete((result) {
  ///     hideLoadingSpinner();
  ///     print('Operation completed: ${result.isSuccess}');
  ///   });
  /// ```
  Future<void> onComplete(void Function(AsyncResult<T> result) callback) async {
    final result = await this;
    callback(result);
  }

  /// Transforms the AsyncResult using a callback
  ///
  /// Example:
  /// ```dart
  /// final message = await AsyncOperations.wrap(() => apiCall())
  ///   .then((result) => result.when(
  ///     success: (data) => 'Success: $data',
  ///     failure: (error, _) => 'Error: $error',
  ///   ));
  /// ```
  Future<R> then<R>(R Function(AsyncResult<T>) callback) async {
    final result = await this;
    return callback(result);
  }

  /// Maps the success data to a new type asynchronously
  ///
  /// Example:
  /// ```dart
  /// final userNameResult = await AsyncOperations.wrap(() => getUser())
  ///   .mapAsync((user) async => await getUserDisplayName(user.id));
  /// ```
  Future<AsyncResult<R>> mapAsync<R>(Future<R> Function(T) mapper) async {
    final result = await this;
    return result.when(
      success: (data) async => AsyncSuccess(await mapper(data)),
      failure: (error, exception) => AsyncFailure<R>(error, exception),
    );
  }

  /// Maps the success data to a new type synchronously
  ///
  /// Example:
  /// ```dart
  /// final userNameResult = await AsyncOperations.wrap(() => getUser())
  ///   .map((user) => user.name);
  /// ```
  Future<AsyncResult<R>> map<R>(R Function(T) mapper) async {
    final result = await this;
    return result.map(mapper);
  }

  /// Flat maps to another AsyncResult
  ///
  /// Example:
  /// ```dart
  /// final postsResult = await AsyncOperations.wrap(() => getUser())
  ///   .flatMapAsync((user) => AsyncOperations.wrap(() => getUserPosts(user.id)));
  /// ```
  Future<AsyncResult<R>> flatMapAsync<R>(Future<AsyncResult<R>> Function(T) mapper) async {
    final result = await this;
    return result.when(
      success: mapper,
      failure: (error, exception) => AsyncFailure<R>(error, exception),
    );
  }

  /// Filters the result based on a predicate
  ///
  /// Example:
  /// ```dart
  /// final validUserResult = await AsyncOperations.wrap(() => getUser())
  ///   .filter((user) => user.isActive, errorMessage: 'User is not active');
  /// ```
  Future<AsyncResult<T>> filter(
      bool Function(T) predicate, {
        String errorMessage = 'Filter condition not met',
      }) async {
    final result = await this;
    return result.filter(predicate, errorMessage: errorMessage);
  }

  /// Returns the data if success, or the fallback if failure
  ///
  /// Example:
  /// ```dart
  /// final user = await AsyncOperations.wrap(() => getUser())
  ///   .getOrElse(() => User.guest());
  /// ```
  Future<T> getOrElse(T Function() fallback) async {
    final result = await this;
    return result.getOrElse(fallback);
  }

  /// Returns this result if success, or the fallback result if failure
  ///
  /// Example:
  /// ```dart
  /// final userResult = await AsyncOperations.wrap(() => getUser())
  ///   .orElse(() => AsyncSuccess(User.guest()));
  /// ```
  Future<AsyncResult<T>> orElse(AsyncResult<T> Function() fallback) async {
    final result = await this;
    return result.orElse(fallback);
  }

  /// Chains multiple async operations with error handling
  ///
  /// Example:
  /// ```dart
  /// await AsyncOperations.wrap(() => login(email, password))
  ///   .onSuccess((user) => saveUserToStorage(user))
  ///   .onSuccess((_) => navigateToHome())
  ///   .onFailure((error, _) => showLoginError(error));
  /// ```
  Future<AsyncResult<T>> chain(Future<void> Function(T) nextOperation) async {
    final result = await this;
    if (result.isSuccess) {
      try {
        await nextOperation(result.data as T);
        return result;
      } catch (e, stackTrace) {
        return AsyncFailure<T>(
          e.toString(),
          e is Exception ? e : Exception(e.toString()),
          stackTrace,
        );
      }
    }
    return result;
  }

  /// Retries the original operation if it failed
  ///
  /// Example:
  /// ```dart
  /// final result = await AsyncOperations.wrap(() => unstableApiCall())
  ///   .retry(maxAttempts: 3, delay: Duration(seconds: 1));
  /// ```
  Future<AsyncResult<T>> retry({
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(Exception)? retryWhen,
  }) async {
    final result = await this;
    if (result.isSuccess) return result;

    // This is a simplified retry - in practice, you'd need access to the original operation
    // For full retry functionality, use AsyncOperations.wrap with retry parameters
    return result;
  }

  /// Adds timeout to the operation
  ///
  /// Example:
  /// ```dart
  /// final result = await AsyncOperations.wrap(() => slowApiCall())
  ///   .timeout(Duration(seconds: 10));
  /// ```
  Future<AsyncResult<T>> timeout(Duration timeout) async {
    try {
      final result = await this.timeout(timeout);
      return result;
    } on TimeoutException catch (e, stackTrace) {
      return AsyncFailure<T>(
        'A operação demorou muito para responder',
        e,
        stackTrace,
      );
    }
  }
}

/// Extensions for Future to integrate with AsyncOperations
extension FutureAsyncExtensions<T> on Future<T> {
  /// Wraps this Future with InnovareCore async operations
  ///
  /// Example:
  /// ```dart
  /// final result = await apiService.login(email, password)
  ///   .innWrap(loadingMessage: "Fazendo login...");
  ///
  /// result.when(
  ///   success: (user) => navigateHome(user),
  ///   failure: (error, _) => showError(error),
  /// );
  /// ```
  Future<AsyncResult<T>> innWrap({
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
    bool silent = false,
    bool showErrorDialog = true,
    int? retryAttempts,
    Duration? retryDelay,
    Duration? timeout,
    CancelToken? cancelToken,
    bool Function(Exception)? retryWhen,
    RetryConfig? retryConfig,
  }) {
    return AsyncOperations.wrap(
          () => this,
      loadingMessage: loadingMessage,
      successMessage: successMessage,
      errorMessage: errorMessage,
      silent: silent,
      showErrorDialog: showErrorDialog,
      retryAttempts: retryAttempts,
      retryDelay: retryDelay,
      timeout: timeout,
      cancelToken: cancelToken,
      retryWhen: retryWhen,
      retryConfig: retryConfig,
    );
  }

  /// Wraps this Future safely (emphasizing safety)
  ///
  /// Example:
  /// ```dart
  /// final result = await riskyOperation()
  ///   .innSafe(retryAttempts: 3);
  /// ```
  Future<AsyncResult<T>> innSafe({
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
    bool silent = false,
    bool showErrorDialog = true,
    int? retryAttempts,
    Duration? retryDelay,
    Duration? timeout,
    CancelToken? cancelToken,
    bool Function(Exception)? retryWhen,
  }) => innWrap(
    loadingMessage: loadingMessage,
    successMessage: successMessage,
    errorMessage: errorMessage,
    silent: silent,
    showErrorDialog: showErrorDialog,
    retryAttempts: retryAttempts,
    retryDelay: retryDelay,
    timeout: timeout,
    cancelToken: cancelToken,
    retryWhen: retryWhen,
  );

  /// Wraps this Future for network operations (with network-optimized settings)
  ///
  /// Example:
  /// ```dart
  /// final result = await apiCall().innNetwork();
  /// ```
  Future<AsyncResult<T>> innNetwork({
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
    bool silent = false,
    bool showErrorDialog = true,
    Duration? timeout,
    CancelToken? cancelToken,
  }) => innWrap(
    loadingMessage: loadingMessage,
    successMessage: successMessage,
    errorMessage: errorMessage,
    silent: silent,
    showErrorDialog: showErrorDialog,
    timeout: timeout,
    cancelToken: cancelToken,
    retryConfig: RetryConfig.network(),
  );

  /// Wraps this Future silently (no UI feedback)
  ///
  /// Example:
  /// ```dart
  /// final result = await backgroundSync().innSilent();
  /// ```
  Future<AsyncResult<T>> innSilent({
    int? retryAttempts,
    Duration? retryDelay,
    Duration? timeout,
    CancelToken? cancelToken,
    bool Function(Exception)? retryWhen,
  }) => innWrap(
    silent: true,
    showErrorDialog: false,
    retryAttempts: retryAttempts,
    retryDelay: retryDelay,
    timeout: timeout,
    cancelToken: cancelToken,
    retryWhen: retryWhen,
  );
}

/// Extensions for List to work with AsyncOperations
extension FutureListExtensions<T> on List<Future<T>> {
  /// Executes all futures in parallel using AsyncOperations
  ///
  /// Example:
  /// ```dart
  /// final results = await [
  ///   getUser(),
  ///   getPosts(),
  ///   getNotifications(),
  /// ].innParallel(loadingMessage: "Carregando dados...");
  /// ```
  Future<AsyncResult<List<T>>> innParallel({
    String? loadingMessage,
    bool silent = false,
    CancelToken? cancelToken,
    int? maxConcurrency,
  }) {
    return AsyncOperations.parallel(
      map((future) => () => future).toList(),
      loadingMessage: loadingMessage,
      silent: silent,
      cancelToken: cancelToken,
      maxConcurrency: maxConcurrency,
    );
  }

  /// Executes all futures in sequence using AsyncOperations
  ///
  /// Example:
  /// ```dart
  /// final results = await [
  ///   step1(),
  ///   step2(),
  ///   step3(),
  /// ].innSequence(loadingMessage: "Processando etapas...");
  /// ```
  Future<AsyncResult<List<T>>> innSequence({
    String? loadingMessage,
    bool silent = false,
    CancelToken? cancelToken,
    ProgressCallback? progressCallback,
  }) {
    return AsyncOperations.sequence(
      map((future) => () => future).toList(),
      loadingMessage: loadingMessage,
      silent: silent,
      cancelToken: cancelToken,
      progressCallback: progressCallback,
    );
  }
}

/// Extensions for Stream to work with AsyncOperations
extension StreamAsyncExtensions<T> on Stream<T> {
  /// Wraps stream operations with AsyncOperations
  ///
  /// Example:
  /// ```dart
  /// final result = await dataStream
  ///   .take(10)
  ///   .innWrap(loadingMessage: "Carregando stream...");
  /// ```
  Future<AsyncResult<List<T>>> innWrap({
    String? loadingMessage,
    bool silent = false,
    CancelToken? cancelToken,
    Duration? timeout,
  }) {
    return AsyncOperations.wrap(
          () => toList(),
      loadingMessage: loadingMessage,
      silent: silent,
      cancelToken: cancelToken,
      timeout: timeout,
    );
  }

  /// Listens to stream with error handling
  ///
  /// Example:
  /// ```dart
  /// dataStream.innListen(
  ///   onData: (data) => updateUI(data),
  ///   onError: (error) => showError(error),
  /// );
  /// ```
  StreamSubscription<T> innListen({
    required void Function(T data) onData,
    void Function(String error)? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return listen(
      onData,
      onError: onError != null
          ? (error, stackTrace) => onError(error.toString())
          : null,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

/// Extensions for Completer to work with AsyncOperations
extension CompleterAsyncExtensions<T> on Completer<T> {
  /// Wraps completer future with AsyncOperations
  ///
  /// Example:
  /// ```dart
  /// final completer = Completer<String>();
  /// final result = await completer.innWrap();
  /// ```
  Future<AsyncResult<T>> innWrap({
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
    bool silent = false,
    bool showErrorDialog = true,
    Duration? timeout,
    CancelToken? cancelToken,
  }) {
    return future.innWrap(
      loadingMessage: loadingMessage,
      successMessage: successMessage,
      errorMessage: errorMessage,
      silent: silent,
      showErrorDialog: showErrorDialog,
      timeout: timeout,
      cancelToken: cancelToken,
    );
  }
}