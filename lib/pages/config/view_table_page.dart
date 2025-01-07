import 'package:flutter/material.dart';
import 'package:flutter_list_people/model/endereco_model.dart';
import 'package:flutter_list_people/model/pessoa_model.dart';
import 'package:flutter_list_people/repositories/config/view_table_respository.dart';
import 'package:flutter_list_people/shared/widgets/custom_appbar.dart';

class ConfigViewTablePage extends StatefulWidget {
  final Function()? onConfigSaved;

  const ConfigViewTablePage({super.key, this.onConfigSaved});

  @override
  State<ConfigViewTablePage> createState() => _ConfigViewTablePageState();
}

class _ConfigViewTablePageState extends State<ConfigViewTablePage> {
  ViewSettings viewSettings = ViewSettings(fieldVisibility: {});
  String selectedTable = 'Dados Pessoal (${PessoaModel.getFields().length})';
  bool selectAll = true;
  bool saveAction = false;

  final Map<String, List<Map<String, String>>> tables = {
    'Dados Pessoal (${PessoaModel.getFields().length})':
        PessoaModel.getFields(),
    'Endereco (${EnderecoModel.getFieldsView().length})':
        EnderecoModel.getFieldsView(),
  };

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  loadSettings() async {
    viewSettings.fieldVisibility =
        await ViewSettings.createFieldVisibility(tables[selectedTable]!);
    await viewSettings.loadPreferences();

    selectAll = viewSettings.fieldVisibility.values.every((value) => value);
    setState(() {});
  }

  void _toggleAll(bool value) {
    setState(() {
      selectAll = value;
    });
    viewSettings.saveAllPreferences(value);
    loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Configuração de Visibilidade",
          leading: [
            IconButton(
              alignment: Alignment.topCenter,
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            DropdownButton<String>(
              value: selectedTable,
              onChanged: (String? newValue) {
                setState(() {
                  selectedTable = newValue!;
                  loadSettings();
                });
              },
              items: tables.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.pressed)) {
                        return selectAll
                            ? Colors.redAccent
                            : Colors.greenAccent;
                      }
                      return selectAll ? Colors.red : Colors.green;
                    },
                  ),
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  shadowColor: WidgetStateProperty.all<Color>(Colors.black),
                  elevation: WidgetStateProperty.all<double>(8),
                  padding: WidgetStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                      side: const BorderSide(
                          color: Color.fromARGB(169, 5, 5, 5), width: 2),
                    ),
                  ),
                ),
                onPressed: () {
                  _toggleAll(!selectAll);
                  if (widget.onConfigSaved != null) {
                    widget.onConfigSaved!();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preferências salvas!')),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    selectAll
                        ? const Icon(Icons.indeterminate_check_box_outlined)
                        : const Icon(Icons.check_box_outlined),
                    const SizedBox(width: 8),
                    Text(selectAll ? "Desmarcar Tudo" : "Selecionar Tudo"),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tables[selectedTable]!.length,
                itemBuilder: (context, index) {
                  var field = tables[selectedTable]![index];
                  bool valid = viewSettings.isFieldVisible(field['name']!);
                  return SwitchListTile(
                    title: Text('${index + 1}. ${field['label']}'),
                    value: valid,
                    onChanged: (bool value) {
                      setState(() {
                        viewSettings.updateFieldVisibility(
                            field['name']!, value);
                        saveAction = true;
                      });
                    },
                  );
                },
              ),
            ),
            if (saveAction)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.pressed)) {
                          return Colors.greenAccent; // Cor ao pressionar
                        }
                        return Colors.green; // Cor padrão
                      },
                    ),
                    foregroundColor: WidgetStateProperty.all<Color>(
                        Colors.white), // Cor do texto
                    shadowColor: WidgetStateProperty.all<Color>(
                        Colors.black), // Cor da sombra
                    elevation: WidgetStateProperty.all<double>(0), // Elevação
                    padding: WidgetStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12), // Padding interno
                    ),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(32), // Bordas arredondadas
                        side: const BorderSide(
                            color: Color.fromARGB(169, 76, 175, 79),
                            width: 2), // Borda com cor
                      ),
                    ),
                  ),
                  onPressed: () async {
                    await viewSettings.savePreferences();
                    if (widget.onConfigSaved != null) {
                      widget.onConfigSaved!();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Preferências salvas!')),
                    );
                    saveAction = false;
                    setState(() {});
                  },
                  child: const Text("Salvar Alteração"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
