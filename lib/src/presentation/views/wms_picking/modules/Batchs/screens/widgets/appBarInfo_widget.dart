// ignore_for_file: file_names

import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBarInfo extends StatelessWidget {
  const AppBarInfo({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BatchBloc, BatchState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(top: size.height * 0.05),
          width: size.width * 1,
          color: primaryColorApp,
          height: size.height * 0.2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_ios,
                            size: 30, color: Colors.white)),
                  ),
                  Text(
                    'Items por separar: ${context.read<BatchBloc>().batchWithProducts.products?.length ?? ""}',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert,
                          size: 30, color: Colors.white)),
                ],
              ),
              const Divider(
                color: lightGrey,
                thickness: 2,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.centerLeft,
                width: size.width * 1,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          context
                                  .read<BatchBloc>()
                                  .batchWithProducts
                                  .batch
                                  ?.name ??
                              '',
                          style: const TextStyle(
                              fontSize: 14, color: Color.fromARGB(255, 30, 18, 18)),
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Esteban Rodriguez',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
