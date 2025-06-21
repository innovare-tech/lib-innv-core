// ========================================
// async_config.dart
// ========================================

import 'package:flutter/foundation.dart';

/// Configuration class for async operations
///
/// Controls default behavior like timeouts, retry attempts, logging, etc.
class AsyncConfig {
  /// Default timeout for operations
  final Duration defaultTimeout;

  /// Default number of retry attempts
  final int defaultRetryAttempts;

  /// Delay between retry attempts
  final Duration retryDelay;

  /// Whether to enable logging
  final bool enableLogging;

  /// Default loading message
  final String defaultLoadingMessage;

  /// Maximum delay for exponential backoff
  final Duration maxRetryDelay;

  /// Whether to use exponential backoff for retries
  final bool useExponentialBackoff;

  const AsyncConfig({
    this.defaultTimeout = const Duration(seconds: 30),
    this.defaultRetryAttempts = 0,
    this.retryDelay = const Duration(seconds: 1),
    this.enableLogging = kDebugMode,
    this.defaultLoadingMessage = 'Aguarde...',
    this.maxRetryDelay = const Duration(seconds: 30),
    this.useExponentialBackoff = true,
  });

  /// Creates a development configuration
  factory AsyncConfig.development() {
    return const AsyncConfig(
      defaultTimeout: Duration(seconds: 60), // Longer timeout for debugging
      defaultRetryAttempts: 1,
      retryDelay: Duration(seconds: 2),
      enableLogging: true,
      defaultLoadingMessage: '[DEV] Aguarde...',
    );
  }

  /// Creates a production configuration
  factory AsyncConfig.production() {
    return const AsyncConfig(
      defaultTimeout: Duration(seconds: 30),
      defaultRetryAttempts: 2,
      retryDelay: Duration(seconds: 1),
      enableLogging: false,
      defaultLoadingMessage: 'Aguarde...',
    );
  }

  /// Global instance
  static AsyncConfig instance = const AsyncConfig();

  /// Creates a copy with modified values
  AsyncConfig copyWith({
    Duration? defaultTimeout,
    int? defaultRetryAttempts,
    Duration? retryDelay,
    bool? enableLogging,
    String? defaultLoadingMessage,
    Duration? maxRetryDelay,
    bool? useExponentialBackoff,
  }) {
    return AsyncConfig(
      defaultTimeout: defaultTimeout ?? this.defaultTimeout,
      defaultRetryAttempts: defaultRetryAttempts ?? this.defaultRetryAttempts,
      retryDelay: retryDelay ?? this.retryDelay,
      enableLogging: enableLogging ?? this.enableLogging,
      defaultLoadingMessage: defaultLoadingMessage ?? this.defaultLoadingMessage,
      maxRetryDelay: maxRetryDelay ?? this.maxRetryDelay,
      useExponentialBackoff: useExponentialBackoff ?? this.useExponentialBackoff,
    );
  }
}

/// Interface for managing loading states
///
/// Implement this interface to integrate with your UI loading system
abstract class LoadingManager {
  /// Shows a loading indicator with the given message
  void show(String message);

  /// Dismisses the loading indicator
  void dismiss();

  /// Updates the loading message (optional - implement if supported)
  void updateMessage(String message) {
    // Default implementation does nothing
    // Override if your loading system supports message updates
  }

  /// Shows loading with progress (optional - implement if supported)
  void showWithProgress(String message, double progress) {
    show(message); // Default fallback
  }
}

/// Interface for managing notifications/messages
///
/// Implement this interface to integrate with your notification system
abstract class NotificationManager {
  /// Shows a success notification
  void showSuccess(String message);

  /// Shows an error notification
  void showError(String message);

  /// Shows an info notification
  void showInfo(String message);

  /// Shows a warning notification (optional)
  void showWarning(String message) {
    showInfo(message); // Default fallback
  }
}

/// Interface for tracking operation progress
///
/// Implement this for operations that support progress tracking
abstract class ProgressCallback {
  /// Called when operation progress changes
  ///
  /// [progress] - Value between 0.0 and 1.0
  /// [message] - Optional progress message
  void onProgress(double progress, String? message);
}

/// Simple implementation of ProgressCallback
class SimpleProgressCallback implements ProgressCallback {
  final void Function(double progress, String? message) _onProgressUpdate;

  SimpleProgressCallback(this._onProgressUpdate);

  @override
  void onProgress(double progress, String? message) {
    _onProgressUpdate(progress, message);
  }
}

/// Token for cancelling async operations
///
/// Example:
/// ```dart
/// final cancelToken = CancelToken();
///
/// // Start operation
/// final result = await AsyncOperations.wrap(
///   () => longRunningOperation(),
///   cancelToken: cancelToken,
/// );
///
/// // Cancel if needed
/// cancelToken.cancel();
/// ```
class CancelToken {
  bool _isCancelled = false;
  final List<VoidCallback> _callbacks = [];
  String? _reason;

