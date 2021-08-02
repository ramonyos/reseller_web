import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:ccf_reseller_web_app/components/textInputComponent.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/screens/login/index.dart';
import 'package:ccf_reseller_web_app/screens/login/otp.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';

class ChangePasswordScreen extends StatefulWidget {
  var user;
  ChangePasswordScreen(this.user);
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  String? _password;
  String? _rePassWordPhone;
  final GlobalKey<ScaffoldState> _scaffoldKeyChangePasswrod =
      new GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  Future editPassword() async {
    setState(() {
      _isLoading = true;
    });
    var now = DateTime.now();
    final Map<String, dynamic> bodyRaw = {
      "uid": "${widget.user['uid']}",
      "pwd": "${controllerPhone.text}",
      "uname": "${widget.user['uname']}",
      "uotpcode": "${widget.user['uotpcode']}",
      "datecreate": "$now",
      "ustatus": "${widget.user['ustatus']}",
      "utype": "${widget.user['utype']}",
      "u3": "${widget.user['u3']}",
      "u4": "${widget.user['u4']}",
      "u5": "${widget.user['u5']}",
      "phone": "${widget.user['phone']}",
      "level": "${widget.user['level']}",
      "staffid": "${widget.user['staffid']}",
      "staffposition": "${widget.user['staffposition']}",
      "job": "${widget.user['job']}",
      "address": "${widget.user['address']}",
      "email": "${widget.user['email']}",
      "dob": "${widget.user['dob']}",
      "idtype": "${widget.user['idtype']}",
      "idnumber": "${widget.user['idnumber']}",
      "banktype": "${widget.user['banktype']}",
      "banknumber": "${widget.user['banknumber']}",
      "verifystatus": "${widget.user['verifystatus']}",
      "gender": "${widget.user['gender']}"
    };
    try {
      final Response response = await api().put(
        Uri.parse(baseURLInternal + 'CcfuserRes/' + widget.user['uid']),
        headers: {
          "content-type": "application/json",
        },
        body: json.encode(bodyRaw),
      );
      setState(() {
        _isLoading = false;
      });
      showInSnackBar(AppLocalizations.of(context)!.successfully, logolightGreen,
          _scaffoldKeyChangePasswrod);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreenNewTamplate(),
        ),
      );
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  TextEditingController controllerPhone = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyChangePasswrod,
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
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
                        _password = v;
                      });
                    },
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    maxleng: 8,
                    icons: FontAwesomeIcons.key,
                    hintText: AppLocalizations.of(context)!.password,
                    labelText:
                        AppLocalizations.of(context)!.max_8_characters_only,
                  ),
                  Padding(padding: EdgeInsets.all(10)),
                  TextInputComponent(
                    onChanged: (v) {
                      setState(() {
                        _rePassWordPhone = v;
                      });
                    },
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    maxleng: 8,
                    controller: controllerPhone,
                    icons: FontAwesomeIcons.key,
                    hintText: "Re-Password",
                    // AppLocalizations.of(context)!.password,
                    labelText:
                        AppLocalizations.of(context)!.max_8_characters_only,
                  ),
                  Padding(padding: EdgeInsets.all(10)),
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

                        // Navigator.of(context).push(MaterialPageRoute(
                        //   builder: (context) => OTPScreen(
                        //     _name ?? "",
                        //     _password ?? "",
                        //     _phone ?? "",
                        //   ),
                        // ));

                        // check re-password
                        if (_password == _rePassWordPhone) {
                          editPassword();
                        } else {
                          showInSnackBar(
                              AppLocalizations.of(context)!.password_not_match,
                              Colors.red,
                              _scaffoldKeyChangePasswrod);
                        }
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
