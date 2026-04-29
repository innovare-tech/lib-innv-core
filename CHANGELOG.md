## 2.0.3 (2026-04-29)

### Added
- Enum `AsyncErrorHandling` (`inline`, `global`, `silent`) em `lib/src/async/async_config.dart` que substitui o par confuso `silent` + `showErrorDialog`. Param `errorHandling` adicionado em `AsyncOperations.wrap`/`safe`/`run`/`network` + `AsyncExecutor.execute`. `AsyncOperations.silent()` agora usa `AsyncErrorHandling.silent` internamente.
- Auto-silent em `AsyncExecutor.execute`: detecta `Get.context == null` (UI nao montada / bootstrap / cold-start) e forca `effectiveSilent = true` automaticamente, suprimindo `loadingManager.show` e `notificationManager.showError` para evitar `Assertion failed: overlayEntry != null` durante `SessionBootstrap`. Operacao continua executando e caller recebe `AsyncFailure`/`AsyncSuccess` normalmente.
- Log informativo `[ASYNC] UI nao pronta (Get.context == null) -- degradando para silent.` quando `AsyncConfig.instance.enableLogging` esta ligado e `Get.context == null`.
- Guards `Get.context == null` em `Confirmation.showOkCancel`, `Confirmation.showOkDialog`, `Confirmation.showDialog` e `Custom.show` (paridade com `Loading.show` e `Notification._internalShow` que ja tinham guards). `showOkCancel` retorna sem chamar `onOk`; demais retornam `Future.value(null)`/`void`.
- Testes unitarios em `test/data/async_operations_test.dart` (5 grupos, 22 cases) cobrindo: auto-silent com `Get.reset()`, UI montada via `MaterialApp(navigatorKey: Get.key)`, todos os 3 modos do enum, precedencia `errorHandling` sobre `silent`/`showErrorDialog`, retrocompat dos aliases legacy, helper `AsyncOperations.silent()`. Testes em `test/dialogs/dialogs_test.dart` (2 grupos, 10 cases) validando guards de `Confirmation`/`Custom`/`Loading`/`Notification` + idempotencia (5 chamadas seguidas com ctx null sem throw).

### Deprecated
- Parametros `silent` (substituir por `errorHandling: AsyncErrorHandling.silent`) e `showErrorDialog` (substituir por `errorHandling: AsyncErrorHandling.inline` ou `AsyncErrorHandling.global`) em `AsyncExecutor.execute` + `AsyncOperations.wrap`/`safe`/`run`/`network`. Aliases continuam funcionais (sem regressao).

### Fixed
- `Confirmation.showOkCancel`/`showOkDialog`/`showDialog` lancavam `Unexpected null value` quando chamados antes do `MaterialApp` montar (bootstrap / cold-start). Agora retornam noop silencioso.
- `Custom.show` lancava erro de `Overlay` ausente em mesma janela. Agora retorna `null` silencioso.

### Migration
- Codigo existente continua funcionando sem alteracao -- aliases legacy preservados.
- Migracao recomendada (gradual):
  ```dart
  // Antes
  AsyncOperations.wrap(op, silent: false, showErrorDialog: false);
  AsyncOperations.wrap(op, silent: true);

  // Depois
  AsyncOperations.wrap(op, errorHandling: AsyncErrorHandling.inline);
  AsyncOperations.wrap(op, errorHandling: AsyncErrorHandling.silent);
  ```
- Apps que dependiam do crash em `Get.context == null` (improvavel) precisam adicionar checks explicitos antes de chamar `Dialogs.confirm.*` ou `Dialogs.customDialog.show`.

## 1.0.0 (2025-04-07)

### Features
- Introduzido o logotipo oficial da Innovare como um widget `CustomPainter` (`InnovareLogo`).