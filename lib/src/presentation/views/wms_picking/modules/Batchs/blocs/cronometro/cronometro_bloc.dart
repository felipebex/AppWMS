import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'cronometro_event.dart';
part 'cronometro_state.dart';

class CronometroBloc extends Bloc<CronometroEvent, CronometroState> {
  bool isRunning = false;
  DateTime? startTime;
  Timer? timer;

   StreamController<int> streamController = StreamController<int>.broadcast();

  CronometroBloc() : super(CronometroInitial()) {
    on<StartCronometroEvent>(_onStartCronometroEvent);
    on<StopCronometroEvent>(_onStopCronometroEvent);
  }

 void _onStartCronometroEvent(
    StartCronometroEvent event, Emitter<CronometroState> emit) async {
  if (!isRunning) {
    start();
  }
}

  void _onStopCronometroEvent(
      StopCronometroEvent event, Emitter<CronometroState> emit) {
    stop();
  }

  void startTimer() {
    if (startTime != null) {
      isRunning = true;
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        print('Start time: $startTime');
        final elapsedTime = DateTime.now().difference(startTime ?? DateTime.now());
        streamController.add(elapsedTime.inSeconds);
      });
    }
  }

  Future<void> start() async {
    startTime = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('startTime', startTime!.millisecondsSinceEpoch);
    startTimer();
  }

  Future<void> loadStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimeMillis = prefs.getInt('startTime');
    if (startTimeMillis != null) {
      startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
      startTimer();
    }
  }

  void stop() {
    isRunning = false;
    timer?.cancel();
    startTime = null;
    streamController.add(0); // Para reiniciar el stream
  }

  @override
  Future<void> close() {
    timer?.cancel(); // Cancela el timer si está activo
    streamController.close(); // Cierra el StreamController
    return super.close(); // Llama al método close del Bloc
  }
}
