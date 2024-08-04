import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/core/constants/app_data.dart';
import 'package:zoozoowin_/core/loader_widget.dart';
import 'package:zoozoowin_/core/utils/screen_utils.dart';
import 'package:zoozoowin_/features/game1/gam1_screen.dart';
import 'package:zoozoowin_/features/game1/game_provider.dart';
import 'package:zoozoowin_/features/home/data/home_provider.dart';
import 'package:zoozoowin_/features/home/data/result_ticket_provider.dart';
import 'package:zoozoowin_/features/home/screens/notification_screen.dart';
import 'package:badges/badges.dart' as badges;
import 'package:zoozoowin_/features/home/screens/result_ticket_screen.dart';
import 'package:zoozoowin_/notification_service.dart';
import 'package:zoozoowin_/ui/atoms/shine_button.dart';

class Game1TimeSlotScreen extends StatefulWidget {
  @override
  State<Game1TimeSlotScreen> createState() => _Game1TimeSlotScreenState();
}

class _Game1TimeSlotScreenState extends State<Game1TimeSlotScreen>
    with TickerProviderStateMixin {
  String formattedDate = "";
  Timer? timer;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    formattedDate =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    // Set up the timer to check the time every minute
    timer = Timer.periodic(Duration(minutes: 1), (Timer t) => _checkTime());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _checkTime() {
    DateTime now = DateTime.now();
    int currentHour = now.hour;
    int currentMinute = now.minute;

    // Check if the current time is within the specified slot range
    if (currentHour >= 12 && currentHour < 24 && currentMinute == 50) {
      PushNotificationService.sendFCMMessage(
          "PLAY WIN - time slot",
          "Current hour time slot is going to close in 10 minutes.");
    }
  }

  @override
  Widget build(BuildContext context) {
    Stream<DateTime> _timeStream =
        Stream<DateTime>.periodic(Duration(seconds: 1), (_) => DateTime.now());

    return Consumer<GameProvider>(
      builder: (context, value, child) => LoaderWidget(
        isLoading: value.isLoading,
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 0, 73, 122),
          body: Container(
            decoration: BoxDecoration(
                // image: DecorationImage(
                //   image: AssetImage(AppImages.background),
                //   fit: BoxFit.cover,
                // ),
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomSpacers.height40,
                _buildTop(context),
                _buildResult(),
                CustomSpacers.height10,
                CustomSpacers.height6,
                Text(
                  'GAME SLOT TIME 12PM TO 12AM',
                  style: TextStyle(
                      fontSize: 23.w,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                CustomSpacers.height10,
                SingleChildScrollView(
                  child: StreamBuilder<DateTime>(
                    stream: _timeStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Padding(
                          padding: EdgeInsets.only(top: 100.h),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      }

                      DateTime now = snapshot.data!;
                      int currentHour = now.hour;
                      int currentMinute = now.minute;

                      List<String> timeSlots = AppData.timeSlots;
                      List<String> slotImages =
                          List.generate(timeSlots.length, (index) {
                        if (currentHour < 12 || currentHour >= 24) {
                          return 'assets/images/greyslot.png';
                        }

                        List<String> timeParts = timeSlots[index].split(" ");
                        List<String> hourMinuteParts = timeParts[0].split(":");
                        int slotHour = int.parse(hourMinuteParts[0]);
                        int slotMinute = int.parse(hourMinuteParts[1]);
                        if (timeParts[1] == 'PM' && slotHour != 12)
                          slotHour += 12;
                        if (timeParts[1] == 'AM' && slotHour == 12)
                          slotHour = 0;

                        if (slotHour < currentHour ||
                            (slotHour == currentHour && currentMinute >= 55)) {
                          if (slotHour == currentHour &&
                              currentMinute >= 55 &&
                              currentMinute < 60) {
                            return 'assets/images/slotclosed.png';
                          } else {
                            return 'assets/images/redslot.png';
                          }
                        } else {
                          return 'assets/images/greenslot.png';
                        }
                      });

                      List<Widget> timeSlotWidgets =
                          List.generate(timeSlots.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            if (slotImages[index] ==
                                'assets/images/greenslot.png') {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 107, 173),
                                builder: (context) {
                                  return Container(
                                    height: 180.h,
                                    decoration: BoxDecoration(
                                        // image: DecorationImage(
                                        //   image: AssetImage(AppImages.background),
                                        //   fit: BoxFit.cover,
                                        // ),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(34),
                                            topRight: Radius.circular(40))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            'CHOOSE ENTRY AMOUNT',
                                            style: TextStyle(
                                                fontSize: 20.w,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white),
                                          ),
                                          CustomSpacers.height20,
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              _buildCircleAvatar(context, '₹10',
                                                  timeSlots[index]),
                                              _buildCircleAvatar(context, '₹50',
                                                  timeSlots[index]),
                                              _buildCircleAvatar(context,
                                                  '₹100', timeSlots[index]),
                                              _buildCircleAvatar(context,
                                                  '₹200', timeSlots[index]),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                          child: Consumer<GameProvider>(
                            builder: (context, value, child) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 2),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.asset(
                                        slotImages[index],
                                        width: 180.w,
                                        height: 90.h,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Positioned(
                                      left: 50.w,
                                      top: 15.h,
                                      child: Center(
                                        child: Text(
                                          timeSlots[index],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.w,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    value.getSlot[timeSlots[index]]
                                        ? Positioned(
                                            right: 145.w,
                                            top: 4.h,
                                            child: Icon(
                                              Icons.play_circle,
                                              color: const Color.fromARGB(
                                                  255, 255, 255, 255),
                                              size: 25.w,
                                            ))
                                        : Container(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      });

                      Widget timeSlotsColumn1 = Column(
                        children: timeSlotWidgets.getRange(0, 6).toList(),
                      );

                      Widget timeSlotsColumn2 = Column(
                        children: timeSlotWidgets.getRange(6, 12).toList(),
                      );

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          timeSlotsColumn1,
                          timeSlotsColumn2,
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTop(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
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
                      "PICK A TIME SLOT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.w,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationScreen(),
                      ),
                    );
                  },
                  child: Image.asset(
                    AppIcons.notification,
                    height: 30.h,
                    width: 30.w,
                  )),
            ],
          ),
        ),
      );

  Widget _buildResult() => ChangeNotifierProvider(
        create: (context) => ResultTicketProvider(),
        child: Consumer<HomeProvider>(
          builder: (context, value, child) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: () {
                AppData.navigateToNotification(context, ResultTicketScreen());
              },
              child: Container(
                height: 70.h,
                width: 350.w,
                // color: Colors.amber,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Container(
                    //   height: 50.h,
                    //   width: 300.w,
                    //   padding: EdgeInsets.all(8),
                    //   decoration: BoxDecoration(
                    //     gradient: LinearGradient(
                    //       colors: [Color(0xFF00FF0A), Color(0xFF008A12)],
                    //       begin: Alignment.topCenter,
                    //       end: Alignment.bottomCenter,
                    //     ),
                    //     borderRadius: BorderRadius.circular(10),
                    //   ),
                    //   child: Center(
                    //     child: Text(
                    //       'TICKETS & RESULTS',
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: 23.w,
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    CustomShinyButton(
                        text: "TICKETS & RESULTS", width: 300.w, height: 50.h),
                    Positioned(
                      left: 280.w,
                      bottom: 40.h,
                      child: Image.asset(
                        AppImages.live,
                        height: 20.h,
                      ),
                    ),
                    Positioned(
                      left: 25.w,
                      bottom: 33.h,
                      child: Container(
                        child: Center(
                          child: badges.Badge(
                            badgeStyle: badges.BadgeStyle(
                              borderSide: BorderSide(
                                width: 2,
                                color: Colors.white,
                              ),
                            ),
                            badgeContent: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                value.totalCount.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildCircleAvatar(BuildContext context, String text, String time) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Close the bottom sheet
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Game1Screen(
                time: time,
                amount: text == "₹10"
                    ? 10
                    : text == "₹50"
                        ? 50
                        : text == "₹100"
                            ? 100
                            : 200),
          ),
        );
      },
      child: CircleAvatar(
        radius: 40.r,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 38.r,
          backgroundColor: const Color.fromARGB(255, 0, 73, 122),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.w,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
