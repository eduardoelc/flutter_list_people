import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CepSearch extends StatelessWidget {
  final TextEditingController cepController;
  final VoidCallback onSearch;

  const CepSearch({
    super.key,
    required this.cepController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: cepController,
            decoration: const InputDecoration(
              labelText: 'CEP',
              border: OutlineInputBorder(),
              hintText: '00000-000',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CepInputFormatter(),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.rectangle,
            border: Border.all(
              color: Colors.blue, // Cor da borda
              width: 2.0, // Largura da borda
            ),
            borderRadius: BorderRadius.circular(8), // Arredondamento dos cantos
          ),
          height: 50,
          child: IconButton(
            icon: const Icon(
              Icons.search,
              size: 32,
            ),
            onPressed: onSearch,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
