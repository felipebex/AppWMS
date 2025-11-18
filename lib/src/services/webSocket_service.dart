import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  // 1. Singleton: Permite que solo exista una instancia de este servicio
  static final WebSocketService _instance = WebSocketService._internal();

  factory WebSocketService() => _instance;

  // Constructor privado para asegurar la instancia única
  WebSocketService._internal();

  // 2. Propiedades del Canal y Estado
  WebSocketChannel? _channel;
  bool _isConnected = false;

  // ✅ StreamController para exponer los mensajes a los BLoCs
  final StreamController<dynamic> _messageController = StreamController.broadcast();
  
  // ✅ Stream público para que los BLoCs se suscriban (pueden ser múltiples)
  Stream<dynamic> get messages => _messageController.stream;

  // ⚠️ URL DE PRUEBA: Reemplazar con tu URL de backend, si es necesario.
  final String _socketUrl = 'ws://34.127.73.152:5020/ws'; 

  // 3. Conectar al WebSocket
  void connect() {
    if (_isConnected) {
      print("WebSocketService: Ya conectado.");
      return;
    }

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_socketUrl));
      _isConnected = true;
      print("WebSocketService: Intentando conectar a $_socketUrl");

      // 4. Iniciar la escucha del canal
      _channel!.stream.listen(
        (data) {
          _handleMessage(data); // Envía el mensaje al StreamController
        },
        onDone: () {
          _isConnected = false;
          print("WebSocketService: Conexión cerrada.");
          // Lógica de reconexión si es necesaria
        },
        onError: (error) {
          _isConnected = false;
          print("WebSocketService: Error en la conexión: $error");
        },
      );
    } catch (e) {
      _isConnected = false;
      print("WebSocketService: Error al iniciar la conexión: $e");
    }
  }

  // 5. Manejar el mensaje: Añadir datos al Stream
  void _handleMessage(dynamic data) {
    print("WebSocketService: Mensaje recibido: $data");
    // ✅ Añadir el dato recibido al Stream para que los BLoCs reaccionen
    if (!_messageController.isClosed) {
      _messageController.add(data); 
    }
  }

  // 6. Enviar datos al servidor
  void sendMessage(dynamic data) {
    if (_isConnected && _channel != null) {
      // Si envías JSON, usa jsonEncode(data)
      _channel!.sink.add(data);
    } else {
      print("WebSocketService: Error, no conectado. No se puede enviar: $data");
    }
  }

  // 7. Limpieza de recursos (¡Crucial!)
  void dispose() {
    _channel?.sink.close();
    _messageController.close(); // ✅ CERRAR EL CONTROLLER
    _isConnected = false;
    print("WebSocketService: Recursos liberados.");
  }
}