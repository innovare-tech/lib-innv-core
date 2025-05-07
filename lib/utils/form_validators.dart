import 'package:brasil_fields/brasil_fields.dart';

class FormValidators {
  static String? validateCPF(String? value) {
    if (value == null || value.isEmpty) return 'Campo obrigatório';
    if (!CPFValidator.isValid(value)) return 'CPF inválido';
    return null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) return 'Campo obrigatório';
    try {
      final parts = value.split('/');
      if (parts.length != 3) return 'Data inválida';
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        return 'Data inválida';
      }
    } catch (_) {
      return 'Data inválida';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Campo obrigatório';
    if (value.length < 15) return 'Número de celular inválido';
    return null;
  }

  static String? validatePlate(String? value) {
    if (value == null || value.isEmpty) return 'Campo obrigatório';
    final regex = RegExp(r'^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$');
    if (!regex.hasMatch(value)) return 'Placa inválida';
    return null;
  }
}
