// ========================================
// async_utils.dart - DEPRECATED
// ========================================

import 'package:flutter/foundation.dart';
import 'package:innovare_core/innovare_core.dart';
import 'package:logger/logger.dart';

/// **DEPRECATED**: Use AsyncOperations.wrap() instead
/// 
/// This class is deprecated and will be removed in a future version.
/// 
/// Migration guide:
/// ```dart
/// // OLD:
/// asyncWrapper(() => apiCall()).onSuccess((data) => {});
/// 
/// // NEW:
/// final result = await AsyncOperations.wrap(() => apiCall());
/// result.when(
///   success: (data) => {},
///   failure: (error, exception) => {},
/// );
/// 
/// // OR with extensions:
/// await apiCall().innWrap().onSuccess((data) => {});
/// ```
@Deprecated(
    'Use AsyncOperations.wrap() instead. '
        'This class will be removed in v2.0.0. '
        'See migration guide in documentation.'
)
class AsyncWrapperResponse<T> {
  final T? data;
  final String? message;
  final bool success;

  /// **DEPRECATED**: Use AsyncResult<T> instead
  @Deprecated('Use AsyncResult<T> instead')
  AsyncWrapperResponse({
    required this.data,
    required this.message,
    required this.success,
  });

  /// **DEPRECATED**: Use AsyncResult.when() instead
  /// 
  /// Migration:
  /// ```dart
  /// // OLD:
  /// response.onSuccess((data) => {});
  /// 
  /// // NEW:
  /// result.when(
  ///   success: (data) => {},
  ///   failure: (error, exception) => {},
  /// );
  /// ```
  @Deprecated('Use AsyncResult.when() instead')
  void onSuccess(void Function(T? data) onSuccess) {
    if (success) {
      onSuccess(data);
    }
  }

  /// Converts this deprecated response to the new AsyncResult
  /// 
  /// This method helps with gradual migration
  AsyncResult<T> toAsyncResult() {
    if (success && data != null) {
      return AsyncSuccess(data!);
    } else {
      return AsyncFailure<T>(message ?? 'Unknown error');
    }
  }
}

/// **DEPRECATED**: Use AsyncOperations.wrap() extensions instead
/// 
/// Migration guide:
/// ```dart
/// // OLD:
/// asyncWrapper(() => apiCall())
///   .onSuccess((data) => {})
///   .onError((error) => {});
/// 
/// // NEW:
/// await AsyncOperations.wrap(() => apiCall())
///   .onSuccess((data) => {})
///   .onFailure((error, exception) => {});
/// ```
@Deprecated(
    'Use AsyncOperations.wrap() with extensions instead. '
        'This extension will be removed in v2.0.0.'
)
extension AsyncWrapperResponseExtension<T> on Future<AsyncWrapperResponse<T>> {
  /// **DEPRECATED**: Use AsyncResult.onSuccess() instead
  @Deprecated('Use AsyncResult.onSuccess() instead')
  void onSuccess(void Function(T? data) onSuccess) {
    then((response) {
      if (response.success) {
        onSuccess(response.data);
      }
    });
  }

  /// **DEPRECATED**: Use AsyncResult.onFailure() instead
  @Deprecated('Use AsyncResult.onFailure() instead')
  void onError(void Function(String? message) onError) {
    then((response) {
      if (!response.success) {
        onError(response.message);
      }
    });
  }

  /// Converts this deprecated Future<AsyncWrapperResponse> to Future<AsyncResult>
  /// 
  /// This method helps with gradual migration
  Future<AsyncResult<T>> toAsyncResult() async {
    final response = await this;
    return response.toAsyncResult();
  }
}

/// **DEPRECATED**: Use AsyncOperations.wrap() instead
/// 
/// This function is deprecated and will be removed in a future version.
/// Please migrate to the new AsyncOperations.wrap() method.
/// 
/// ## Migration Examples:
/// 
/// ### Basic Usage:
/// ```dart
/// // OLD:
/// final result = await asyncWrapper(() => apiCall());
/// 
/// // NEW:
/// final result = await AsyncOperations.wrap(() => apiCall());
/// ```
/// 
/// ### With Success Callback:
/// ```dart
/// // OLD:
/// asyncWrapper(() => apiCall()).onSuccess((data) => {
///   // handle success
/// });
/// 
/// // NEW:
/// await AsyncOperations.wrap(() => apiCall()).onSuccess((data) => {
///   // handle success - data is never null here!
/// });
/// ```
/// 
/// ### With Error Handling:
/// ```dart
/// // OLD:
/// asyncWrapper(() => apiCall())
///   .onSuccess((data) => {})
///   .onError((error) => {});
/// 
/// // NEW:
/// await AsyncOperations.wrap(() => apiCall())
///   .onSuccess((data) => {})
///   .onFailure((error, exception) => {});
/// ```
/// 
/// ### Pattern Matching (Recommended):
/// ```dart
/// // NEW APPROACH:
/// final result = await AsyncOperations.wrap(() => apiCall());
/// result.when(
///   success: (data) => {
///     // handle success - data is guaranteed non-null
///   },
///   failure: (error, exception) => {
///     // handle error - error is guaranteed non-null
///   },
/// );
/// ```
/// 
/// ### Extension Usage:
/// ```dart
/// // NEW WITH EXTENSIONS:
/// await apiCall().innWrap(
///   loadingMessage: "Loading...",
///   retryAttempts: 2,
/// ).onSuccess((data) => {});
/// ```
/// 
/// ## Benefits of New Implementation:
/// - ✅ Type-safe (no nullable confusion)
/// - ✅ Retry with exponential backoff
/// - ✅ Timeout support
/// - ✅ Cancellation support
/// - ✅ Better error handling
/// - ✅ Dependency injection (testable)
/// - ✅ Progress tracking
/// - ✅ Multiple operation patterns (parallel, sequence)
@Deprecated(
    'Use AsyncOperations.wrap() instead. '
        'This function will be removed in v2.0.0. '
        'See migration guide in documentation.'
)
Future<AsyncWrapperResponse<T>> asyncWrapper<T>(
    Future<T> Function() asyncFunction, {
      String loadingMessage = 'Aguarde...',
      String? successMessage,
      String? errorMessage,
      bool silent = false,
      bool showErrorDialog = true,
    }) async {
  // Show deprecation warning in debug mode
  if (kDebugMode) {
    print('⚠️  DEPRECATION WARNING: asyncWrapper() is deprecated. '
        'Use AsyncOperations.wrap() instead. '
        'See migration guide in documentation.');
  }

  silent.ifFalse(() {
    Dialogs.loading().show(loadingMessage);
  });

  try {
    final response = await asyncFunction();

    if (!silent && successMessage != null) {
      Dialogs.notification().success(successMessage);
    }

    return AsyncWrapperResponse(data: response, message: null, success: true);
  } catch (e, stackTrace) {
    String? message = errorMessage;

    if (e is RestError) {
      message = e.message as String?;
    }

    showErrorDialog.ifTrue(() {
      Dialogs.notification().error(message ?? e.toString());
    });

    Logger().e(
        message,
        error: e,
        stackTrace: stackTrace
    );

    return AsyncWrapperResponse(data: null, message: message, success: false);
  } finally {
    Dialogs.loading().dismiss();
  }
}

