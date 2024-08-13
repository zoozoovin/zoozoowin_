// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/core/utils/screen_utils.dart';
import 'package:zoozoowin_/features/game2/game2_provider.dart';
import 'package:zoozoowin_/features/wallet/data/transaction_provider.dart';
import 'package:zoozoowin_/features/wallet/data/wallet_provider.dart';
import 'package:zoozoowin_/notification_service.dart';
import 'package:zoozoowin_/ui/atoms/custom_button_game2.dart';
import 'package:zoozoowin_/ui/atoms/shine_button2.dart';

class Game2Screen extends StatefulWidget {
  const Game2Screen({super.key});

  @override
  State<Game2Screen> createState() => _Game2ScreenState();
}

class _Game2ScreenState extends State<Game2Screen> {
  Timer? _mainTimer;
  Timer? _boundaryTimer;
  int _remainingTime = 20;
  bool _isGameInProgress = false;
  bool _betPlaced = false; // Flag to track bet placement
  String? _winningCardId;
  Random _random = Random();
  String? _currentImage;
  List<String> selectedCardIds = [];
  int totalBetAmount = 0;

  // Map card IDs to image paths
  final Map<String, String> cardImages = {
    'c1': "assets/k_jack.png",
    'c2': "assets/k_heart.png",
    'c3': "assets/k_club.png",
    'c4': "assets/k_diamond.png",
    'c5': "assets/q_jack.png",
    'c6': "assets/q_heart.png",
    'c7': "assets/q_club.png",
    'c8': "assets/q_diamond.png",
    'c9': "assets/j_jack.png",
    'c10': "assets/j_heart.png",
    'c11': "assets/j_club.png",
    'c12': "assets/j_diamond.png",
  };

