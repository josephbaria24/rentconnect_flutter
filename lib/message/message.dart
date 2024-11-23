// ignore_for_file: no_leading_underscores_for_local_identifiers, avoid_print

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rentcon/message/conversationPage.dart';
import 'package:rentcon/provider/conversation.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:http/http.dart' as http;

import '../pages/toast.dart';

class MessagePage extends StatefulWidget {
  final String token;
  final String email;

  const MessagePage({
    required this.token,
    required this.email,
    Key? key,
  }) : super(key: key);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late FToast ftoast;
  late String email;
  late String userId;
  late ToastNotification toast;
  final themeController = Get.find<ThemeController>();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> conversations = [];
  List<Map<String, dynamic>> filteredConversations = [];
   List<Map<String, dynamic>> filteredDialogUsers = [];
  bool isLoadingUsers = true; // Loading state for users
  bool isLoadingConversations = true; // Loading state for conversations
  List<Map<String, dynamic>> filteredUsers = [];


   final TextEditingController searchController = TextEditingController();
    final TextEditingController userSearchController = TextEditingController(); // Controller for dialog search
  late ToastNotification toastNotification;
  @override
  void initState() {
    super.initState();
    email = JwtDecoder.decode(widget.token)['email']?.toString() ?? 'Unknown email';
    userId = JwtDecoder.decode(widget.token)['_id']?.toString() ?? 'Unknown ID';
    ftoast = FToast();
    ftoast.init(context);
    fetchUsers();
    fetchConversations();
    searchController.addListener(searchConversations);
    toastNotification = ToastNotification(context);
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('https://rentconnect.vercel.app/users-with-profiles'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          users = List<Map<String, dynamic>>.from(json.decode(response.body)['users']);
          filteredDialogUsers = users; // Initialize with all users
          isLoadingUsers = false;
        });
      } else {
        print('Failed to fetch users: ${response.body}');
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }





Future<void> fetchConversations({bool refresh = false}) async {
  try {
    final response = await http.get(
      Uri.parse('https://rentconnect.vercel.app/conversations/$userId'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      Provider.of<ConversationProvider>(context, listen: false).fetchConversations(
        List<Map<String, dynamic>>.from(json.decode(response.body)),
      );
    } else {
      print('Failed to fetch conversations: ${response.body}');
    }
  } catch (e) {
    print('Error fetching conversations: $e');
  }
}

  Future<void> refreshConversations() async {
    setState(() => isLoadingConversations = true);
    await fetchConversations();
  }


  void searchConversations() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredConversations = conversations.where((conversation) {
        final name = '${conversation['firstName'] ?? ''} ${conversation['lastName'] ?? ''}'.toLowerCase();
        final email = conversation['email']?.toLowerCase() ?? '';
        return name.contains(query) || email.contains(query);
      }).toList();
    });
  }



