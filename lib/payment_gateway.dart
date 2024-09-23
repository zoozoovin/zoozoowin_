import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:payu_upi_flutter/PayUUPIConstantKeys.dart';
import 'package:payu_upi_flutter/payu_upi_flutter.dart';
import 'package:crypto/crypto.dart';

class MyWidget extends StatefulWidget {
  final Function(double) onAmountEntered;
  const MyWidget({super.key , required this.onAmountEntered});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> implements PayUUPIProtocol {
  late PayUUpiFlutter payUUpiFlutter;
  TextEditingController keyTextField = TextEditingController(text: "smsplus");
  TextEditingController saltTextField = TextEditingController(text: "1b1b0");
  TextEditingController vpaTextField =
      TextEditingController(text: "anything@payu");
  TextEditingController userCredentialTextField =
      TextEditingController(text: "umang:arya");
  TextEditingController accountNumberTextField =
      TextEditingController(text: "123456789012345");
  TextEditingController accountIFSCTextField =
      TextEditingController(text: "IFSC1234");

  TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    payUUpiFlutter = PayUUpiFlutter(this);
    PayUTestCredentials.merchantKey = keyTextField.text;
    PayUTestCredentials.merchantSalt = saltTextField.text;
    PayUTestCredentials.vpa = vpaTextField.text;
    PayUTestCredentials.userCredential = userCredentialTextField.text;
    PayUTestCredentials.accountNumber = accountNumberTextField.text;
    PayUTestCredentials.accountIFSC = accountIFSCTextField.text;
  }

  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    //   home: Scaffold(
    //     appBar: AppBar(
    //       title: const Text('UPI Plugin example app'),
    //     ),
    //     body: Center(
    //         child: Container(
    //             margin: const EdgeInsets.only(left: 20.0, right: 20.0),
    //             child: ListView(children: <Widget>[
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: <Widget>[
    //                   ElevatedButton(
    //                     child: const Text("PayU - UPI Intent"),
    //                     onPressed: () {
    //                       payViaUPIIntent();
    //                     },
    //                   ),
    //                 ],
    //               ),
    //             ]))),
    //   ),
    // );

    return AlertDialog(
      title: Text('Enter Amount to add'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount (Rs.)',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter amount';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await payViaUPIIntent();
              
            },
            child: const Text('Add Money'),
          ),
        ],
      ),
    );
  }


  void _showSuccessMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Amount added successfully.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the success message dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  validateVPA() async {
    // ignore: prefer_interpolation_to_compose_strings
    var vpaHash = HashService.calculateHash(PayUTestCredentials.merchantKey +
        '|' +
        "validateVPA" +
        '|' +
        PayUTestCredentials.vpa +
        '|' +
        PayUTestCredentials.merchantSalt);
    var params = PayUParams.createPayUPaymentParams(PayUPaymentModeKeys.upi);
    params[PayUPaymentParamKey.vpa] = PayUTestCredentials.vpa;
    params[PayUPaymentParamKey.hashes] = {
      PayUPaymentParamKey.validate_vpa: vpaHash
    };
    var data = await payUUpiFlutter.validateVPA(params: params);
    // showAlertDialog(context, "Validate VPA", "$data");
  }

  payViaUPIIntent() async {
    var params = PayUParams.createPayUPaymentParams(PayUPaymentModeKeys.INTENT);
    params[PayUPaymentParamKey.hashes] =
        HashService.paymentHash(params[PayUPaymentParamKey.transaction_id]);
    params[PayUPaymentParamKey.intent_app] = PayUTestCredentials.paytmScheme;
    payUUpiFlutter.makeUPIPayment(params: params);
  }

  Future<void> func() async {
    if (_amountController.text.isNotEmpty) {
      double amount = double.parse(_amountController.text);
      widget.onAmountEntered(amount);
      Navigator.pop(context); // Close the amount dialog
      _showSuccessMessage(context); // Show success message
    }
  }

  @override
  onPayUUPIMakePayment(Map response) {
    String eventType = response[PayUEventType.eventType];
    switch (eventType) {
      case PayUEventType.onPaymentSuccess:
        {
          String eventResponse = parsePayUResponse(response);
          func();
          //  showAlertDialog(context,PayUEventType.onPaymentSuccess,eventResponse);
        }
        break;
      case PayUEventType.onPaymentFailure:
        {
          String eventResponse = parsePayUResponse(response);
          func();
          //  showAlertDialog(context,PayUEventType.onPaymentFailure,eventResponse);
        }
        break;

      case PayUEventType.onErrorReceived:
        {
          String eventResponse = parsePayUResponse(response);
          func();
          //  showAlertDialog(context,PayUEventType.onPaymentSuccess,eventResponse);
        }
        break;

      case PayUEventType.onPaymentTerminate:
        {
          String eventResponse = parsePayUResponse(response);
          func();
          //  showAlertDialog(context,PayUEventType.onPaymentSuccess,eventResponse);
        }
        break;

      default:
        {
          func();
          //  showAlertDialog(context,PayUEventType.invalidEvent,"");
        }
        break;
    }
  }

  @override
  onPayUUPIValidateVPA(Map response) {
    String eventType = response[PayUEventType.eventType];
    switch (eventType) {
      case PayUEventType.onValidateSuccess:
        {
          String eventResponse = parsePayUResponse(response);
          func();
          //  showAlertDialog(context,PayUEventType.onValidateSuccess,eventResponse);
        }
        break;

      case PayUEventType.onErrorReceived:
        {
          String eventResponse = parsePayUResponse(response);
          func();
          //  showAlertDialog(context,PayUEventType.onErrorReceived,eventResponse);
        }
        break;

      default:
        {
          func();
          //  showAlertDialog(context,PayUEventType.invalidEvent,"");
        }
        break;
    }
  }

  String parsePayUResponse(Map response) {
    var eventResponse = response[PayUEventType.eventResponse];
    return eventResponse != null ? eventResponse.toString() : "";
  }
}

