import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ccf_reseller_web_app/screens/forgetPassword/index.dart';
import 'package:ccf_reseller_web_app/screens/login/changePassword.dart';
import 'package:ccf_reseller_web_app/screens/team&condition/index.dart';
import '../../providers/login/index.dart';
import '../../utils/colors.dart';
import '../../utils/const.dart';
import '../home/home.dart';

class LoginScreenNewTamplate extends StatefulWidget {
  @override
  _LoginScreenNewTamplateState createState() => _LoginScreenNewTamplateState();
}

class _LoginScreenNewTamplateState extends State<LoginScreenNewTamplate> {
  TextStyle style = TextStyle(color: Colors.white);
  TextEditingController controllerPhoneLogin = TextEditingController();
  TextEditingController controllerPasswordLogin = TextEditingController();
  bool _isPhoneNull = false;
  bool _isPassword = false;

  var phone;
  var pwd;

  bool _isLoading = false;

//function for logincustomer
  Future loginStaffOnly() async {
    var phone = controllerPhoneLogin.text;
    var password = controllerPasswordLogin.text;
    setState(() {
      _isLoading = true;
    });
    final storage = await SharedPreferences.getInstance();

// InterUser/ChangePassword/0401
    try {
      await Provider.of<RegisterRef>(context, listen: false)
          .loginForStaff(phone, password)
          .then((value) async => {
                setState(() {
                  _isLoading = false;
                }),
                if (value[0]['changePassword'] == null ||
                    value[0]['changePassword'] == "N")
                  {
                    // user need to change password
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              FirstChangePasswordScreen(storeUser: value[0])),
                    )
                  }
                else
                  {
                    await storage.setString("user_id", value[0]['uid'] ?? ""),
                    await storage.setString(
                        "user_name", value[0]['uname'] ?? ""),
                    await storage.setString("user_email",
                        value[0]['email'] != null ? value[0]['email'] : ""),
                    await storage.setString("pwd", value[0]['pwe'] ?? ""),
                    await storage.setString(
                        "user_phone", value[0]['phone'].toString()),
                    await storage.setString(
                        "level", value[0]['level'].toString()),
                    await storage.setString("edit", value[0]['u5'].toString()),
                    await Provider.of<RegisterRef>(context, listen: false)
                        .postInAppLog("LogIn"),
                    showInSnackBar(AppLocalizations.of(context)!.successfully,
                        logolightGreen, _scaffoldKeyLogin),
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ),
                    ),
                  },
              })
          .catchError((onError) {
        logger().e("onError: $onError");
        setState(() {
          _isLoading = false;
        });

        showInSnackBar(
            AppLocalizations.of(context)!.error, Colors.red, _scaffoldKeyLogin);
      });
    } catch (error) {
      logger().e("error: $error");

      showInSnackBar(
          AppLocalizations.of(context)!.error,
          // "Error",
          Colors.red,
          _scaffoldKeyLogin);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future loginCustomer() async {
    var phone = controllerPhoneLogin.text;
    var password = controllerPasswordLogin.text;
    setState(() {
      _isLoading = true;
    });
    final storage = await SharedPreferences.getInstance();

    try {
      await Provider.of<RegisterRef>(context, listen: false)
          .loginReferer(phone, password)
          .then((value) async => {
                if (value[0]['uid'] != null)
                  {
                    await storage.setString("user_id", value[0]['uid']),
                    await storage.setString("user_name", value[0]['uname']),
                    await storage.setString("image_profile", value[0]['u1']),
                    await storage.setString("user_email", value[0]['u2']),
                    await storage.setString("pwd", value[0]['pwd']),
                    await storage.setString("user_phone", value[0]['phone']),
                    await storage.setString(
                        "level", value[0]['level'].toString()),
                    await storage.setString("edit", value[0]['u5'].toString()),
                  },
                setState(() {
                  _isLoading = false;
                }),
                if (value[0]['token'] != null)
                  {
                    showInSnackBar(AppLocalizations.of(context)!.successfully,
                        logolightGreen, _scaffoldKeyLogin),
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ),
                    ),
                  }
                else
                  {
                    showInSnackBar(
                        AppLocalizations.of(context)!
                            .invalid_your_password_and_phonenumber,
                        Colors.red,
                        _scaffoldKeyLogin),
                  }
              })
          .catchError((onError) {
        setState(() {
          _isLoading = false;
        });

        showInSnackBar(
            AppLocalizations.of(context)!.error, Colors.red, _scaffoldKeyLogin);
      });
    } catch (error) {
      logger().e('errror : ${error}');
      showInSnackBar(
          AppLocalizations.of(context)!.error, Colors.red, _scaffoldKeyLogin);
      setState(() {
        _isLoading = false;
      });
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKeyLogin =
      new GlobalKey<ScaffoldState>();

  int changeUrlInternal = 0;
  int changeUrlExterma = 0;
  bool stateChangeUrl = false;
  void _incrementCounter() {
    setState(() {
      stateChangeUrl = !stateChangeUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return ChangeNotifierProvider(
      create: (_) => RegisterRef(),
      child: Scaffold(
        key: _scaffoldKeyLogin,
        backgroundColor: Colors.grey.shade200,
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: isWeb() ? widthView(context, 0.33) : null,
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 60.0,
                          ),
                          SizedBox(
                            height: isWeb() ? widthView(context, 0.09) : 155,
                            child: Material(
                              elevation: 6.0,
                              shape: CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(
                                "assets/images/1024.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          Container(
                            // padding: EdgeInsets.only(
                            //     top: 20, left: 10, right: 10, bottom: 10),
                            child: Card(
                              elevation: 3.0,
                              color: logolightGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                padding: EdgeInsets.all(15),
                                // width: screenSize.width / 3,
                                child: Column(
                                  children: <Widget>[
                                    Padding(padding: EdgeInsets.all(5)),
                                    Container(
                                      alignment: Alignment.topLeft,
                                      // padding: EdgeInsets.all(15),
                                      child: Text(
                                        AppLocalizations.of(context)!.login,
                                        style: TextStyle(
                                            fontSize: fontSizeLg,
                                            color: Colors.white,
                                            fontWeight: fontWeight700),
                                      ),
                                    ),
                                    Container(
                                        child: Container(
                                      padding: EdgeInsets.only(top: 10),
                                      child: TextFormField(
                                        textInputAction: TextInputAction.next,
                                        controller: controllerPhoneLogin,
                                        maxLength: 10,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9]'),
                                          ),
                                        ],
                                        style: TextStyle(color: Colors.black),
                                        decoration: InputDecoration(
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .phone_number,
                                          labelText: "093245401",
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: _isPhoneNull == true
                                                    ? Colors.red
                                                    : Colors.white),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: _isPhoneNull == true
                                                    ? Colors.red
                                                    : Colors.white),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: _isPhoneNull == true
                                                    ? Colors.red
                                                    : Colors.white),
                                          ),
                                          hintStyle: TextStyle(
                                            color: Colors.black38,
                                          ),
                                          labelStyle:
                                              TextStyle(color: Colors.black38),
                                          suffixIcon: Icon(
                                            FontAwesomeIcons.phone,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )),
                                    Padding(padding: EdgeInsets.all(10)),
                                    Container(
                                      child: TextFormField(
                                        //connection login with enter
                                        onFieldSubmitted: (value) {
                                          // loginStaffOnly();
                                        },
                                        textInputAction: TextInputAction.next,
                                        controller: controllerPasswordLogin,
                                        obscureText: true,
                                        maxLength: 8,
                                        style: TextStyle(color: Colors.black),
                                        decoration: InputDecoration(
                                            hintText:
                                                AppLocalizations.of(context)!
                                                    .password,
                                            labelText:
                                                AppLocalizations.of(context)!
                                                    .password,
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: _isPassword == true
                                                      ? Colors.red
                                                      : Colors.white),
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: _isPassword == true
                                                      ? Colors.red
                                                      : Colors.white),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: _isPassword == true
                                                      ? Colors.red
                                                      : Colors.white),
                                            ),
                                            hintStyle: TextStyle(
                                              color: Colors.black38,
                                            ),
                                            labelStyle: TextStyle(
                                                color: Colors.black38),
                                            suffixIcon: Icon(
                                              FontAwesomeIcons.key,
                                              color: Colors.white,
                                            )),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(10)),
                                    // Container(
                                    //     alignment: Alignment.centerRight,
                                    //     child: InkWell(
                                    //       onTap: () {
                                    //         // ForgetPassword
                                    //         Navigator.of(context)
                                    //             .push(MaterialPageRoute(
                                    //           builder: (context) =>
                                    //               ForgetPassword(),
                                    //         ));
                                    //       },
                                    //       child: Text(
                                    //         AppLocalizations.of(context)!
                                    //             .forget_password,
                                    //         style: TextStyle(color: logoDarkBlue),
                                    //       ),
                                    //     )),
                                    // Padding(padding: EdgeInsets.all(10)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                alignment: Alignment.center,
                                // padding: EdgeInsets.only(left: 250),
                                // ignore: deprecated_member_use
                                child: RaisedButton(
                                  onPressed: () {
                                    if (controllerPhoneLogin.text == "") {
                                      setState(() {
                                        _isPhoneNull = true;
                                      });
                                    } else {
                                      setState(() {
                                        _isPhoneNull = false;
                                      });
                                    }

                                    if (controllerPasswordLogin.text == "") {
                                      setState(() {
                                        _isPassword = true;
                                      });
                                    } else {
                                      setState(() {
                                        _isPassword = false;
                                      });
                                    }
                                    if (controllerPasswordLogin.text != "" &&
                                        controllerPhoneLogin.text != "") {
                                      loginStaffOnly();
                                    }
                                  },
                                  color: logoDarkBlue,
                                  elevation: 5.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Container(
                                    // width: 210,
                                    // height: 35,
                                    padding: EdgeInsets.all(15),
                                    // width: widthView(context, 0.2),
                                    child: Center(
                                      child: Text(
                                        AppLocalizations.of(context)!.login,
                                        style: TextStyle(
                                            fontWeight: fontWeight700,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
