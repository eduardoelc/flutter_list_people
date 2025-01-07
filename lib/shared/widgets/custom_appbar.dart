import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final List<Widget>? actions;
  final List<Widget>? leading;

  const CustomAppBar(
      {super.key,
      required this.title,
      this.backgroundColor = Colors.blueGrey,
      this.actions,
      this.leading});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20, // Ajuste de tamanho
          fontWeight: FontWeight.bold, // Título em negrito
        ),
      ),
      centerTitle: true,
      backgroundColor: backgroundColor,
      leading: leading != []
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: leading ?? [],
            )
          : Container(),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/**
 * @description: Como utilizar "actions".
 * ______________________________________
 * actions: [
 *   IconButton(
 *     icon: const Icon(Icons.search),
 *     onPressed: () {
 *       // Ação para o botão de pesquisa
 *     },
 *   ),
 *   IconButton(
 *     icon: const Icon(Icons.settings),
 *     onPressed: () {
 *       // Ação para o botão de configurações
 *     },
 *   ),
 * ],
 */
