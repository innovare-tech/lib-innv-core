import 'package:innovare_core/innovare_core.dart';
import 'package:logger/logger.dart';

class AsyncWrapperResponse<T> {
  final T? data;
  final String? message;
  final bool success;

  AsyncWrapperResponse({
    required this.data,
    required this.message,
    required this.success,
  });

  void onSuccess(void Function(T? data) onSuccess) {
    if (success) {
      onSuccess(data);
    }
  }
}

extension AsyncWrapperResponseExtension<T> on Future<AsyncWrapperResponse<T>> {
  void onSuccess(void Function(T? data) onSuccess) {
    then((response) {
      if (response.success) {
        onSuccess(response.data);
      }
    });
  }

  void onError(void Function(String? message) onError) {
    then((response) {
      if (!response.success) {
        onError(response.message);
      }
    });
  }
}

Future<AsyncWrapperResponse<T>> asyncWrapper<T>(
  Future<T> Function() asyncFunction, {
  String loadingMessage = 'Aguarde...',
  String? successMessage,
  String? errorMessage,
  bool silent = false,
  bool showErrorDialog = true,
}) async {
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