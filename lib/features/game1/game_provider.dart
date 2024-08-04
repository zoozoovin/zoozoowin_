import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/core/constants/app_data.dart';

class GameProvider with ChangeNotifier {
  Map<String, dynamic> _getSlot = {};
  Map<String, dynamic> get getSlot => _getSlot;

  bool _isLoading = false;
  bool get isLoading => _isLoading;


  GameProvider(){
    initializeStream();
  }

  Future<void> initializeStream() async {
    _isLoading = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DatabaseReference ref = FirebaseDatabase.instance.ref('Game1');

    DateTime now = DateTime.now();
    String formattedDate =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    for (String slot in AppData.timeSlots) {
      DatabaseReference slotRef =
          ref.child('${formattedDate}_$slot/${prefs.getString('phone')}');

      slotRef.onValue.listen((event) {
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.value != null) {
          _getSlot[slot] = true;
        } else {
          _getSlot[slot] = false;
        }

        // Notify listeners for each change
        notifyListeners();
      });
    }
    _isLoading = false;
    notifyListeners(); 
  }
}
