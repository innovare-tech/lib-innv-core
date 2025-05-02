import 'package:intl/intl.dart';

extension NumExtensions on num {
  String toCurrencyString([String locale = 'pt_BR', String symbol = 'R\$']) {
    return NumberFormat.currency(locale: locale, symbol: symbol).format(this);
  }
}