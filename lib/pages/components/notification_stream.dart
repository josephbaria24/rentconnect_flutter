import 'dart:async';

class NotificationStream {
  // StreamController to manage the stream
  final StreamController<List<dynamic>> _controller = StreamController<List<dynamic>>.broadcast();

  // Getter for the stream
  Stream<List<dynamic>> get stream => _controller.stream;

  // Method to add notifications to the stream
  void addNotification(List<dynamic> notifications) {
    _controller.add(notifications);
  }

  // Dispose method to close the stream
  void dispose() {
    _controller.close();
  }
}
