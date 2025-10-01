import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();

  factory WebSocketService() {
    return _instance;
  }

  WebSocketService._internal();

  late WebSocketChannel _channel;
  final String _url = 'wss://echo.websocket.events';
  final StreamController<String> _messageController = StreamController.broadcast();

  // Expone el stream de mensajes para que los widgets puedan escucharlo.
  Stream<String> get messages => _messageController.stream;

  void connect() {
    try {
      _channel = IOWebSocketChannel.connect(_url);
      _channel.stream.listen(
        (message) {
          // Agrega los mensajes entrantes al StreamController
          _messageController.sink.add(message.toString());
        },
        onDone: () {
          print('Conexión WebSocket cerrada.');
          _messageController.close();
        },
        onError: (error) {
          print('Error en la conexión WebSocket: $error');
          _messageController.addError(error);
        },
      );
    } catch (e) {
      print('No se pudo conectar al servidor WebSocket: $e');
    }
  }

  void sendMessage(String message) {
    if (_channel != null) {
      _channel.sink.add(message);
    } else {
      print('No se pudo enviar el mensaje. Conexión no establecida.');
    }
  }

  void disconnect() {
    if (_channel != null) {
      _channel.sink.close();
      _messageController.close();
    }
  }
}