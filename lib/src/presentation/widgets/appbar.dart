// ignore_for_file: must_be_immutable

import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:flutter/material.dart';

class AppBarGlobal extends StatelessWidget implements PreferredSizeWidget {
  String tittle;
  Widget actions;
  AppBarGlobal({super.key, required this.tittle, required this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(

      centerTitle: true,
      title: Text(tittle, style: const TextStyle(color: white)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [actions],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(20),
      )),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
