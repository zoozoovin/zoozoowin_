import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider with ChangeNotifier {
  String _profileName = "";
  String get profileName => _profileName;
  String _phone = "";
  String get pphone => _phone;

  ProfileProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _phone = prefs.getString('phone') ?? '';
    notifyListeners();
    final ref = FirebaseDatabase.instance
        .ref('username')
        .child(prefs.getString('phone') ?? '');
    DataSnapshot snapshot = await ref.child('profileName').get();
    if (snapshot.exists) {
      _profileName = snapshot.value.toString();
      notifyListeners();
    }
  }

  Future<void> changeName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ref = FirebaseDatabase.instance
        .ref('username')
        .child(prefs.getString('phone') ?? '');
    await ref.update({
      'profileName': name,
    });
    _profileName = name;
    notifyListeners();
  }
}
