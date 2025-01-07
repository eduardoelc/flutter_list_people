import 'package:flutter/material.dart';
import 'package:flutter_list_people/model/endereco_model.dart';
import 'package:flutter_list_people/model/pessoa_model.dart';
import 'package:flutter_list_people/pages/config/view_table_page.dart';
import 'package:flutter_list_people/pages/create_pessoa_page.dart';
import 'package:flutter_list_people/pages/edit_pessoa_page.dart';
import 'package:flutter_list_people/repositories/back4app/back4app_pessoa_repository.dart';
import 'package:flutter_list_people/repositories/config/view_table_respository.dart';
import 'package:flutter_list_people/shared/widgets/custom_appbar.dart';
import 'package:flutter_list_people/shared/widgets/pessoa_list_title.dart';

class ListaContatosPage extends StatefulWidget {
  const ListaContatosPage({super.key});

  @override
  State<ListaContatosPage> createState() => _ListaContatosPageState();
}

class _ListaContatosPageState extends State<ListaContatosPage> {
  bool loading = false;

  var _pessoasModel = PessoasModel([]);
  Back4appPessoaRepository back4appPessoaRepository =
      Back4appPessoaRepository();
  ViewSettings viewSettingsPessoas = ViewSettings(fieldVisibility: {});
  ViewSettings viewSettingsEndereco = ViewSettings(fieldVisibility: {});

  @override
  void initState() {
    super.initState();
    obterDados();
  }

  void obterDados() async {
    setState(() => loading = true);
    _pessoasModel = await back4appPessoaRepository.getPessoas();
    // Campo Visualizado Pessoas
    viewSettingsPessoas.fieldVisibility =
        await ViewSettings.createFieldVisibility(PessoaModel.getFields());
    await viewSettingsPessoas.loadPreferences();
    // Campo Visualizado Endereço
    viewSettingsEndereco.fieldVisibility =
        await ViewSettings.createFieldVisibility(EnderecoModel.getFields());
    await viewSettingsEndereco.loadPreferences();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Lista de Contatos",
          actions: [
            IconButton(
              style: ButtonStyle(
                elevation: WidgetStateProperty.all(8),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                backgroundColor: const WidgetStatePropertyAll(Colors.white54),
                padding: WidgetStateProperty.all(EdgeInsets.all(4)),
                overlayColor: WidgetStateProperty.all(Colors.grey.shade500),
                splashFactory: NoSplash.splashFactory,
              ),
              icon: const Icon(
                Icons.settings_outlined,
                color: Colors.black54,
                size: 30,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfigViewTablePage(
                        onConfigSaved:
                            obterDados // Passa o callback para a ConfigPage
                        ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            loading
                ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _pessoasModel.results?.length,
                      itemBuilder: (context, index) {
                        final pessoa = _pessoasModel.results?[index];

                        return Dismissible(
                          background: Container(
                            color: Colors.red,
                            child: const Align(
                              alignment: Alignment(-0.9, 0),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                          secondaryBackground: Container(
                            color: Colors
                                .blue, // Cor do fundo quando editar (direita)
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              setState(() => loading = true);
                              try {
                                await back4appPessoaRepository
                                    .deletePessoa(pessoa.objectId);

                                setState(() {
                                  loading = false;
                                  _pessoasModel.results?.removeAt(index);
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("CEP Removido com sucesso!")),
                                );
                                return true;
                              } catch (e) {
                                setState(() => loading = false);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Erro ao remover CEP: ${e.toString()}")),
                                );
                              }
                            } else if (direction ==
                                DismissDirection.endToStart) {
                              final updatedData = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditPessoaPage(pessoa: pessoa),
                                ),
                              );

                              if (updatedData != null &&
                                  updatedData is PessoaModel) {
                                setState(() => _pessoasModel.results?[index] =
                                    updatedData);
                              }
                            }
                            return false;
                          },
                          direction: DismissDirection.horizontal,
                          key: Key(pessoa!.objectId.toString()),
                          child: PessoaListTitle(
                            pessoa: pessoa,
                            vsPessoa: viewSettingsPessoas,
                            vsEndereco: viewSettingsEndereco,
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          focusColor: Colors.greenAccent,
          child: const Icon(Icons.add),
          onPressed: () async {
            // Navigator.pop(context);
            final updatedData = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePessoaPage()),
            );

            if (updatedData != null && updatedData is PessoaModel) {
              setState(() => _pessoasModel.results?.add(updatedData));
            }
          },
        ),
      ),
    );
  }
}
