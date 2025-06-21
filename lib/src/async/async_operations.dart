// ========================================
// async_operations.dart
// ========================================

import 'dart:async';
import 'package:innovare_core/data/errors/rest_error.dart';

import 'async_result.dart';
import 'async_config.dart';

/// Core class for executing async operations with enhanced error handling,
/// retry logic, timeout, cancellation, and loading management
class AsyncOperations {
  static AsyncExecutor? _executor;

  /// Configures the global AsyncOperations instance
  ///
  /// Must be called once before using any async operations
  ///
  /// Example:
  /// ```dart
  /// AsyncOperations.configure(
  ///   loadingManager: DialogsLoadingManager(),
  ///   notificationManager: DialogsNotificationManager(),
  ///   logger: (message, error, stackTrace) => Logger().e(message, error: error, stackTrace: stackTrace),
  ///   config: AsyncConfig.production(),
  /// );
  /// ```
  static void configure({
    required LoadingManager loadingManager,
    required NotificationManager notificationManager,
    void Function(String message, Object error, StackTrace? stackTrace)? logger,
    AsyncConfig? config,
  }) {
    _executor = AsyncExecutor(
      loadingManager: loadingManager,
      notificationManager: notificationManager,
      logger: logger,
    );

    if (config != null) {
      AsyncConfig.instance = config;
    }
  }

  /// Gets the configured executor instance
  static AsyncExecutor get executor {
    if (_executor == null) {
      throw StateError(
          'AsyncOperations not configured. '
              'Call AsyncOperations.configure() first in your app initialization.'
      );
    }
    return _executor!;
  }

  /// Wraps an async operation with comprehensive error handling and features
  ///
  /// This is the main method for executing async operations safely.
  ///
  /// Example:
  /// ```dart
  /// final result = await AsyncOperations.wrap(
  ///   () => apiService.login(email, password),
  ///   loadingMessage: "Fazendo login...",
  ///   timeout: Duration(seconds: 15),
  ///   retryAttempts: 2,
  /// );
  ///
  /// result.when(
  ///   success: (user) => navigateToHome(user),
  ///   failure: (error, exception) => showError(error),
  /// );
  /// ```
  static Future<AsyncResult<T>> wrap<T>(
      Future<T> Function() operation, {
        String? loadingMessage,
        String? successMessage,
        String? errorMessage,
        bool silent = false,
        bool showErrorDialog = true,
        int? retryAttempts,
        Duration? retryDelay,
        Duration? timeout,
        ProgressCallback? progressCallback,
        CancelToken? cancelToken,
        bool Function(Exception)? retryWhen,
        RetryConfig? retryConfig,
      }) {
    return executor.execute(
      operation,
      loadingMessage: loadingMessage,
      successMessage: successMessage,
      errorMessage: errorMessage,
      silent: silent,
      showErrorDialog: showErrorDialog,
      retryAttempts: retryAttempts,
      retryDelay: retryDelay,
      timeout: timeout,
      progressCallback: progressCallback,
      cancelToken: cancelToken,
      retryWhen: retryWhen,
      retryConfig: retryConfig,
    );
  }

  /// Alias for wrap() with safety emphasis
  ///
  /// Same functionality as wrap(), but emphasizes the safety aspect
  ///
  /// Example:
  /// ```dart
  /// final result = await AsyncOperations.safe(() => riskyOperation());
  /// ```
  static Future<AsyncResult<T>> safe<T>(
      Future<T> Function() operation, {
        String? loadingMessage,
        String? successMessage,
        String? errorMessage,
        bool silent = false,
        bool showErrorDialog = true,
        int? retryAttempts,
        Duration? retryDelay,
        Duration? timeout,
        ProgressCallback? progressCallback,
        CancelToken? cancelToken,
        bool Function(Exception)? retryWhen,
        RetryConfig? retryConfig,
      }) => wrap(
    operation,
    loadingMessage: loadingMessage,
    successMessage: successMessage,
    errorMessage: errorMessage,
    silent: silent,
    showErrorDialog: showErrorDialog,
    retryAttempts: retryAttempts,
    retryDelay: retryDelay,
    timeout: timeout,
    progressCallback: progressCallback,
    cancelToken: cancelToken,
    retryWhen: retryWhen,
    retryConfig: retryConfig,
  );

