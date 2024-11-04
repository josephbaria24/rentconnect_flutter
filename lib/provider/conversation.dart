import 'package:flutter/material.dart';

class ConversationProvider with ChangeNotifier {
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> get conversations => _conversations;

  bool isLoading = true;

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  void fetchConversations(List<Map<String, dynamic>> newConversations) {
    _conversations = newConversations;
    isLoading = false;
    notifyListeners();
  }

  void addConversation(Map<String, dynamic> conversation) {
    _conversations.add(conversation);
    notifyListeners();
  }

   // New method to update the conversation as unread
  void updateConversationAsUnread(String recipientId) {
    for (var conversation in _conversations) {
      if (conversation['recipientId'] == recipientId) {
        conversation['isRead'] = false; // Mark as unread
        notifyListeners(); // Notify listeners to rebuild the UI
        break;
      }
    }
  }

  void removeConversation(String recipientId) {
    _conversations.removeWhere((conversation) => conversation['recipientId'] == recipientId);
    notifyListeners();
  }
}
