import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final String _url = 'wss://mc37wrds-8000.inc1.devtunnels.ms/api/v1/ws/a7af3df4-0734-4068-b073-f2ed29d967dd/2025-02-24'; // Replace with your WebSocket server URL
  final String _token;

  // Constructor
  WebSocketService(this._token);

  // Connect to WebSocket server
  void connect() {
    // Create WebSocket connection with authentication token
    _channel = WebSocketChannel.connect(Uri.parse('$_url?token=$_token'));
    print("Connected to WebSocket at ");
  }

  // Send message through WebSocket
  void sendMessage(String message) {
    _channel?.sink.add(message);
  }

  Stream<dynamic> get messages {
    return _channel!.stream.map((message) {
      // Log the incoming message to the console
      print('Received message: $message');
      return message;
    });
  }

  // Close connection
  void disconnect() {
    _channel?.sink.close();
  }
}