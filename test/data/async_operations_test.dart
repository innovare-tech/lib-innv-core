// Estes testes validam explicitamente o comportamento dos parametros
// `silent`/`showErrorDialog` (deprecated em favor de `AsyncErrorHandling`)
// como parte da garantia de retrocompat. Os warnings deprecated sao
// esperados e silenciados em massa para nao poluir o `flutter analyze`.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:innovare_core/src/async/async_config.dart';
import 'package:innovare_core/src/async/async_operations.dart';
import 'package:innovare_core/src/async/async_result.dart';

/// Recorder p/ `LoadingManager` — grava chamadas sem dependências externas.
class _RecorderLoadingManager implements LoadingManager {
  int showCount = 0;
  int dismissCount = 0;
  int updateMessageCount = 0;
  String? lastMessage;

  @override
  void show(String message) {
    showCount++;
    lastMessage = message;
  }

  @override
  void dismiss() {
    dismissCount++;
  }

  @override
  void updateMessage(String message) {
    updateMessageCount++;
  }

  @override
  void showWithProgress(String message, double progress) {
    show(message);
  }
}

/// Recorder p/ `NotificationManager`.
class _RecorderNotificationManager implements NotificationManager {
  int errorCount = 0;
  int successCount = 0;
  int infoCount = 0;
  int warningCount = 0;
  String? lastError;
  String? lastSuccess;

  @override
  void showError(String message) {
    errorCount++;
    lastError = message;
  }

  @override
  void showSuccess(String message) {
    successCount++;
    lastSuccess = message;
  }

  @override
  void showInfo(String message) {
    infoCount++;
  }

  @override
  void showWarning(String message) {
    warningCount++;
  }
}