  /// Alias for wrap() with execution emphasis
  ///
  /// Example:
  /// ```dart
  /// final result = await AsyncOperations.run(() => backgroundTask());
  /// ```
  static Future<AsyncResult<T>> run<T>(
      Future<T> Function() operation, {
        String? loadingMessage,
        String? successMessage,
        String? errorMessage,
        bool silent = false,
        bool showErrorDialog = true,
        int? retryAttempts,
        Duration? retryDelay,
        Duration? timeout,
        ProgressCallback? progressCallback,
        CancelToken? cancelToken,
        bool Function(Exception)? retryWhen,
        RetryConfig? retryConfig,
      }) => wrap(
    operation,
    loadingMessage: loadingMessage,
    successMessage: successMessage,
    errorMessage: errorMessage,
    silent: silent,
    showErrorDialog: showErrorDialog,
    retryAttempts: retryAttempts,
    retryDelay: retryDelay,
    timeout: timeout,
    progressCallback: progressCallback,
    cancelToken: cancelToken,
    retryWhen: retryWhen,
    retryConfig: retryConfig,
  );

  /// Executes operation silently (no loading dialog, no error dialog)
  ///
  /// Useful for background operations
  ///
  /// Example:
  /// ```dart
  /// final result = await AsyncOperations.silent(() => backgroundSync());
  /// ```
  static Future<AsyncResult<T>> silent<T>(
      Future<T> Function() operation, {
        String? errorMessage,
        int? retryAttempts,
        Duration? retryDelay,
        Duration? timeout,
        CancelToken? cancelToken,
        bool Function(Exception)? retryWhen,
        RetryConfig? retryConfig,
      }) => wrap(
    operation,
    silent: true,
    showErrorDialog: false,
    errorMessage: errorMessage,
    retryAttempts: retryAttempts,
    retryDelay: retryDelay,
    timeout: timeout,
    cancelToken: cancelToken,
    retryWhen: retryWhen,
    retryConfig: retryConfig,
  );

  /// Executes operation with network-optimized retry settings
  ///
  /// Example:
  /// ```dart
  /// final result = await AsyncOperations.network(() => apiCall());
  /// ```
  static Future<AsyncResult<T>> network<T>(
      Future<T> Function() operation, {
        String? loadingMessage,
        String? successMessage,
        String? errorMessage,
        bool silent = false,
        bool showErrorDialog = true,
        Duration? timeout,
        ProgressCallback? progressCallback,
        CancelToken? cancelToken,
      }) => wrap(
    operation,
    loadingMessage: loadingMessage,
    successMessage: successMessage,
    errorMessage: errorMessage,
    silent: silent,
    showErrorDialog: showErrorDialog,
    timeout: timeout,
    progressCallback: progressCallback,
    cancelToken: cancelToken,
    retryConfig: RetryConfig.network(),
  );

  /// Executes multiple operations in parallel and combines results
  ///
  /// Example:
  /// ```dart
  /// final results = await AsyncOperations.parallel([
  ///   () => getUser(),
  ///   () => getPosts(),
  ///   () => getNotifications(),
  /// ]);
  /// ```
  static Future<AsyncResult<List<T>>> parallel<T>(
      List<Future<T> Function()> operations, {
        String? loadingMessage,
        bool silent = false,
        CancelToken? cancelToken,
        int? maxConcurrency,
      }) async {
    return wrap(
          () async {
        if (maxConcurrency != null && maxConcurrency > 0) {
          // Limited concurrency
          final results = <T>[];
          for (int i = 0; i < operations.length; i += maxConcurrency) {
            final batch = operations.skip(i).take(maxConcurrency);
            final batchResults = await Future.wait(
              batch.map((op) => op()),
            );
            results.addAll(batchResults);

            // Check for cancellation between batches
            cancelToken?.throwIfCancelled();
          }
          return results;
        } else {
          // Unlimited concurrency
          return await Future.wait(
            operations.map((op) => op()),
          );
        }
      },
      loadingMessage: loadingMessage,
      silent: silent,
      cancelToken: cancelToken,
    );
  }

