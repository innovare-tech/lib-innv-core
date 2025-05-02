import 'package:flutter/material.dart';

extension FormExtensions on GlobalKey<FormState> {
  void onValidate(
    VoidCallback onValid, {
    VoidCallback? onInvalid,
  }) {
    if (currentState?.validate() ?? false) {
      onValid.call();
    } else {
      onInvalid?.call();
    }
  }
}