import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:intl/intl.dart';

class DynamicFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String format;

  const DynamicFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.format,
  });

  String? _validateField(String? value) {
    if (value == null || value.isEmpty) {
      return "O campo $label é obrigatório.";
    }

    switch (format) {
      case 'fone':
        RegExp regExp = RegExp(r'^\(\d{2}\)\s?\d{4,5}-\d{4}$');
        if (!regExp.hasMatch(value)) {
          return "Telefone inválido.";
        }
        break;
      case 'date':
        try {
          DateFormat('dd/MM/yyyy').parseStrict(value);
        } catch (e) {
          return "Data inválida.";
        }
        break;
      case 'CEP':
        if (value.length != 8) {
          return "CEP inválido.";
        }
        break;
      case 'CPF':
        if (!CPFValidator.isValid(value)) {
          return "CPF inválido.";
        }
        break;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (controller.text.isNotEmpty) {
      _applyMask(controller);
    }

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: _getKeyboardType(),
      inputFormatters: _getInputFormatters(),
      validator: _validateField,
    );
  }

  TextInputType _getKeyboardType() {
    switch (format) {
      case 'fone':
        return TextInputType.phone;
      case 'date':
        return TextInputType.datetime;
      case 'number':
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    switch (format) {
      case 'fone':
        return [
          FilteringTextInputFormatter.digitsOnly,
          TelefoneInputFormatter(),
        ];
      case 'date':
        return [
          FilteringTextInputFormatter.digitsOnly,
          DataInputFormatter(),
        ];
      case 'CEP':
        return [
          FilteringTextInputFormatter.digitsOnly,
          CepInputFormatter(),
        ];
      case 'CPF':
        return [
          FilteringTextInputFormatter.digitsOnly,
          CpfInputFormatter(),
        ];
      default:
        return [];
    }
  }

  // Função para aplicar a máscara manualmente
  void _applyMask(TextEditingController controller) {
    if (format == 'fone' && controller.text.isNotEmpty) {
      final formatted = TelefoneInputFormatter().formatEditUpdate(
        TextEditingValue(text: controller.text),
        TextEditingValue(text: controller.text),
      );

      controller.value = TextEditingValue(
        text: formatted.text,
        selection: TextSelection.collapsed(offset: formatted.text.length),
      );
    }
  }
}
