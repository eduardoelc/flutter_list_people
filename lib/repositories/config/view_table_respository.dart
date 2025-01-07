import 'package:shared_preferences/shared_preferences.dart';

class ViewSettings {
  Map<String, bool> fieldVisibility;

  ViewSettings({required this.fieldVisibility});

  // Criar as configurações de visibilidade para os campos da tabela
  static Future<Map<String, bool>> createFieldVisibility(
      List<Map<String, String>> fields) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, bool> fieldVisibility = {};
    for (var field in fields) {
      String fieldName = field['name']!;
      fieldVisibility[fieldName] = prefs.getBool(fieldName) ?? true;
    }

    return fieldVisibility;
  }

  // Carregar as configurações de visibilidade
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    fieldVisibility.forEach((key, _) {
      bool? value = prefs.getBool(key);
      if (value != null) {
        fieldVisibility[key] = value;
      }
    });
  }

  // Salvar as configurações de visibilidade
  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    fieldVisibility.forEach((key, value) {
      prefs.setBool(key, value);
    });
  }

  // Salvar todas as configurações de visibilidade
  Future<void> saveAllPreferences(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    for (var key in fieldVisibility.keys) {
      prefs.setBool(key, value);
    }
  }

  // Alterar a visibilidade de um campo
  void updateFieldVisibility(String field, bool visibility) {
    fieldVisibility[field] = visibility;
  }

  // Verificar se um campo está visível
  bool isFieldVisible(String field) {
    return fieldVisibility[field] == true;
  }

  // Verificar se um campo está visível
  static Future<String> getFieldLabel(
      String name, List<Map<String, String>> fields) async {
    for (var field in fields) {
      if (name == field['name']) {
        return field['label']!;
      }
    }
    return ""; // Retorna string vazia se não encontrar o nome
  }
}