//Pass these values from your app to SDK, this data is only for test purpose
class PayUParams {
  static Map createPayUPaymentParamsForTPV() {
    var params = PayUParams.createPayUPaymentParams(PayUPaymentModeKeys.INTENT);
    params[PayUPaymentParamKey.beneficiary_account_number] =
        PayUTestCredentials.accountNumber;
    params[PayUPaymentParamKey.beneficiary_ifsc] =
        PayUTestCredentials.accountIFSC;
    params[PayUPaymentParamKey.hashes] =
        HashService.paymentTPVHash(params[PayUPaymentParamKey.transaction_id]);
    return params;
  }

  static Map createPayUPaymentParams(String paymentMode) {
    var additionalParam = {
      PayUAdditionalParamKeys.udf1: PayUTestCredentials.udf1,
      PayUAdditionalParamKeys.udf2: PayUTestCredentials.udf2,
      PayUAdditionalParamKeys.udf3: PayUTestCredentials.udf3,
      PayUAdditionalParamKeys.udf4: PayUTestCredentials.udf4,
      PayUAdditionalParamKeys.udf5: PayUTestCredentials.udf5
    };
    var payUPaymentParams = {
      PayUPaymentParamKey.key: PayUTestCredentials.merchantKey,
      PayUPaymentParamKey.amount: PayUTestCredentials.amount,
      PayUPaymentParamKey.product_info: PayUTestCredentials.productInfo,
      PayUPaymentParamKey.first_name: PayUTestCredentials.firstName,
      PayUPaymentParamKey.email: PayUTestCredentials.email,
      PayUPaymentParamKey.phone: PayUTestCredentials.phone,
      PayUPaymentParamKey.ios_surl: PayUTestCredentials.sUrl,
      PayUPaymentParamKey.ios_furl: PayUTestCredentials.fUrl,
      PayUPaymentParamKey.android_surl: PayUTestCredentials.sUrl,
      PayUPaymentParamKey.android_furl: PayUTestCredentials.fUrl,
      PayUPaymentParamKey.environment: "0", //0 => Production 1 => Test
      PayUPaymentParamKey.user_credentials: PayUTestCredentials
          .userCredential, //TODO: Pass user credential to fetch saved cards => A:B - Optional
      PayUPaymentParamKey.transaction_id:
          "PayU_" + DateTime.now().millisecondsSinceEpoch.toString(),
      PayUPaymentParamKey.additional_param: additionalParam,
      PayUPaymentParamKey.payment_mode: paymentMode,
      PayUPaymentParamKey.disable_intent_seamless_failure: "-1",
    };
    return payUPaymentParams;
  }
}

