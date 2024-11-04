import 'package:flutter/foundation.dart';
import 'package:rentcon/models/message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MessageProvider with ChangeNotifier {
  List<Message> messages = [];
  IO.Socket? _socket;

  MessageProvider() {
    _initSocket();
  }

  void _initSocket() {
    _socket = IO.io('http://192.168.1.12:3000', // Change to your server's address
      IO.OptionBuilder()
        .setTransports(['websocket']) // Specify the transport method
        .setQuery({'email': 'user_email_here'}) // Replace with actual user email
        .build());

    // Listen for connection
    _socket?.on('connect', (_) {
      print('Connected to the socket server');
    });

    // Listen for messages from the server
    _socket?.on('message', (data) {
      Message newMessage = Message(
        message: data['message'],
        sender: data['sender'],
        recipient: data['recipient'],
        sentAt: DateTime.fromMillisecondsSinceEpoch(data['sentAt']),
      );
      addNewMessage(newMessage);
    });

    // Handle disconnection
    _socket?.on('disconnect', (_) {
      print('Disconnected from the socket server');
    });
  }

  void deleteMessage(String messageId) {
  messages.removeWhere((message) => message.id == messageId);
  notifyListeners(); // Ensure the UI is notified of the change
}

  // Method to add a new message
  void addNewMessage(Message message) {
    if (message.message.trim().isEmpty) {
      print('Cannot add an empty message');
      return;
    }

   
    if (!messages.any((m) =>
        m.message == message.message &&
        m.sender == message.sender &&
        m.recipient == message.recipient)) {
      messages.add(message);
      print('Added new message: ${message.message} from ${message.sender} to ${message.recipient} at ${message.sentAt}');

      notifyListeners();
    }
  }
  

  
  List<Message> getMessagesForRecipient(String recipient) {
    return messages.where((data) =>
        data.recipient == recipient || data.sender == recipient).toList();
  }

}