  /// Executes operations in sequence (one after another)
  ///
  /// Example:
  /// ```dart
  /// final results = await AsyncOperations.sequence([
  ///   () => step1(),
  ///   () => step2(),
  ///   () => step3(),
  /// ]);
  /// ```
  static Future<AsyncResult<List<T>>> sequence<T>(
      List<Future<T> Function()> operations, {
        String? loadingMessage,
        bool silent = false,
        CancelToken? cancelToken,
        ProgressCallback? progressCallback,
      }) async {
    return wrap(
          () async {
        final results = <T>[];

        for (int i = 0; i < operations.length; i++) {
          cancelToken?.throwIfCancelled();

          progressCallback?.onProgress(
            i / operations.length,
            'Executando ${i + 1}/${operations.length}',
          );

          final result = await operations[i]();
          results.add(result);
        }

        progressCallback?.onProgress(1.0, 'Concluído');
        return results;
      },
      loadingMessage: loadingMessage,
      silent: silent,
      cancelToken: cancelToken,
    );
  }

  /// Creates a delay operation
  ///
  /// Example:
  /// ```dart
  /// await AsyncOperations.delay(Duration(seconds: 2));
  /// ```
  static Future<AsyncResult<void>> delay(
      Duration duration, {
        CancelToken? cancelToken,
        String? message,
      }) {
    return wrap(
          () async {
        final completer = Completer<void>();

        final timer = Timer(duration, () {
          if (!completer.isCompleted) {
            completer.complete();
          }
        });

        cancelToken?.onCancel(() {
          timer.cancel();
          if (!completer.isCompleted) {
            completer.completeError(CancellationException('Delay cancelled'));
          }
        });

        return completer.future;
      },
      silent: true,
      loadingMessage: message,
    );
  }

  /// Gets the current configuration
  static AsyncConfig get config => AsyncConfig.instance;

  /// Updates the global configuration
  static void updateConfig(AsyncConfig config) {
    AsyncConfig.instance = config;
  }

  /// Resets the AsyncOperations instance (useful for testing)
  static void reset() {
    _executor = null;
    AsyncConfig.instance = const AsyncConfig();
  }
}

/// Internal executor class that handles the actual operation execution
class AsyncExecutor {
  final LoadingManager? loadingManager;
  final NotificationManager? notificationManager;
  final void Function(String message, Object error, StackTrace? stackTrace)? logger;

  const AsyncExecutor({
    this.loadingManager,
    this.notificationManager,
    this.logger,
  });

