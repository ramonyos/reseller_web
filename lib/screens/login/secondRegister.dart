import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ccf_reseller_web_app/components/textInputComponent.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ccf_reseller_web_app/screens/login/otp.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? _name;
  String? _password;
  String? _phone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          AppLocalizations.of(context)!.register,
          style: TextStyle(color: logolightGreen),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Center(
              child: Text(
                AppLocalizations.of(context)!.create_account,
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
            Padding(padding: EdgeInsets.all(40)),
            TextInputComponent(
              onChanged: (v) {
                setState(() {
                  _name = v;
                });
              },
              inputFormatters: [
                // ignore: deprecated_member_use
                WhitelistingTextInputFormatter(
                  RegExp("[a-z A-Z]"),
                ),
              ],
              icons: FontAwesomeIcons.user,
              hintText: AppLocalizations.of(context)!.name,
              labelText: AppLocalizations.of(context)!.name,
            ),
            Padding(padding: EdgeInsets.all(10)),
            TextInputComponent(
              onChanged: (v) {
                setState(() {
                  _password = v;
                });
              },
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              maxleng: 8,
              icons: FontAwesomeIcons.key,
              hintText: AppLocalizations.of(context)!.password,
              labelText: AppLocalizations.of(context)!.max_8_characters_only,
            ),
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

                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => OTPScreen(
                      _name ?? "",
                      _password ?? "",
                      _phone ?? "",
                    ),
                  ));
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
