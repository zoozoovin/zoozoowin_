import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:zoozoowin_/core/constants/app_data.dart';

class HomeProvider with ChangeNotifier {
  int _totalCount = 0;
  int get totalCount => _totalCount;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _tc = "";
  String get tc => _tc;

  HomeProvider() {
    // initializeStream();
    fetchData();
  }

  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('result_game1');
  Map<String, dynamic>? _data;
  Map<String, dynamic>? get data => _data;

  List<StreamSubscription<DatabaseEvent>> _subscriptions = [];

  Future<void> initializeStream() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DatabaseReference ref = FirebaseDatabase.instance.ref('Game1');
    DateTime now = DateTime.now();
    String formattedDate =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    _totalCount = 0; // Reset the count at the beginning

    for (String slot in AppData.timeSlots) {
      DatabaseReference slotRef =
          ref.child('${formattedDate}_$slot/${prefs.getString('phone')}');

        DataSnapshot snapshot = await slotRef.get();
        if (snapshot.value != null) {
          _totalCount++;
        }
        notifyListeners(); // Notify listeners for each change
  

    }
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();
    print("Fetch data ==============================================");
    DateTime now = DateTime.now();
    String todayDate = DateFormat('dd-MM-yyyy').format(now);
    int currentHour = now.hour;
    int hourToFetch = currentHour - 1;

    String formattedTime;
    if (hourToFetch >= 12) {
      formattedTime = DateFormat('hh:00 a')
          .format(DateTime(now.year, now.month, now.day, hourToFetch));
      String key = '${todayDate}_$formattedTime';
      _setUpDataListener(key);
    } else {
      DateTime previousDay = now.subtract(Duration(days: 1));
      String previousDate = DateFormat('dd-MM-yyyy').format(previousDay);
      String key = '${previousDate}_11:00 PM';
      _tc = "11:00 PM";
      _setUpDataListener(key);
    }
  }

  void _setUpDataListener(String key) {
    // Cancel any previous subscriptions
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Set up a new listener
    StreamSubscription<DatabaseEvent> subscription =
        _databaseReference.child(key).onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.value != null) {
        _data = Map<String, dynamic>.from(snapshot.value as Map);
        _tc = key.split('_').last;
      } else {
        _data = null;
      }
      _isLoading = false;
      notifyListeners();
    });
    _subscriptions.add(subscription);
  }

  @override
  void dispose() {
    // Cancel all subscriptions
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
