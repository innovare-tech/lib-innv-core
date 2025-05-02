import 'package:flutter/material.dart';

extension TextEditingControllerExtensions on TextEditingController {
  bool matches(String value, [bool caseSensitive = false]) {
    return text == value || (!caseSensitive && text.toLowerCase() == value.toLowerCase());
  }
}