  @override
  void initState() {
    super.initState();
    totalBetAmount = 10;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Provider.of<Game2Provider>(context, listen: false).set();
    });
    // _showResultDialog();
  }

  @override
  void dispose() {
    _mainTimer?.cancel();
    _boundaryTimer?.cancel();
    super.dispose();
  }

  Future<void> startTimer() async {
    setState(() {
      _isGameInProgress = true;
    });

    _mainTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime -= 1;
        });
      } else {
        _mainTimer?.cancel();
        _boundaryTimer?.cancel();
        await _fetchWinningCard();
        _showResultDialog(); // Fetch the winning card from the backend
        setState(() {
          _currentImage = cardImages[_winningCardId];
        });
      }
    });

    _boundaryTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      _moveBoundaryRandomly();
    });
  }

  Future<void> _fetchWinningCard() async {
    final p = Provider.of<Game2Provider>(context, listen: false);
    setState(() {
      _winningCardId = p.wonCard; // Assume result contains the winning card ID
    });
  }

  void _moveBoundaryRandomly() {
    if (_isGameInProgress) {
      setState(() {
        _currentImage =
            cardImages.values.elementAt(_random.nextInt(cardImages.length));
      });
    }
  }

  void _showResultDialog() {
    final wallet = Provider.of<WalletProvider>(context, listen: false);
    final bid = Provider.of<Game2Provider>(context, listen: false);
    if (bid.isWin == "win") {
      PushNotificationService.sendFCMMessage(
          "Patti king", "HURRAY ! you won ₹ ${bid.wonAmount} in patti king");
    }

    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black38, // Set the background color to black
          insetPadding:
              EdgeInsets.zero, // Remove default padding around the dialog
          child: bid.isWin == "win"
              ? Container(
                  width: MediaQuery.of(context).size.width, // Full screen width
                  height:
                      MediaQuery.of(context).size.height, // Full screen height
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Centered background GIF
                      Center(
                        child: Image.asset(
                          'assets/won.gif',
                          width: MediaQuery.of(context).size.width *
                              0.9, // Scale to 90% of screen width
                          height: MediaQuery.of(context).size.height *
                              0.9, // Scale to 90% of screen height
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Positioned content in the center
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomSpacers.height18,

                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _resetGame();
                              },
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Image.asset('assets/cross.png'),
                                  )),
                            ),
                            CustomSpacers.height40,
                            // Card image
                            Image.asset(
                              cardImages[_winningCardId!]!,
                              height: 200, // Increase size of the card image
                              width: 200, // Increase size of the card image
                            ),
                            SizedBox(height: 20), // Add spacing between images
                            // You Won image
                            Padding(
                              padding: EdgeInsets.only(left: 20.w),
                              child: Container(
                                width: 300.w,
                                height: 200.h,
                                decoration: BoxDecoration(
                                  // color: Colors.white,
                                  image: DecorationImage(
                                      image: AssetImage('assets/youwon.png'),
                                      fit: BoxFit.cover),
                                ),
                              ),
                            ),

                            //You won Money =========================

                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomButtonGame2(
                                text: "TOTAL WIN - ₹ ${bid.wonAmount} ",
                                width: 380.w,
                                height: 60.h,
                                style: TextStyle(
                                    fontSize: 28.w,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                                color: Colors.amber,
                              ),
                            ),
                            CustomSpacers.height14,
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: CustomButtonGame2(
                                      text: "EXIT",
                                      width: 150.w,
                                      height: 60.h,
                                      style: TextStyle(
                                          fontSize: 24.w,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic),
                                      image: 'assets/cross.png',
                                      color: Colors.red,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      _resetGame();
                                    },
                                    child: CustomShinyButton2(
                                        text: "PLAY AGAIN",
                                        width: 220.w,
                                        height: 60.h,
                                        style: TextStyle(
                                            fontSize: 20.w,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic),
                                        image: 'assets/playagain.png'),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width, // Full screen width
                  height:
                      MediaQuery.of(context).size.height, // Full screen height
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Centered background GIF
                      Center(
                        child: Image.asset(
                          'assets/loss.gif',
                          width: MediaQuery.of(context).size.width *
                              0.9, // Scale to 90% of screen width
                          height: MediaQuery.of(context).size.height *
                              0.9, // Scale to 90% of screen height
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Positioned content in the center
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomSpacers.height18,

                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _resetGame();
                              },
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Image.asset('assets/cross.png'),
                                  )),
                            ),
                            CustomSpacers.height40,
                            // Card image
                            Image.asset(
                              cardImages[_winningCardId!]!,
                              height: 200, // Increase size of the card image
                              width: 200, // Increase size of the card image
                            ),
                            SizedBox(height: 20), // Add spacing between images
                            // You Won image
                            Padding(
                              padding: EdgeInsets.only(left: 20.w),
                              child: Container(
                                width: 300.w,
                                height: 200.h,
                                decoration: BoxDecoration(
                                  // color: Colors.white,
                                  image: DecorationImage(
                                      image: AssetImage('assets/youloss.png'),
                                      fit: BoxFit.cover),
                                ),
                              ),
                            ),

                            //You won Money =========================
                            CustomSpacers.height38,
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _resetGame();
                              },
                              child: CustomShinyButton2(
                                  text: "PLAY AGAIN",
                                  width: 300.w,
                                  height: 60.h,
                                  style: TextStyle(
                                      fontSize: 20.w,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic),
                                  image: 'assets/playagain.png'),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  void _resetGame() {
    final p = Provider.of<Game2Provider>(context, listen: false);
    setState(() {
      _remainingTime = 20;
      selectedCardIds.clear();
      totalBetAmount = 10;
      _currentImage = null;
      _isGameInProgress = false;
      _betPlaced = false; // Reset the betPlaced flag
    });
    p.set(); // Reset the game provider state
  }

  Future<void> placeBet() async {
    final wallet = Provider.of<WalletProvider>(context, listen: false);
    if (selectedCardIds.isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text('Select atleast one card to place bet!'),
      // ));
      showTopSnackBar(context, 'Select atleast one card to place bet!');
      return;
    }
    if (totalBetAmount > wallet.walletBalance) {
      unplaceBet();
    } else {
      setState(() {
        _betPlaced = true; // Set the betPlaced flag to true
      });

      DateTime now = DateTime.now();
      String formattedDate =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      String time = DateFormat('HH:mm:ss').format(now);

      startTimer();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final p = Provider.of<Game2Provider>(context, listen: false);
      await p.fetchResult(
          prefs.getString('phone') ?? '', selectedCardIds, totalBetAmount);
      wallet.deductCashWallet(double.parse((totalBetAmount).toString()));
      final pr = Provider.of<TransactionProvider>(context, listen: false);

      await pr.deductedAmount(
          formattedDate,
          time,
          double.parse((totalBetAmount).toString()),
          'Amount deducted - Rs ${totalBetAmount}',
          'placebet-game2');

      await pr.allTransUpdate(
          formattedDate,
          time,
          double.parse((totalBetAmount).toString()),
          'Amount deducted - Rs ${totalBetAmount}',
          'placebet-game2');
      // wallet.subWalletAmount(double.parse(totalBetAmount.toString()));
      showTopSnackBar(context, 'Bet placed successfully!');
    }
  }

  void showTopSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top +
            10, // Adjust the top padding if needed
        left: 10,
        right: 10,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue, // SnackBar background color
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                style: TextStyle(color: Colors.white), // SnackBar text color
              ),
            ),
          ),
        ),
      ),
    );

    overlay?.insert(overlayEntry);

    // Dismiss the snackbar after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Future<bool> _onWillPop() async {
    if (_isGameInProgress) {
      return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Warning'),
              content: Text('The game is in progress. Do you want to exit?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Exit'),
                ),
              ],
            ),
          )) ??
          false;
    }
    return true;
  }

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/game2bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomSpacers.height52,
                    _buildTop(),
                    CustomSpacers.height6,
                    // _buildTimerLogic(),
                    CustomSpacers.height20,
                    CustomSpacers.height20,
                    _buildCardGrid(),
                    CustomSpacers.height20,
                    !_betPlaced
                        ? _buildBetControls()
                        : _currentImage != null
                            ? Container(
                                width: 100.w,
                                height: 150.h,
                                decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                      width: 100,
                                      child: Image.asset(_currentImage!)),
                                ),
                              )
                            : Container(),
                    CustomSpacers.height20,
                    !_betPlaced ? _buildPlaceBetButton() : _buildTimerLogic(),
                    CustomSpacers.height20,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTop() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                  CustomSpacers.width12,
                  Text(
                    "PATTI KING",
                    style: TextStyle(
                        fontSize: 17.h,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                // _showResultDialog();
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Center(
                    child: Image.asset(
                      'assets/youtube.png',
                      height: 50.h,
                      width: 50.w,
                      // color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );

  Widget _buildCardGrid() {
    return Wrap(
      // alignment: WrapAlignment.spaceEvenly,
      children: cardImages.keys.map((cardId) {
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: BuildCards(
            images: cardImages[cardId]!,
            onTap: () => onCardTap(cardId),
            isSelected: selectedCardIds.contains(cardId),
          ),
        );
      }).toList(),
    );
  }

  void onCardTap(String cardId) {
    setState(() {
      if (selectedCardIds.contains(cardId)) {
        selectedCardIds.remove(cardId);
      } else if (selectedCardIds.length < 3) {
        selectedCardIds.add(cardId);
      }
    });
  }

  Widget _buildBetControls() {
    return Column(
      children: [
        CustomSpacers.height15,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (totalBetAmount > 0) totalBetAmount -= 10;
                });
              },
              child: Container(
                height: 80.h,
                width: 80.w,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/decreament.png')),
                  // color: Colors.white,
                  // borderRadius: BorderRadius.circular(10),
                ),
                // child: const Center(
                //   child: Icon(
                //     Icons.remove,
                //     color: Colors.black,
                //   ),
                // ),
              ),
            ),
            CustomSpacers.width10,
            Container(
              height: 50.h,
              width: 100.w,

              decoration: BoxDecoration(
                  // color: Colors.amber,
                  image: DecorationImage(
                image: AssetImage('assets/game2middle.png'),
              )),
              // color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: Text(
                  '$totalBetAmount',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            CustomSpacers.width10,
            GestureDetector(
              onTap: () {
                setState(() {
                  totalBetAmount += 10;
                });
              },
              child: Container(
                height: 80.h,
                width: 80.w,
                decoration: BoxDecoration(
                    // color: Colors.amber,
                    image: DecorationImage(
                  image: AssetImage('assets/increament.png'),
                )),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceBetButton() {
    return GestureDetector(
      onTap: placeBet,
      child: Container(
        height: 80.h,
        width: 300.w,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/game2placebet.png')),
          // color: selectedCardIds.isEmpty ? Colors.grey : Colors.amber,
          borderRadius: BorderRadius.circular(10),
        ),
        // child: Center(
        //   child: Text(
        //     'PLACE BET',
        //     style: TextStyle(
        //       fontSize: 20,
        //       fontWeight: FontWeight.bold,
        //       color: Colors.black,
        //     ),
        //   ),
        // ),
      ),
    );
  }

  Widget _buildTimerLogic() {
    return Visibility(
      visible: _betPlaced, // Show timer only if the bet is placed
      child: Container(
        height: 100, // Define a height to ensure the Stack has constraints
        child: Stack(
          children: [
            Positioned(
              top: kToolbarHeight - 35,
              left: 10,
              right: 10,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  height: 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.green.shade400,
                        Colors.green.shade700,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _remainingTime > 0
                          ? "00:00:${_remainingTime.toString().padLeft(2, '0')}"
                          : "00:00:20",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BuildCards extends StatelessWidget {
  final String images;
  final VoidCallback onTap;
  final bool isSelected;

  const BuildCards({
    required this.images,
    required this.onTap,
    required this.isSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.0),
        child: Container(
          // height: 140.h,
          // width: 75.w,
          decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: isSelected
                  ? const Color.fromARGB(255, 108, 255, 34)
                  : Colors.transparent,
              width: 5,
            ),
          ),
          child: Image.asset(
            images,
            width: 80.w,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}
