import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoozoowin_/core/managers/shared_preference_manager.dart';
import 'package:zoozoowin_/features/notificaiton_provider.dart';
import 'package:zoozoowin_/features/wallet/data/transaction_provider.dart';
import 'package:zoozoowin_/notification_service.dart';

class WalletProvider extends ChangeNotifier {
  List<dynamic> _addCashAmount = [];
  List<dynamic> get addCashAmount => _addCashAmount;

  double _lastAddedCashAmount = 0.0;
  double get lastAddedCashAmount => _lastAddedCashAmount;
  double _lastWithdrawCashAmount = 0.0;
  double get lastWithdrawCashAmount => _lastWithdrawCashAmount;

  List<dynamic> _bonusCashAmount = [];
  List<dynamic> get bonusCashAmount => _bonusCashAmount;

  double _totalBonusCashAmount = 0.0;
  double get totalBonusCashAmount => _totalBonusCashAmount;

  List<dynamic> _withdrawCashAmount = [];
  List<dynamic> get withdrawCashAmount => _withdrawCashAmount;

  double _walletBalance = 0.0;
  double get walletBalance => _walletBalance;

  int _point = 0;
  int get point => _point;

  NotificaitonProvider noti = NotificaitonProvider();

  WalletProvider() {
    _initializeWalletStreams();
  }

  Future<void> _initializeWalletStreams() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ref = FirebaseDatabase.instance
        .ref('username')
        .child(prefs.getString('phone') ?? '');

