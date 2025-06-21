// ========================================
// InnovareCore Library
// ========================================

library innovare_core;

// ========================================
// CORE IMPORTS (needed for the library to work)
// ========================================
import 'package:flutter/foundation.dart';
import 'package:innovare_core/src/async/async_config.dart';
import 'package:innovare_core/src/async/async_operations.dart';
import 'package:innovare_core/src/async/async_result.dart';

// ========================================
// ASYNC MODULE (New Implementation)
// ========================================
export 'src/async/async_operations.dart';
export 'src/async/async_result.dart';
export 'src/async/async_config.dart';
export 'src/async/extensions.dart';

// ========================================
// EXTENSIONS
// ========================================
export 'extensions/bool_extensions.dart';
export 'extensions/color_extensions.dart';
export 'extensions/datetime_extensions.dart';
export 'extensions/dynamic_extensions.dart';
export 'extensions/file_data_extensions.dart';
export 'extensions/form_extensions.dart';
export 'extensions/generic_extensions.dart';
export 'extensions/http_response_extensions.dart';
export 'extensions/int_extensions.dart';
export 'extensions/map_extensions.dart';
export 'extensions/num_extensions.dart';
export 'extensions/response_data_extensions.dart';
export 'extensions/string_extensions.dart';
export 'extensions/text_editing_controller_extensions.dart';
export 'extensions/widget_extensions.dart';

// ========================================
// DATA LAYER
// ========================================

// Errors
export 'data/errors/rest_error.dart';
export 'data/errors/unknown_rest_error.dart';

// Core Data
export 'data/auth_manager.dart';
export 'data/paginated_response_dto.dart';
export 'data/resource_dto.dart';
export 'data/rest_connect.dart';
export 'data/rest_context.dart';
export 'data/rest_options.dart';
export 'data/upload_resource_dto.dart';

// ========================================
// UI COMPONENTS
// ========================================
export 'dialogs/dialogs.dart';
export 'src/innovare_logo/innovare_logo.dart';

// ========================================
// COMMONS & UTILITIES
// ========================================
export 'commons/mapper.dart';
export 'utils/form_validators.dart';

// ========================================
// DEPRECATED (Will be removed in v2.0.0)
// ========================================

/// **DEPRECATED**: Use AsyncOperations instead
/// This export will be removed in v2.0.0
@Deprecated('Use AsyncOperations instead. Will be removed in v2.0.0')
export 'utils/async_utils.dart';

// ========================================
// INNOVARE CORE CLASS
// ========================================

/// Main class providing access to all InnovareCore modules
///
/// Usage:
/// ```dart
/// // Setup (once in your app)
/// InnovareCore.Operations.configure(
///   loadingManager: YourLoadingManager(),
///   notificationManager: YourNotificationManager(),
/// );
///
/// // Usage
/// final result = await InnovareCore.Operations.wrap(() => apiCall());
///
/// // Or using aliases
/// final result = await InnOps.wrap(() => apiCall());
/// ```
class InnovareCore {
  // Private constructor to prevent instantiation
  InnovareCore._();

  /// Access to async operations module
  ///
  /// Example:
  /// ```dart
  /// final result = await InnovareCore.Operations.wrap(() => apiCall());
  /// ```
  static AsyncOperations get Operations => AsyncOperations();

  /// Alias for Operations (same functionality)
  ///
  /// Example:
  /// ```dart
  /// final result = await InnovareCore.Async.wrap(() => apiCall());
  /// ```
  static AsyncOperations get Async => AsyncOperations();

  /// Get library version
  static String get version => '1.0.0';

  /// Get library name
  static String get name => 'InnovareCore';

  /// Check if library is configured properly
  static bool get isConfigured {
    try {
      AsyncOperations.executor;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Quick setup method for common configurations
  ///
  /// Example:
  /// ```dart
  /// InnovareCore.quickSetup(
  ///   loadingManager: DialogsLoadingManager(),
  ///   notificationManager: DialogsNotificationManager(),
  /// );
  /// ```
  static void quickSetup({
    required LoadingManager loadingManager,
    required NotificationManager notificationManager,
    void Function(String, Object, StackTrace?)? logger,
    AsyncConfig? config,
  }) {
    AsyncOperations.configure(
      loadingManager: loadingManager,
      notificationManager: notificationManager,
      logger: logger,
      config: config,
    );
  }

  /// Reset library state (useful for testing)
  static void reset() {
    AsyncOperations.reset();
  }

// Future modules can be added here:
// static CacheManager get Cache => CacheManager();
// static AuthManager get Auth => AuthManager();
// static UIHelpers get UI => UIHelpers();
}

// ========================================
// GLOBAL ALIASES
// ========================================

/// Short alias for AsyncOperations - focused on operations
///
/// Example:
/// ```dart
/// final result = await InnOps.wrap(() => apiCall());
/// ```
typedef InnOps = AsyncOperations;

/// Short alias for AsyncOperations - focused on async
///
/// Example:
/// ```dart
/// final result = await InnAsync.wrap(() => apiCall());
/// ```
typedef InnAsync = AsyncOperations;

/// Short alias for AsyncOperations - focused on safety
///
/// Example:
/// ```dart
/// final result = await InnSafe.safe(() => apiCall());
/// ```
typedef InnSafe = AsyncOperations;

// ========================================
// CONVENIENCE FUNCTIONS
// ========================================

/// Global convenience function for quick async operations
///
/// Example:
/// ```dart
/// final result = await innWrap(() => apiCall());
/// ```
Future<AsyncResult<T>> innWrap<T>(
    Future<T> Function() operation, {
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
    operation,
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

/// Global convenience function for safe async operations
///
/// Example:
/// ```dart
/// final result = await innSafe(() => riskyOperation());
/// ```
Future<AsyncResult<T>> innSafe<T>(
    Future<T> Function() operation, {
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
    }) {
  return AsyncOperations.safe(
    operation,
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
}

// ========================================
// LIBRARY INFORMATION
// ========================================

/// Shows library information and setup status
void showInnovareCoreInfo() {
  if (kDebugMode) {
    print('''
📦 InnovareCore v${InnovareCore.version}
   Status: ${InnovareCore.isConfigured ? '✅ Configured' : '❌ Not Configured'}
   
   ${InnovareCore.isConfigured ? '''
   Available modules:
   • AsyncOperations (InnOps, InnAsync, InnSafe)
   • Extensions
   • REST utilities
   • UI Components
   ''' : '''
   Setup required:
   InnovareCore.quickSetup(
     loadingManager: YourLoadingManager(),
     notificationManager: YourNotificationManager(),
   );
   '''}
   
   📚 Documentation: [your docs link]
    ''');
  }
}

// ========================================
// AUTO-INITIALIZATION CHECK
// ========================================

void _checkInitialization() {
  if (kDebugMode && !InnovareCore.isConfigured) {
    print('''
⚠️  InnovareCore not configured!
   
   Add this to your main.dart:
   
   InnovareCore.quickSetup(
     loadingManager: DialogsLoadingManager(),
     notificationManager: DialogsNotificationManager(),
   );
    ''');
  }
}

// Show initialization check when library is imported
final _initCheck = _checkInitialization();