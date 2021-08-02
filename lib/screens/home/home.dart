import 'dart:convert';

import 'package:ccf_reseller_web_app/screens/createAccountInternalUser/CreateAccountUser.dart';
import 'package:ccf_reseller_web_app/screens/listAllReferer/index.dart';
import 'package:ccf_reseller_web_app/screens/listInternalUser/index.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:ccf_reseller_web_app/providers/locale/index.dart';
import 'package:ccf_reseller_web_app/providers/login/index.dart';
import 'package:ccf_reseller_web_app/providers/notification/index.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/screens/history/index.dart';
import 'package:ccf_reseller_web_app/screens/listCustomer/index.dart';
import 'package:ccf_reseller_web_app/screens/login/index.dart';
import 'package:ccf_reseller_web_app/screens/notification/index.dart';
import 'package:ccf_reseller_web_app/screens/profile/index.dart';
import 'package:ccf_reseller_web_app/screens/register/index.dart';
import 'package:ccf_reseller_web_app/screens/reportCustomer/index.dart';
import 'package:ccf_reseller_web_app/screens/team&condition/index.dart';
import 'package:ccf_reseller_web_app/screens/updateCustomer/index.dart';
import 'package:ccf_reseller_web_app/screens/verifyAccount/index.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  void initState() {
    getUser();
    getLevel();
    listNotification();
    FirebaseMessaging.instance.getNotificationSettings();
    FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String? title = message.notification!.title;
      String? body = message.notification!.body;
      showInSnackBar(
          "Title: $title, body: $body", logolightGreen, _scaffoldKey);

      RemoteNotification notification = message.notification!;
      AndroidNotification? android = message.notification?.android;
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      String? title = message.notification!.title;
      String? body = message.notification!.body;
      showInSnackBar(
          "Title: $title, body: $body", logolightGreen, _scaffoldKey);
      Navigator.pushNamed(context, '/message', arguments: NotificationScreen());
    });
    FirebaseMessaging.instance.getToken().then((String? token) {
      assert(token != null);
      postTokenPushNotification(token);
    });
    super.initState();
  }

  var listNotificationData;
  var totalMessage;
  var totalUnread = 0;
  var totalRead;
  Future listNotification() async {
    try {
      await Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotification(20, 1)
          .then((value) {
        for (var item in value) {
          setState(() {
            totalMessage = item['totalMessage'];
            totalUnread = item['totalUnread'];
            totalRead = item['totalRead'];
            listNotificationData = item['listMessages'];
          });
        }
      }).catchError((onError) {
        logger().e("onError: ${onError}");
      });
    } catch (error) {
      logger().e("catch onError: ${error}");
    }
  }

  postTokenPushNotification(tokens) async {
    final storage = await SharedPreferences.getInstance();
    String user_ucode = (await storage.getString("user_id"))!;
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'POST', Uri.parse(baseURLInternal + 'CcfuserRes/$user_ucode/mtoken'));
      request.body = json.encode({"mtoken": "$tokens", "uid": "$user_ucode"});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
    } catch (error) {
      logger().e("error: ${error}");
    }
  }

  var listUser;
  var totalCustomer = 0;
  var totalPadding = 0;
  var totalLoanApproved = 0;
  var level = "";
  var listCard = [];
  int converterToInt = 0;
  getUser() async {
    // getReferer
    final storage = await SharedPreferences.getInstance();

    try {
      await Provider.of<RegisterRef>(context, listen: false)
          .getReferer()
          .then((value) async {
        setState(() {
          listUser = value[0]['ccfreferalRe'];
          totalCustomer = value[0]['totalCustomer'];
          totalPadding = value[0]['totalPaddingCustomer'];
          totalLoanApproved = value[0]['totalLoanCustomer'];
        });
        await storage.setString("refcode", value[0]['ccfreferalRe']['refcode']);
      }).catchError((onError) {
        logger().e("catchError: ${onError}");
      });
    } catch (error) {
      logger().e("catch: ${error}");
    }
  }

  getLevel() async {
    final storage = await SharedPreferences.getInstance();

    level = (await storage.getString('level'))!;
    converterToInt = int.parse(level);
    logger().e("converterToInt: ${converterToInt}");
    if (converterToInt == 0) {
      listCard = [
        {
          "icons": "person_add",
          "cname": "register_customer",
          "description": "Book now",
        },
        {
          "icons": "person_add",
          "cname": "report_customer",
          "description": "Book now",
        },
      ];
    } else {
      listCard = [
        {
          "icons": "person_add",
          "cname": "register_customer",
          "description": "Book now",
        },
        {
          "icons": "person_add",
          "cname": "update_customer",
          "description": "Book now",
        },
        {
          "icons": "person_add",
          "cname": "list_customer",
          "description": "Book now",
        },
        {
          "icons": "person_add",
          "cname": "report_customer",
          "description": "Book now",
        },
      ];
    }
  }

  //
  final isFlagKhmer = const AssetImage('assets/images/khmer.png');

  final isFlagEnglish = const AssetImage('assets/images/english.png');
  //
  khmerLanguage() {
    Locale _temp;
    _temp = Locale('km', 'KH');

    Provider.of<LocaleProvider>(context, listen: false).setLocale(_temp);
  }

