  import 'package:adaptive_dialog/adaptive_dialog.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_easyloading/flutter_easyloading.dart';
  import 'package:get/get.dart';
  import 'package:innovare_core/extensions/string_extensions.dart';
  import 'package:toastification/toastification.dart';

  abstract class Dialogs {
    @Deprecated('Use Dialogs.loading instead')
    static Loading loading() => _loading;

    @Deprecated('Use Dialogs.notification instead')
    static Notification notification() => _notification;

    @Deprecated('Use Dialogs.customDialog instead')
    static Custom custom() => _custom;

    @Deprecated('Use Dialogs.confirm instead')
    static Confirmation confirmation() => _confirmation;

    static Loading get loadingInstance => _loading;
    static Notification get toast => _notification;
    static Confirmation get confirm => _confirmation;
    static Custom get customDialog => _custom;

    static final Loading _loading = Loading();
    static final Notification _notification = Notification();
    static final Custom _custom = Custom();
    static final Confirmation _confirmation = Confirmation();
  }

  class Custom {
    /// Mostra um dialog customizado. **Retorna `null` silenciosamente**
    /// quando o `MaterialApp` ainda não montou (bootstrap / cold-start)
    /// — `Get.dialog` requer `Overlay` ancestral que ainda não existe
    /// nesse momento. Paridade com `Loading.show` e `Notification._internalShow`.
    Future<T?> show<T>(
      Widget widget, {
        bool barrierDismissible = true
      }) async {
      if (Get.context == null) return null;
      return await Get.dialog(
        widget,
        barrierDismissible: barrierDismissible,
      );
    }
  }

  class Loading {
    /// Mostra o overlay de loading global. **Retorna silenciosamente**
    /// quando o `MaterialApp` ainda não montou (bootstrap / cold-start) —
    /// `EasyLoading.overlayEntry` é null nesse momento e a chamada
    /// disparava `Assertion failed: overlayEntry != null` derrubando o
    /// app inteiro. Após o app render do primeiro frame o overlay fica
    /// pronto e a chamada volta a funcionar normalmente.
    Future<void> show(String message) async {
      if (Get.context == null) return;
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
        title: title,
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
        title: title,
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
        title: title,
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
        title: title,
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
      // Guard contra `Get.context!` lancar `Unexpected null value`
      // quando chamado antes do `MaterialApp` montar (bootstrap /
      // cold-start). Sintoma observado: erro de rede durante o
      // SessionBootstrap dispara `notificationManager.showError`
      // -> `Dialogs.notification.error` -> `_internalShow`, que
      // crasha aqui em null-check e leva o app a tela branca em F5.
      // Toast nessa janela e' UX redundante (splash ja' cobre) -- e'
      // seguro suprimir silenciosamente. Apos o primeiro frame o
      // contexto vira nao-null e os toasts voltam a aparecer.
      final ctx = Get.context;
      if (ctx == null) return;
      toastification.show(
        context: ctx,
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
    /// Mostra dialog de confirmação ok/cancel. **No-op silencioso**
    /// quando o `MaterialApp` ainda não montou (bootstrap / cold-start):
    /// `onOk` NÃO é chamado e o future resolve sem erro. Paridade com
    /// `Loading.show` e `Notification._internalShow`. Sem o guard, o
    /// `Get.context!` lançaria `Unexpected null value` derrubando fluxos
    /// de auto-confirmação em SessionBootstrap.
    Future<void> showOkCancel({
      required String title,
      required String message,
      String okLabel = 'Sim',
      String cancelLabel = 'Não',
      required VoidCallback onOk,
    }) async {
      final ctx = Get.context;
      if (ctx == null) return;
      final result = await showOkCancelAlertDialog(
        context: ctx,
        title: title,
        message: message,
        okLabel: okLabel,
        cancelLabel: cancelLabel,
        barrierDismissible: false,
        style: AdaptiveStyle.adaptive,
        defaultType: OkCancelAlertDefaultType.ok
      );

      if (result == OkCancelResult.ok) {
        onOk();
      }
    }

    /// Mostra dialog informativo com botão OK. **No-op silencioso**
    /// quando o `MaterialApp` ainda não montou (bootstrap / cold-start).
    Future<void> showOkDialog({
      required String title,
      required String message,
    }) async {
      final ctx = Get.context;
      if (ctx == null) return;
      await showOkAlertDialog(
        context: ctx,
        title: title,
        message: message,
        style: AdaptiveStyle.adaptive,
        barrierDismissible: false,
      );
    }

    /// Mostra alert dialog genérico. **No-op silencioso** quando o
    /// `MaterialApp` ainda não montou (bootstrap / cold-start).
    Future<void> showDialog({
      required String title,
      required String message,
    }) async {
      final ctx = Get.context;
      if (ctx == null) return;
      return await showAlertDialog(
        context: ctx,
        style: AdaptiveStyle.adaptive,
        title: title,
        message: message,
      );
    }
  }