void _showUserSelectionDialog() {
  userSearchController.clear(); // Clear search field on opening the dialog
  // Filter out the current user's email before showing the dialog
  filteredDialogUsers = users.where((user) => user['email'] != widget.email).toList();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          // Listener for search input to filter users
          userSearchController.addListener(() {
            final query = userSearchController.text.toLowerCase();
            setState(() { // Localized setState for this dialog
              filteredDialogUsers = users.where((user) {
                final email = user['email']?.toLowerCase() ?? '';
                return email.contains(query) && user['email'] != widget.email; // Ensure current user's email is not shown
              }).toList();
            });
          });

          return AlertDialog(
            backgroundColor: themeController.isDarkMode.value ? const Color.fromARGB(255, 37, 37, 43) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Column(
              children: [
                Text(
                  "Select a Recipient",
                  style: TextStyle(
                    fontFamily: 'manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 40),
                  child: TextField(
                    controller: userSearchController,
                    decoration: InputDecoration(
                      labelText: 'Search by email',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ],
            ),
            content: isLoadingUsers
                ? Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12), // 5 radius for rounded corners
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
              child: Container(
                width: 100, // Adjust size as needed
                height: 100,
                color:themeController.isDarkMode.value? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.2), // Frosted glass effect
                child: Center(
                  child: CupertinoActivityIndicator(color: themeController.isDarkMode.value? Colors.white : Colors.black), // Your indicator
                ),
              ),
            ),
          ),
        )
                : SizedBox(
                    height: 300,
                    width: 300,
                    child: ListView.builder(
                      itemCount: filteredDialogUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredDialogUsers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user['profilePicture'] ?? 'https://st3.depositphotos.com/6672868/14508/v/380/depositphotos_145085237-stock-illustration-user-profile-group.jpg'),
                          ),
                          title: Text(
                            user['email'],
                            style: TextStyle(
                              fontFamily: 'manrope',
                              fontSize: 14,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConversationPage(
                                  userToken: widget.token,
                                  recipient: user['_id'],
                                  recipientName: user['email'],
                                  recipientProfilePicture: user['profilePicture'] ?? 'https://st3.depositphotos.com/6672868/14508/v/380/depositphotos_145085237-stock-illustration-user-profile-group.jpg',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
            actions: [
              TextButton(
                child: Text(
                  "Close",
                  style: TextStyle(
                    color: themeController.isDarkMode.value ? Colors.white : Colors.black,
                    fontFamily: 'manrope',
                  ),
                ),
                onPressed: () {
                  userSearchController.clear(); // Clear search field on close
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    },
  );
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: themeController.isDarkMode.value ? Color.fromRGBO(28, 29, 34, 1) : Colors.white,
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          children: [
            Text(
              'Messages',
              style: TextStyle(
                fontFamily: 'manrope',
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 5),
            Lottie.asset('assets/icons/messages.json',
            height: 40,
            repeat: false)
          ],
        ),
      ),
    ),
    backgroundColor: themeController.isDarkMode.value ? Color.fromRGBO(28, 29, 34, 1) : Colors.white,
    floatingActionButton: FloatingActionButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      backgroundColor: themeController.isDarkMode.value ? Colors.white : const Color.fromARGB(255, 0, 0, 0),
      onPressed: _showUserSelectionDialog,
      child: Icon(
        LineAwesomeIcons.pencil_alt_solid,
        color: themeController.isDarkMode.value ? Colors.black : Colors.white,
      ),
    ),
    body: Consumer<ConversationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12), // 5 radius for rounded corners
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
              child: Container(
                width: 100, // Adjust size as needed
                height: 100,
                color:themeController.isDarkMode.value? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.2), // Frosted glass effect
                child: Center(
                  child: CupertinoActivityIndicator(color: themeController.isDarkMode.value? Colors.white : Colors.black), // Your indicator
                ),
              ),
            ),
          ),
        );
        }

        final filteredConversations = provider.conversations; // Assuming you have a list of conversations in your provider

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: themeController.isDarkMode.value
                            ? Colors.grey[900]!
                            : const Color(0xff101617).withOpacity(0.09),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                        spreadRadius: 0.1,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: themeController.isDarkMode.value
                          ? const Color.fromARGB(255, 36, 38, 43)
                          : Colors.white,
                      contentPadding: const EdgeInsets.all(15),
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        color: themeController.isDarkMode.value
                            ? Colors.grey
                            : const Color(0xffDDDADA),
                        fontSize: 14,
                      ),
                      prefixIcon: GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(0, 54, 231, 163),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(7.0),
                              child: Image.asset(
                                'assets/icons/search.png',
                                color: themeController.isDarkMode.value
                                    ? const Color.fromARGB(255, 255, 255, 255)
                                    : Colors.black,
                                width: 15.0,
                                height: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: refreshConversations,
                    child: filteredConversations.isEmpty // Check if there are no conversations
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                'assets/icons/noMessage.json', // Add your Lottie animation file here
                                width: 200,
                                height: 200,
                                repeat: false
                              ),
                              
                              Text(
                                'No messages yet!',
                                style: TextStyle(
                                  fontFamily: 'manrope',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: themeController.isDarkMode.value ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredConversations.length,
                          itemBuilder: (context, index) {
                            final conversation = filteredConversations[index];
                            final timeString = conversation['time'] ?? '';
                            final formattedTime = _formatTime(timeString);
                            return _buildMessageTile(
                              profileImageUrl: conversation['profilePicture'] ?? 'https://st3.depositphotos.com/6672868/14508/v/380/depositphotos_145085237-stock-illustration-user-profile-group.jpg',
                              name: '${conversation['firstName'] ?? 'Unverified'} ${conversation['lastName'] ?? 'User'}',
                              message: conversation['lastMessage'] ?? '',
                              time: formattedTime,
                              isRead: conversation['isRead'] ?? false,
                              unreadMessages: conversation['unreadMessages'] ?? 0,
                              recipientId: conversation['recipientId'],
                            );
                          },
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

  String _formatTime(String timeString) {
    try {
      final dateTime = DateTime.parse(timeString);
      return DateFormat.jm().format(dateTime);
    } catch (e) {
      return timeString;
    }
  }


  // Add this method to show the bottom modal
void _showBottomModal(String recipientId) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.mark_email_unread),
              title: Text("Mark as Unread"),
              onTap: () {
                Navigator.pop(context);
                _markMessagesAsUnread(recipientId);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text("Delete Conversation"),
              onTap: () {
                Navigator.pop(context);
                _deleteConversation(recipientId);
              },
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildMessageTile({
  required String profileImageUrl,
  required String name,
  required String message,
  required String time,
  required String recipientId,
  bool isRead = false,
  int unreadMessages = 0,
}) {
  return Dismissible(
    key: ValueKey(recipientId),
    direction: DismissDirection.endToStart,
    background: Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20),
      child: Icon(Icons.delete, color: Colors.white),
    ),
    onDismissed: (direction) {
      // Remove the conversation
      _deleteConversation(recipientId);
    },
    child: GestureDetector(
      onLongPress: () => _showBottomModal(recipientId),
      onTap: () async {
         await _markConversationAsRead(recipientId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationPage(
              userToken: widget.token,
              recipient: recipientId,
              recipientName: name,
              recipientProfilePicture: profileImageUrl.isNotEmpty
                  ? profileImageUrl
                  : 'https://st3.depositphotos.com/6672868/14508/v/380/depositphotos_145085237-stock-illustration-user-profile-group.jpg',
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(profileImageUrl),
          ),
          title: Text(
            name,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
               fontWeight: isRead ? FontWeight.w500 : FontWeight.bold, // Bold if unread
              fontFamily: "manrope",
              fontSize: 15,
              color: themeController.isDarkMode.value ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: "manrope",
              fontWeight: isRead ? FontWeight.w400 : FontWeight.bold,
              color: themeController.isDarkMode.value ? Colors.grey[300] : Colors.black54,
            ),
          ),
          trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
           
            
            Text(
              time,
              style: TextStyle(
                fontFamily: "manrope",
                fontWeight:  isRead? FontWeight.w600 :  FontWeight.w700,
                color: themeController.isDarkMode.value ? Colors.grey[300] : Colors.black54,
              ),
            ),
            SizedBox(width: 8),
             if (!isRead) // Show blue dot if there are unread messages
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    ),
  ));
}



