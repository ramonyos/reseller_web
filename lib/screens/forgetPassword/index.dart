import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ccf_reseller_web_app/components/textInputComponent.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/screens/forgetPassword/otpForgetPassword.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';

class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  String? _phone;
  Future checkExitingPhone() async {
    if (controllerPhone.text != "0" &&
        controllerPhone.text != "" &&
        controllerPhone.text.length > 8) {
      try {
        var request = http.Request(
            'GET',
            Uri.parse(
                baseURLInternal + 'CcfuserRes/${controllerPhone.text}/phone'));

        http.StreamedResponse response = await request.send();
        // final respStr = await response.stream.bytesToString();
        // var json = jsonDecode(respStr);
        if (response.statusCode == 200) {
          // notifyListeners();
          // return json;
          final respStr = await response.stream.bytesToString();
          var json = jsonDecode(respStr);
          // var userid = await response.stream.bytesToString();
          print(json['uid']);

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      OTPScreenForgetPassword(controllerPhone.text, json)));
        } else {
          print(response.reasonPhrase);
        }
      } catch (error) {
        logger().e("catch: ${error}");
      }
    }
  }

  TextEditingController controllerPhone = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKeyReSetPassword =
      new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKeyReSetPassword,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: logolightGreen,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.forget_password,
          style: TextStyle(color: logolightGreen),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Center(
              child: Text(
                AppLocalizations.of(context)!.please_verify,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: fontWeight700,
                  color: logolightGreen,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(3)),
            Center(
                child: Text(
              AppLocalizations.of(context)!
                  .welcome_to_our_chok_chey_finance_plc,
              style: TextStyle(color: Colors.grey),
            )),
            Center(
                child: Text(
              AppLocalizations.of(context)!.confirm_your_phone_number,
              style: TextStyle(color: Colors.grey),
            )),
            Padding(padding: EdgeInsets.all(10)),
            TextInputComponent(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              maxleng: 10,
              icons: FontAwesomeIcons.phoneAlt,
              hintText: AppLocalizations.of(context)!.phone,
              labelText: "023922126",
              controller: controllerPhone,
              onChanged: (v) {
                setState(() {
                  _phone = v;
                });
              },
            ),
            Padding(padding: EdgeInsets.all(10)),
            Container(
              alignment: Alignment.centerRight,
              child: RaisedButton(
                color: logoDarkBlue,
                onPressed: () {
                  // if (controllerNameCreateAccount.text != "" &&
                  //     controllerPhoneCreateAccount.text != "")
                  //   Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (context) => OTPScreen(
                  //       _name ?? "",
                  //       _phone ?? "",
                  //       _password ?? "",
                  //     ),
                  //   ));

                  // check exiting phone number

                  checkExitingPhone();
                  // Navigator.of(context).push(MaterialPageRoute(
                  //   builder: (context) => OTPScreenForgetPassword(
                  //     _phone ?? "",
                  //   ),
                  // ));
                },
                child: Text(
                  AppLocalizations.of(context)!.send,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
