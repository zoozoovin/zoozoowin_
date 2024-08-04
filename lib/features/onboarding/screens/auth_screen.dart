import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:googleapis/cloudsearch/v1.dart';
import 'package:phone_email_auth/phone_email_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/core/constants/app_data.dart';
import 'package:zoozoowin_/core/managers/shared_preference_manager.dart';
import 'package:zoozoowin_/features/nav_screen.dart';
import 'package:zoozoowin_/features/onboarding/data/profile_name_generator.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref('username');
  String useraccessToken = "";
  String jwtUserToken = "";
  bool hasUserLogin = false;
  String phone = "";
  Future<void> verify() async {
    print("hello");
    await PhoneEmail.getUserInfo(
      accessToken: useraccessToken,
      clientId: '18810700881589792944',
      onSuccess: (userData) async {
        setState(() {
          var phoneEmailUserModel = userData;
          var countryCode = phoneEmailUserModel?.countryCode;
          phone = phoneEmailUserModel.phoneNumber!;
        });

        await _checkUserAndSaveData(phone);

        AppData.navigateToNotification(context, NavBarScreen(index: 0));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
         height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(AppImages.phone_bg), fit: BoxFit.cover)),
        child: Align(
          alignment: Alignment.center,
          child: PhoneLoginButton(
            
            borderRadius: 10,
            buttonColor: Colors.teal,
            label: 'Sign in with Phone',
            onSuccess: (String accessToken, String jwtToken) async {
              if (accessToken.isNotEmpty) {
                setState(() {
                  useraccessToken = accessToken;
                  jwtUserToken = jwtToken;
                  hasUserLogin = true;
                });
        
                await verify();
              }
            },
          ),
        ),
      ),
    );
  }

  ProfileNameGenerator _generator = ProfileNameGenerator();
  String _randomName = "";
  Future<void> _checkUserAndSaveData(String phoneNum) async {
    String phone = phoneNum;
    DatabaseReference ref = _database.child(phone);
    DataSnapshot snapshot = await ref.get();
    _randomName = _generator.generateRandomName();
    if (!snapshot.exists) {
      await ref.set({
        'phone': phone,
        'walletBalance': 0.0,
        'profileName': _randomName,
        'fcm_token': SharedPreferencesManager.getString("fcm_token")
      });
      _savePhoneNumberToLocalDatabase(phone);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => NavBarScreen(index: 0)));
    } else {
      // setState(() {
      //   _isLoading = false;
      // });
      _savePhoneNumberToLocalDatabase(phone);

      Fluttertoast.showToast(
        msg: 'User already exists',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => NavBarScreen(index: 0)));
    }
  }

  Future<void> _savePhoneNumberToLocalDatabase(String phone) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone', phone);
    await prefs.setBool('isLogin', true);
  }
}
