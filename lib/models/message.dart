class Message {
  final String? id;
  final String message;
  final String sender;
  final String recipient;
  final DateTime sentAt;
  final bool isRead; // Add the isRead field
  final Map<String, bool>? deleted; // Track soft deletion

  Message({
    this.id,
    required this.message,
    required this.sender,
    required this.recipient,
    required this.sentAt,
    this.isRead = false, // Default value for isRead
    this.deleted, // Initialize the deleted field
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    final sentAtValue = json['sentAt'];
    DateTime sentAt;

    if (sentAtValue is int) {
      sentAt = DateTime.fromMillisecondsSinceEpoch(sentAtValue);
    } else if (sentAtValue is String) {
      try {
        sentAt = DateTime.parse(sentAtValue);
      } catch (e) {
        sentAt = DateTime.now(); // Fallback if parsing fails
      }
    } else {
      sentAt = DateTime.now(); // Fallback if sentAt is missing
    }

    return Message(
      id: json['_id'], // Assuming the ID is provided in the JSON
      message: json['content']?.toString() ?? '',
      sender: json['sender']?.toString() ?? '',
      recipient: json['recipient']?.toString() ?? '',
      sentAt: sentAt,
      isRead: json['isRead'] ?? false, // Initialize isRead from JSON, default to false
      deleted: json['deleted'] != null ? Map<String, bool>.from(json['deleted']) : null, // Handle deleted field
    );
  }
}
