import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/core/constants/app_data.dart';
import 'package:zoozoowin_/core/helpers/scaffold_helpers.dart';
import 'package:zoozoowin_/core/utils/screen_utils.dart';
import 'package:zoozoowin_/features/wallet/data/wallet_provider.dart';
import 'package:zoozoowin_/features/wallet/transaction_history_screen.dart';
import 'package:zoozoowin_/features/wallet/widget/payment_dialog.dart';
import 'package:zoozoowin_/ui/atoms/shine_button.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Consumer<WalletProvider>(
        builder: (context, value, child) => Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(AppImages.background), fit: BoxFit.cover)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomSpacers.height64,
              //transaction history
              InkWell(
                onTap: () {
                  // AppData.navigateToNotification(context, TransactionHistoryScreen());
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TransactionHistoryScreen()));
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  child: SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages.transaction,
                          height: 30.h,
                          width: 30.w,
                        ),
                        Text(
                          "Transaction\nHistory",
                          style: TextStyle(
                              fontSize: 11.w,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              CustomSpacers.height14,

              //=====wallet balance

              SizedBox(
                  child: Container(
                height: 90.h,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    // color: Colors.redAccent,
                    image: DecorationImage(
                        image: AssetImage(AppImages.wallet_line1))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Wallet Balance",
                        style: TextStyle(
                            fontSize: 16.w,
                            fontWeight: FontWeight.w400,
                            color: Colors.white)),
                    Text("₹ " + value.walletBalance.toInt().toString(),
                        style: TextStyle(
                            fontSize: 30.w,
                            fontWeight: FontWeight.w500,
                            color: Colors.white))
                  ],
                ),
              )),

              CustomSpacers.height30,

              //==========Wallet Card ======

              _buildWalletcard(),
              // CustomSpacers.height14,

              //============reffer offer =================
              _buildReferOffer(),

              //=============buildBanner ================
              CustomSpacers.height48,
              _showBanner ? _buildBanner() : Container(),
            ],
          ),
        ),
      ),
    ));
  }

  _buildWalletcard() => Consumer<WalletProvider>(
        builder: (context, value, child) => Padding(
          padding: const EdgeInsets.all(10.0),
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // WalletCard(
                // img: AppImages.addcashIcon,
                //   title: "LAST ADDED",
                // amount: value.lastAddedCashAmount.toInt().toInt().toString(),
                //   button: AppImages.addcashbutton,
                //   ontap: () {
                // print("addcash");
                // _navigateToAddMoneyScreen(context);
                //   },
                // ),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Row(
                          children: [
                            Image.asset(
                              AppImages.addcashIcon,
                              height: 50.h,
                              width: 50.w,
                            ),
                            CustomSpacers.width16,
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'LAST ADDED',
                                      style: TextStyle(
                                          fontSize: 12.w,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black),
                                    ),
                                    CustomSpacers.width6,
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.black54,
                                      size: 16.w,
                                    )
                                  ],
                                ),
                                Text(
                                  "₹ " +
                                      value.lastAddedCashAmount
                                          .toInt()
                                          .toInt()
                                          .toString(),
                                  style: TextStyle(
                                      fontSize: 20.w,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                          onTap: () {
                            print("addcash");
                            _navigateToAddMoneyScreen(context);
                          },
                          child: CustomShinyButton(
                            height: 50.h,
                            text: 'Add Cash',
                            width: 130.w,
                            // ic: false,
                            // style: TextStyle(
                                // fontSize: 20.w,
                                // fontWeight: FontWeight.w600,
                                // color: Colors.white,
                                // fontStyle: FontStyle.italic),
                          ))
                    ],
                  ),
                ),
                Divider(
                  thickness: 0.5,
                  color: Colors.black,
                ),
                WalletCard(
                  img: AppImages.withdrawicon,
                  title: "LAST WITHDRAWAL",
                  amount: value.lastWithdrawCashAmount.toInt().toString(),
                  button: AppImages.withdrawbutton,
                  ontap: () {
                    _showWithdrawalDialog(context);
                  },
                ),
                Divider(
                  thickness: 0.5,
                  color: Colors.black,
                ),
                WalletCard(
                  img: AppImages.bonuscashicon,
                  title: "TOTAL BONUS",
                  amount: value.totalBonusCashAmount.toInt().toString(),
                  button: AppImages.bonusbutton,
                  ontap: () {},
                ),
              ],
            ),
          ),
        ),
      );

  _buildReferOffer() => Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  child: Row(
                    children: [
                      Image.asset(
                        AppImages.specialOffer,
                        height: 60.h,
                        width: 60.w,
                      ),
                      CustomSpacers.width8,
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "REFER AND EARN UPTO RS 500",
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                fontSize: 16.w),
                          ),
                          Text(
                            "click to refer",
                            style: TextStyle(fontSize: 13.w),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_outlined)
              ],
            ),
          ),
        ),
      );

  bool _showBanner = true;
  _buildBanner() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 120.h,
          decoration: const BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
                image: AssetImage(AppImages.banner), fit: BoxFit.cover),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              //
              InkWell(
                onTap: () {
                  setState(() {
                    _showBanner = false;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Image.asset(
                    AppIcons.cross,
                    height: 20.h,
                  ),
                ),
              )
            ],
          ),
        ),
      );

  void _navigateToAddMoneyScreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<WalletProvider>(
          builder: (context, value, child) => PaymentDialog(
            onAmountEntered: (amount) {
              // _amountInWallet += amount;
              value.addCashWalletAmount(amount);
            },
          ),
        );
      },
    );
  }

  void _showWithdrawalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        double withdrawalAmount = 0.00;
        return Consumer<WalletProvider>(
          builder: (context, value, child) => AlertDialog(
            title: const Text('Withdraw Amount'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        'Current Amount in Wallet: ₹${value.walletBalance.toString()}'),
                    const SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter Amount to Withdraw (₹)',
                      ),
                      onChanged: (value) {
                        withdrawalAmount = double.tryParse(value) ?? 0.00;
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (withdrawalAmount <= value.walletBalance) {
                          // setState(() {
                          //   _amountInWallet -= withdrawalAmount;
                          // });

                          value.withdrawWalletAmount(withdrawalAmount);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Withdrawal successful!'),
                          ));
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Insufficient balance!'),
                          ));
                        }
                      },
                      child: const Text('Withdraw'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<WalletProvider>(
          builder: (context, value, child) => WithdrawDialog(
            currentAmount: value.walletBalance,
            onAmountWithdrawn: (amount) {
              if (amount <= value.walletBalance) {
                // Deduct the amount from the wallet balance
                // updateWalletBalance(amount);

                value.withdrawWalletAmount(amount);
              }
            },
          ),
        );
      },
    );
  }
}

