class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  late String email;
  late String userId;
  late String userRole;
  late String profileStatus;
  // You can add other variables as needed
}