    ref.child('addCashAmount').onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        _addCashAmount = List<dynamic>.from(event.snapshot.value as List);
        // _addCashAmount = _addCashAmount.reversed.toList();
        if (_addCashAmount.isNotEmpty) {
          _lastAddedCashAmount = _parseAmount(_addCashAmount.last['amount']);
        }
        notifyListeners();
      }
    });

    ref.child('bonusCashAmount').onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        _bonusCashAmount = List<dynamic>.from(event.snapshot.value as List);
        // _bonusCashAmount = _bonusCashAmount.reversed.toList();
        _totalBonusCashAmount = 0.0;
        for (dynamic i in _bonusCashAmount) {
          _totalBonusCashAmount += _parseAmount(i['amount']);
        }
        notifyListeners();
      }
    });

    ref.child('withdrawCashAmount').onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        _withdrawCashAmount = List<dynamic>.from(event.snapshot.value as List);
        // _withdrawCashAmount = _withdrawCashAmount.reversed.toList();
        if (_withdrawCashAmount.isNotEmpty) {
          _lastWithdrawCashAmount =
              _parseAmount(_withdrawCashAmount.last['amount']);
        }
        notifyListeners();
      }
    });

    ref.child('walletBalance').onValue.listen((event) {
      if (event.snapshot.exists) {
        _walletBalance = _parseAmount(event.snapshot.value);
        notifyListeners();
      }
    });

    ref.child('point').onValue.listen((event) {
      if (event.snapshot.exists) {
        _point = int.parse(event.snapshot.value.toString());
        notifyListeners();
      }
    });
  }

  double _parseAmount(dynamic amount) {
    if (amount is int) {
      return amount.toDouble();
    } else if (amount is double) {
      return amount;
    } else if (amount is String) {
      return double.tryParse(amount) ?? 0.0;
    } else {
      return 0.0;
    }
  }

  TransactionProvider p = TransactionProvider();

  void addCashWalletAmount(double amt) async {
    _walletBalance += amt;
    _lastAddedCashAmount = amt;
    DateTime now = DateTime.now();

    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);

    _addCashAmount.add({
      'date': formattedDate,
      'time': formattedTime,
      'title': 'Cash added of Rs ${amt}',
      'amount': amt
    });

    // _addCashAmount = _addCashAmount.reversed.toList();

    await p.allTransUpdate(formattedDate, formattedTime, amt,
        'Cash Added - Rs ${amt.toInt()}', 'wallet');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ref = FirebaseDatabase.instance
        .ref('username')
        .child(prefs.getString('phone') ?? '');
    await ref.update({
      'addCashAmount': _addCashAmount,
      'walletBalance': _walletBalance,
    });

    notifyListeners();
    noti.addNotificaiton("Cash Added of rs ${amt.toInt()}", formattedDate,
        formattedTime, 'wallet');
    PushNotificationService.sendFCMMessage("Cash Added Successfully",
        "You have added rs ${amt.toInt()} in your wallet");
  }

  void withdrawWalletAmount(double amt) async {
    _walletBalance -= amt;
    _lastWithdrawCashAmount = amt;
    DateTime now = DateTime.now();

    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    _withdrawCashAmount.add({
      'date': formattedDate,
      'time': formattedTime,
      'amount': amt,
      'title': 'Cash withdrawal of Rs ${amt}'
    });

    // _withdrawCashAmount = _withdrawCashAmount.reversed.toList();

    await p.allTransUpdate(formattedDate, formattedTime, amt,
        'Cash withdrawal - Rs ${amt.toInt()}', 'wallet');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ref = FirebaseDatabase.instance
        .ref('username')
        .child(prefs.getString('phone') ?? '');
    await ref.update({
      'withdrawCashAmount': _withdrawCashAmount,
      'walletBalance': _walletBalance,
    });
    notifyListeners();
    noti.addNotificaiton("Cash Withdrawal of rs ${amt.toInt()}", formattedDate,
        formattedTime, 'wallet');
    PushNotificationService.sendFCMMessage("Withhdrawal Successfully",
        "Withdrawal of rs ${amt.toInt()} successfully");
  }

  void deductCashWallet(double amt) async {
    _walletBalance -= amt;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ref = FirebaseDatabase.instance
        .ref('username')
        .child(prefs.getString('phone') ?? '');
    await ref.update({
      'walletBalance': _walletBalance,
    });

    notifyListeners();
  }

  //===========add points to spin wheel page ===================

  Future<void> addPointsToSpinWheelPage(int amt) async {
    _point += amt;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final ref = FirebaseDatabase.instance
        .ref('username')
        .child(prefs.getString('phone') ?? '');

    await ref.update({
      'point': _point,
    });

    notifyListeners();
  }

  //=============redeem points to wallet ===================
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<void> redeemPoints(int pt) async {
    _isLoading = true;
    notifyListeners();
    int add = pt ~/ 10;
    _point -= pt;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final ref = FirebaseDatabase.instance
        .ref('username')
        .child(prefs.getString('phone') ?? '');
    await ref.update({
      'point': _point,
    });
    await addBonusCash(add.toDouble());
    _isLoading = false;

    notifyListeners();
  }

  Future<void> addBonusCash(double add) async {
    _totalBonusCashAmount += add;

    DateTime now = DateTime.now();

    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);

    _bonusCashAmount.add({
      'date': formattedDate,
      'time': formattedTime,
      'title': 'Bonus Cash added of Rs ${add}',
      'amount': add
    });

    // _addCashAmount = _addCashAmount.reversed.toList();

    await p.allTransUpdate(formattedDate, formattedTime, add,
        'Bonus Cash Added - Rs ${add.toInt()}', 'wallet');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ref = FirebaseDatabase.instance
        .ref('username')
        .child(prefs.getString('phone') ?? '');
    await ref.update({
      'bonusCashAmount': _bonusCashAmount,
      // 'walletBalance': _walletBalance,
      'bonusCash': _totalBonusCashAmount,
    });

    notifyListeners();
    noti.addNotificaiton("Cash Added of rs ${add.toInt()}", formattedDate,
        formattedTime, 'wallet');
    PushNotificationService.sendFCMMessage("Bonus Cash Added Successfully",
        "We have added rs ${add.toInt()} in your wallet");
  }
}
