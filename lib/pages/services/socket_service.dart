// lib/services/socket_service.dart

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  IO.Socket? _socket;

  SocketService._internal();

  void connect() {
    if (_socket == null) {
      _socket = IO.io('http://192.168.1.12:3000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      _socket!.onConnect((_) {
        print('Connected to socket server');
      });

      _socket!.onDisconnect((_) {
        print('Disconnected from socket server');
      });
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void listen(String event, void Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }
}
