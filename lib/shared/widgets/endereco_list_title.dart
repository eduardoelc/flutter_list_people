import 'package:flutter/material.dart';
import 'package:flutter_list_people/model/endereco_model.dart';
import 'package:flutter_list_people/repositories/config/view_table_respository.dart';
import 'package:flutter_list_people/shared/widgets/async_label_text.dart';

class EnderecoListTitle extends StatelessWidget {
  final EnderecoModel endereco;
  final ViewSettings vsEndereco;
  final String n;

  EnderecoListTitle(
      {super.key,
      required this.endereco,
      required this.n,
      required this.vsEndereco});

  static Future<String> getLabel(String name) async {
    var label =
        await ViewSettings.getFieldLabel(name, EnderecoModel.getFields());
    return label;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: (vsEndereco.isFieldVisible('logradouro'))
          ? AsyncLabelText(
              name: 'logradouro',
              dado: n.isNotEmpty
                  ? '${endereco.logradouro}, $n'
                  : endereco.logradouro,
              getLabelFunction: getLabel,
            )
          : const Text(""),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (vsEndereco.isFieldVisible('bairro'))
            AsyncLabelText(
              name: 'bairro',
              dado: endereco.bairro,
              getLabelFunction: getLabel,
            ),
          if (vsEndereco.isFieldVisible('localidade'))
            AsyncLabelText(
              name: 'localidade',
              dado: endereco.localidade,
              getLabelFunction: getLabel,
            ),
          if (vsEndereco.isFieldVisible('estado') ||
              vsEndereco.isFieldVisible('uf'))
            AsyncLabelText(
              name: vsEndereco.isFieldVisible('estado') ? 'estado' : 'uf',
              dado: vsEndereco.isFieldVisible('estado') &&
                      vsEndereco.isFieldVisible('uf')
                  ? "${endereco.estado} (${endereco.uf})"
                  : (vsEndereco.isFieldVisible('estado'))
                      ? endereco.estado
                      : endereco.uf,
              getLabelFunction: getLabel,
            ),
          if (vsEndereco.isFieldVisible('cep'))
            AsyncLabelText(
              name: 'cep',
              dado: endereco.cep,
              getLabelFunction: getLabel,
            ),
        ],
      ),
    );
  }
}
