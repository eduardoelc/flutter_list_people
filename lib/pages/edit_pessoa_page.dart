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

class EditPessoaPage extends StatefulWidget {
  final PessoaModel pessoa;

  const EditPessoaPage({
    super.key,
    required this.pessoa,
  });

  @override
  State<EditPessoaPage> createState() => _EditPessoaPageState();
}

class _EditPessoaPageState extends State<EditPessoaPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  File? _selectedImage;
  var viacepModel = ViaCEPModel();
  var viaCepRepository = ViaCepRepository();

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
    _controllers["objectId"] = TextEditingController();
    _controllers["objectId"]!.text = widget.pessoa.objectId;

    for (var field in PessoaModel.dynamicFields()) {
      String fieldName = field['name']!;
      _controllers[fieldName] = TextEditingController();

      // Preenche os controladores com os dados existentes da pessoa
      switch (fieldName) {
        case 'nome':
          _controllers[fieldName]!.text = widget.pessoa.nome;
          break;
        case 'telefone':
          _controllers[fieldName]!.text = widget.pessoa.telefone;
          break;
        case 'dataNacimento':
          _controllers[fieldName]!.text = widget.pessoa.dataNacimento;
          break;
        case 'numero':
          _controllers[fieldName]!.text = widget.pessoa.numero;
          break;
      }
    }

    _controllers['cep'] = TextEditingController();
    _controllers['imagem'] = TextEditingController();
    if (widget.pessoa.imagem.isNotEmpty) {
      _selectedImage = File(widget.pessoa.imagem);
      _controllers['imagem']?.text = widget.pessoa.imagem;
    } else {
      _controllers['imagem']?.text = '';
    }
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
      widget.pessoa.endereco = EnderecoModel.criar(viacepModel);
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

    // Pegue a imagem da galeria
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // Converta para File
        print("Path: ${pickedFile.path}");
        // Atualize o controlador 'imagem' com o caminho da imagem selecionada
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
      var result = EnderecosModel([EnderecoModel.vazio()]);

      if (_controllers['cep']!.text.isNotEmpty) {
        result = await back4appEnderecoRepository
            .validCep(widget.pessoa.endereco.cep);

        if (result.cep.isEmpty) {
          await back4appEnderecoRepository.postCep(widget.pessoa.endereco);
          result = await back4appEnderecoRepository
              .validCep(widget.pessoa.endereco.cep);
        }
      }

      final pessoa = PessoaModel.criarEdit(
        widget.pessoa.objectId,
        _controllers['nome']?.text ?? '',
        _controllers['telefone']?.text ?? '',
        _controllers['imagem']?.text ?? '',
        _controllers['numero']?.text ?? '',
        _controllers['dataNacimento']?.text ?? '',
        _controllers['cep']!.text.isEmpty
            ? widget.pessoa.endereco
            : result.cep[0],
      );

      await back4appPessoaRepository.putPessoa(pessoa);

      _formKey.currentState?.reset();
      _controllers.values.forEach((controller) => controller.clear());

      Navigator.pop(context, pessoa);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dados editado com sucesso!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Campo faltando validação!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Edição",
          backgroundColor: Colors.blue.shade900,
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
                              _selectedImage!) // Exibe a imagem selecionada
                          : const Text("Nenhuma imagem selecionada"),
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
                if (widget.pessoa.endereco != [])
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_controllers['cep']!.text.isEmpty)
                            Text(
                              "CEP Informado: ${widget.pessoa.endereco.cep}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )
                          else
                            Container(),
                          Text(
                              "Logradouro: ${widget.pessoa.endereco.logradouro}"),
                          Text("Bairro: ${widget.pessoa.endereco.bairro}"),
                          Text(
                              "Localidade: ${widget.pessoa.endereco.localidade}"),
                          Text("UF: ${widget.pessoa.endereco.uf}"),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _salvarPessoa,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blue.shade700,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "Salvar Alteração",
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
