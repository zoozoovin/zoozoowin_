import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/core/constants/app_data.dart';

class TicketProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, int> _cardCounts = {}; // Map to store card counts for each slot
  Map<String, List<Map<String, dynamic>>> _cardLists = {};

  Map<String, int> get cardCounts => _cardCounts;
  Map<String, List<Map<String, dynamic>>> get cardLists => _cardLists;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  Map<String, String> _cardTotalAmount = {};
  Map<String, String> get cardTotalAmount => _cardTotalAmount;

  TicketProvider() {
    _initializeStream();
  }

  Future<void> _initializeStream() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DatabaseReference ref = FirebaseDatabase.instance.ref('Game1');
    DateTime now = DateTime.now();
    String formattedDate =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    for (String slot in AppData.timeSlots) {
      DatabaseReference slotRef = ref.child(
          '${formattedDate}_$slot/${prefs.getString('phone')}/selectedCards');

      slotRef.onValue.listen((event) {
        _totalCount = 0;
        _processSnapshot(event.snapshot, slot);
        // _totalCount = _cardLists.length;

        _cardCounts.forEach((key, val) {
          if (val != 0) {
            _totalCount++;
            notifyListeners();
          }
        });
      });
    }
  }

  void _processSnapshot(DataSnapshot snapshot, String slot) {
    double tam = 0;
    if (snapshot.value != null) {
      List<dynamic> data = snapshot.value as List<dynamic>;
      _cardCounts[slot] = data.length;
      // _totalCount++;

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
      print(tam);
      _cardLists[slot] = cardList;
      _cardTotalAmount[slot] = tam.toString();
      print(_cardTotalAmount);
    } else {
      _cardCounts[slot] = 0;
      _cardLists[slot] = []; // Initialize with empty list
    }

    notifyListeners();
  }

  // =================== // ======================

  String _cardWonImage = "";
  String get cardWon => _cardWonImage;
  Future<void> showResult(String formattedDate, String _timeSlot) async {
    _isLoading = true;
    notifyListeners();
    _cardWonImage = "";

    DatabaseReference ref = FirebaseDatabase.instance
        .ref('result_game1/${formattedDate}_${_timeSlot}');
    print('${formattedDate}_${_timeSlot}');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.value != null) {
      Map<Object?, Object?> data = snapshot.value as Map<Object?, Object?>;

      _cardWonImage = AppData.cardImages[data['cardWon'].toString()]!;

      
      notifyListeners();
    } else {
      // Handle the case where the result does not exist

      print("No result data found.");
    }
    _isLoading = true;
    notifyListeners();
  }
}
