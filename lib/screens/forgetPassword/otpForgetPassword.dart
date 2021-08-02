import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/screens/forgetPassword/changeScreen.dart';
import 'package:ccf_reseller_web_app/screens/home/home.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPScreenForgetPassword extends StatefulWidget with ChangeNotifier {
  String phoneNumber;
  var listUser;

  OTPScreenForgetPassword(this.phoneNumber, this.listUser);
  @override
  _OTPScreenForgetPasswordState createState() =>
      _OTPScreenForgetPasswordState();
}

class _OTPScreenForgetPasswordState extends State<OTPScreenForgetPassword> {
  @override
  void initState() {
    // TODO: implement initState
    signInWithPhoneNumber();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var otpCompleted;
  // TextEditingController _smsController = TextEditingController();
  StreamController<ErrorAnimationType> errorController =
      StreamController<ErrorAnimationType>();

  late String currentText;
  late String _verificationId;
  //
  final GlobalKey<ScaffoldState> _scaffoldKeyOTP =
      new GlobalKey<ScaffoldState>();

  var status;
  bool _isLoading = false;
  void signInWithPhoneNumber() async {
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: "+855" + widget.phoneNumber,
          timeout: Duration(seconds: 60),
          verificationCompleted:
              (PhoneAuthCredential phoneAuthCredential) async {
            await _auth.signInWithCredential(phoneAuthCredential).then((value) {
              // var uname = widget.name;
              var phone = widget.phoneNumber;
              var otp = '';
              var otpID = 'value.user.uid';
              // var passwords = widget.password;

              // _postToServerCreateUserByPhone(
              //     uname, passwords, phone, otp, otpID);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChangePasswordScreen(widget.listUser)));
              // editPassword("");
            }).catchError((onError) {});
          },
          verificationFailed: (FirebaseAuthException authException) => {
                showInSnackBar(
                    AppLocalizations.of(context)!
                            .phone_number_verification_failed +
                        'Code: ${authException.code}. Message: ${authException.message}',
                    Colors.red,
                    _scaffoldKeyOTP),
              },
          codeSent: (verificationId, forceResendingToken) {
            _verificationId = verificationId;
            showInSnackBar(
                AppLocalizations.of(context)!
                    .please_check_your_phone_for_the_verification_code,
                logolightGreen,
                _scaffoldKeyOTP);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
            showInSnackBar(
                AppLocalizations.of(context)!.verification +
                    "code: ${verificationId}",
                logolightGreen,
                _scaffoldKeyOTP);
          });
    } catch (e) {
      showInSnackBar(
          AppLocalizations.of(context)!.failed_to_verify_phone_number +
              ": ${e}",
          Colors.red,
          _scaffoldKeyOTP);
    }
  }

  Future onCompletedOTP(v) async {
    try {
      await _auth
          .signInWithCredential(PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: v.trim(),
      ))
          .then((value) async {
        // var uname = widget.name;
        // var phone = widget.phoneNumber;
        // var otp = v;
        // var otpID = value.user?.uid;
        // await editPassword("");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChangePasswordScreen(widget.listUser)));
      }).catchError((onError) {
        showInSnackBar("${onError.message}", Colors.red, _scaffoldKeyOTP);
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (e.code == 'session-expired') {
        print('session-expired.');
      } else if (e.code == 'session-expired') {
        print('The account already exists for that email.');
      } else {
        showInSnackBar("${e.message}", Colors.red, _scaffoldKeyOTP);
      }
    } on PlatformException catch (e) {
      setState(() {
        _isLoading = false;
      });
      handleError(e);
    }
  }

  //create user login
  Future editPassword(passwords) async {
    setState(() {
      _isLoading = true;
    });
    var pwd = passwords;

    final Map<String, dynamic> bodyRaw = {
      "pwd": "$pwd",
    };
    try {
      final Response response = await api().post(
        Uri.parse(baseURLInternal + 'CcfuserRes'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json'
        },
        body: json.encode(bodyRaw),
      );
      final storage = await SharedPreferences.getInstance();

      final value = jsonDecode(response.body);
      if (value['uid'] != null) {
        await storage.setString("user_id", value['uid']);
        await storage.setString("user_name", value['uname']);
        if (value['u1'] != null)
          await storage.setString("image_profile", value['u1']);
        if (value['u2'] != null)
          await storage.setString("user_email", value['u2']);
        await storage.setString("user_phone", value['phone']);
        await storage.setString("pwd", value['pwd']);
        await storage.setString("ustatus", value['ustatus']);
        await storage.setString("refcode", value['ccfreferalRe'][0]['refcode']);
        await storage.setString("level", value['level'].toString());
        setState(() {
          _isLoading = false;
        });
        showInSnackBar(AppLocalizations.of(context)!.successfully,
            logolightGreen, _scaffoldKeyOTP);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showInSnackBar(
          AppLocalizations.of(context)!.error, Colors.red, _scaffoldKeyOTP);
    }
  }

  String? errorMessage;
  handleError(PlatformException error) {
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        setState(() {
          errorMessage = 'Invalid Code';
        });
        break;
      default:
        setState(() {
          errorMessage = error.message.toString();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyOTP,
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
          AppLocalizations.of(context)!.phone_verification,
          style: TextStyle(color: logolightGreen),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Center(
                      child: Text(
                    AppLocalizations.of(context)!.enter_otp,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: fontWeight700,
                        color: logolightGreen),
                  )),
                  Padding(padding: EdgeInsets.all(5)),
                  Center(
                      child: Container(
                    width: 200,
                    child: Text(
                      AppLocalizations.of(context)!
                              .please_enter_the_verification_code_send_to +
                          ' ' +
                          widget.phoneNumber,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )),
                  Container(
                    child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: PinCodeTextField(
                          length: 6,
                          animationType: AnimationType.fade,
                          cursorColor: Colors.black,
                          pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(5),
                              fieldHeight: 50,
                              fieldWidth: 40,
                              activeFillColor: logolightGreen,
                              activeColor: logolightGreen,
                              inactiveFillColor: Colors.white,
                              inactiveColor: logolightGreen,
                              selectedColor: logolightGreen,
                              selectedFillColor: logolightGreen),
                          animationDuration: Duration(milliseconds: 300),
                          enableActiveFill: true,
                          onCompleted: (v) => onCompletedOTP(v),
                          onChanged: (value) {},
                          appContext: context,
                          beforeTextPaste: (String? text) {
                            print("Allowing to paste $text");
                            return true;
                          },
                        )),
                  ),
                ],
              ),
            ),
    );
  }
}
