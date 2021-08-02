import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:ccf_reseller_web_app/providers/historyBalance/index.dart';
import 'package:ccf_reseller_web_app/providers/login/index.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  GlobalKey<ScaffoldState> _scaffoldKeyHistory = new GlobalKey<ScaffoldState>();
// HistroyBalance
//

  @override
  void initState() {
    // TODO: implement initState
    listHistoryBalance();
    getUser();
    super.initState();
  }

  int _pageSize = 20;
  int _pageNumber = 1;
  String _sdate = "";
  String _edate = "";
  var listBalance = [];
  bool _isLoanding = false;

  Future listHistoryBalance() async {
    setState(() {
      _isLoanding = true;
    });
    try {
      await Provider.of<HistroyBalance>(context, listen: false)
          .fetchAllBalanceByID(_pageSize, _pageNumber, _sdate, _edate)
          .then((value) {
        setState(() {
          listBalance = value;
          _isLoanding = false;
        });
      }).onError((error, stackTrace) {
        setState(() {
          _isLoanding = false;
        });
      });
    } catch (error) {
      setState(() {
        _isLoanding = false;
      });
    }
  }

  var listUser;
  var totalCustomer = 0;
  var totalPadding = 0;
  var totalLoanApproved = 0;
  var level = "";
  var listCard = [];

  getUser() async {
    final storage = await SharedPreferences.getInstance();

    // getReferer
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
        await storage.setString("refcode", listUser['refcode']);
      }).catchError((onError) {
        logger().e("catchError: ${onError}");
      });
    } catch (error) {
      logger().e("catch: ${error}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKeyHistory,
        backgroundColor: Colors.white,
        appBar: AppBar(
          // color: Colors.grey.shade100,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            AppLocalizations.of(context)!.history,
            style: TextStyle(color: logolightGreen),
          ),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: logolightGreen,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: _isLoanding
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                color: Colors.grey.shade100,
                child: Column(
                  children: [
                    Expanded(
                      flex: 0,
                      child: Container(
                        padding: EdgeInsets.only(bottom: 10),
                        color: Colors.white,
                        child: Column(
                          children: [
                            Container(
                              child: Text(AppLocalizations.of(context)!
                                  .available_balance),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: Text(
                                    "${listUser != null && listUser['bal'] != null ? listUser['bal'].toString() : 0.toString()}",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: fontWeight700),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    AppLocalizations.of(context)!.usd,
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: fontWeight700),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(5)),
                    Expanded(
                      flex: 1,
                      child: listBalance == null
                          ? Center(
                              child: Text("No History"),
                            )
                          : GroupedListView<dynamic, String>(
                              elements: listBalance,
                              padding: EdgeInsets.all(0),
                              groupHeaderBuilder: (element) => Container(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  children: [
                                    Container(
                                        padding: EdgeInsets.only(
                                            left: 10, bottom: 5, top: 5),
                                        child: Text(getDateTimeMDY(
                                            element['datecreate']))),
                                  ],
                                ),
                              ),
                              groupBy: (element) =>
                                  getDateTimeMDY(element['datecreate']),
                              groupSeparatorBuilder: (String groupByValue) =>
                                  Text(groupByValue),
                              itemBuilder: (context, dynamic element) => Card(
                                shape: new RoundedRectangleBorder(
                                    side: new BorderSide(
                                        color: Colors.grey.shade100,
                                        width: 0.5),
                                    borderRadius: BorderRadius.circular(4.0)),
                                margin: EdgeInsets.all(0),
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.signInAlt,
                                            color: logolightGreen,
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10)),
                                          Text(element['transitiontype']),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            element['amount'].toString(),
                                            style: TextStyle(
                                                color: logolightGreen,
                                                fontWeight: fontWeight700),
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(right: 5)),
                                          Text(
                                            AppLocalizations.of(context)!.usd,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              itemComparator: (item1, item2) =>
                                  item1['datecreate'].compareTo(
                                      item2['datecreate']), // optional
                              useStickyGroupSeparators: true, // optional
                              floatingHeader: true, // optional
                              order: GroupedListOrder.DESC, // optional
                            ),
                    )
                  ],
                ),
              ));
  }
}
