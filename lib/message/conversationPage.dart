// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:rentcon/models/message.dart';
import 'package:rentcon/provider/conversation.dart';
import 'package:rentcon/provider/message.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

class ConversationPage extends StatefulWidget {
  final String userToken;
  final String recipient;
   final String recipientName;
  final String recipientProfilePicture;
  const ConversationPage({required this.userToken, required this.recipient, required this.recipientName, required this.recipientProfilePicture,Key? key}) : super(key: key);

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage>  with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> messages = []; // Store messages as a list of maps
  final ThemeController _themeController = Get.find<ThemeController>();
  late IO.Socket _socket;
  late String email;
  late String userId;


  @override
  void initState() {
    super.initState();
    userId = JwtDecoder.decode(widget.userToken)['_id']?.toString() ?? 'Unknown email';
    email = JwtDecoder.decode(widget.userToken)['email']?.toString() ?? 'Unknown email';
    _socket = IO.io('http://192.168.1.12:3000', 
  IO.OptionBuilder().setTransports(['websocket']).setQuery({'email': userId}).build());

    _connectSocket();
    _fetchMessages();
    _fetchMessages(clearMessages: true);
    
  }


_fetchMessages({bool clearMessages = false}) async {
  if (clearMessages) {
    Provider.of<MessageProvider>(context, listen: false).messages.clear(); // Clear existing messages
  }

  try {
    final response = await http.get(
      Uri.parse('https://rentconnect.vercel.app/messages?sender=$userId&recipient=${widget.recipient}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> messageList = json.decode(response.body);
      for (var msg in messageList) {
        // Skip messages that are deleted for this user
        if (msg['deleted'] != null && msg['deleted'][userId] == true) {
          continue;
        }
        Provider.of<MessageProvider>(context, listen: false).addNewMessage(Message.fromJson(msg));
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } else {
      print('Failed to load messages: ${response.body}');
    }
  } catch (error) {
    print('Error fetching messages: $error');
  }
}

_connectSocket() {
  _socket.onConnect((_) {
    print('Connected to socket server');
  });

  _socket.onConnectError((data) {
    print('Connection error: $data');
  });

  _socket.onDisconnect((_) {
    print('Disconnected from socket server');
  });
  _socket.on('deleteMessage', (data) {
  final messageId = data['messageId'];
  Provider.of<MessageProvider>(context, listen: false).deleteMessage(messageId);
});
  
  

  // Listen for incoming messages
  _socket.on('message', (data) {
  print('Received message: $data'); // Debugging the incoming message

  if (mounted) {
    final newMessage = Message.fromJson(data);

    if (newMessage.message.isNotEmpty) {
      Provider.of<MessageProvider>(context, listen: false).addNewMessage(newMessage);
       WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom()); // Optionally scroll to the bottom after receiving the message
    } else {
      print('Received an empty message. Skipping...');
    }
  }
});

}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Scroll to the bottom when the widget is rebuilt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

void _scrollToBottom() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  });
}

// Call this method after the provider updates the UI

 

  Future<void> _sendMessage() async {
    final messageContent = _messageController.text.trim();
    if (messageContent.isEmpty) {
      print('Cannot send an empty message');
      return;
    }

    final messageData = {
      'content': messageContent,
      'sender': userId,
      'recipient': widget.recipient,
      'sentAt': DateTime.now().millisecondsSinceEpoch,
    };

    Provider.of<MessageProvider>(context, listen: false).addNewMessage(
      Message(
        message: messageContent,
        sender: userId,
        recipient: widget.recipient,
        sentAt: DateTime.now(),
      ),
    );

    _messageController.clear();
    _scrollToBottom(); // Scroll after sending a message

    try {
      final response = await http.post(
        Uri.parse('https://rentconnect.vercel.app/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(messageData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save message');
      }

      _socket.emit('message', messageData);
    } catch (error) {
      print('Error sending message: $error');
    }
  }

