import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Game2Provider extends ChangeNotifier {
  int _bidAmount = 0;
  int get bidAmount => _bidAmount;
  Game2Provider() {
    getLast5Matches();
  }
  Future<void> set() async {
    _bidAmount = 0;
    notifyListeners();
  }

  void incAmount() {
    _bidAmount += 10;
    notifyListeners();
  }

  void dcrAmount(BuildContext context) {
    if (_bidAmount - 10 >= 0) {
      _bidAmount -= 10;
    }
    notifyListeners();
  }

  String _wonCard = "";
  String get wonCard => _wonCard;
  String _isWin = "";
  String get isWin => _isWin;
  int _wonAmount = 0;
  int get wonAmount => _wonAmount;

  Future<void> fetchResult(String phone, List<String> cards, int bet) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST',
        Uri.parse('https://zoozoowin-game-server2-0j57.onrender.com/bet'));
    request.body =
        json.encode({"phoneNumber": phone, "cardIds": cards, "betAmount": bet});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print("request sent");

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();

      // Decode the response body from JSON to a Dart map
      Map<String, dynamic> jsonResponse = json.decode(responseBody);
      print("=============json response===========");
      print(jsonResponse);
      if (jsonResponse.containsKey('wonAmount')) {
        _wonAmount = jsonResponse['wonAmount'];

        notifyListeners();
        print('cardWon: ${jsonResponse['wonCard']}');
      }

      // Check if 'cardWon' exists and print it
      if (jsonResponse.containsKey('wonCard')) {
        _wonCard = jsonResponse['wonCard'];

        notifyListeners();
        print('cardWon: ${jsonResponse['wonCard']}');
      } else {
        _wonCard = "";
        notifyListeners();
        print('cardWon key not found in the response.');
      }
      _isWin = jsonResponse['status'];
    } else {
      print(response.reasonPhrase);
    }
  }

  List<dynamic> _last5Matches = [];
  List<dynamic> get last5Matches => _last5Matches;

  Future<void> getLast5Matches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DatabaseReference ref = FirebaseDatabase.instance
        .ref('game2/${prefs.getString('phone')}/Last5Matches');

    ref.onValue.listen((event) {
      if (event.snapshot.value != null) {
        _last5Matches = event.snapshot.value as List<dynamic>;
        print(_last5Matches);
        notifyListeners();
      }
    });
  }
}