  /// Whether this token has been cancelled
  bool get isCancelled => _isCancelled;

  /// The reason for cancellation (if any)
  String? get reason => _reason;

  /// Cancels the operation
  ///
  /// [reason] - Optional reason for cancellation
  void cancel([String? reason]) {
    if (_isCancelled) return;

    _isCancelled = true;
    _reason = reason;

    // Notify all callbacks
    for (final callback in _callbacks) {
      try {
        callback();
      } catch (e) {
        // Ignore callback errors
      }
    }
    _callbacks.clear();
  }

  /// Registers a callback to be called when cancelled
  ///
  /// If already cancelled, the callback is called immediately
  void onCancel(VoidCallback callback) {
    if (_isCancelled) {
      callback();
    } else {
      _callbacks.add(callback);
    }
  }

  /// Throws CancellationException if cancelled
  void throwIfCancelled() {
    if (_isCancelled) {
      throw CancellationException(_reason ?? 'Operation was cancelled');
    }
  }

  /// Creates a new token that will be cancelled when this token is cancelled
  CancelToken createChild() {
    final child = CancelToken();
    onCancel(() => child.cancel(_reason));
    return child;
  }
}

/// Exception thrown when an operation is cancelled
class CancellationException implements Exception {
  final String message;

  CancellationException(this.message);

  @override
  String toString() => 'CancellationException: $message';
}

/// Exception for timeout scenarios
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message (timeout: ${timeout.inSeconds}s)';
}

/// Exception for network-related errors
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException(this.message, [this.statusCode]);

  @override
  String toString() => statusCode != null
      ? 'NetworkException: $message (status: $statusCode)'
      : 'NetworkException: $message';
}

/// Exception for validation errors
class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>> fieldErrors;

  ValidationException(this.message, [this.fieldErrors = const {}]);

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception for authentication/authorization errors
class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException([this.message = 'Não autorizado']);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Utility class for creating common exceptions
class AsyncExceptions {
  /// Creates a timeout exception
  static TimeoutException timeout(Duration timeout) =>
      TimeoutException('Operação demorou muito para responder', timeout);

  /// Creates a cancellation exception
  static CancellationException cancelled([String? reason]) =>
      CancellationException(reason ?? 'Operação cancelada');

  /// Creates a network exception
  static NetworkException network(String message, [int? statusCode]) =>
      NetworkException(message, statusCode);

  /// Creates a validation exception
  static ValidationException validation(String message, [Map<String, List<String>>? fieldErrors]) =>
      ValidationException(message, fieldErrors ?? {});

  /// Creates an unauthorized exception
  static UnauthorizedException unauthorized([String? message]) =>
      UnauthorizedException(message ?? 'Não autorizado');
}

/// Enum for different retry strategies
enum RetryStrategy {
  /// Fixed delay between retries
  fixed,

  /// Exponential backoff (delay doubles each time)
  exponentialBackoff,

  /// Linear backoff (delay increases linearly)
  linearBackoff,
}

/// Configuration for retry behavior
class RetryConfig {
  /// Maximum number of retry attempts
  final int maxAttempts;

  /// Base delay between retries
  final Duration baseDelay;

  /// Maximum delay between retries
  final Duration maxDelay;

  /// Retry strategy to use
  final RetryStrategy strategy;

  /// Function to determine if an exception should trigger a retry
  final bool Function(Exception)? retryWhen;

  const RetryConfig({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.strategy = RetryStrategy.exponentialBackoff,
    this.retryWhen,
  });

  /// Creates retry config for network operations
  factory RetryConfig.network() {
    return RetryConfig(
      maxAttempts: 3,
      baseDelay: Duration(seconds: 1),
      strategy: RetryStrategy.exponentialBackoff,
      retryWhen: (exception) =>
      exception is NetworkException ||
          exception is TimeoutException,
    );
  }

  /// Creates retry config for auth operations
  factory RetryConfig.auth() {
    return RetryConfig(
      maxAttempts: 1, // Usually don't retry auth failures
      baseDelay: Duration(seconds: 1),
      retryWhen: (exception) => exception is NetworkException,
    );
  }

  /// Calculates delay for given attempt number
  Duration calculateDelay(int attemptNumber) {
    switch (strategy) {
      case RetryStrategy.fixed:
        return baseDelay;

      case RetryStrategy.exponentialBackoff:
        final delay = baseDelay * (1 << (attemptNumber - 1)); // 2^(attempt-1)
        return delay < maxDelay ? delay : maxDelay;

      case RetryStrategy.linearBackoff:
        final delay = baseDelay * attemptNumber;
        return delay < maxDelay ? delay : maxDelay;
    }
  }

  /// Checks if the exception should trigger a retry
  bool shouldRetry(Exception exception) {
    return retryWhen?.call(exception) ?? true;
  }
}