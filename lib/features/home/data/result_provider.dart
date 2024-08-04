import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/core/constants/app_data.dart';

class ResultProvider with ChangeNotifier {
  List<dynamic> _resultHistoryList = [];

  List<dynamic> get resultHistoryList => _resultHistoryList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<void> showHistory(String date) async {
    _resultHistoryList.clear();
    _isLoading = true;
    notifyListeners();

    List<Future<void>> fetchTasks = [];

    for (String slot in AppData.timeSlots) {
      fetchTasks.add(_fetchSlotResult(date, slot));
    }

    await Future.wait(fetchTasks);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchSlotResult(String date, String slot) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('result_game1/${date}_$slot');
    DataSnapshot snapshot = await ref.get();
    if (snapshot.value != null) {
      Map<Object?, Object?> data = snapshot.value as Map<Object?, Object?>;
      _resultHistoryList
          .add({'time': slot, 'cardWon': AppData.cardImages[data['cardWon']]});
    } else {
      _resultHistoryList.add({'time': slot, 'cardWon': 'coming'});
    }
  }

  Map<String, List<Map<String, dynamic>>> _cardLists = {};
  Map<String, List<Map<String, dynamic>>> get cardLists => _cardLists;

  Future<void> getSelCards(String formattedDate, String time) async {
    _isLoading = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DatabaseReference ref = FirebaseDatabase.instance.ref('Game1');

    DatabaseReference slotRef = ref.child(
        '${formattedDate}_$time/${prefs.getString('phone')}/selectedCards');

    slotRef.onValue.listen((event) {
      _processSnapshot(event.snapshot, time);
    });
  }

  int _totalCount = 0;
  int get totalCount => _totalCount;
  Map<String, String> _cardTotalAmount = {};
  Map<String, String> get cardTotalAmount => _cardTotalAmount;

  void _processSnapshot(DataSnapshot snapshot, String slot) {
    double tam = 0;
    if (snapshot.value != null) {
      List<dynamic> data = snapshot.value as List<dynamic>;

      _totalCount++;

      // Prepare card list
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
    } else {
      _cardLists[slot] = []; // Initialize with empty list
    }

    _isLoading = false;
    notifyListeners();
  }
}







// Future<void> showHistory(String date) async {
  //   for (String i in AppData.timeSlots) {
  //     DatabaseReference ref =
  //         FirebaseDatabase.instance.ref('result_game1/${date}_${i}');

  //     DataSnapshot snapshot = await ref.get();
  //     if (snapshot.value != null) {
  //       Map<Object?, Object?> data = snapshot.value as Map<Object?, Object?>;

  //       print(data['cardWon']);
  //       resultHistoryList
  //           .add({'time': i, 'cardWon': AppData.cardImages[data['cardWon']]});

  //       print(cardWon);
  //       print(cardWonImage);
  //     } else {
  //       // Handle the case where the result does not exist
  //       resultHistoryList.add({'time': i, 'cardWon': 'coming'});

  //       print("No result data found.");
  //     }
  //   }
  // }