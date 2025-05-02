import 'package:flutter/material.dart';
import 'package:innovare_core/dialogs/dialogs.dart';

extension WidgetExtensions on Widget {
  void makeDialog<T>({Function(T)? onReturnValue}) async {
    final result = await Dialogs.custom().show<T>(this);

    if (result != null) {
      onReturnValue?.call(result);
    }
  }
}