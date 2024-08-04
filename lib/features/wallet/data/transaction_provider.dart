import 'dart:ffi';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoozoowin_/core/app_imports.dart';

class TransactionProvider with ChangeNotifier {
  List<dynamic> _allTrans = [];
  List<dynamic> get allTrans => _allTrans;
  List<dynamic> _addCashAmount = [];
  List<dynamic> get addCashAmount => _addCashAmount;

  List<dynamic> _withdrawCashAmount = [];
  List<dynamic> get withdrawCashAmount => _withdrawCashAmount;

  List<dynamic> _bonusCashAmount = [];
  List<dynamic> get bonusCashAmount => _bonusCashAmount;

  List<dynamic> _wonCashAmount = [];
  List<dynamic> get wonCashAmount => _wonCashAmount;

  List<dynamic> _deductCashAmount = [];
  List<dynamic> get deductCashAmount => _deductCashAmount;

  TransactionProvider() {
    _initializeStream();
  }

  Future<void> _initializeStream() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ref = FirebaseDatabase.instance
        .ref('username')
        .child(prefs.getString('phone') ?? '');

    ref.child('allTrans').onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        _allTrans = List<dynamic>.from(event.snapshot.value as List);
        // _allTrans = _allTrans.reversed.toList();
        notifyListeners();
      }
    });

    ref.child('addCashAmount').onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        _addCashAmount = List<dynamic>.from(event.snapshot.value as List);
        // _addCashAmount = _addCashAmount.reversed.toList();
        notifyListeners();
      }
    });

    ref.child('bonusCashAmount').onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        _bonusCashAmount = List<dynamic>.from(event.snapshot.value as List);
        // _bonusCashAmount = _bonusCashAmount.reversed.toList();
        notifyListeners();
      }
    });

    ref.child('withdrawCashAmount').onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        _withdrawCashAmount = List<dynamic>.from(event.snapshot.value as List);
        // _withdrawCashAmount = _withdrawCashAmount.reversed.toList();
        notifyListeners();
      }
    });

    ref.child('wonCashAmount').onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        _wonCashAmount = List<dynamic>.from(event.snapshot.value as List);
        // _wonCashAmount = _wonCashAmount.reversed.toList();
        notifyListeners();
      }
    });

    ref.child('deducted').onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        _deductCashAmount = List<dynamic>.from(event.snapshot.value as List);
        // _deductCashAmount = _deductCashAmount.reversed.toList();
        notifyListeners();
      }
    });
  }

  Future<void> allTransUpdate(String formattedDate, String formattedTime,
      double amt, String title, String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ref = FirebaseDatabase.instance
        .ref('username')
        .child(prefs.getString('phone') ?? '');

    await ref.child('allTrans').onValue.listen((event) async {
      if (event.snapshot.exists && event.snapshot.value != null) {
        _allTrans = List<dynamic>.from(event.snapshot.value as List);
        // _allTrans = _allTrans.reversed.toList();
        notifyListeners();
      }
    });

    DateTime d = DateTime.now();

    List<dynamic> h = _allTrans;
    h.add({
      'date': formattedDate,
      'timeSlot': formattedTime,
      'time': DateFormat('HH:mm:ss').format(DateTime.now()),
      'title': title,
      'amount': amt,
      'type': type
    });
    // h = h.reversed.toList();
    await ref.update({
      'allTrans': h,
    });
  }

  Future<void> deductedAmount(String formattedDate, String formattedTime,
      double amt, String title, String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ref = FirebaseDatabase.instance
        .ref('username')
        .child(prefs.getString('phone') ?? '');

    await ref.child('deducted').onValue.listen((event) async {
      if (event.snapshot.exists && event.snapshot.value != null) {
        _deductCashAmount = List<dynamic>.from(event.snapshot.value as List);
        // _deductCashAmount = _deductCashAmount.reversed.toList();
        notifyListeners();
      }
    });

    DateTime d = DateTime.now();

    List<dynamic> h = _deductCashAmount;
    h.add({
      'date': formattedDate,
      'timeSlot': formattedTime,
      'time': DateFormat('HH:mm:ss').format(DateTime.now()),
      'title': title,
      'amount': amt,
      'type': type
    });
    // h = h.reversed.toList();
    await ref.update({
      'deducted': h,
    });
  }
}
