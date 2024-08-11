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
    'c1': "assets/images/k_jack.png",
    'c2': "assets/images/k_heart.png",
    'c3': "assets/images/k_club.png",
    'c4': "assets/images/q_jack.png",
    'c5': "assets/images/q_heart.png",
    'c6': "assets/images/q_club.png",
    'c7': "assets/images/j_jack.png",
    'c8': "assets/images/j_heart.png",
    'c9': "assets/images/j_club.png",
    'c10': "assets/images/k_diamond.png",
    'c11': "assets/images/q_diamond.png",
    'c12': "assets/images/j_diamond.png",
  };

  @override
  void initState() {
    super.initState();
    totalBetAmount = 10;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Provider.of<Game2Provider>(context, listen: false).set();
    });
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
          "Patti king", "HURRAY ! you won rs${bid.wonAmount} in patti king");
    }

    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: _winningCardId != null
                    ? Image.asset(
                        cardImages[_winningCardId!]!,
                        height: 100,
                        width: 100,
                      )
                    : Container(),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    bid.isWin == "win"
                        ? 'You Won! Rs${bid.wonAmount}'
                        : 'You Lost!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: bid.isWin == "win" ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // Text color
                  padding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12), // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Button border radius
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context)
                      .pop(); // Close the game screen (if needed)
                  _resetGame();
                },
                child: Text('OK'),
              ),
            ],
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
      totalBetAmount = 0;
      _currentImage = null;
      _isGameInProgress = false;
      _betPlaced = false; // Reset the betPlaced flag
    });
    p.set(); // Reset the game provider state
  }

  Future<void> placeBet() async {
        final wallet = Provider.of<WalletProvider>(context, listen: false);
    if(selectedCardIds.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Select atleast one card to place bet!'),
      ));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Bet placed successfully!'),
      ));
    }
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
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                    CustomSpacers.height30,
                    !_betPlaced
                        ? _buildBetControls()
                        : _currentImage != null
                            ? Container(
                              decoration: BoxDecoration(
                              color: Colors.amber,
                                borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                    width: 100, child: Image.asset(_currentImage!)),
                              ),
                            )
                            : Container(),
                    CustomSpacers.height20,
                    !_betPlaced ? _buildPlaceBetButton() : _buildTimerLogic(),
                    CustomSpacers.height40,
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
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
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
              Image.asset(
                'assets/icons/videotutorial.png',
                height: 30.h,
                width: 30.w,
                color: Colors.yellow,
              )
            ],
          ),
        ),
      );

  Widget _buildCardGrid() {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: cardImages.keys.map((cardId) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
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
      onTap:  placeBet,
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
      child: Container(
        height: 140.h,
        width: 75.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 6,
          ),
        ),
        child: Image.asset(images),
      ),
    );
  }
}