Future<List<Map<String, dynamic>>> fetchConversationsFromApi() async {
  try {
    final response = await http.get(
      Uri.parse('https://rentconnect.vercel.app/conversations/${userId}'),
      headers: {'Authorization': 'Bearer ${widget.userToken}'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load conversations');
    }
  } catch (e) {
    print('Error fetching conversations: $e');
    return []; // Return an empty list on error
  }
}

  @override
  void dispose() {
     WidgetsBinding.instance.removeObserver(this);
  _socket.dispose(); // Ensure the socket is disposed
     _messageController.dispose();
      _scrollController.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();



  String formatTimestamp(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
  bool shouldShowTimestamp(DateTime currentMessageTime, DateTime? lastMessageTime) {
    if (lastMessageTime == null) return true;
    return currentMessageTime.difference(lastMessageTime).inHours >= 1;
  }
@override
Widget build(BuildContext context) {
  return WillPopScope(
     onWillPop: () async {
        // Fetch conversations when the back button is pressed
        List<Map<String, dynamic>> newConversations = await fetchConversationsFromApi();
        Provider.of<ConversationProvider>(context, listen: false).fetchConversations(newConversations);
        return true; // Allow the back navigation
      },
    child: Scaffold(
      resizeToAvoidBottomInset: true, // Allows the screen to adjust when the keyboard is shown
      backgroundColor: _themeController.isDarkMode.value ? const Color.fromARGB(255, 20, 20, 20) : Colors.white,
      appBar: AppBar(
        backgroundColor: _themeController.isDarkMode.value ? const Color.fromARGB(255, 20, 20, 20) : Colors.white,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.recipientProfilePicture),
            ),
            const SizedBox(width: 10),
            Expanded(  // Prevent overflow by expanding and allowing ellipsis
              child: Text(
                widget.recipientName,
                style: const TextStyle(
                  fontFamily: 'manrope',
                  fontSize: 17,
                ),
                overflow: TextOverflow.ellipsis,  // Add ellipsis for long names
              ),
            ),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 12.0),
          child: SizedBox(
            height: 40,
            width: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: BorderSide(
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                  width: 0.90,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
               onPressed: () async {
          Navigator.pop(context);
          List<Map<String, dynamic>> newConversations = await fetchConversationsFromApi();
          Provider.of<ConversationProvider>(context, listen: false).fetchConversations(newConversations);
        },
              child: Icon(
                Icons.chevron_left,
                color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                size: 16,
              ),
            ),
          ),
        ),
      ),
    
      body: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.0), // Adjust for keyboard
        child: Column(
          children: [
            Expanded(
              child: Consumer<MessageProvider>(
                builder: (_, provider, __) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  final recipientMessages = provider.getMessagesForRecipient(widget.recipient);
    
                  if (recipientMessages.isEmpty) {
                    return const Center(
                      child: Text("No messages with this recipient."),
                    );
                  }
    
                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: recipientMessages.length,
                    itemBuilder: (context, index) {
                      final message = recipientMessages[index];
                      final isSender = message.sender == userId;
                      final DateTime? lastMessageTime = index > 0 ? recipientMessages[index - 1].sentAt : null;
                      final bool showTimestamp = shouldShowTimestamp(message.sentAt, lastMessageTime);
    
                      return Column(
                        crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (showTimestamp) 
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  formatTimestamp(message.sentAt),
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                decoration: BoxDecoration(
                                  color: isSender
                                      ? const Color.fromARGB(255, 156, 247, 194)
                                      : (_themeController.isDarkMode.value ? const Color.fromARGB(255, 170, 170, 170) : const Color.fromARGB(255, 223, 223, 223)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  message.message,
                                  style: TextStyle(
                                    color: isSender ? Colors.black : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (_, index) => const SizedBox(height: 5),
                  );
                },
              ),
            ),
            Container(
              color: const Color.fromARGB(0, 238, 238, 238),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: _themeController.isDarkMode.value ? const Color.fromARGB(221, 83, 83, 83) : const Color.fromARGB(179, 182, 182, 182),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: TextField(
                              cursorColor: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintStyle: TextStyle(
                                  fontFamily: 'manrope',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w300,
                                ),
                                hintText: 'Type your message here...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 11),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: _themeController.isDarkMode.value ? const Color.fromARGB(255, 14, 223, 122) : const Color.fromARGB(255, 31, 31, 31),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (_messageController.text.trim().isNotEmpty) {
                            _sendMessage();
                          }
                        },
                        icon: const Icon(Icons.send_rounded, size: 22),
                        color: Colors.white,
                        alignment: Alignment.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}