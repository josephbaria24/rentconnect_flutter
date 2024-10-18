import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/theme_controller.dart';
import 'toast.dart'; // Import ToastNotification

class MessagePage extends StatefulWidget {
  final String token;
  const MessagePage({required this.token, Key? key}) : super(key: key);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late String email;
  late FToast ftoast;
  late ToastNotification toast;
  final themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    email = JwtDecoder.decode(widget.token)['email']?.toString() ?? 'Unknown email';
  }

  @override
  Widget build(BuildContext context) {
    // Initialize FToast and ToastNotification here
    ftoast = FToast();
    ftoast.init(context);

    return Scaffold(
      backgroundColor: themeController.isDarkMode.value ? Color.fromRGBO(28, 29, 34, 1) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search bar at the top
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: themeController.isDarkMode.value ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search message...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Icon(Icons.tune, color: Colors.grey),
                  ],
                ),
              ),
              SizedBox(height: 20),
              
              // Messages list
              Expanded(
                child: ListView(
                  children: [
                    // Sample chat tiles
                    _buildMessageTile(
                      profileImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
                      name: 'Sebastian Rudiger',
                      message: 'Perfect! Will check it 🔥',
                      time: '09:34 PM',
                      isUnread: false,
                    ),
                    _buildMessageTile(
                      profileImageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
                      name: 'Caroline Varsaha',
                      message: 'Thanks, Jimmy! Talk later',
                      time: '08:12 PM',
                      isUnread: true,
                      unreadMessages: 2,
                    ),
                    _buildMessageTile(
                      profileImageUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
                      name: 'Darshan Patelchi',
                      message: 'Sound good for me too!',
                      time: '02:29 PM',
                      isUnread: true,
                      unreadMessages: 3,
                    ),
                    _buildMessageTile(
                      profileImageUrl: 'https://randomuser.me/api/portraits/men/4.jpg',
                      name: 'Mohammed Arnold',
                      message: 'No rush, mate! Just let...',
                      time: '01:08 PM',
                      isUnread: false,
                    ),
                    _buildMessageTile(
                      profileImageUrl: 'https://randomuser.me/api/portraits/women/5.jpg',
                      name: 'Tamara Schipchinskaya',
                      message: 'Okay, I’ll tell him about it',
                      time: '11:15 AM',
                      isUnread: false,
                    ),
                    _buildMessageTile(
                      profileImageUrl: 'https://randomuser.me/api/portraits/women/6.jpg',
                      name: 'Ariana Amberline',
                      message: 'Good night, Honey! ❤️',
                      time: 'Yesterday',
                      isUnread: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageTile({
    required String profileImageUrl,
    required String name,
    required String message,
    required String time,
    bool isUnread = false,
    int unreadMessages = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(profileImageUrl),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: themeController.isDarkMode.value ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          message,
          style: TextStyle(
            color: themeController.isDarkMode.value ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: isUnread ? Colors.blue : Colors.grey,
              ),
            ),
            if (isUnread)
              Container(
                margin: EdgeInsets.only(top: 4),
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadMessages.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
