// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:zoozoowin_/core/utils/custom_spacers.dart';
import 'package:zoozoowin_/core/utils/screen_utils.dart';
import 'package:badges/badges.dart' as badges;
import 'package:zoozoowin_/features/home/data/result_ticket_provider.dart';

class ResultTicketScreen extends StatefulWidget {
  const ResultTicketScreen({super.key});

  @override
  State<ResultTicketScreen> createState() => _ResultTicketScreenState();
}

class _ResultTicketScreenState extends State<ResultTicketScreen>
    with TickerProviderStateMixin {
  String formattedDate = '';
  bool _isLoading = false;

  late AnimationController _controller2;
  late Animation<double> _animation2;
  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    formattedDate =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<ResultTicketProvider>(context, listen: false)
          .getSelectedCards(formattedDate);

      await Provider.of<ResultTicketProvider>(context, listen: false)
          .showHistory(formattedDate);
      setState(() {
        _isLoading = false;
      });
    });
    _controller2 = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _animation2 =
        Tween<double>(begin: -200.w, end: -5.w).animate(CurvedAnimation(
      parent: _controller2,
      curve: Curves.linear,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ResultTicketProvider>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 73, 122),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomSpacers.height45,
                _buildTop(),
                CustomSpacers.height6,
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    width: 350.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 50.h,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formattedDate,
                                style: TextStyle(
                                    fontSize: 18.w,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black),
                              ),
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey,
                                child: Center(
                                    child: Icon(
                                  Icons.date_range,
                                  color: Colors.white,
                                  size: 20.w,
                                )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                CustomSpacers.height10,
                _buildHeading(),
                _buildBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTop() => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
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
                      "RESULT & TICKETS",
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

  DateTime? _selectedDate;
  String _formattedDatePick = '';

  // Function to display the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        // _formattedDatePick = _formatDate(pickedDate);
        formattedDate = _formatDate(pickedDate);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<ResultTicketProvider>(context, listen: false)
          .getSelectedCards(formattedDate);
      await Provider.of<ResultTicketProvider>(context, listen: false)
          .showHistory(formattedDate);
      setState(() {
        _isLoading = false;
      });
    });

    // ignore: await_only_futures
    // await showHistory(_formattedDatePick);
  }

  // Function to format the date manually
  String _formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return "$day-$month-$year";
  }

  _buildBody() => Consumer<ResultTicketProvider>(
        builder: (context, value, child) => !_isLoading
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                // CustomSpacers.height10,
                _buildWidget(
                    "12:00 PM",
                    value.cardCounts["12:00 PM"] ?? 0,
                    value.cardLists["12:00 PM"] ?? [],
                    value.resultHistoryList[0]['wonCard']),
                _buildWidget(
                    "01:00 PM",
                    value.cardCounts["01:00 PM"] ?? 0,
                    value.cardLists["01:00 PM"] ?? [],
                    value.resultHistoryList[1]['wonCard']),
                _buildWidget(
                    "02:00 PM",
                    value.cardCounts["02:00 PM"] ?? 0,
                    value.cardLists["02:00 PM"] ?? [],
                    value.resultHistoryList[2]['wonCard']),
                _buildWidget(
                    "03:00 PM",
                    value.cardCounts["03:00 PM"] ?? 0,
                    value.cardLists["03:00 PM"] ?? [],
                    value.resultHistoryList[3]['wonCard']),
                _buildWidget(
                    "04:00 PM",
                    value.cardCounts["04:00 PM"] ?? 0,
                    value.cardLists["04:00 PM"] ?? [],
                    value.resultHistoryList[4]['wonCard']),
                _buildWidget(
                    "05:00 PM",
                    value.cardCounts["05:00 PM"] ?? 0,
                    value.cardLists["05:00 PM"] ?? [],
                    value.resultHistoryList[5]['wonCard']),
                _buildWidget(
                    "06:00 PM",
                    value.cardCounts["06:00 PM"] ?? 0,
                    value.cardLists["06:00 PM"] ?? [],
                    value.resultHistoryList[6]['wonCard']),
                _buildWidget(
                    "07:00 PM",
                    value.cardCounts["07:00 PM"] ?? 0,
                    value.cardLists["07:00 PM"] ?? [],
                    value.resultHistoryList[7]['wonCard']),
                _buildWidget(
                    "08:00 PM",
                    value.cardCounts["08:00 PM"] ?? 0,
                    value.cardLists["08:00 PM"] ?? [],
                    value.resultHistoryList[8]['wonCard']),
                _buildWidget(
                    "09:00 PM",
                    value.cardCounts["09:00 PM"] ?? 0,
                    value.cardLists["09:00 PM"] ?? [],
                    value.resultHistoryList[9]['wonCard']),
                _buildWidget(
                    "10:00 PM",
                    value.cardCounts["10:00 PM"] ?? 0,
                    value.cardLists["10:00 PM"] ?? [],
                    value.resultHistoryList[10]['wonCard']),
                _buildWidget(
                    "11:00 PM",
                    value.cardCounts["11:00 PM"] ?? 0,
                    value.cardLists["11:00 PM"] ?? [],
                    value.resultHistoryList[11]['wonCard']),
                CustomSpacers.height26,
              ])
            : Padding(
                padding: EdgeInsets.only(top: 300.h),
                child: Container(
                    height: 30.h,
                    width: 30.w,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    )),
              ),
      );

  _buildHeading() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 40.h,
            width: 280.w,
            decoration: BoxDecoration(
              // color: Colors.red,
              border: Border.all(color: Colors.white),
            ),
            child: Center(
              child: Text(
                "CHECK TICKET",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26.w,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Container(
            height: 40.h,
            width: 120.w,
            decoration: BoxDecoration(
              // color: Colors.red,
              border: Border.all(color: Colors.white),
            ),
            child: Center(
              child: Text(
                "RESULT",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26.w,
                    fontWeight: FontWeight.w600),
              ),
            ),
          )
        ],
      );

  Duration _calculateRemainingTime(String slotTime) {
    DateTime now =
        DateTime.now().add(Duration(hours: 1)); // Increment the current hour
    int slotHour =
        int.parse(slotTime.split(":")[0]) + (slotTime.contains("PM") ? 12 : 0);
    DateTime slotDateTime = DateTime(now.year, now.month, now.day, slotHour);

    if (slotDateTime.isBefore(now)) {
      slotDateTime = slotDateTime.add(Duration(days: 1));
    }

    return slotDateTime.difference(now);
  }

  _buildWidget(String title, int count, List<Map<String, dynamic>> cardList,
      String cardWon) {
    return Consumer<ResultTicketProvider>(
      builder: (context, value, child) => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 70.h,
              width: 280.w,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
              ),
              child: InkWell(
                onTap: () {
                  _showUserCard(context, cardList, title, cardWon);
                },
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Container(
                    height: 60.h,
                    width: 300.w,
                    // color: Colors.amber,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Container(
                            padding: EdgeInsets.all(6),
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                    radius: 25.r,
                                    backgroundColor: Colors.white,
                                    child: Image.asset(
                                      'assets/images/tickets.png',
                                      height: 30.h,
                                      width: 30.w,
                                    )),
                                CustomSpacers.width16,
                                Center(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                        fontSize: 26.w,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                                CustomSpacers.width20,
                                count != 0
                                    ? badges.Badge(
                                        badgeStyle: badges.BadgeStyle(
                                            borderSide: BorderSide(
                                                color: Colors.white, width: 2)),
                                        badgeContent: Container(
                                          height: 23.h,
                                          width: 23.w,
                                          child: Padding(
                                            padding: const EdgeInsets.all(1.0),
                                            child: Center(
                                              child: Text(
                                                count.toString(),
                                                // '12',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14.w),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 70.h,
              width: 120.w,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
              ),
              child: Center(
                child: cardWon != 'coming'
                    ? Container(
                        child: Center(
                            child: Image.asset(
                          cardWon,
                          height: 90.h,
                        )),
                      )
                    : Container(
                        height: 55.h,
                        width: 100.w,
                        child: Center(
                            child: Text(
                          'Not\nDeclared',
                          style: TextStyle(
                              fontSize: 14.w,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showUserCard(BuildContext context, List<Map<String, dynamic>> cardList,
      String title, String cardWon) async {
    final p = Provider.of<ResultTicketProvider>(context, listen: false);
    if (cardList.isNotEmpty) {
      double price = double.parse(p.cardTotalAmount[title].toString());
      // for( var i in cardList){
      //   if(i['image'] == cardWon){

      //   }
      // }
      await p.wonAmount(formattedDate);

      print(title);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  height: 700.h,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        "assets/images/show_my_cards.png",
                      ),
                      fit: BoxFit.none,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomSpacers.height52,
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Icon(
                                Icons.cancel,
                                size: 35.w,
                                color: Colors.white,
                              ),
                            )),
                      ),
                      CustomSpacers.height10,
                      Center(
                        child: Container(
                          width: 120.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black,
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                              ),
                              child: Text(
                                "₹ ${price.toInt().toString()}",
                                // '₹ 20000',
                                style: TextStyle(
                                  fontSize: 22.w,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      CustomSpacers.height4,
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 50.w,
                          // vertical: 30.h,
                        ),
                        child: Container(
                          height: 400.h,
                          width: 300.w,
                          child: Scrollbar(
                            thumbVisibility: true,
                            // scrollbarOrientation:  ,
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8.w,
                                mainAxisSpacing: 8.h,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: cardList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          border: cardList[index]['image']
                                                      .toString() ==
                                                  cardWon
                                              ? Border.all(
                                                  color: Colors.black, width: 2)
                                              : null),
                                      // radius: 25.r,
                                      child: Image.asset(
                                        cardList[index]['image'].toString(),
                                        height: 40.h,
                                        width: 40.w,
                                      ),
                                    ),
                                    CustomSpacers.height10,
                                    Text(
                                      cardList[index]['amount'].toString() +
                                          ' ₹',
                                      style: TextStyle(
                                        fontSize: 18.w,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      CustomSpacers.height10,
                      Column(
                        children: [
                          cardWon != 'coming'
                              ? Container()
                              : Text(
                                  "Result Not Declared",
                                  style: TextStyle(
                                    fontSize: 16.w,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                    fontStyle: FontStyle.italic,
                                    letterSpacing: 2,
                                  ),
                                ),
                          CustomSpacers.height6,
                          cardWon != 'coming'
                              ? !p.isLoading
                                  ? p.slotWonAmount[title] != '0'
                                      ? Column(
                                          children: [
                                            // Image.asset(
                                            //   'assets/happy.png',
                                            //   height: 60.h,
                                            //   width: 60.w,
                                            // ),
                                            CustomSpacers.height10,
                                            Text(
                                              'YOU WON ₹${p.slotWonAmount[title].toString()} ',
                                              // 'YOU WON ₹240000 ',
                                              style: TextStyle(
                                                fontSize: 20.w,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.black,
                                                fontStyle: FontStyle.italic,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            // Image.asset(
                                            //   'assets/sad.png',
                                            //   height: 60.h,
                                            //   width: 60.w,
                                            // ),
                                            CustomSpacers.height10,
                                            Text(
                                              'YOU LOSE',
                                              style: TextStyle(
                                                fontSize: 16.w,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.black,
                                                fontStyle: FontStyle.italic,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                          ],
                                        )
                                  : CircularProgressIndicator()
                              : Container(),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    } else {
      Fluttertoast.showToast(
        msg: "No cards selected !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}








                // ListView.builder(
                //     physics: NeverScrollableScrollPhysics(),
                //     shrinkWrap: true,
                //     itemCount: 12,
                //     itemBuilder: (contxt, index) {
                //       return Container(
                //         // color: Colors.red,
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Container(
                //               height: 70.h,
                //               width: 280.w,
                //               decoration: BoxDecoration(
                //                 // color: Colors.red,
                //                 border: Border.all(color: Colors.white),
                //               ),
                //               child: InkWell(
                //                 onTap: (){
                //                   _showUserCard(context, cardList, title, cardWon);
                //                 },
                //                 child: Padding(
                //                   padding: const EdgeInsets.all(8.0),
                //                   child: Stack(
                //                     children: [
                //                       Container(
                //                         padding: EdgeInsets.all(12),
                //                         decoration: BoxDecoration(
                //                           image: DecorationImage(
                //                             image: AssetImage(AppImages.ticket),
                //                             fit: BoxFit.cover,
                //                           ),
                //                           gradient: LinearGradient(
                //                             colors: [
                //                               Color(0xFF00FF0A),
                //                               Color(0xFF008A12)
                //                             ],
                //                             begin: Alignment.topCenter,
                //                             end: Alignment.bottomCenter,
                //                           ),
                //                           borderRadius: BorderRadius.circular(10),
                //                         ),
                //                         child: Center(
                //                           child: Text(
                //                             'DOWNLOAD NOW',
                //                             style: TextStyle(
                //                               color: Colors.white,
                //                               fontWeight: FontWeight.bold,
                //                               fontSize: 12,
                //                             ),
                //                           ),
                //                         ),
                //                       ),
                //                       Positioned.fill(
                //                         child: AnimatedBuilder(
                //                           animation: _animation2,
                //                           builder: (context, child) {
                //                             return Transform(
                //                               transform:
                //                                   Matrix4.translationValues(
                //                                       _animation2.value, 0, 0),
                //                               child: Container(
                //                                 decoration: BoxDecoration(
                //                                   gradient: LinearGradient(
                //                                     colors: [
                //                                       Colors.transparent,
                //                                       Colors.white
                //                                           .withOpacity(0.5)
                //                                     ],
                //                                     begin: Alignment.centerLeft,
                //                                     end: Alignment.centerRight,
                //                                   ),
                //                                   // transform: Matrix4.rotationZ(-0.785398), // -45 degrees in radians
                //                                 ),
                //                               ),
                //                             );
                //                           },
                //                         ),
                //                       ),
                //                       Positioned(
                //                         left: 240.w,
                //                         bottom: 35.h,
                //                         child: count != 0
                //                             ? badges.Badge(
                //                                 badgeContent: Container(
                //                                   height: 17.h,
                //                                   width: 17.w,
                //                                   child: Center(
                //                                     child: Text(
                //                                       count.toString(),
                //                                       style: TextStyle(
                //                                           color: Colors.white,
                //                                           fontSize: 14.w),
                //                                     ),
                //                                   ),
                //                                 ),
                //                               )
                //                             : Container(),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //             ),
                //             Container(
                //               height: 70.h,
                //               width: 120.w,
                //               decoration: BoxDecoration(
                //                 // color: Colors.red,
                //                 border: Border.all(color: Colors.white),
                //               ),
                //               child: Center(
                //                 // child: Text(
                //                 //   "",
                //                 //   style: TextStyle(
                //                 //       color: Colors.white,
                //                 //       fontSize: 26.w,
                //                 //       fontWeight: FontWeight.w600),
                //                 // ),

                //                 child: cardWon != 'coming'
                //                     ? Container(
                //                         height: 55.h,
                //                         width: 100.w,
                //                         decoration: BoxDecoration(
                //                           image: DecorationImage(
                //                             image:
                //                                 AssetImage("assets/result.png"),
                //                             fit: BoxFit.fitHeight,
                //                           ),
                //                         ),
                //                         child: Center(
                //                             child: Image.asset(
                //                           cardWon,
                //                           height: 40.h,
                //                         )),
                //                       )
                //                     : Container(
                //                         height: 55.h,
                //                         width: 100.w,
                //                         decoration: BoxDecoration(
                //                           image: DecorationImage(
                //                             image: AssetImage(
                //                                 "assets/noResult.png"),
                //                             fit: BoxFit.fitHeight,
                //                           ),
                //                         ),
                //                         child: Center(
                //                             child: Text(
                //                           'Not\nDeclared',
                //                           style: TextStyle(
                //                               fontSize: 14.w,
                //                               fontWeight: FontWeight.w600,
                //                               color: Colors.white),
                //                           textAlign: TextAlign.center,
                //                         )),
                //                       ),
                //               ),
                //             )
                //           ],
                //         ),
                //       );
                //     })




                 // if (count != 0)
                        //   Positioned(
                        //     left: 49.w,
                        //     bottom: 28.h,
                        //     child: badges.Badge(
                        //       badgeContent: Container(
                        //         height: 17.h,
                        //         width: 17.w,
                        //         child: Padding(
                        //           padding: const EdgeInsets.all(2.0),
                        //           child: Center(
                        //             child: Text(
                        //               count.toString(),
                        //               // '12',
                        //               style: TextStyle(
                        //                   color: Colors.white, fontSize: 14.w),
                        //             ),
                        //           ),
                        //         ),
                        //       ),

                        //     ),
                        //   ),






                        // Padding(
                        //   padding: const EdgeInsets.all(6.0),
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       image: DecorationImage(
                        //         image: AssetImage(AppImages.ticket),
                        //         fit: BoxFit.cover,
                        //       ),
                        //       // color: Colors.red,
                        //       gradient: LinearGradient(
                        //         colors: [Color(0xFF00FF0A), Color(0xFF008A12)],
                        //         begin: Alignment.topCenter,
                        //         end: Alignment.bottomCenter,
                        //       ),
                        //       borderRadius: BorderRadius.circular(10),
                        //     ),
                        //     child: Center(
                        //       child: Text(
                        //         title,
                        //         style: TextStyle(
                        //           color: Colors.white,
                        //           fontWeight: FontWeight.bold,
                        //           fontSize: 20.w,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // Positioned.fill(
                        //   child: AnimatedBuilder(
                        //     animation: _animation2,
                        //     builder: (context, child) {
                        //       return Transform(
                        //         transform: Matrix4.translationValues(
                        //             _animation2.value, 0, 0),
                        //         child: Container(
                        //           decoration: BoxDecoration(
                        //             gradient: LinearGradient(
                        //               colors: [
                        //                 Colors.transparent,
                        //                 Colors.white.withOpacity(0.5)
                        //               ],
                        //               begin: Alignment.centerLeft,
                        //               end: Alignment.centerRight,
                        //             ),
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),