Future<void> _markMessagesAsUnread(String recipientId) async {
  try {
    final response = await http.patch(
      Uri.parse('https://rentconnect.vercel.app/messages/markAsUnread'), // Ensure the URL is correct
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'recipient': recipientId, // Send recipientId in the body
      }),
    );

    if (response.statusCode == 200) {
      // Assuming the response contains the updated conversation
      final data = json.decode(response.body);
      
      // Update the UI to reflect the change
      Provider.of<ConversationProvider>(context, listen: false)
          .updateConversationAsUnread(recipientId);
      
    } else {
      throw Exception('Failed to mark messages as unread');
    }
  } catch (error) {
    print('Error marking messages as unread: $error');
    // Handle error, e.g., show a Snackbar
  }
}

  Future<void> _markConversationAsRead(String recipientId) async {
    try {
      final response = await http.patch(
        Uri.parse('https://rentconnect.vercel.app/messages/markAsRead'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
        'recipient': recipientId, // Send recipientId in the body
      }),
      );

      if (response.statusCode == 200) {
      } else {
        // Handle error response
        print('Failed to mark conversation as read: ${response.body}');
      }
    } catch (e) {
      print('Error marking conversation as read: $e');
    }
  }

Future<void> _deleteConversation(String recipientId) async {
  try {
    print('Attempting to delete conversation between $userId and $recipientId');

    final response = await http.patch(
      Uri.parse('https://rentconnect.vercel.app/messages/markAsDeleted'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({'userId': userId, 'recipientId': recipientId}),
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      // Call the provider to remove the conversation
      Provider.of<ConversationProvider>(context, listen: false).removeConversation(recipientId);

      toastNotification.success('Conversation deleted');
    } else {
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      throw Exception('Failed to mark conversation as deleted');
    }
  } catch (error) {
    print('Error deleting conversation: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete conversation')),
    );
  }
}
}
