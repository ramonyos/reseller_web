import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:provider/provider.dart';
import 'package:ccf_reseller_web_app/providers/login/index.dart';
import 'package:ccf_reseller_web_app/screens/home/home.dart';
import 'package:ccf_reseller_web_app/screens/login/secondRegister.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';

class TeamCondition extends StatefulWidget {
  bool isByFacebook = false;
  bool isShowCheckBox = false;

  TeamCondition({required this.isByFacebook, required this.isShowCheckBox});
  @override
  _TeamConditionState createState() => _TeamConditionState();
}

class _TeamConditionState extends State<TeamCondition> {
  bool isChecked = false;
  static final FacebookLogin facebookSignIn = new FacebookLogin();

  // by facebook
  Future<Null> initiateFacebookLogin() async {
    if (Platform.isAndroid) {
      final FacebookLoginResult result = await facebookSignIn.logIn(['email']);
      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          https.Response graphResponse = await api().get(Uri.parse(
              'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,picture,email&access_token=${result.accessToken.token}'));
          final profile = jsonDecode(graphResponse.body);
          createUserbyFacebook(profile);
          // Add your route to home page here after sign In
          break;
        case FacebookLoginStatus.cancelledByUser:
          showInSnackBar(AppLocalizations.of(context)!.cancel, Colors.red,
              _scaffoldKeyTermAndCondition);
          break;
        case FacebookLoginStatus.error:
          showInSnackBar(AppLocalizations.of(context)!.error, Colors.red,
              _scaffoldKeyTermAndCondition);
          break;
      }
    } else {
      final FacebookLoginResult result = await facebookSignIn.logIn(['email']);
      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          https.Response graphResponse = await api().get(Uri.parse(
              'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,picture,email&access_token=${result.accessToken.token}'));
          final profile = jsonDecode(graphResponse.body);
          createUserbyFacebook(profile);

          // Add your route to home page here after sign In
          break;
        case FacebookLoginStatus.cancelledByUser:
          showInSnackBar(AppLocalizations.of(context)!.cancel, Colors.red,
              _scaffoldKeyTermAndCondition);
          break;
        case FacebookLoginStatus.error:
          showInSnackBar(AppLocalizations.of(context)!.error, Colors.red,
              _scaffoldKeyTermAndCondition);
          break;
      }
    }
  }

  bool _isLoading = false;

  Future createUserbyFacebook(profile) async {
    final storage = await SharedPreferences.getInstance();

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<RegisterRef>(context, listen: false)
          .createLoginFacebook(profile, true)
          .then(
            (value) async => {
              if (value['uid'] != null)
                {
                  await storage.setString("user_id", value['uid']),
                  await storage.setString("user_name", value['uname']),
                  await storage.setString("image_profile", value['u1']),
                  await storage.setString("user_email", value['u2']),
                  await storage.setString("user_phone", value['phone']),
                  await storage.setString("pwd", value['pwd']),
                  await storage.setString("ustatus", value['ustatus']),
                  await storage.setString(
                      "refcode", value['ccfreferalRe'][0]['refcode']),
                  await storage.setString("level", value['level'].toString()),
                  setState(
                    () {
                      // data = value;
                      _isLoading = false;
                    },
                  ),
                  showInSnackBar(AppLocalizations.of(context)!.successfully,
                      logolightGreen, _scaffoldKeyTermAndCondition),
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ),
                  ),
                },
            },
          )
          .onError((error, stackTrace) {
        setState(() {
          _isLoading = false;
        });
        throw true;
      }).catchError(
        (onError) {
          setState(
            () {
              _isLoading = false;
            },
          );
          logger().e("catchError: ${onError}");

          showInSnackBar(AppLocalizations.of(context)!.error, Colors.red,
              _scaffoldKeyTermAndCondition);
        },
      );
    } catch (error) {
      logger().e("catch: ${error}");
      showInSnackBar(AppLocalizations.of(context)!.error, Colors.red,
          _scaffoldKeyTermAndCondition);
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKeyTermAndCondition =
      new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyTermAndCondition,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.terms_and_conditions),
        backgroundColor: logolightGreen,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              child: Text(
                                'CHOKCHEY Mobile App Terms & Conditions ',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: fontSizeXs,
                                    fontWeight: fontWeight700),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 5),
                              child: Text(
                                'Updated: May 5, 2021',
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    'I.DEFINITIONS CHOKCHEY',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeXs,
                                        fontWeight: fontWeight600),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text(
                                    'CHOKCHEY mobile application: Mean an application for a smartphone that can be downloaded by you from the following application stores: App store or Google Play. ',
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    'II.TERMS AND CONDITIONS',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeXs,
                                        fontWeight: fontWeight600),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text(
                                      'Please read these Terms and Conditions carefully before using the CHOKCHEY mobile application operated by CHOKCHEY FINANCE PLC. '),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text(
                                      "Your access to and use of the CHOKCHEY App is conditioned on your acceptance of and compliance with these Terms, and also the Terms and Conditions for CHOKCHEY FINANCE PLC Services.  "),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "By accessing or using the CHOKCHEY App, you agree to be bound by all these Terms. If you disagree with any part of the terms found herein or the Terms and Conditions for CHOKCHEY Services, then you may choose not to access the CHOKCHEY App. ")),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    '1) CHOKCHEY FINANCE PLC Services',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeXs,
                                        fontWeight: fontWeight600),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "All CHOKCHEY services found in the CHOKCHEY App are available only to existing CHOKCHEY Account holders and are likewise governed and covered by the Terms and Conditions for CHOKCHEY FINANCE PLC Services. Your use of these services shall be bound by all terms and conditions as listed herein and subject to your utmost acceptance and compliance. ")),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    '2) Personal Information',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeXs,
                                        fontWeight: fontWeight600),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "All personal information is protected and governed by the CHOKCHEY App Privacy Policy (below) and all information will only be used based on the agreed reasons listed down in the CHOKCHEY App Privacy Policy. ")),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    '3) Potential Links To Other Web Sites ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeXs,
                                        fontWeight: fontWeight600),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "Our Service may contain links to third- party web sites or services that are not owned or controlled by CHOKCHEY FINANCE PLC. As being third-party links, CHOKCHEY FINANCE PLC. has no control over, and assumes no responsibility for, the content, privacy policies, or practices of any third-party web sites or services. You further acknowledge and agree that CHOKCHEY FINANCE PLC shall not be responsible or liable, directly, or indirectly, for any damage or loss caused or alleged to be caused by or in connection with use of or reliance on any such content, goods or services available on or through any such web sites or services. ")),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    '4) Changes',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeXs,
                                        fontWeight: fontWeight600),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "CHOKCHEY FINANCE PLC reserve the right, at our sole discretion, to modify or replace these Terms & Conditions at any time. If a revision is material, we will try to provide at least 30 days’ notice prior to any new terms taking effect. ")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "What constitutes as a material change will be determined at our sole discretion. ")),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    '5) Access and Contact',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeXs,
                                        fontWeight: fontWeight600),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "If you have any question about the CHOKCHEY App Terms and Conditions or the Terms and Conditions of CHOKCHEY FINANCE PLC Services, contact us at info@chokchey.com.kh or phone number (+855) 23 922 126. ")),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    'III. PRIVACY POLICY FOR CHOKCHEY APP ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeXs,
                                        fontWeight: fontWeight600),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "Your privacy is important to us. ")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "CHOKCHEY FINANCE PLC, the publisher of the CHOKCHEY App is committed to ensuring your privacy is protected. Should we ask you to provide certain information by which you can be identified when using this application, you can be assured that it will only be used in accordance with this privacy statement. ")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "This privacy policy may be updated from time to time. The last update was brought into effect on …………………………………………… ")),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    '1). What information do we collect? ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeXs,
                                        fontWeight: fontWeight600),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "We may collect, store, and use the following CHOKCHEY kinds of information: ")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -      Any information that you provide to us for the purpose of registering yourself with us (including name, phone number, account number, NID or Passport, Photo) ")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -      The type of information that we collect for the purpose of register/sign up screen may change from time to time.")),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    '2). How do we access your Information?  ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeXs,
                                        fontWeight: fontWeight600),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    '3). We may access to your smartphone Information such gallery, mix, photo and NID or Passport both. How do we use your personal information? ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeXs,
                                        fontWeight: fontWeight600),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "We mainly require your personal information to understand your needs and provide you with a better service. Personal information submitted to us via the CHOKCHEY App will be used for the purposes specified in this privacy policy, and in particular for the following CHOKCHEY reasons: ")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -     Administer the application. ")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -     Enable you to log-in ")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -      Enable your use of the services available on the application such as sign up, check your balance in referral pocket, among others defined and still to be defined; ")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -      Validate purchases, refunds and any other similar activities; ")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -     Internal record keeping; ")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -     Improve our products and services; ")),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    '4). Disclosures',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeXs,
                                        fontWeight: fontWeight600),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "We may disclose information about you to any of our employees, officers, commercial partners and agents insofar as reasonably necessary for the purposes as set out in this privacy policy. ")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "In addition, we may disclose your personal information: ")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -     To the extent that we are required to do so by law; ")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -     In connection with any legal proceedings or prospective legal proceedings; ")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -     In order to establish, exercise or defend our legal rights (including providing information to others for the purposes of fraud prevention and reducing credit risk); ")),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    '5). Websites',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeXs,
                                        fontWeight: fontWeight600),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "Our application may contain links to websites. This privacy policy only applies to this application. When you link to websites you should read their own privacy policies. ")),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    '6). Our commitment to data security ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeXs,
                                        fontWeight: fontWeight600),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "We are committed to ensuring that your information is secure. In item Order to prevent unauthorized access or disclosure, we have put in place suitable physical, electronic, and managerial procedures to safeguard and secure the information we collected. Your personal information is encrypted on both the back-end and the app side. ")),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    '6). Changes',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeXs,
                                        fontWeight: fontWeight600),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -     CHOKCHEY reserves the right, at our sole discretion to modify or replace these Terms and Conditions, fee and payment at any time. CHOKCHEY will give you  at least 30 day- notice of any change before it takes effect by: Notice displayed on CHOKCHEY’s website at www.chokchey.com.kh or by major daily media, or ")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -     Contacting you on your mobile phone via SMS notification.")),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    'Access and Contact ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeXs,
                                        fontWeight: fontWeight600),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "If you have any questions about this privacy policy or our treatment of your personal information or you would like to access the personal information, we hold concerning you, contact us at info@chokchey.com.kh or by phone number (+855) 23 922 126. ")),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    'IV. REFERRAL AGREEMENT, FEE, AND PAYMENT',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeXs,
                                        fontWeight: fontWeight600),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "1) Referrer agrees to help to promote and refer clients to CHOKCHEY FINANCE PLC.")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "2) CHOKCHEY FINANCE PLC agrees to provide referral fee to referrer with following conditions:")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -     \$7 for loan disbursement amount from \$ 1,000 to \$ 10,000")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -     \$15 for loan disbursement amount from \$ 10,001 to \$ 30,000")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -     \$20 for loan disbursement amount bigger than \$ 30,000.")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "3) The payout for referrer shall be made unless referrer has verified his/her account with the following information: ")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -     upload selfie picture with NID or Passport; ")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -     upload front and back NID or Passport or any document required by us;")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -     fill in full name, NID or Passport number, gender, date of birth, expired date;")),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "     -     Bank type and bank account number.")),
                                Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text(
                                    '4). Referral fees shall be earned only when the referred loan application is approved and disbursed in system of CHOKCHEY FINANCE PLC.',
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    '5). CHOKCHEY FINANCE PLC and Referrer agreed to pay and receive referral fees on every 1st to 5th of the month after the referred loan application is successfully approved and disbursed in ChokChey Finance system; and payment can be made through: E-cash Transfer: Finance Team will transfer the approved amount to referrer’s bank account.',
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    '6). Referrer agrees to support providing any information if clients have any issues or late repayment.',
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    '6). Changes',
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    '7). Both parties agree to keep any confidential information to avoid reaching this agreement to third party(s).',
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 15),
                                  child: Text(
                                    'V. Governing Law',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeXs,
                                        fontWeight: fontWeight600),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "These specific Teams and Conditions are governed by the laws of Cambodia.")),
                                Padding(padding: EdgeInsets.only(bottom: 20))
                              ],
                            ),
                          ],
                        ),
                      )),

                  // expend 1
                  if (widget.isShowCheckBox == true)
                    Expanded(
                      flex: 0,
                      child: Container(
                        padding: EdgeInsets.all(0),
                        margin: EdgeInsets.all(0),
                        width: widthView(context, 0.93),
                        height: widthView(context, 0.3),
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isChecked,
                                      onChanged: (v) {
                                        setState(() {
                                          isChecked = v!;
                                        });
                                      },
                                    ),
                                    Text(
                                        "I agree to Chokchey's Terms & Conditons."),
                                  ],
                                )),
                            // ignore: deprecated_member_use
                            RaisedButton(
                              color: logolightGreen,
                              onPressed: () {
                                if (widget.isByFacebook == true) {
                                  initiateFacebookLogin();
                                } else {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => RegisterScreen(),
                                  ));
                                }
                              },
                              child: Container(
                                width: widthView(context, 0.5),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.continues,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
      // floatingActionButton:
    );
  }
}