//
  englishLanguage() {
    Locale _temp;
    _temp = Locale('en', 'US');
    Provider.of<LocaleProvider>(context, listen: false).setLocale(_temp);
  }

  //
  String version = "";
  // fetchVersionApp() async {
  //   PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
  //     version = packageInfo.version;

  //     String appName = packageInfo.appName;
  //     String packageName = packageInfo.packageName;
  //     String buildNumber = packageInfo.buildNumber;
  //   });
  // }

  _drawerList(context) {
    String versionString =
        baseURLInternal == "http://119.82.252.42:2032/api/" ? "version" : "v";
    return Drawer(
        child: Container(
            color: Colors.white,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(top: 50),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          //Hello Profile
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfileScreen()));
                            },
                            child: Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.solidUserCircle,
                                  color: logolightGreen,
                                  size: 50,
                                ),
                                Padding(padding: EdgeInsets.all(10)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.hello,
                                      style: TextStyle(color: logolightGreen),
                                    ),
                                    Padding(padding: EdgeInsets.all(3)),
                                    Text(
                                      listUser != null &&
                                              listUser['refname'] != null
                                          ? "${listUser['refname']}"
                                          : "",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: logolightGreen,
                                          fontSize: fontSizeLg),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  //                   <--- left side
                                  color: Colors.black,
                                  width: 0.3,
                                ),
                                top: BorderSide(
                                  //                    <--- top side
                                  color: Colors.black,
                                  width: 0.3,
                                ),
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          //Profile
                          InkWell(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfileScreen())),
                            child: Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.userCog,
                                  color: logolightGreen,
                                ),
                                Padding(padding: EdgeInsets.all(10)),
                                Text(
                                  AppLocalizations.of(context)!.update_profile,
                                  style: TextStyle(fontWeight: fontWeight500),
                                )
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          //History
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HistoryScreen()));
                            },
                            child: Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.listAlt,
                                  color: logolightGreen,
                                ),
                                Padding(padding: EdgeInsets.all(10)),
                                Text(
                                  AppLocalizations.of(context)!.history,
                                  style: TextStyle(fontWeight: fontWeight500),
                                )
                              ],
                            ),
                          ),
                          // Verify Account Referrer
                          if (converterToInt == 4 || converterToInt == 5)
                            Padding(padding: EdgeInsets.all(10)),
                          if (converterToInt == 4 || converterToInt == 5)
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => VerifyScreen()));
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.checkDouble,
                                    color: logolightGreen,
                                  ),
                                  Padding(padding: EdgeInsets.all(10)),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .verify_account_user,
                                    style: TextStyle(fontWeight: fontWeight500),
                                  )
                                ],
                              ),
                            ),
                          //create user for internal Chokchey Finance Plc.
                          if (converterToInt == 4 || converterToInt == 5)
                            Padding(padding: EdgeInsets.all(10)),
                          if (converterToInt == 4 || converterToInt == 5)
                            InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CreateAccountInternal())),
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.userPlus,
                                    color: logolightGreen,
                                  ),
                                  Padding(padding: EdgeInsets.all(10)),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .create_account_internal,
                                    style: TextStyle(fontWeight: fontWeight500),
                                  )
                                ],
                              ),
                            ),
                          if (converterToInt == 4 || converterToInt == 5)
                            Padding(padding: EdgeInsets.all(10)),
                          if (converterToInt == 4 || converterToInt == 5)
                            InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ListAllUserInternal())),
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.users,
                                    color: logolightGreen,
                                  ),
                                  Padding(padding: EdgeInsets.all(10)),
                                  Text(
                                    "List All User Internal",
                                    style: TextStyle(fontWeight: fontWeight500),
                                  )
                                ],
                              ),
                            ),
                          // ListAllReferer
                          if (converterToInt == 4 || converterToInt == 5)
                            Padding(padding: EdgeInsets.all(10)),
                          if (converterToInt == 4 || converterToInt == 5)
                            InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ListAllReferer())),
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.users,
                                    color: logolightGreen,
                                  ),
                                  Padding(padding: EdgeInsets.all(10)),
                                  Text(
                                    "List All Referer",
                                    style: TextStyle(fontWeight: fontWeight500),
                                  )
                                ],
                              ),
                            ),
                          Padding(padding: EdgeInsets.all(10)),
                          InkWell(
                            onTap: () => khmerLanguage(),
                            child: Row(
                              children: [
                                Image(
                                  image: isFlagKhmer,
                                  height: 17,
                                  fit: BoxFit.fill,
                                ),
                                Padding(padding: EdgeInsets.all(10)),
                                Text(
                                  AppLocalizations.of(context)!.khmer,
                                  style: TextStyle(fontWeight: fontWeight500),
                                )
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          InkWell(
                            onTap: () => englishLanguage(),
                            child: Row(
                              children: [
                                Image(
                                  image: isFlagEnglish,
                                  height: 17,
                                  fit: BoxFit.fill,
                                ),
                                Padding(padding: EdgeInsets.all(10)),
                                Text(
                                  AppLocalizations.of(context)!.english,
                                  style: TextStyle(fontWeight: fontWeight500),
                                )
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TeamCondition(
                                            isByFacebook: true,
                                            isShowCheckBox: false,
                                          )));
                            },
                            child: Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.book,
                                  color: logolightGreen,
                                ),
                                Padding(padding: EdgeInsets.all(10)),
                                Text(
                                  AppLocalizations.of(context)!
                                      .terms_and_conditions,
                                  style: TextStyle(fontWeight: fontWeight500),
                                )
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          InkWell(
                            onTap: () async {
                              // final storage =
                              //     await SharedPreferences.getInstance();

                              // await Provider.of<RegisterRef>(context,
                              //         listen: false)
                              //     .postInAppLog("LogOut");
                              // storage.remove('user_id');
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          LoginScreenNewTamplate()),
                                  ModalRoute.withName('/'));
                            },
                            child: Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.signOutAlt,
                                  color: logolightGreen,
                                ),
                                Padding(padding: EdgeInsets.all(10)),
                                Text(
                                  AppLocalizations.of(context)!.log_out,
                                  style: TextStyle(fontWeight: fontWeight500),
                                )
                              ],
                            ),
                          ),
                        ],
                      )),
                  ListTile(
                    title: Text("$versionString " + '$version'),
                    onTap: () {},
                  ),
                ])));
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 100) / 4;
    final double itemWidth = size.width / 2.5;
    return ChangeNotifierProvider(
      create: (_) => RegisterRef(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: new Drawer(
          child: _drawerList(context),
        ),
        appBar: AppBar(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.menu_open_sharp,
                color: Colors.grey,
              ),
              onPressed: () => _scaffoldKey.currentState!.openDrawer(),
            ),
            actions: <Widget>[
              new Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  new IconButton(
                      icon: Icon(
                        Icons.notifications,
                        size: 25,
                        color: Colors.grey.shade400,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotificationScreen()),
                        );
                      }),
                  totalUnread != 0
                      ? new Positioned(
                          right: 11,
                          top: 14,
                          child: new Container(
                            padding: EdgeInsets.all(2),
                            decoration: new BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              totalUnread.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : new Container()
                ],
              ),
            ]),
        body: SingleChildScrollView(
            child: Center(
          child: Container(
            width: isWeb()
                ? widthView(context, 0.5)
                : isIphoneX(context)
                    ? widthView(context, 0.35)
                    : null,
            color: Colors.white,
            // padding: EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    // padding: EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.hello,
                          style: TextStyle(
                              fontSize: fontSizeLg,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          listUser != null && listUser['refname'] != null
                              ? " ${listUser['refname']}"
                              : "",
                          style: TextStyle(
                              fontSize: fontSizeLg,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
                Container(
                    padding: EdgeInsets.only(left: 10, bottom: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.welcome_chokchey_finacen,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: fontSizeXs,
                      ),
                    )),
                Card(
                  elevation: 5,
                  color: logolightGreen,
                  margin: EdgeInsets.all(5),
                  child: Container(
                      // width: isIphoneX(context)
                      //     ? MediaQuery.of(context).size.width * 1
                      //     : MediaQuery.of(context).size.width * 0.35,
                      padding: EdgeInsets.all(15),
                      // height: isIphoneX(context)
                      //     ? MediaQuery.of(context).size.width * 0.35
                      //     : MediaQuery.of(context).size.width * 0.1,
                      child: Center(
                          child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "\$ ${listUser != null && listUser['bal'] != null ? listUser['bal'].toString() : 0.toString()}",
                            style: TextStyle(
                              fontSize: fontSizeLg,
                              color: Colors.white,
                              fontWeight: fontWeight800,
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(5)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.people,
                                        color: Colors.white,
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(right: 5.0)),
                                      Text(
                                        "${totalCustomer}",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: fontSizeSm,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  Text(
                                      AppLocalizations.of(context)!
                                          .total_customer,
                                      style: TextStyle(
                                          color: Colors.white, height: 2)),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.assignment,
                                        color: Colors.white,
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(right: 5.0)),
                                      Text(
                                        "$totalPadding",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: fontSizeSm,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  Text(
                                      AppLocalizations.of(context)!
                                          .total_padding_loan,
                                      style: TextStyle(
                                          color: Colors.white, height: 2)),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_box,
                                        color: Colors.white,
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(right: 5.0)),
                                      Text(
                                        "$totalLoanApproved",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: fontSizeSm,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  Text(AppLocalizations.of(context)!.total_loan,
                                      style: TextStyle(
                                          color: Colors.white, height: 2)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ))),
                ),
                Padding(padding: EdgeInsets.all(10)),
                GridView.count(
                  childAspectRatio: (5 / 3),
                  controller: new ScrollController(keepScrollOffset: false),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  crossAxisCount: isIphoneX(context) ? 2 : 4,
                  children: List.generate(
                    listCard.length,
                    (i) {
                      var icons = listCard[i]['cname'] == 'register_customer'
                          ? Icon(
                              FontAwesomeIcons.userPlus,
                              color: logolightGreen,
                              size: 25,
                            )
                          : listCard[i]['cname'] == 'list_customer'
                              ? Icon(
                                  FontAwesomeIcons.list,
                                  color: logolightGreen,
                                  size: 25,
                                )
                              : listCard[i]['cname'] == 'update_customer'
                                  ? Icon(
                                      FontAwesomeIcons.userEdit,
                                      color: logolightGreen,
                                      size: 25,
                                    )
                                  : Icon(
                                      FontAwesomeIcons.chartPie,
                                      color: logolightGreen,
                                      size: 25,
                                    );

                      var nameMenu = listCard[i]['cname'] == 'register_customer'
                          ? AppLocalizations.of(context)!.register_customer
                          : listCard[i]['cname'] == 'list_customer'
                              ? AppLocalizations.of(context)!.list_customer
                              : listCard[i]['cname'] == 'update_customer'
                                  ? AppLocalizations.of(context)!
                                      .update_customer
                                  : AppLocalizations.of(context)!
                                      .report_customer;
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: logolightGreen, width: 1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (listCard[i]['cname'] == 'register_customer') {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RegisterCustomer()));
                            }
                            if (listCard[i]['cname'] == 'list_customer') {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ListCustomer(true)));
                            }
                            if (listCard[i]['cname'] == 'update_customer') {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UpdateCustomer(true)));
                            }
                            if (listCard[i]['cname'] == 'report_customer') {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ReportCustomer()));
                            }
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: Text(nameMenu,
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontFamily: 'Roboto Mono',
                                          fontSize: fontSizeXs,
                                          fontWeight: fontWeight500)),
                                ),
                                icons,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        )),
      ),
    );
  }
}