// ========================================
// MIGRATION HELPERS
// ========================================

/// Helper class to assist with migration from asyncWrapper to AsyncOperations
class AsyncMigrationHelper {
  /// Converts asyncWrapper call to new AsyncOperations.wrap call
  /// 
  /// This is a temporary helper to ease migration
  @Deprecated('Use AsyncOperations.wrap() directly instead')
  static Future<AsyncResult<T>> migrateAsyncWrapper<T>(
      Future<T> Function() asyncFunction, {
        String loadingMessage = 'Aguarde...',
        String? successMessage,
        String? errorMessage,
        bool silent = false,
        bool showErrorDialog = true,
      }) {
    return AsyncOperations.wrap(
      asyncFunction,
      loadingMessage: loadingMessage,
      successMessage: successMessage,
      errorMessage: errorMessage,
      silent: silent,
      showErrorDialog: showErrorDialog,
    );
  }

  /// Shows migration examples for common patterns
  static void showMigrationExamples() {
    if (kDebugMode) {
      print('''
🔄 AsyncWrapper Migration Examples:

1. Basic usage:
   OLD: asyncWrapper(() => apiCall())
   NEW: AsyncOperations.wrap(() => apiCall())

2. With callbacks:
   OLD: asyncWrapper(() => apiCall()).onSuccess((data) => {})
   NEW: await AsyncOperations.wrap(() => apiCall()).onSuccess((data) => {})

3. Pattern matching (recommended):
   NEW: 
   final result = await AsyncOperations.wrap(() => apiCall());
   result.when(
     success: (data) => {},
     failure: (error, exception) => {},
   );

4. Extension usage:
   NEW: await apiCall().innWrap().onSuccess((data) => {})

📚 Full documentation: [link to your docs]
      ''');
    }
  }
}

// ========================================
// BACKWARD COMPATIBILITY EXTENSIONS
// ========================================

/// Extension to help migrate existing code gradually
extension AsyncWrapperMigrationExtensions<T> on Future<T> {
  /// **DEPRECATED**: Use innWrap() instead
  /// 
  /// Temporary method to help with migration
  @Deprecated('Use innWrap() instead')
  Future<AsyncWrapperResponse<T>> asyncWrap({
    String loadingMessage = 'Aguarde...',
    String? successMessage,
    String? errorMessage,
    bool silent = false,
    bool showErrorDialog = true,
  }) {
    return asyncWrapper(
          () => this,
      loadingMessage: loadingMessage,
      successMessage: successMessage,
      errorMessage: errorMessage,
      silent: silent,
      showErrorDialog: showErrorDialog,
    );
  }

  /// Migration helper that returns new AsyncResult
  /// 
  /// Use this as a stepping stone to migrate to AsyncOperations
  Future<AsyncResult<T>> migrateToAsyncResult({
    String loadingMessage = 'Aguarde...',
    String? successMessage,
    String? errorMessage,
    bool silent = false,
    bool showErrorDialog = true,
  }) {
    return AsyncMigrationHelper.migrateAsyncWrapper(
          () => this,
      loadingMessage: loadingMessage,
      successMessage: successMessage,
      errorMessage: errorMessage,
      silent: silent,
      showErrorDialog: showErrorDialog,
    );
  }
}

// ========================================
// DEPRECATION NOTICES
// ========================================

/// Shows deprecation notice when importing this file
void _showDeprecationNotice() {
  if (kDebugMode) {
    print('''
⚠️  DEPRECATION NOTICE:
   async_utils.dart is deprecated and will be removed in v2.0.0
   
   Please migrate to AsyncOperations:
   - More type-safe
   - Better error handling  
   - Retry & timeout support
   - Cancellation support
   - Dependency injection
   
   Quick migration:
   asyncWrapper(() => call()) → AsyncOperations.wrap(() => call())
   
   📚 Migration guide: [your documentation link]
    ''');
  }
}

// Show notice when file is imported
final _deprecationNotice = _showDeprecationNotice();