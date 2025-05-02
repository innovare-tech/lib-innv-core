import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:jwt_decoder/jwt_decoder.dart';

extension StringExtensions on String {
  Text wrapInText({
    TextStyle? style,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.clip,
    int? maxLines,
    StrutStyle? strutStyle,
    TextWidthBasis textWidthBasis = TextWidthBasis.parent,
    TextHeightBehavior? textHeightBehavior,
  }) {
    return Text(
      this,
      style: style,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }

  String asCpf() {
    final normalized = replaceAll(RegExp(r'\D'), '');

    if (normalized.length != 11) return normalized;

    return '${normalized.substring(0, 3)}.${normalized.substring(3, 6)}.${normalized.substring(6, 9)}-${normalized.substring(9)}';
  }

  String asCnpj() {
    final normalized = replaceAll(RegExp(r'\D'), '');

    if (normalized.length != 14) return normalized;

    return '${normalized.substring(0, 2)}.${normalized.substring(2, 5)}.${normalized.substring(5, 8)}/${normalized.substring(8, 12)}-${normalized.substring(12)}';
  }

  String asDocument() {
    if (length == 11) {
      return asCpf();
    } else if (length == 14) {
      return asCnpj();
    }

    return "";
  }

  bool isCNPJ() {
    final normalized = replaceAll(RegExp(r'\D'), '');

    return normalized.length == 14;
  }

  bool isCpf() {
    final normalized = replaceAll(RegExp(r'\D'), '');

    return normalized.length == 11;
  }

  bool isValidDate([String format = "yyyy-MM-dd"]) {
    try {
      final dateFormat = intl.DateFormat(format);
      dateFormat.parseStrict(this);
      return true;
    } catch (e) {
      return false;
    }
  }

  String? convertDateFormat(String fromFormat, String toFormat) {
    try {
      String normalizedDateString = replaceAll(RegExp(r'([-+]\d{2}):(\d{2})'), '');

      final fromDateFormat = intl.DateFormat(fromFormat);
      final toDateFormat = intl.DateFormat(toFormat);
      final date = fromDateFormat.parseStrict(normalizedDateString);
      return toDateFormat.format(date);
    } catch (e) {
      return null;
    }
  }

  String onlyNumbers() {
    return replaceAll(RegExp(r'\D'), '');
  }

  T decodeJwt<T>(Function(Map<String, dynamic>) fromJson) {
    return fromJson(JwtDecoder.decode(this));
  }

}

extension NullableStringExtensions on String? {
  Text? wrapInText({
    TextStyle? style,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.clip,
    int? maxLines,
    StrutStyle? strutStyle,
    TextWidthBasis textWidthBasis = TextWidthBasis.parent,
    TextHeightBehavior? textHeightBehavior,
  }) {
    return this == null
        ? null
        : Text(
            this!,
            style: style,
            textAlign: textAlign,
            textDirection: textDirection,
            locale: locale,
            softWrap: softWrap,
            overflow: overflow,
            maxLines: maxLines,
            strutStyle: strutStyle,
            textWidthBasis: textWidthBasis,
            textHeightBehavior: textHeightBehavior,
          );
  }
}