import 'package:firebase_database/firebase_database.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoozoowin_/core/app_imports.dart';

class UpdateProvider with ChangeNotifier {
  bool _isUpdate = false;
  bool get isUpdate => _isUpdate;

  String _url = "";
  String get url => _url;
  Future<void> update_app() async {
    String version = await getCurrentVersion();
    final ver_ref = FirebaseDatabase.instance.ref('app_version');
    final url_ref = FirebaseDatabase.instance.ref('app_url');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ref1 = FirebaseDatabase.instance
        .ref('username')
        .child(prefs.getString('phone') ?? '');

    await ref1.update({
      'app_version': version,
    });

    DataSnapshot versnapshot = await ver_ref.get();
    DataSnapshot urlsnapshot = await url_ref.get();

    DataSnapshot snapshot1 = await ref1.get();
    Map<String, dynamic> _data;
    _data = Map<String, dynamic>.from(snapshot1.value as Map);
    // ref.onValue.listen((event) {
    //   _url = event.snapshot.value.toString();
    //   notifyListeners();
    //   if (event.snapshot.exists &&
    //       event.snapshot.value != null &&
    //       event.snapshot.value == _data['app_url']) {

    //     _isUpdate = true;
    //     notifyListeners();
    //   }
    // });

    // print(_data['app_url'].toString());
    _url = urlsnapshot.value.toString();
    notifyListeners();
    if (version != versnapshot.value.toString()) {
      _isUpdate = true;
      notifyListeners();
    }

    print("======================URL============================");
    print(_url);
    print(_isUpdate);
  }

    Future<String> getCurrentVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return packageInfo.version;
  }
}
