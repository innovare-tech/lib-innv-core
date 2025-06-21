  import 'package:adaptive_dialog/adaptive_dialog.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_easyloading/flutter_easyloading.dart';
  import 'package:get/get.dart';
  import 'package:innovare_core/extensions/string_extensions.dart';
  import 'package:toastification/toastification.dart';

  abstract class Dialogs {
    static Loading loading() => Loading();
    static Notification notification() => Notification();
    static Custom custom() => Custom();
    static Confirmation confirmation() => Confirmation();
  }

  class Custom {
    Future<T?> show<T>(
      Widget widget, {
        bool barrierDismissible = true
      }) async {
      return await Get.dialog(
        widget,
        barrierDismissible: barrierDismissible,
      );
    }
  }

  class Loading {
    Future<void> show(String message) async {
      EasyLoading.show(status: message);
    }

    void dismiss() {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  class Notification {

    void success(
      String message, {
      String? title,
    }) {
      _internalShow(
        message: message,
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
      );
    }

    void error(
      String message, {
      String? title,
    }) {
      _internalShow(
        message: message,
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored
      );
    }

    void warning(
      String message, {
      String? title,
    }) {
      _internalShow(
        message: message,
        type: ToastificationType.warning,
        style: ToastificationStyle.fillColored
      );
    }

    void info(
      String message, {
      String? title,
    }) {
      _internalShow(
        message: message,
        type: ToastificationType.info,
        style: ToastificationStyle.fillColored
      );
    }

    void _internalShow({
      String? title,
      required String message,
      ToastificationType? type,
      ToastificationStyle? style,
      Alignment? alignment,
      Duration? autoCloseDuration = const Duration(seconds: 3),
      BorderRadiusGeometry? borderRadius,
      bool showProgressBar = false,
    }) {
      toastification.show(
        context: Get.context!,
        type: type,
        style: style,
        title: title.wrapInText(),
        description: message.wrapInText(),
        alignment: alignment,
        autoCloseDuration: autoCloseDuration,
        borderRadius: borderRadius,
        showProgressBar: showProgressBar,
      );
    }
  }

  class Confirmation {
    Future<void> showOkCancel({
      required String title,
      required String message,
      String okLabel = 'Sim',
      String cancelLabel = 'Não',
      required VoidCallback onOk,
    }) async {
      final result = await showOkCancelAlertDialog(
        context: Get.context!,
        title: title,
        message: message,
        okLabel: okLabel,
        cancelLabel: cancelLabel,
        barrierDismissible: false,
        style: AdaptiveStyle.macOS,
        defaultType: OkCancelAlertDefaultType.ok
      );

      if (result == OkCancelResult.ok) {
        onOk();
      }
    }

    Future<void> showOkDialog({
      required String title,
      required String message,
    }) async {
      await showOkAlertDialog(
        context: Get.context!,
        title: title,
        message: message,
        style: AdaptiveStyle.macOS,
        barrierDismissible: false,
      );
    }

    Future<void> showDialog({
      required String title,
      required String message,
    }) async {
      return await showAlertDialog(
        context: Get.context!,
        style: AdaptiveStyle.macOS,
        title: title,
        message: message,
      );
    }
  }