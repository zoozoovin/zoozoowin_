import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/core/utils/screen_utils.dart';
import 'package:zoozoowin_/features/notificaiton_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(AppImages.background), fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSpacers.height60,
              _buildTop(),
              _buildNotification(),
            ],
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
          children: [
            Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ),
            CustomSpacers.width12,
            Text(
              "Notifications",
              style: TextStyle(
                  fontSize: 20.h,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            )
          ],
        ),
      );

  _buildNotification() =>
        Expanded(
        child: SingleChildScrollView(
          child: Container(
            // height: 400.h,
            width: MediaQuery.of(context).size.width,
            child: Consumer<NotificaitonProvider>(builder: (context, value, child) {
              List<dynamic> keys = value.notificationList.keys.toList();
              return value.notificationList.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: keys.length,
                      itemBuilder: (BuildContext context, int index) {
                        String date = keys[index];
                        List<dynamic> items = value.notificationList[date];
                        return _widget(items);
                      },
                    )
                  : Center(
                      child: Padding(
                        padding: EdgeInsets.only(top : 48.0),
                        child: Text(
                        "No new Notifications !",
                        style: TextStyle(
                            fontSize: 17.w,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                                            ),
                      ));
            }),
          ),
        ),
      );

  _widget(List<dynamic> items) => ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25.r,
                        backgroundColor: Colors.white,
                        child: items[index]['type'] != "game"
                            ? Image.asset(
                                AppIcons.wallet,
                                color: Colors.black,
                                height: 30.h,
                                width: 30.w,
                              )
                            : Icon(
                                Icons.gamepad_sharp,
                                color: Colors.black,
                              ),
                      ),
                      CustomSpacers.width16,
                      SizedBox(
                        width: 250.w,
                        child: Text(
                          items[index]['type'] == 'game'
                              ? "${items[index]['title']}"
                              : "${items[index]['title']}\nDone Successfuly",
                          style: TextStyle(
                              fontSize: 18.w,
                              color: Colors.white,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Provider.of<NotificaitonProvider>(context, listen: false)
                          .removeNotification(items[index]['date'], index);
                    },
                    child: Container(
                      height: 20.h,
                      width: 12.w,
                      child: Text(
                        "X",
                        style: TextStyle(
                            fontSize: 18.w,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
              CustomSpacers.height20,
              Divider(
                thickness: 0.4,
              ),
              CustomSpacers.height20,
            ],
          );
        },
      );
}
