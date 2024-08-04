import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/core/constants/app_data.dart';
import 'package:zoozoowin_/core/managers/shared_preference_manager.dart';

class ResultTicketProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, int> _cardCounts = {}; // Map to store card counts for each slot
  Map<String, List<Map<String, dynamic>>> _cardLists = {};

  Map<String, int> get cardCounts => _cardCounts;
  Map<String, List<Map<String, dynamic>>> get cardLists => _cardLists;

  Map<String, String> _cardTotalAmount = {};
  Map<String, String> get cardTotalAmount => _cardTotalAmount;

  Future<void> getSelectedCards(String formattedDate) async {
    _isLoading = true;
    notifyListeners();
    _cardCounts = {};
    _cardLists = {};
    _cardTotalAmount = {};
    DatabaseReference ref = FirebaseDatabase.instance.ref('Game1');

    for (String slot in AppData.timeSlots) {
      double tam = 0;

      DatabaseReference slotRef = ref.child(
          '${formattedDate}_$slot/${SharedPreferencesManager.getString('phone')}/selectedCards');

      DataSnapshot snapshot = await slotRef.get();
      if (snapshot.value != null) {
        List<dynamic> data = snapshot.value as List<dynamic>;
        _cardCounts[slot] = data.length;
        List<Map<String, dynamic>> cardList = [];

        for (var item in data) {
          if (item != null && item is Map) {
            Map<String, dynamic> map = item.cast<String, dynamic>();
            tam += map['amount'];

            cardList.add({
              'image': AppData.cardImages[map['cardId']],
              'amount': map['amount']
            });
          }
        }
        _cardLists[slot] = cardList;
        _cardTotalAmount[slot] = tam.toString();

        _isLoading = false;
        notifyListeners();
      } else {
        _cardCounts[slot] = 0;
        _cardLists[slot] = [];
        _isLoading = false;
        notifyListeners(); // Initialize with empty list
      }
    }
    print(_cardTotalAmount);
  }

  //result ===============

  List<dynamic> _resultHistoryList = [];

  List<dynamic> get resultHistoryList => _resultHistoryList;

  Future<void> showHistory(String date) async {
    _resultHistoryList.clear();
    _isLoading = true;
    notifyListeners();

    for (String slot in AppData.timeSlots) {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref('result_game1/${date}_$slot');
      DataSnapshot snapshot = await ref.get();
      if (snapshot.value != null) {
        Map<Object?, Object?> data = snapshot.value as Map<Object?, Object?>;
        _resultHistoryList.add(
            {'time': slot, 'wonCard': AppData.cardImages[data['cardWon']]});
      } else {
        _resultHistoryList.add({'time': slot, 'wonCard': 'coming'});
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // ============ How much amount you won=============

  Map<String, dynamic> _slotWonAmount = {};
  Map<String, dynamic> get slotWonAmount => _slotWonAmount;
  Future<void> wonAmount(String formattedDate) async {
    _isLoading = true;
    notifyListeners();
    DatabaseReference ref = FirebaseDatabase.instance.ref(
        'username/${SharedPreferencesManager.getString('phone')}/wonCashAmount');
    DataSnapshot snapshot = await ref.get();
    if (snapshot.value != null) {
      print('inside');
      for (String slot in AppData.timeSlots) {
        List<dynamic> data = snapshot.value as List<dynamic>;
        for (var i in data) {
          print(i['timeSlot']);
          print(i['date']);
          if (i['timeSlot'] == slot && i['date'] == formattedDate) {
            _slotWonAmount[slot] = i['amount'];
          } else {
            _slotWonAmount[slot] = '0';
          }
        }
      }
    }
    print(_slotWonAmount);
    _isLoading = false;
    notifyListeners();
  }
}
