import 'dart:async';

/// StreamController for logout events
/// Used to notify providers when user should be logged out (e.g., on 401 errors)
final logoutEventController = StreamController<bool>.broadcast();