class PayUTestCredentials {
  static String merchantKey = ""; //TODO: Add Merchant Key
  static String merchantSalt = "";
  static const sUrl =
      "https://cbjs.payu.in/sdk/success"; //TODO: Add Success URL.
  static const fUrl = "https://cbjs.payu.in/sdk/failure"; //TODO Add Fail URL.

  static String userCredential = ''; //TODO: Remove it

  static String accountNumber = ''; //TODO: Remove it

  static String accountIFSC = ''; //TODO: Remove it

  static String vpa = ''; //TODO: Remove it

  static const udf1 = "udf1";
  static const udf2 = "udf2";
  static const udf3 = "udf3";
  static const udf4 = "udf4";
  static const udf5 = "udf5";

  static const amount = "1";
  static const productInfo = "Info";
  static const firstName = "Abc";
  static const email = "test@gmail.com";
  static const phone = "9999999999";

  static const gPayScheme = "gpay";
  static const paytmScheme = "paytm";
  static const paytmPackageName = "net.one97.paytm";

  static var si_details = {
    PayUSIParamsKeys.is_free_trial: "0",
    PayUSIParamsKeys.si: '1',
    PayUSIParamsKeys.si_params: {
      PayUSIParamsKeys.is_free_trial: "0",
      PayUSIParamsKeys.billing_amount: '1', //Required
      PayUSIParamsKeys.billing_interval: 1, //Required
      PayUSIParamsKeys.payment_start_date: '2022-12-24', //Required
      PayUSIParamsKeys.payment_end_date: '2023-12-24', //Required
      PayUSIParamsKeys.billing_cycle: //Required
          'ONCE', // YEARLY | MONTHLY | WEEKLY | DAILY | ONCE | ADHOC
      PayUSIParamsKeys.billing_currency: 'INR',
      PayUSIParamsKeys.billing_limit: 'ON', //ON, BEFORE, AFTER
      PayUSIParamsKeys.billing_rule: 'MAX', //MAX, EXACT
      PayUSIParamsKeys.si: '1', //MAX, EXACT
    }
  };
}

class HashService {
  static Map paymentHash(String txnId) {
    var finalHashString =
        paymentHashString(txnId) + '|' + PayUTestCredentials.merchantSalt;
    var paymentHash = HashService.calculateHash(finalHashString);
    var hash = {PayUPaymentParamKey.payment: paymentHash};
    return hash;
  }

  static Map paymentTPVHash(String txnId) {
    var beneficiaryDetail = "{\"beneficiaryAccountNumber\":\"" +
        PayUTestCredentials.accountNumber +
        "\"" +
        ",\"ifscCode\":\"" +
        PayUTestCredentials.accountIFSC +
        "\"" +
        "}";

    var finalHashStirng = paymentHashString(txnId) +
        '|' +
        beneficiaryDetail +
        '|' +
        PayUTestCredentials.merchantSalt;

    var paymentHash = HashService.calculateHash(finalHashStirng);
    var hash = {PayUPaymentParamKey.payment: paymentHash};
    return hash;
  }

  static Map validateVPAHash(String vpa) {
    var vpaHash = HashService.calculateHash(PayUTestCredentials.merchantKey +
        '|' +
        "validateVPA" +
        '|' +
        vpa +
        '|' +
        PayUTestCredentials.merchantSalt);
    var hash = {PayUPaymentParamKey.validate_vpa: vpaHash};
    return hash;
  }

  static String paymentHashString(String txnId) {
    var hashString =
        '${PayUTestCredentials.merchantKey}|$txnId|${PayUTestCredentials.amount}|${PayUTestCredentials.productInfo}|${PayUTestCredentials.firstName}|${PayUTestCredentials.email}|${PayUTestCredentials.udf1}|${PayUTestCredentials.udf2}|${PayUTestCredentials.udf3}|${PayUTestCredentials.udf4}|${PayUTestCredentials.udf5}|||||';
    return hashString;
  }

  static String getSHA512Hash(String hashData) {
    var bytes = utf8.encode(hashData); // data being hashed
    var hash = sha512.convert(bytes);
    return hash.toString();
  }

  static String calculateHash(String data) {
    print("PayU flutter hash Stirng $data");
    var hash = getSHA512Hash(data);
    print("PayU flutter hashData $hash");
    //Don't use this method, get the hash from your backend.
    return hash;
  }
}