class WalletCard extends StatefulWidget {
  String img;
  String title;
  String amount;
  String button;
  Function() ontap;
  WalletCard(
      {super.key,
      required this.img,
      required this.title,
      required this.amount,
      required this.button,
      required this.ontap});

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Row(
              children: [
                Image.asset(
                  widget.img,
                  height: 50.h,
                  width: 50.w,
                ),
                CustomSpacers.width16,
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                              fontSize: 12.w,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ),
                        CustomSpacers.width6,
                        Icon(
                          Icons.info_outline,
                          color: Colors.black54,
                          size: 16.w,
                        )
                      ],
                    ),
                    Text(
                      "₹ " + widget.amount,
                      style: TextStyle(
                          fontSize: 20.w,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
              onTap: widget.ontap,
              child: Image.asset(
                widget.button,
                width: 120.w,
              ))
        ],
      ),
    );
  }
}

class WithdrawDialog extends StatefulWidget {
  final double currentAmount;
  final Function(double) onAmountWithdrawn;

  const WithdrawDialog(
      {Key? key, required this.currentAmount, required this.onAmountWithdrawn})
      : super(key: key);
  @override
  _WithdrawDialogState createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends State<WithdrawDialog> {
  TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Withdraw Amount'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Current Amount in Wallet: ${widget.currentAmount} Rs.'),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Enter Amount to Withdraw (Rs.)',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter amount';
              }
              double amount = double.parse(value);
              if (amount > widget.currentAmount) {
                return 'Withdrawal amount cannot exceed current amount';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_amountController.text.isNotEmpty) {
                double amount = double.parse(_amountController.text);
                widget.onAmountWithdrawn(amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
