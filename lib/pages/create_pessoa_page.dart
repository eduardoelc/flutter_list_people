import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_list_people/model/endereco_model.dart';
import 'package:flutter_list_people/model/pessoa_model.dart';
import 'package:flutter_list_people/model/viacep_model.dart';
import 'package:flutter_list_people/repositories/back4app/back4app_endereco_repository.dart';
import 'package:flutter_list_people/repositories/back4app/back4app_pessoa_repository.dart';
import 'package:flutter_list_people/repositories/viacep/via_cep_repository.dart';
import 'package:flutter_list_people/shared/widgets/cep_search.dart';
import 'package:flutter_list_people/shared/widgets/custom_appbar.dart';
import 'package:flutter_list_people/shared/widgets/dynamic_form_field.dart';
import 'package:image_picker/image_picker.dart';

class CreatePessoaPage extends StatefulWidget {
  const CreatePessoaPage({Key? key}) : super(key: key);

  @override
  State<CreatePessoaPage> createState() => _CreatePessoaPageState();
}

class _CreatePessoaPageState extends State<CreatePessoaPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  File? _selectedImage; // Para armazenar a imagem selecionada
  var viacepModel = ViaCEPModel();
  var viaCepRepository = ViaCepRepository();
  var endereco = EnderecoModel.vazio();

  bool _isLoadingEndereco = false;

  Back4appEnderecoRepository back4appEnderecoRepository =
      Back4appEnderecoRepository();
  Back4appPessoaRepository back4appPessoaRepository =
      Back4appPessoaRepository();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (var field in PessoaModel.dynamicFields()) {
      _controllers[field['name']!] = TextEditingController();
    }
    _controllers['cep'] = TextEditingController();
    _controllers['imagem'] = TextEditingController();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _buscarEndereco() async {
    FocusScope.of(context).unfocus();

    final cep = _controllers['cep']?.text.trim();

    if (cep == null || cep.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite um CEP válido!")),
      );
      return;
    }

    setState(() => _isLoadingEndereco = true);

    try {
      viacepModel = await viaCepRepository.consultarCEP(cep);
      endereco = EnderecoModel.criar(viacepModel);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Não foi possível buscar o endereço.")),
      );
    } finally {
      setState(() => _isLoadingEndereco = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _controllers['imagem']?.text = pickedFile.path;
      });
    } else {
      // Caso o usuário cancele a seleção
      print('Imagem não selecionada');
    }
  }

  Future<void> _salvarPessoa() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      try {
        var result = await back4appEnderecoRepository.validCep(endereco.cep);
        if (result.cep.isEmpty) {
          await back4appEnderecoRepository.postCep(endereco);
          result = await back4appEnderecoRepository.validCep(endereco.cep);
        }

        final pessoa = PessoaModel.criar(
          _controllers['nome']?.text ?? '',
          _controllers['telefone']?.text ?? '',
          _controllers['imagem']?.text ?? '',
          _controllers['numero']?.text ?? '',
          _controllers['dataNacimento']?.text ?? '',
          result.cep[0],
        );

        await back4appPessoaRepository.postPessoa(pessoa);

        _formKey.currentState?.reset();
        endereco = EnderecoModel.vazio();
        _controllers.values.forEach((controller) => controller.clear());

        Navigator.pop(context, pessoa);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pessoa cadastrada com sucesso!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao cadastrar pessoa.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos obrigatórios!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Cadastro",
          backgroundColor: Colors.green.shade900,
          leading: [
            IconButton(
              alignment: Alignment.topCenter,
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  // Caso não possa voltar, redirecione para outra ação ou ignore
                  print('Não há rotas para voltar');
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => const ListaContatosPage()),
                  // );
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            ) // Exibe a imagem selecionada
                          : const Text("Nenhuma imagem selecionada",
                              style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text("Selecionar Imagem da Galeria"),
                      ),
                      // const SizedBox(height: 20),
                      // TextFormField(
                      //   controller: _controllers['imagem'],
                      //   readOnly: true, // Torne o campo somente leitura
                      //   decoration: const InputDecoration(
                      //     labelText: "Caminho da Imagem",
                      //     border: OutlineInputBorder(),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                // const SizedBox(height: 20),
                for (var field in PessoaModel.dynamicFields())
                  if (field['name'] != 'endereco' && field['name'] != null) ...[
                    const SizedBox(height: 10),
                    DynamicFormField(
                      label: field['label']!,
                      controller: _controllers[field['name']]!,
                      format: field['format']!,
                    ),
                  ],
                const SizedBox(height: 20),
                const Text(
                  "Buscar Endereço pelo CEP",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CepSearch(
                          cepController: _controllers['cep']!,
                          onSearch: _buscarEndereco),
                    ),
                    const SizedBox(width: 10),
                    _isLoadingEndereco
                        ? const CircularProgressIndicator()
                        : Container(),
                  ],
                ),
                const SizedBox(height: 10),
                if (endereco != [])
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Logradouro: ${endereco.logradouro}"),
                          Text("Bairro: ${endereco.bairro}"),
                          Text("Localidade: ${endereco.localidade}"),
                          Text("UF: ${endereco.uf}"),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _salvarPessoa,
                  iconAlignment: IconAlignment.end,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green.shade700,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "Salvar Dados",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
