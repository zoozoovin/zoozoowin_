import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:zoozoowin_/core/app_imports.dart';

class HomeProvider with ChangeNotifier {
  int _totalCount = 0;
  int get totalCount => _totalCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _tc = "";
  String get tc => _tc;

  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('result_game1');

  Map<String, dynamic>? _data;
  Map<String, dynamic>? get data => _data;

  HomeProvider() {
    fetchData();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    DateTime now = DateTime.now();
    String todayDate = DateFormat('dd-MM-yyyy').format(now);
    int currentHour = now.hour;
    int hourToFetch = currentHour - 1;

    String key;
    if (hourToFetch >= 12) {
      String formattedTime = DateFormat('hh:00 a')
          .format(DateTime(now.year, now.month, now.day, hourToFetch));
      key = '${todayDate}_$formattedTime';
    } else {
      DateTime previousDay = now.subtract(Duration(days: 1));
      String previousDate = DateFormat('dd-MM-yyyy').format(previousDay);
      key = '${previousDate}_11:00 PM';
      _tc = "11:00 PM";
    }

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
  }
}
