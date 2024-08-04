import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoozoowin_/core/app_imports.dart';

class NotificaitonProvider with ChangeNotifier {
  Map<dynamic, dynamic> _notificationList = {};
  Map<dynamic, dynamic> get notificationList => _notificationList;

  NotificaitonProvider() {
    _initializeStream();
  }

  Future<void> _initializeStream() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ref = FirebaseDatabase.instance
        .ref('notification')
        .child(prefs.getString('phone') ?? '');

    ref.onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        Map<dynamic, dynamic> _notification =
            Map<dynamic, dynamic>.from(
                event.snapshot.value as Map<dynamic, dynamic>);
        if (_notification.isNotEmpty) {
          _notificationList = _notification;
        }

        print(_notificationList);
        notifyListeners();
      }

    });
  }

  Future<void> addNotificaiton(String title, String formattedDate,
      String formattedTime, String type) async {
    List<dynamic> data = [];
    if (_notificationList.containsKey(formattedDate)) {
      data = List<dynamic>.from(_notificationList[formattedDate]); // Create a mutable list
      data.add({
        'title': title,
        'date': formattedDate,
        'time': formattedTime,
        'type': type
      });
    } else {
      data = [
        {
          'title': title,
          'date': formattedDate,
          'time': formattedTime,
          'type': type
        }
      ];
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ref = FirebaseDatabase.instance
        .ref('notification')
        .child(prefs.getString('phone') ?? '');

    ref.update({
      formattedDate: data
    });

    notifyListeners();
  }




  void removeNotification(String date, int index) async {
    if (_notificationList.containsKey(date)) {
      List<dynamic> notifications = List.from(_notificationList[date]);
      notifications.removeAt(index);
      if (notifications.isEmpty) {
        _notificationList.remove(date);
      } else {
        _notificationList[date] = notifications;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final ref = FirebaseDatabase.instance
          .ref('notification')
          .child(prefs.getString('phone') ?? '');

      ref.update({
        date: notifications,
      });

      notifyListeners();
    }
  }
}
