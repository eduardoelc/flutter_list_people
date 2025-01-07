import 'package:flutter/material.dart';

class AsyncLabelText extends StatelessWidget {
  final String name;
  final String dado;
  final Future<String> Function(String) getLabelFunction;

  const AsyncLabelText({
    super.key,
    required this.name,
    required this.dado,
    required this.getLabelFunction,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getLabelFunction(name),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Carregando...");
        } else if (snapshot.hasError) {
          return const Text("Erro ao carregar");
        } else if (snapshot.hasData) {
          return Text.rich(
            TextSpan(
              text: '${snapshot.data!}: ', // Rótulo (label) em negrito
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              children: [
                TextSpan(
                  text: dado, // Dado em estilo normal
                  style: const TextStyle(
                      fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ],
            ),
          );
        } else {
          return const Text('Campo não encontrado');
        }
      },
    );
  }
}
