import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zoozoowin_/core/constants/app_icons.dart';
import 'package:zoozoowin_/core/constants/app_images.dart';
import 'package:zoozoowin_/core/utils/custom_spacers.dart';
import 'package:zoozoowin_/core/utils/screen_utils.dart';
import 'package:zoozoowin_/features/wallet/data/transaction_provider.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  int _selectedIndex = 0;
  final List<String> _dropdownItems = [
    'All transactions',
    'Cash added',
    'Cash withdrawal',
    'Bonus cash added',
    'Won cash amount',
    'Deducted cash amount'
  ];
  String _selectedDropdownItem = 'All transactions';

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedDropdownItem = _dropdownItems[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(AppImages.background), fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              CustomSpacers.height36,
              _buildTop(),
              CustomSpacers.height20,
              _buildDropdown(),
              // CustomSpacers.height20,
              _buildContainer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTop() => InkWell(
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
              "Transaction History",
              style: TextStyle(
                  fontSize: 17.h,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            )
          ],
        ),
      );

  _buildDropdown() => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: DropdownButton<String>(
          value: _selectedDropdownItem,
          items: _dropdownItems.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              _onTabSelected(_dropdownItems.indexOf(newValue));
            }
          },
          style: TextStyle(color: Colors.black, fontSize: 16.w),
          dropdownColor: Colors.white,
          underline: Container(),
          isExpanded: true,
        ),
      );

  _buildContainer() => Expanded(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            AllContainer(),
            AddCashContainer(),
            WithdrawCashContainer(),
            BonusCashContainer(),
            WonCashContainer(),
            DeductedContainer(),
          ],
        ),
      );
}

class AllContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, value, child) => Container(
        child: value.allTrans.isNotEmpty
            ? ListView.builder(
                itemCount: value.allTrans.length,
                itemBuilder: (context, ind) {
                  int index = value.allTrans.length - ind - 1;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      // height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              // radius: 25,
                              child: value.allTrans[index]['type'] ==
                                      'placebet-game1'
                                  ? Image.asset(
                                      AppImages.game1,
                                      height: 50.h,
                                      width: 50.w,
                                    )
                                  : value.allTrans[index]['type'] == 'wallet'
                                      ? Image.asset(
                                          AppIcons.wallet,
                                          height: 35.h,
                                          width: 35.w,
                                          color: Colors.black,
                                        )
                                      : null,
                            ),
                            CustomSpacers.width20,
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(value.allTrans[index]['date'] +
                                    " - ${value.allTrans[index]['time']}"),
                                Container(
                                  width: 250.w,
                                  child: Text(
                                    "${value.allTrans[index]['title']}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18.w),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                })
            : Center(
                child: Text(
                  "OOPS! , No transactions",
                  style: TextStyle(
                      fontSize: 18.w,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
      ),
    );
  }
}

class AddCashContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, value, child) => Container(
        child: value.addCashAmount.isNotEmpty
            ? ListView.builder(
                itemCount: value.addCashAmount.length,
                itemBuilder: (context, ind) {
                  int index = value.addCashAmount.length - ind - 1;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      // height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              // radius: 20,
                              child: Image.asset(
                                AppImages.addcashIcon,
                                height: 40.h,
                                width: 40.w,
                              ),
                            ),
                            CustomSpacers.width20,
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(value.addCashAmount[index]['date'] +
                                    " - ${value.addCashAmount[index]['time']}"),
                                Container(
                                  width: 250.w,
                                  child: Text(
                                    "Cash Added - Rs ${value.addCashAmount[index]['amount']}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18.w),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                })
            : Center(
                child: Text(
                  "OOPS! , No cash Added",
                  style: TextStyle(
                      fontSize: 18.w,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
      ),
    );
  }
}

class WithdrawCashContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, value, child) => Container(
        child: value.withdrawCashAmount.isNotEmpty
            ? ListView.builder(
                itemCount: value.withdrawCashAmount.length,
                itemBuilder: (context, ind) {
                  int index = value.withdrawCashAmount.length - ind - 1;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      // height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              // radius: 20,
                              child: Image.asset(
                                AppImages.withdrawicon,
                                height: 40.h,
                                width: 40.w,
                              ),
                            ),
                            CustomSpacers.width20,
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(value.withdrawCashAmount[index]['date'] +
                                    " - ${value.withdrawCashAmount[index]['time']}"),
                                Container(
                                  width: 250.w,
                                  child: Text(
                                    "Cash Withdrawal - Rs ${value.withdrawCashAmount[index]['amount']}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18.w),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                })
            : Center(
                child: Text(
                  "OOPS! , No cash Withdrawal",
                  style: TextStyle(
                      fontSize: 18.w,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
      ),
    );
  }
}

class BonusCashContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, value, child) => Container(
        child: value.bonusCashAmount.isNotEmpty
            ? ListView.builder(
                itemCount: value.bonusCashAmount.length,
                itemBuilder: (context, ind) {
                  int index = value.bonusCashAmount.length - ind - 1;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      // height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              // radius: 20,
                              child: Image.asset(
                                AppImages.bonuscashicon,
                                height: 40.h,
                                width: 40.w,
                              ),
                            ),
                            CustomSpacers.width20,
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(value.bonusCashAmount[index]['date'] +
                                    " - ${value.bonusCashAmount[index]['time']}"),
                                Container(
                                  width: 250.w,
                                  child: Text(
                                    "Bonus Cash Added - Rs ${value.bonusCashAmount[index]['amount']}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18.w),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                })
            : Center(
                child: Text(
                  "OOPS! , No bonus cash added",
                  style: TextStyle(
                      fontSize: 18.w,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
      ),
    );
  }
}

class WonCashContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, value, child) => Container(
        child: value.wonCashAmount.isNotEmpty
            ? ListView.builder(
                itemCount: value.wonCashAmount.length,
                itemBuilder: (context, ind) {
                  int index = value.wonCashAmount.length - ind - 1;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      // height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Row(
                          children: [
                            // CircleAvatar(
                            //   radius: 20,
                            //   child: ),
                            // ),

                            value.wonCashAmount[index]['type'] == "game1"
                                ? Image.asset(
                                    AppImages.game1,
                                    height: 40.h,
                                    width: 40.w,
                                  )
                                : Image.asset(
                                    AppImages.game2,
                                    height: 40.h,
                                    width: 40.w,
                                  ),
                            CustomSpacers.width20,
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(value.wonCashAmount[index]['date'] +
                                    " - ${value.wonCashAmount[index]['timeSlot']}"),
                                Container(
                                  width: 250.w,
                                  child: Text(
                                    // "You Won - Rs ${value.wonCashAmount[index]['amount']} in ${value.wonCashAmount[index]['timeSlot']}",

                                    value.wonCashAmount[index]['title'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18.w),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                })
            : Center(
                child: Text(
                  "OOPS! , You have not won",
                  style: TextStyle(
                      fontSize: 18.w,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
      ),
    );
  }
}

class DeductedContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, value, child) => Container(
        child: value.deductCashAmount.isNotEmpty
            ? ListView.builder(
                itemCount: value.deductCashAmount.length,
                itemBuilder: (context, ind) {
                  int index = value.deductCashAmount.length - ind - 1;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      // height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              // radius: 25,
                              child: value.deductCashAmount[index]['type'] ==
                                      'placebet-game1'
                                  ? Image.asset(
                                      AppImages.game1,
                                      height: 50.h,
                                      width: 50.w,
                                    )
                                  : value.deductCashAmount[index]['type'] ==
                                          'wallet'
                                      ? Image.asset(
                                          AppIcons.wallet,
                                          height: 35.h,
                                          width: 35.w,
                                          color: Colors.black,
                                        )
                                      : null,
                            ),
                            CustomSpacers.width20,
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(value.deductCashAmount[index]['date'] +
                                    " - ${value.deductCashAmount[index]['time']}"),
                                Container(
                                  width: 250.w,
                                  child: Text(
                                    "${value.deductCashAmount[index]['title']}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18.w),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                })
            : Center(
                child: Text(
                  "OOPS! , No transactions",
                  style: TextStyle(
                      fontSize: 18.w,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
      ),
    );
  }
}