  /// Executes an operation with all the enhanced features
  Future<AsyncResult<T>> execute<T>(
      Future<T> Function() operation, {
        String? loadingMessage,
        String? successMessage,
        String? errorMessage,
        bool silent = false,
        bool showErrorDialog = true,
        int? retryAttempts,
        Duration? retryDelay,
        Duration? timeout,
        ProgressCallback? progressCallback,
        CancelToken? cancelToken,
        bool Function(Exception)? retryWhen,
        RetryConfig? retryConfig,
      }) async {
    final config = AsyncConfig.instance;

    // Determine retry configuration
    final effectiveRetryConfig = retryConfig ?? RetryConfig(
      maxAttempts: retryAttempts ?? config.defaultRetryAttempts,
      baseDelay: retryDelay ?? config.retryDelay,
      retryWhen: retryWhen,
    );

    final effectiveTimeout = timeout ?? config.defaultTimeout;

    // Show loading if not silent
    if (!silent && loadingManager != null) {
      loadingManager!.show(loadingMessage ?? config.defaultLoadingMessage);
    }

    try {
      T result;

      // Execute with retry if configured
      if (effectiveRetryConfig.maxAttempts > 0) {
        result = await _executeWithRetry(
          operation,
          effectiveRetryConfig,
          cancelToken,
          progressCallback,
        );
      } else {
        result = await operation();
      }

      // Apply timeout if specified
      if (effectiveTimeout != Duration.zero) {
        result = await _applyTimeout(result, effectiveTimeout, cancelToken);
      }

      // Success handling
      if (!silent && successMessage != null && notificationManager != null) {
        notificationManager!.showSuccess(successMessage);
      }

      return AsyncSuccess(result);

    } catch (e, stackTrace) {
      // Error handling
      final errorMsg = _extractErrorMessage(e, errorMessage);

      if (showErrorDialog && notificationManager != null && !silent) {
        notificationManager!.showError(errorMsg);
      }

      if (logger != null && config.enableLogging) {
        logger!(errorMsg, e, stackTrace);
      }

      return AsyncFailure<T>(
        errorMsg,
        e is Exception ? e : Exception(e.toString()),
        stackTrace,
      );

    } finally {
      if (!silent && loadingManager != null) {
        loadingManager!.dismiss();
      }
    }
  }

  /// Executes operation with retry logic
  Future<T> _executeWithRetry<T>(
      Future<T> Function() operation,
      RetryConfig retryConfig,
      CancelToken? cancelToken,
      ProgressCallback? progressCallback,
      ) async {
    int attempt = 0;
    Exception? lastException;

    while (attempt < retryConfig.maxAttempts) {
      // Check for cancellation
      cancelToken?.throwIfCancelled();

      try {
        // Report progress
        progressCallback?.onProgress(
          attempt / retryConfig.maxAttempts,
          'Tentativa ${attempt + 1}/${retryConfig.maxAttempts}',
        );

        return await operation();

      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempt++;

        // Check if we should retry this exception
        if (!retryConfig.shouldRetry(lastException)) {
          rethrow;
        }

        // If this was the last attempt, don't delay
        if (attempt >= retryConfig.maxAttempts) {
          rethrow;
        }

        // Wait before retrying
        final delay = retryConfig.calculateDelay(attempt);
        await Future.delayed(delay);
      }
    }

    // This should never be reached, but just in case
    throw lastException ?? Exception('Max retry attempts exceeded');
  }

  /// Applies timeout to a result (if result is already computed, returns it immediately)
  Future<T> _applyTimeout<T>(T result, Duration timeout, CancelToken? cancelToken) async {
    if (timeout == Duration.zero) return result;

    return await Future.any([
      Future.value(result),
      Future.delayed(timeout).then((_) =>
      throw TimeoutException('Operation timed out', timeout)
      ),
      if (cancelToken != null)
        Future.any([
          Stream.fromFuture(Future.delayed(Duration(days: 365))).listen(null).asFuture(),
        ]).then((_) => throw CancellationException('Operation was cancelled')),
    ]);
  }

  /// Extracts a user-friendly error message from various exception types
  String _extractErrorMessage(dynamic error, String? fallbackMessage) {
    if (fallbackMessage != null) return fallbackMessage;

    if (error is TimeoutException) {
      return 'A operação demorou muito para responder. Tente novamente.';
    }

    if (error is CancellationException) {
      return 'Operação cancelada';
    }

    if (error is NetworkException) {
      return error.statusCode != null
          ? 'Erro de rede (${error.statusCode}): ${error.message}'
          : 'Erro de rede: ${error.message}';
    }

    if (error is UnauthorizedException) {
      return 'Acesso não autorizado. Faça login novamente.';
    }

    if (error is ValidationException) {
      return error.message;
    }

    if (error is RestError) {
      return (error.message as String?) ?? 'Erro desconhecido na requisição: ${error.response.statusCode}';
    }

    return error.toString();
  }
}