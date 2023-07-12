import 'package:flutter/foundation.dart';
import 'package:vital_monitor/logic/models/userModel.dart';

class UserProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void logout() {
    _user = User(null, null, null);
    notifyListeners();
  }
}
