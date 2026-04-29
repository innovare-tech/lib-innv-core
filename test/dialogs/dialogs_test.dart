import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:innovare_core/dialogs/dialogs.dart';

void main() {
  // Necessário para acessar `Get.context` (que depende de
  // `WidgetsBinding.instance.buildOwner`) em testes não-widget.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dialogs guards — Get.context == null (bootstrap / cold-start)', () {
    setUp(() {
      // Garante que Get.context retorna null (estado de bootstrap).
      Get.reset();
    });

    test(
      'Confirmation.showOkCancel: ctx null → não throw, onOk NÃO chamado',
      () async {
        var onOkCalled = false;

        await Dialogs.confirm.showOkCancel(
          title: 'Atenção',
          message: 'Confirmar?',
          onOk: () => onOkCalled = true,
        );

        expect(onOkCalled, isFalse);
      },
    );

    test(
      'Confirmation.showOkDialog: ctx null → não throw',
      () async {
        await Dialogs.confirm.showOkDialog(
          title: 'Info',
          message: 'mensagem',
        );
        // Sem assertion: não throw é o comportamento desejado.
      },
    );

    test(
      'Confirmation.showDialog: ctx null → não throw',
      () async {
        await Dialogs.confirm.showDialog(
          title: 'Alerta',
          message: 'algum aviso',
        );
      },
    );

    test(
      'Custom.show: ctx null → retorna null sem throw',
      () async {
        final result = await Dialogs.customDialog.show<int>(
          const SizedBox.shrink(),
        );
        expect(result, isNull);
      },
    );

    test(
      'Loading.show: ctx null → retorna sem throw',
      () async {
        await Dialogs.loadingInstance.show('Carregando...');
        // Confirma paridade com guards já existentes.
      },
    );

    test(
      'idempotência: 5 chamadas seguidas em todos os guards com ctx null',
      () async {
        for (var i = 0; i < 5; i++) {
          await Dialogs.confirm.showOkCancel(
            title: 't',
            message: 'm',
            onOk: () {},
          );
          await Dialogs.confirm.showOkDialog(title: 't', message: 'm');
          await Dialogs.confirm.showDialog(title: 't', message: 'm');
          await Dialogs.customDialog.show<void>(const SizedBox.shrink());
          await Dialogs.loadingInstance.show('m');
        }
        // Ausência de exception é o critério de sucesso.
      },
    );
  });

  group('Notification guards — Get.context == null', () {
    setUp(() {
      Get.reset();
    });

    test('Notification.error: ctx null → não throw', () {
      // O guard já existia (`_internalShow` retorna early se ctx null);
      // este teste documenta o comportamento e protege contra regressão.
      Dialogs.toast.error('falha qualquer');
    });

    test('Notification.success: ctx null → não throw', () {
      Dialogs.toast.success('ok');
    });

    test('Notification.info: ctx null → não throw', () {
      Dialogs.toast.info('info');
    });

    test('Notification.warning: ctx null → não throw', () {
      Dialogs.toast.warning('warn');
    });
  });
}
