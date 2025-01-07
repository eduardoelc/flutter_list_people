import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_list_people/model/pessoa_model.dart';
import 'package:flutter_list_people/repositories/config/view_table_respository.dart';
import 'package:flutter_list_people/shared/widgets/async_label_text.dart';
import 'package:flutter_list_people/shared/widgets/endereco_list_title.dart';
import 'package:intl/intl.dart';

class PessoaListTitle extends StatelessWidget {
  final PessoaModel pessoa;
  final ViewSettings vsPessoa;
  final ViewSettings vsEndereco;

  const PessoaListTitle(
      {super.key,
      required this.pessoa,
      required this.vsPessoa,
      required this.vsEndereco});

  static Future<String> getLabel(String name) async {
    var label = await ViewSettings.getFieldLabel(name, PessoaModel.getFields());
    return label;
  }

  // Função para mostrar a imagem em tamanho grande
  void _showImage(BuildContext context, String? imagePath) {
    if (imagePath != null && imagePath.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pop(); // Fecha o diálogo ao clicar na imagem
              },
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover, // Ajusta a imagem para cobrir a tela
              ),
            ),
          );
        },
      );
    } else {
      // Caso a pessoa não tenha imagem, exibe um ícone padrão
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // Fecha o diálogo ao clicar
              },
              child: const Center(
                child: Icon(Icons.image_not_supported,
                    size: 50.0), // Ícone de pessoa
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasValidImage =
        pessoa.imagem.isNotEmpty && File(pessoa.imagem).existsSync();

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.white,
        child: ExpansionTile(
          leading: (vsPessoa.isFieldVisible('imagem'))
              ? GestureDetector(
                  onTap: () {
                    _showImage(context, pessoa.imagem);
                  },
                  child: hasValidImage
                      ? CircleAvatar(
                          backgroundImage: FileImage(File(pessoa.imagem)),
                          radius: 30.0,
                        )
                      : const CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 30.0,
                          child: Icon(Icons.image, color: Colors.white),
                        ),
                )
              : null,
          backgroundColor: Colors.black12,
          textColor: Colors.black54,
          title: Text(
            pessoa.nome,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (vsPessoa.isFieldVisible('dataNacimento'))
                AsyncLabelText(
                  name: 'dataNacimento',
                  dado: pessoa.dataNacimento,
                  getLabelFunction: getLabel,
                ),
              if (vsPessoa.isFieldVisible('telefone'))
                AsyncLabelText(
                  name: 'telefone',
                  dado: pessoa.telefone,
                  getLabelFunction: getLabel,
                ),
              if (vsPessoa.isFieldVisible('createdAt'))
                AsyncLabelText(
                  name: 'createdAt',
                  dado: DateFormat('dd/MM/yyyy HH:mm')
                      .format(DateTime.parse(pessoa.createdAt).toLocal())
                      .toString(),
                  getLabelFunction: getLabel,
                ),
              if (vsPessoa.isFieldVisible('updatedAt'))
                AsyncLabelText(
                  name: 'updatedAt',
                  dado: DateFormat('dd/MM/yyyy HH:mm')
                      .format(DateTime.parse(pessoa.createdAt).toLocal())
                      .toString(),
                  getLabelFunction: getLabel,
                ),
            ],
          ),
          children: (vsPessoa.isFieldVisible('endereco'))
              ? [
                  Container(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      final endereco = pessoa.endereco;
                      return EnderecoListTitle(
                          endereco: endereco,
                          n: pessoa.numero,
                          vsEndereco: vsEndereco);
                    },
                  ),
                ]
              : [],
        ),
      ),
    );
  }
}
