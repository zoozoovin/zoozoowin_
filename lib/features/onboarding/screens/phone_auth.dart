import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:twilio_phone_verify/twilio_phone_verify.dart';
import 'package:zoozoowin_/core/constants/app_images.dart';
import 'package:zoozoowin_/features/nav_screen.dart';
import 'package:zoozoowin_/features/onboarding/data/profile_name_generator.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref('username');

  String _verificationId = '';
  bool _isCodeSent = false;
  bool _isLoading = false;
  late TwilioPhoneVerify _twilioPhoneVerify;

  @override
  void initState() {
    super.initState();
    _twilioPhoneVerify = TwilioPhoneVerify(
      accountSid: 'AC793e6541a9f9114557c178bb096fbbf4',
      serviceSid: 'VAda45fa97cf825ba0a547465b8a5893ff',
      authToken: 'abc9f7c750419bb7fb0c66aee409a128',
    );
  }

  Future<void> sendCode() async {
    setState(() {
      _isLoading = true;
    });

    String phoneNumber = _phoneController.text.trim();
    String phone = "+91" + phoneNumber;
    print(phone);
    // if (phone.isEmpty || _isLoading) return;


    print("fater return");

    // Basic format check for E.164 format
    if (!RegExp(r'^\+\d{10,15}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid phone number'),
      ));
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      TwilioResponse twilioResponse =
          await _twilioPhoneVerify.sendSmsCode(phone);

      if (twilioResponse.successful == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Code sent successfully!'),
        ));

        setState(() {
          _isCodeSent = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(twilioResponse.errorMessage ?? 'Unknown error'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send code: ${e.toString()}'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> verifyCode() async {
    setState(() {
      _isLoading = true;
    });

    String otpCode =
        _otpControllers.map((controller) => controller.text).join();
    String phone = "+91" + _phoneController.text;
    // if (phone.isEmpty || otpCode.isEmpty || _isLoading) return;

    try {
      TwilioResponse twilioResponse = await _twilioPhoneVerify.verifySmsCode(
        phone: phone,
        code: otpCode,
      );

      if (twilioResponse.successful == true) {
        if (twilioResponse.verification?.status ==
            VerificationStatus.approved) {
          _checkUserAndSaveData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Invalid code'),
          ));
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(twilioResponse.errorMessage ?? 'Unknown error'),
        ));
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to verify code: ${e.toString()}'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkUserAndSaveData() async {
    String phone = _phoneController.text;
    DatabaseReference ref = _database.child(phone);
    DataSnapshot snapshot = await ref.get();
    if (!snapshot.exists) {
      await ref.set({
        'phone': phone,
        'walletBalance': 0.0,
        'profileName': ProfileNameGenerator().generateRandomName(),
        'fcm_token': await SharedPreferences.getInstance()
            .then((prefs) => prefs.getString("fcm_token") ?? ""),
      });
      await _savePhoneNumberToLocalDatabase(phone);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => NavBarScreen(index: 0)));
    } else {
      Fluttertoast.showToast(
        msg: 'User already exists',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      await _savePhoneNumberToLocalDatabase(phone);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => NavBarScreen(index: 0)));
    }
  }

  Future<void> _savePhoneNumberToLocalDatabase(String phone) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone', phone);
    await prefs.setBool('isLogin', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.phone_bg),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildVerification(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerification() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 53, 184, 255),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 10),
                  Row(
                    children: [
                      Text(
                        "+91",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      VerticalDivider(thickness: 2),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          hintText: 'Mobile Number',
                          border: InputBorder.none,
                        ),
                        readOnly: _isCodeSent,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [LengthLimitingTextInputFormatter(10)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: _isCodeSent ? 15 : 10),
            if (_isCodeSent)
              AutofillGroup(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 3,
                            color: const Color.fromARGB(255, 53, 184, 255),
                          ),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _otpControllers[index],
                          decoration: const InputDecoration(
                            hintText: '_',
                            hintStyle: TextStyle(fontSize: 20),
                            counterText: '',
                            border: InputBorder.none,
                          ),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          autofillHints: [AutofillHints.oneTimeCode],
                          style: const TextStyle(fontSize: 24),
                          onChanged: (value) {
                            if (value.length == 1 && index < 5) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 15),
            _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      if (_isCodeSent) {
                        verifyCode();
                      } else {
                        sendCode();
                      }
                    },
                    child: Container(
                      height: 50.0,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(width: 3, color: Colors.white),
                        color: const Color.fromARGB(255, 53, 184, 255),
                      ),
                      child: Center(
                        child: Text(
                          _isCodeSent ? 'VERIFY' : 'SEND OTP',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      );
}