/// Helper p/ montar um `MaterialApp` que registra `Get.context`.
Future<void> _mountApp(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: Get.key,
      home: const Scaffold(body: SizedBox.shrink()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // Necessário para acessar `Get.context` (que depende de
  // `WidgetsBinding.instance.buildOwner`) em testes não-widget.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AsyncExecutor.execute — auto-silent (Get.context == null)', () {
    late _RecorderLoadingManager loading;
    late _RecorderNotificationManager notif;
    late AsyncExecutor executor;

    setUp(() {
      loading = _RecorderLoadingManager();
      notif = _RecorderNotificationManager();
      executor = AsyncExecutor(
        loadingManager: loading,
        notificationManager: notif,
      );
      // `Get.reset()` limpa singletons e o navigator, garantindo que
      // `Get.context == null` (estado de bootstrap).
      Get.reset();
    });

    test(
      'silent:false + ctx null → loadingManager.show NÃO chamado, retorna Success',
      () async {
        expect(Get.context, isNull);

        final result = await executor.execute(
          () async => 42,
          silent: false,
        );

        expect(loading.showCount, 0);
        expect(loading.dismissCount, 0);
        expect(result, isA<AsyncSuccess<int>>());
        expect((result as AsyncSuccess<int>).data, 42);
      },
    );

    test(
      'silent:false + showErrorDialog:true + erro + ctx null → showError NÃO chamado, retorna Failure',
      () async {
        final result = await executor.execute<int>(
          () async => throw Exception('boom'),
          silent: false,
          showErrorDialog: true,
        );

        expect(notif.errorCount, 0);
        expect(loading.showCount, 0);
        expect(result, isA<AsyncFailure<int>>());
      },
    );

    test(
      'log informativo é emitido quando enableLogging=true e ctx null',
      () async {
        // Apenas valida que a operação não throws com logging ligado.
        // O `debugPrint` real é capturado pelo framework.
        final originalConfig = AsyncConfig.instance;
        AsyncConfig.instance = const AsyncConfig(enableLogging: true);
        try {
          final result = await executor.execute(() async => 1);
          expect(result, isA<AsyncSuccess<int>>());
        } finally {
          AsyncConfig.instance = originalConfig;
        }
      },
    );

    test(
      'idempotência: 5 chamadas seguidas com ctx null não throw',
      () async {
        for (var i = 0; i < 5; i++) {
          final result = await executor.execute(() async => i);
          expect(result, isA<AsyncSuccess<int>>());
        }
        expect(loading.showCount, 0);
        expect(notif.errorCount, 0);
      },
    );
  });

  group('AsyncExecutor.execute — UI montada (Get.context != null)', () {
    late _RecorderLoadingManager loading;
    late _RecorderNotificationManager notif;
    late AsyncExecutor executor;

    setUp(() {
      loading = _RecorderLoadingManager();
      notif = _RecorderNotificationManager();
      executor = AsyncExecutor(
        loadingManager: loading,
        notificationManager: notif,
      );
      Get.reset();
    });

    testWidgets(
      'silent:false + ctx populado → loadingManager.show chamado',
      (tester) async {
        await _mountApp(tester);
        expect(Get.context, isNotNull);

        await executor.execute(
          () async => 1,
          silent: false,
          timeout: Duration.zero,
        );

        expect(loading.showCount, 1);
        expect(loading.dismissCount, 1);
      },
    );

    testWidgets(
      'silent:false + erro + ctx populado → showError chamado',
      (tester) async {
        await _mountApp(tester);

        await executor.execute<int>(
          () async => throw Exception('falha'),
          silent: false,
          showErrorDialog: true,
          timeout: Duration.zero,
        );

        expect(notif.errorCount, 1);
      },
    );

    testWidgets(
      'silent:true (legacy) + ctx populado → loadingManager.show NÃO chamado',
      (tester) async {
        await _mountApp(tester);

        await executor.execute(
          () async => 1,
          silent: true,
          timeout: Duration.zero,
        );

        expect(loading.showCount, 0);
      },
    );
  });

  group('AsyncErrorHandling enum (UI montada)', () {
    late _RecorderLoadingManager loading;
    late _RecorderNotificationManager notif;
    late AsyncExecutor executor;

    setUp(() {
      loading = _RecorderLoadingManager();
      notif = _RecorderNotificationManager();
      executor = AsyncExecutor(
        loadingManager: loading,
        notificationManager: notif,
      );
      Get.reset();
    });

    testWidgets(
      'AsyncErrorHandling.inline + erro → showError NÃO chamado, retorna Failure',
      (tester) async {
        await _mountApp(tester);

        final result = await executor.execute<int>(
          () async => throw Exception('boom'),
          errorHandling: AsyncErrorHandling.inline,
          timeout: Duration.zero,
        );

        expect(notif.errorCount, 0);
        expect(loading.showCount, 1); // loading aparece em inline
        expect(result, isA<AsyncFailure<int>>());
      },
    );

    testWidgets(
      'AsyncErrorHandling.global + erro → showError chamado',
      (tester) async {
        await _mountApp(tester);

        await executor.execute<int>(
          () async => throw Exception('boom'),
          errorHandling: AsyncErrorHandling.global,
          timeout: Duration.zero,
        );

        expect(notif.errorCount, 1);
        expect(loading.showCount, 1);
      },
    );

    testWidgets(
      'AsyncErrorHandling.silent + erro → ambos noop',
      (tester) async {
        await _mountApp(tester);

        final result = await executor.execute<int>(
          () async => throw Exception('boom'),
          errorHandling: AsyncErrorHandling.silent,
          timeout: Duration.zero,
        );

        expect(notif.errorCount, 0);
        expect(loading.showCount, 0);
        expect(result, isA<AsyncFailure<int>>());
      },
    );

    testWidgets(
      'errorHandling tem precedência sobre silent legacy',
      (tester) async {
        await _mountApp(tester);

        // silent:true seria suprimir tudo, mas errorHandling.global vence.
        await executor.execute<int>(
          () async => throw Exception('boom'),
          silent: true,
          errorHandling: AsyncErrorHandling.global,
          timeout: Duration.zero,
        );

        expect(notif.errorCount, 1);
        expect(loading.showCount, 1);
      },
    );
  });

  group('Retrocompat — aliases legacy continuam funcionais', () {
    late _RecorderLoadingManager loading;
    late _RecorderNotificationManager notif;
    late AsyncExecutor executor;

    setUp(() {
      loading = _RecorderLoadingManager();
      notif = _RecorderNotificationManager();
      executor = AsyncExecutor(
        loadingManager: loading,
        notificationManager: notif,
      );
      Get.reset();
    });

    testWidgets(
      'silent:true continua suprimindo (sem errorHandling)',
      (tester) async {
        await _mountApp(tester);

        await executor.execute(
          () async => 1,
          silent: true,
          timeout: Duration.zero,
        );

        expect(loading.showCount, 0);
      },
    );

    testWidgets(
      'showErrorDialog:false + erro + silent:false → suprime apenas dialog',
      (tester) async {
        await _mountApp(tester);

        final result = await executor.execute<int>(
          () async => throw Exception('boom'),
          silent: false,
          showErrorDialog: false,
          timeout: Duration.zero,
        );

        expect(notif.errorCount, 0);
        expect(loading.showCount, 1); // loading apareceu
        expect(result, isA<AsyncFailure<int>>());
      },
    );

    testWidgets(
      'AsyncOperations.silent() helper usa errorHandling.silent internamente',
      (tester) async {
        await _mountApp(tester);
        AsyncOperations.configure(
          loadingManager: loading,
          notificationManager: notif,
        );

        try {
          final result = await AsyncOperations.silent<int>(
            () async => throw Exception('bg'),
            timeout: Duration.zero,
          );

          expect(notif.errorCount, 0);
          expect(loading.showCount, 0);
          expect(result, isA<AsyncFailure<int>>());
        } finally {
          AsyncOperations.reset();
        }
      },
    );
  });
}
