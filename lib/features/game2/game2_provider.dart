import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class Game2Provider extends ChangeNotifier {
  int _bidAmount = 0;
  int get bidAmount => _bidAmount;
  void set() {
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
    var request = http.Request(
        'POST', Uri.parse('https://zoozoowin-game-server2.onrender.com/bet'));
    request.body =
        json.encode({"phoneNumber": phone, "cardIds": cards, "betAmount": bet});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();

      // Decode the response body from JSON to a Dart map
      Map<String, dynamic> jsonResponse = json.decode(responseBody);
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
}
