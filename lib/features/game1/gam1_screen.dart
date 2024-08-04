// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/core/loaded_widget.dart';
import 'package:zoozoowin_/core/loader_widget.dart';
import 'package:zoozoowin_/core/utils/screen_utils.dart';
import 'package:zoozoowin_/features/home/screens/result_ticket_screen.dart';
import 'package:zoozoowin_/features/nav_screen.dart';
import 'package:zoozoowin_/features/wallet/data/transaction_provider.dart';
import 'package:zoozoowin_/features/wallet/data/wallet_provider.dart';
import 'package:zoozoowin_/notification_service.dart';
import 'package:zoozoowin_/ui/atoms/shine_button.dart';

class Game1Screen extends StatefulWidget {
  String time;
  int amount;
  Game1Screen({Key? key, required this.time, required this.amount})
      : super(key: key);

  @override
  State<Game1Screen> createState() => _Game1ScreenState();
}

class _Game1ScreenState extends State<Game1Screen> {
  int getNumberOfCardsWithBets() {
    return cardAmounts.values.where((amount) => amount > 0).length;
  }

  int currentAmount = 0;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
    _fetchPreviousBets();
  }

  Map<String, dynamic> cardAmounts = {
    "c1": 0,
    "c2": 0,
    "c3": 0,
    "c4": 0,
    "c5": 0,
    "c6": 0,
    "c7": 0,
    "c8": 0,
    "c9": 0,
    "c10": 0,
    "c11": 0,
    "c12": 0,
  };
  Map<String, dynamic> initialCardAmounts = {};
  Map<String, String> cardImages = {
    "c1": "assets/images/k_jack.png",
    "c2": "assets/images/k_heart.png",
    "c3": "assets/images/k_club.png",
    "c4": "assets/images/k_diamond.png",
    "c5": "assets/images/q_jack.png",
    "c6": "assets/images/q_heart.png",
    "c7": "assets/images/q_club.png",
    "c8": "assets/images/q_diamond.png",
    "c9": "assets/images/j_jack.png",
    "c10": "assets/images/j_heart.png",
    "c11": "assets/images/j_club.png",
    "c12": "assets/images/j_diamond.png",
  };
  Future<void> _fetchPreviousBets() async {
    DateTime now = DateTime.now();
    String formattedDate =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone = prefs.getString('phone') ?? '';

    DatabaseReference userBetRef =
        databaseRef.child('${formattedDate}_${widget.time}').child(phone);
    DataSnapshot snapshot = await userBetRef.get();

    if (snapshot.value != null) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      if (data.containsKey('selectedCards')) {
        List<dynamic> selectedCardsData = data['selectedCards'];
        for (var item in selectedCardsData) {
          String cardId = item['cardId'];
          int amount = item['amount'];
          setState(() {
            cardAmounts[cardId] = amount;
            initialCardAmounts[cardId] = amount;
          });
        }
      }
    }

    currentAmount = getTotalAmount();
    print(currentAmount);
  }

  // int getNumberOfCardsWithBets() {
  //   return cardAmounts.values.where((amount) => amount > 0).length;
  // }

  int getTotalAmount() {
    return cardAmounts.values.reduce((sum, amount) => sum + amount);
  }

  void incrementAmount(String cardId) {
    if (getNumberOfCardsWithBets() >= 12 && cardAmounts[cardId] == 0) {
      Fluttertoast.showToast(
        msg: "Bet on only 9 cards are allowed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    setState(() {
      cardAmounts[cardId] = (cardAmounts[cardId] ?? 0) + widget.amount;
      // cardAmounts[cardId] = widget.amount;
    });
  }

  void decrementAmount(String cardId) {
    // Check if the card was previously selected
    if (initialCardAmounts.containsKey(cardId)) {
      // Ensure the amount does not go below the initial amount
      if (cardAmounts[cardId]! > initialCardAmounts[cardId]!) {
        setState(() {
          cardAmounts[cardId] = (cardAmounts[cardId] ?? 0) - widget.amount;
        });
      }
    } else {
      // For cards that were not previously selected, decrement freely
      setState(() {
        if (cardAmounts[cardId]! > 0) {
          cardAmounts[cardId] = (cardAmounts[cardId] ?? 0) - widget.amount;
        }
      });
    }
  }

  bool _isPlaceBet = false;

  @override
  Widget build(BuildContext context) {
    String countdownText = _formatDuration(countdownDuration);
    return LoaderWidget(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 73, 122),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              // image: DecorationImage(
              // image: AssetImage(
              //   AppImages.background,
              // ),
              // fit: BoxFit.cover,
              // ),
              ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomSpacers.height36,
                _buildTop(),
                CustomSpacers.height16,
                _buildWallet(),
                _totalWidget(),
                !_isPlaceBet
                    ? Container(
                        height: 477.h,
                        width: MediaQuery.of(context).size.width,
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 10.h,
                            crossAxisSpacing: 10.w,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: cardAmounts.keys.length,
                          itemBuilder: (context, index) {
                            String cardId = cardAmounts.keys.elementAt(index);
                            return BuildCard(
                              cardId: cardId,
                              image: cardImages[cardId]!,
                              amount: cardAmounts[cardId]!,
                              increment: () => incrementAmount(cardId),
                              decrement: () => decrementAmount(cardId),
                            );
                          },
                        ),
                      )
                    : Container(
                        height: 477.h,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            CustomSpacers.height26,
                            Icon(
                              Icons.check_circle_sharp,
                              color: Colors.green,
                              size: 150.h,
                            ),
                            CustomSpacers.height35,
                            Text(
                              "PLEASE WAIT",
                              style: TextStyle(
                                fontSize: 28.w,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 6,
                              ),
                            ),
                            // SizedBox(height: 20),
                            CustomSpacers.height20,
                            Text(
                              "FOR RESULT",
                              style: TextStyle(
                                fontSize: 28.w,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 5,
                              ),
                            ),
                            CustomSpacers.height30,
                            Text(
                              countdownText,
                              style: TextStyle(
                                fontSize: 28.w,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                CustomSpacers.height18,
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildTop() => InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                ),
                CustomSpacers.width12,
                Text(
                  "PLAY WIN",
                  style: TextStyle(
                      fontSize: 17.h,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ],
            ),
            Text(
              'Min bet : ₹' + widget.amount.toString(),
              style: TextStyle(
                  fontSize: 17.h,
                  fontWeight: FontWeight.w600,
                  color: Colors.yellow),
            ),
            Text(
              widget.time,
              style: TextStyle(
                  fontSize: 17.h,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            )
          ],
        ),
      );

  _buildWallet() => Consumer<WalletProvider>(
        builder: (context, value, child) => Container(
          height: 180.h,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Container(
                height: 150.h,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28.0, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "WALLET",
                            style: TextStyle(
                                fontSize: 24.w, fontWeight: FontWeight.w400),
                          ),
                          // Container(
                          //   height: 30.h,
                          //   width: 80.w,
                          //   decoration: BoxDecoration(
                          //     color: const Color.fromARGB(168, 205, 205, 205),
                          //     borderRadius: BorderRadius.circular(20),
                          //   ),
                          //   child: Center(
                          //     child: Text(
                          //       "Refresh",
                          //       style: TextStyle(
                          //         fontSize: 12.w,
                          //         fontWeight: FontWeight.w300,
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          // Icon(Icons.video)
                        ],
                      ),
                      Text("Current Balance"),
                      Text("₹ " + value.walletBalance.toString(),
                          style: TextStyle(
                              fontSize: 26.w,
                              fontWeight: FontWeight.w500,
                              color: Colors.black))
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 125.h,
                  left: 40.w,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (Context) => NavBarScreen(index: 3)));
                    },
                    // child: Center(
                    //   child: Container(
                    //     height: 45.h,
                    //     width: 300.w,
                    //     decoration: BoxDecoration(
                    //       // color: const Color.fromARGB(255, 233, 233, 233),
                    //       color: Colors.green,
                    //       borderRadius: BorderRadius.circular(20),
                    //     ),
                    //     child: Center(
                    //       child: Text(
                    //         "ADD CASH",
                    //         style: TextStyle(
                    //             fontSize: 25.w,
                    //             fontWeight: FontWeight.w800,
                    //             color: Colors.white),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    child: Center(
                      child: Container(
                        height: 45.h,
                        width: 300.w,
                        // padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          gradient: LinearGradient(
                            colors: [Color(0xFF00FF0A), Color(0xFF008A12)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                "ADD CASH",
                                style: TextStyle(
                                  fontSize: 28.w,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  // fontStyle: FontStyle.italic
                                ),
                              ),
                            ),
                            // CustomSpacers.width14,
                          ],
                        ),
                      ),
                    ),
                  )),
              Positioned(
                  left: 350.w,
                  top: 1.h,
                  child: Image.asset(
                    AppImages.videoicon,
                    height: 40.h,
                    width: 40.w,
                    color: Colors.red,
                  ))
            ],
          ),
        ),
      );

  _totalWidget() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  "Total",
                  style: TextStyle(
                    fontSize: 24.w,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                CustomSpacers.width14,
                Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14.0, vertical: 6),
                      child: Text(
                        "₹ ${getTotalAmount() - currentAmount}",
                        style: TextStyle(
                          fontSize: 20.w,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "Cards",
                  style: TextStyle(
                    fontSize: 24.w,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                CustomSpacers.width14,
                Container(
                  height: 40.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14.0, vertical: 6),
                      child: Text(
                        "${getNumberOfCardsWithBets()}",
                        style: TextStyle(
                          fontSize: 20.w,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );

  void clearAllBets() {
    setState(() {
      cardAmounts.forEach((key, value) {
        cardAmounts[key] =
            initialCardAmounts.containsKey(key) ? initialCardAmounts[key]! : 0;
      });
    });
  }

  Widget _buildFooter() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(
            onTap: clearAllBets,
            // child: Container(
            //   height: 70.h,
            //   width: 70.w,
            //   decoration: BoxDecoration(
            //     border: Border.all(
            //       width: 2,
            //       color: Colors.white,
            //     ),
            //     color: Colors.redAccent,
            //     borderRadius: BorderRadius.circular(100),
            //   ),
            //   child: Center(
            //     child: Text(
            //       "RESET",
            //       style: TextStyle(
            //         fontSize: 18.w,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),

            child: Image.asset(
              'assets/reset.png',
              height: 70.h,
              width: 70.w,
            )),

        CustomSpacers.width20,
        // const SizedBox(height: 20),
        _buildPlaceBetLogic(),
      ]);

  // const SizedBox(height: 30),

  _buildPlaceBetLogic() => GestureDetector(
        onTap: () {
          final wallet = Provider.of<WalletProvider>(context, listen: false);
          if (getTotalAmount() - currentAmount > wallet.walletBalance) {
            unplaceBet();
          } else {
            currentAmount != getTotalAmount()
                ? Place_Bet(getTotalAmount().toString())
                : OverlayManager.showToast(
                    type: ToastType.Alert, msg: "Can't placed bet");
          }
        },
        // // child: Container(
        // height: 60.h,
        // width: 250.w,
        // //   decoration: BoxDecoration(
        // //     border: Border.all(
        // //       width: 2,
        // //       color: Colors.white,
        // //     ),
        // //     color: Colors.green,
        // //     borderRadius: BorderRadius.circular(10),
        // //   ),
        // //   child: Row(
        // //     mainAxisAlignment: MainAxisAlignment.center,
        // //     children: [
        // //       Center(
        // //         child: Text(
        // //           "PLACE BET",
        // //           style: TextStyle(
        // //             fontSize: 28.w,
        // //             fontWeight: FontWeight.w600,
        // //             color: Colors.white,
        // //           ),
        // //         ),
        // //       ),
        // //       // CustomSpacers.width14,
        // //       Icon(
        // //         Icons.check_circle,
        // //         color: Colors.white,
        // //       )
        //     ],
        //   ),
        // ),
        child: CustomShinyButton(
          height: 60.h,
          width: 250.w,
          text: "PLACE BET",
          // ic: true,
         style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
        ),
      );

  void unplaceBet() {
    final wallet = Provider.of<WalletProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Insufficient Balance'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Current Amount in Wallet: ₹${wallet.walletBalance.toString()}'),
                  SizedBox(height: 10),
                ],
              );
            },
          ),
        );
      },
    );
  }

  bool isLoading = false;
  final databaseRef = FirebaseDatabase.instance.ref('Game1');
  void Place_Bet(String totalAmount) async {
    int currentTotalAmount = getTotalAmount();

    // Check if the current total amount is equal to the initial total amount or 0
    if (currentTotalAmount == 0 || currentAmount == currentTotalAmount) {
      print("here inside");
      Fluttertoast.showToast(
        msg: "No new bets placed. Please place a bet before proceeding.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    DateTime now = DateTime.now();
    String formattedDate =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone = prefs.getString('phone') ?? '';

    // Fetch existing selected cards and total amount from Firebase
    DatabaseReference userBetRef =
        databaseRef.child('${formattedDate}_${widget.time}').child(phone);
    DataSnapshot snapshot = await userBetRef.get();

    List<Map<String, dynamic>> existingCards = [];
    int existingTotalAmount = 0;
    if (snapshot.value != null) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      if (data.containsKey('selectedCards')) {
        List<dynamic> selectedCardsData = data['selectedCards'];
        for (var item in selectedCardsData) {
          existingCards.add(Map<String, dynamic>.from(item));
        }
      }
      if (data.containsKey('totalBetAmount')) {
        existingTotalAmount = int.parse(data['totalBetAmount'].toString());
      }
    }

    // Prepare new list of selected cards and their bet amounts
    List<Map<String, dynamic>> newSelectedCards = [];
    cardAmounts.forEach((cardId, amount) {
      if (amount > 0) {
        newSelectedCards.add({'cardId': cardId, 'amount': amount});
      }
    });

    // Combine existing and new selected cards
    Map<String, int> combinedCardAmounts = {};

    for (var card in existingCards) {
      combinedCardAmounts[card['cardId']] = card['amount'];
    }

    for (var card in newSelectedCards) {
      combinedCardAmounts[card['cardId']] = card['amount'];
    }

    // Convert combined amounts to list
    List<Map<String, dynamic>> updatedSelectedCards = [];
    combinedCardAmounts.forEach((cardId, amount) {
      updatedSelectedCards.add({'cardId': cardId, 'amount': amount});
    });

    // Update the total amount
    int newTotalAmount = getTotalAmount();

    final wallet = Provider.of<WalletProvider>(context, listen: false);

    if (newTotalAmount > 20000.0) {
      Fluttertoast.showToast(
        msg: "You have exceeded the limit of ₹ 20000! Can't place bet",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      await userBetRef.set({
        'totalBetAmount': newTotalAmount,
        'selectedCards': updatedSelectedCards,
        'mobile': phone,
      });
      wallet.deductCashWallet(
          double.parse((currentTotalAmount - currentAmount).toString()));
      final p = Provider.of<TransactionProvider>(context, listen: false);

      await p.deductedAmount(
          formattedDate,
          widget.time,
          double.parse((currentTotalAmount - currentAmount).toString()),
          'Amount deducted - Rs ${currentTotalAmount - currentAmount} in ${widget.time} slot',
          'placebet-game1');

      await p.allTransUpdate(
          formattedDate,
          widget.time,
          double.parse((currentTotalAmount - currentAmount).toString()),
          'Amount deducted - Rs ${currentTotalAmount - currentAmount} in ${widget.time} slot',
          'placebet-game1');

      await PushNotificationService.sendFCMMessage("Play win - Bet Placed",
          "Bet placed of Rs ${currentTotalAmount - currentAmount} successfully in ${widget.time} slot");

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => ResultTicketScreen()));
    }

    setState(() {
      isLoading = false;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  late DateTime targetTime;
  late Duration countdownDuration;
  Timer? countdownTimer;
  void _initializeTimer() {
    List<String> timeParts = widget.time.split(' ');
    List<String> hourMinuteParts = timeParts[0].split(':');
    int hour = int.parse(hourMinuteParts[0]);
    int minute = int.parse(hourMinuteParts[1]);
    String period = timeParts[1];

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    DateTime now = DateTime.now();

    targetTime = DateTime(now.year, now.month, now.day, hour, minute);

    targetTime = targetTime.add(Duration(
      hours: 1,
    ));

    countdownDuration = targetTime.difference(now);

    if (countdownDuration.isNegative) {
      countdownDuration = Duration.zero;
    }

    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      print(timer);
      if (countdownDuration.inSeconds > 0) {
        setState(() {
          countdownDuration -= Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
  }
}

class BuildCard extends StatelessWidget {
  final String cardId;
  final String image;
  final int amount;
  final VoidCallback increment;
  final VoidCallback decrement;

  BuildCard({
    required this.cardId,
    required this.image,
    required this.amount,
    required this.increment,
    required this.decrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 80.h,
          width: 80.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: amount > 0 ? Border.all(color: Colors.red, width: 5) : null,
          ),
          child: Center(
            child: Image.asset(
              image,
              height: 50.h,
              width: 50.w,
            ),
          ),
        ),

        // Container(
        //   decoration: BoxDecoration(
        //     border: Border.all()
        //   ),
        //   child: Center(
        //           child: Image.asset(
        //             image,
        //             height: 70.h,
        //             width: 70.w,
        //           ),),
        // ),
        // SizedBox(height: 10),
        CustomSpacers.height10,
        Container(
          height: 30.h,
          width: 170.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // IconButton(
              InkWell(
                  onTap: decrement,
                  child: Icon(
                    Icons.remove_circle_outline,
                    size: 24.w,
                    color: Colors.red,
                  )),
              // onPressed: decrement,

              Text("₹$amount",
                  style:
                      TextStyle(fontSize: 11.w, fontWeight: FontWeight.bold)),
              // IconButton(
              InkWell(
                  onTap: increment,
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 24.w,
                    color: Colors.green,
                  )),
              // onPressed: increment,
            ],
          ),
        ),
      ],
    );
  }
}
