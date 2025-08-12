import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class ProductEmpty extends StatelessWidget {
  const ProductEmpty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No hay productos',
              style: TextStyle(fontSize: 14, color: grey)),
          const Text('Intente buscar otro producto',
              style: TextStyle(fontSize: 12, color: grey)),
          if (context.read<UserBloc>().fabricante.contains("Zebra"))
            const SizedBox(height: 60),
        ],
      ),
    );
  }
}
