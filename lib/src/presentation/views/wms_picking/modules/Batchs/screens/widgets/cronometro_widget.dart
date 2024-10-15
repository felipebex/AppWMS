import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/cronometro/cronometro_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Cronometro extends StatefulWidget {
  const Cronometro({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  State<Cronometro> createState() => _CronometroState();
}

class _CronometroState extends State<Cronometro> {
  @override
  void initState() {
    context.read<CronometroBloc>().loadStartTime();
    super.initState();
  }

  String formatDuration(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CronometroBloc, CronometroState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: lightGrey,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
          height: widget.size.height * 0.07,
          width: widget.size.width * 0.4,
          child: Center(
            child: StreamBuilder<int>(
              stream: context.read<CronometroBloc>().streamController.stream,
              builder: (context, snapshot) {
                final seconds = snapshot.data ?? 0;
                final formattedTime = formatDuration(seconds);
                return Text(
                  formattedTime,
                  style: const TextStyle(fontSize: 18),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
