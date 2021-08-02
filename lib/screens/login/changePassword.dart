import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:ccf_reseller_web_app/providers/login/index.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/screens/home/home.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class FirstChangePasswordScreen extends StatefulWidget {
  dynamic storeUser;

  FirstChangePasswordScreen({
    this.storeUser,
  });
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<FirstChangePasswordScreen> {
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  var chokchey = AssetImage('assets/images/1024.png');
  final TextEditingController id = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController firstLogin = TextEditingController();

  bool _isLoading = false;
  bool autofocus = false;

  final focusPassword = FocusNode();
  final focusFirstLogin = FocusNode();

// Create storage FirstChangePasswordScreen
  Future<void> onClickLogin(context) async {
    final storage = await SharedPreferences.getInstance();

    setState(() {
      _isLoading = true;
    });
    try {
      // final Map<String, dynamic> bodyRow = {"pwd": "${firstLogin.text}"};
      // final Response response = await api().post(
      //   Uri.parse(baseURLInternal +
      //       'InterUser/ChangePassword/' +
      //       widget.storeUser['staffid']),
      //   headers: {"Content-Type": "application/json"},
      //   body: json.encode(bodyRow),
      // );
      // final value = jsonDecode(response.body);

      //
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'POST',
          Uri.parse(baseURLInternal +
              'InterUser/ChangePassword/' +
              widget.storeUser['staffid']));
      request.body = json.encode({"pwd": "${firstLogin.text}"});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var value = jsonDecode(await response.stream.bytesToString());
        setState(() {
          _isLoading = false;
        });
        if (value['changePassword'] == 'Y') {
          await storage.setString("user_id", value['uid'] ?? "");
          await storage.setString("user_name", value['uname'] ?? "");
          await storage.setString("image_profile", value['u1'] ?? "");
          await storage.setString("user_email", value['u2'] ?? "");
          await storage.setString("pwd", value['pwd'] ?? "");
          await storage.setString("user_phone", value['phone'] ?? "");
          await storage.setString("level", value['level'].toString());
          await storage.setString("edit", value['u5'].toString());
          await Provider.of<RegisterRef>(context, listen: false)
              .postInAppLog("LogIn");
          // navigator to home screen
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              ModalRoute.withName("/login"));
        } else {
          setState(() {
            _isLoading = false;
          });
          showInSnackBar(AppLocalizations.of(context)!.error, Colors.red,
              _scaffoldKeyLogin);
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKeyLogin =
      new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Change Password'),
        backgroundColor: logolightGreen,
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: 200.0,
                height: 200.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(42.0),
                  image: DecorationImage(
                    image: chokchey,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Text(
                'Welcome',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: fontSizeLg,
                  color: logoDarkBlue,
                  fontWeight: fontWeight700,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5),
              ),
              Text(
                ' CHOK CHEY Finance',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: fontSizeLg,
                  color: logolightGreen,
                  fontWeight: fontWeight700,
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: TextField(
                    // enabled: false,
                    autofocus: true,
                    controller: firstLogin,
                    focusNode: focusFirstLogin,
                    obscureText: true,
                    onSubmitted: (v) async {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          });
                      await onClickLogin(context);
                    },
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: logolightGreen),
                        ),
                        labelText: 'Change Password',
                        hintText: firstLogin.text,
                        labelStyle: TextStyle(
                            fontSize: 15, color: const Color(0xff0ABAB5)))),
              ),
              Container(
                width: 320,
                height: 45,
                margin: EdgeInsets.only(top: 40, bottom: 20),
                // ignore: deprecated_member_use
                child: FlatButton(
                    color: logolightGreen,
                    textColor: Colors.white,
                    padding: const EdgeInsets.all(8.0),
                    onPressed: () async {
                      await onClickLogin(context);
                    },
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Text(
                            "Log In",
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
