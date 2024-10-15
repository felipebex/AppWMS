import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CronometroPage extends StatefulWidget {
  const CronometroPage({Key? key}) : super(key: key);

  @override
  _CronometroPageState createState() => _CronometroPageState();
}

class _CronometroPageState extends State<CronometroPage> {
  final StreamController<int> _streamController = StreamController<int>();
  bool _isRunning = false;
  DateTime? _startTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadStartTime();
  }

  Future<void> _loadStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimeMillis = prefs.getInt('startTime');
    if (startTimeMillis != null) {
      _startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
      _startTimer();
    }
  }

  void _startTimer() {
    if (_startTime != null) {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final elapsedTime = DateTime.now().difference(_startTime!);
        _streamController.add(elapsedTime.inSeconds);
      });
    }
  }

  Future<void> _start() async {
    _startTime = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('startTime', _startTime!.millisecondsSinceEpoch); 
    _startTimer();
  }

  void _stop() {
    _isRunning = false;
    _timer?.cancel();
    _startTime = null;
    _streamController.add(0); // Para reiniciar el stream
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cronómetro')),
      body: Center(
        child: StreamBuilder<int>(
          stream: _streamController.stream,
          builder: (context, snapshot) {
            final seconds = snapshot.data ?? 0;
            return Text(
              '$seconds segundos',
              style: const TextStyle(fontSize: 48),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isRunning) {
            _stop();
          } else {
            _start();
          }
        },
        child: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
      ),
    );
  }
}
