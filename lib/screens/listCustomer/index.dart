import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ccf_reseller_web_app/providers/listCustomer/indext.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/screens/home/home.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListCustomer extends StatefulWidget {
  var isRefresh = false;
  ListCustomer(this.isRefresh);
  @override
  _ListCustomerState createState() => _ListCustomerState();
}

class _ListCustomerState extends State<ListCustomer> {
  bool _isLoading = false;
  var listCustomer;

  @override
  void initState() {
    // TODO: implement initState
    if (mounted) {
      listCustomers(20, 1, "", "");
    }
    super.initState();
  }

  var finalApproveStatus = "";

  //
  var pageSize = 20;
  var pageNumber = 1;
  var sdate = "";
  var edate = "";
  var status = "";
  var levels;
  var userLogin;
  //
  Future listCustomers(pageSize, pageNumber, sdate, edate) async {
    //
    setState(() {
      _isLoading = true;
    });
    final storage = await SharedPreferences.getInstance();

    var level = await storage.getString('level');
    var user_id = await storage.getString('user_id');

    try {
      await Provider.of<Customer>(context, listen: false)
          .getAllReferal(pageSize, pageNumber, sdate, edate, "")
          .then((value) async => {
                setState(() {
                  _isLoading = false;
                  listCustomer = value;
                  userLogin = int.parse(user_id!);
                  levels = int.parse(level!);
                }),
                if (value != null)
                  if (value[0]['status'] == "FINAL APPROVE")
                    {
                      setState(() {
                        finalApproveStatus = value[0]['status'];
                      })
                    }
              })
          .catchError((onError) {
        setState(() {
          _isLoading = false;
        });
      });
    } catch (error) {}
  }

  void onLoading() async {
    await new Future.delayed(new Duration(seconds: 1), () {
      setState(() {
        widget.isRefresh = false;
      });
    });
  }

  Future loadMore(_pageSizeParam, _pageNumberParam, sdateParam, edateParam,
      statusParam) async {
    dynamic storage = await SharedPreferences.getInstance();
    dynamic uid = await storage.getString('user_id');
    dynamic level = await storage.getString('level');
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'POST', Uri.parse(baseURLInternal + 'CcfreferalCusUps/all'));
      request.body = json.encode({
        "pageSize": _pageSizeParam,
        "pageNumber": _pageNumberParam,
        "uid": "$uid",
        "sdate": "$sdate",
        "edate": "$edate"
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final value = jsonDecode(await response.stream.bytesToString());
        setState(() {
          _isLoading = false;
          listCustomer = value;
          userLogin = int.parse(uid.toString());
          levels = int.parse(level.toString());
        });
        if (value[0]['status'] == "FINAL APPROVE") {
          setState(() {
            finalApproveStatus = value[0]['status'];
          });
        }
      } else {
        print(response.reasonPhrase);
      }
      //
    } catch (error) {
      logger().e("error: $error");
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    if (widget.isRefresh == true) {
      onLoading();
    }
    return NotificationListener(
      onNotification: (scrollState) {
        if (scrollState is ScrollEndNotification &&
            scrollState.metrics.pixels != 160) {
          Future.delayed(const Duration(milliseconds: 100), () {}).then((s) {
            setState(() {
              pageSize += 10;
            });
            loadMore(pageSize, pageNumber, sdate, edate, status);
          });
        }
        return false;
      },
      child: Provider(
        create: (_) => Customer(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            title: Text(
              AppLocalizations.of(context)!.list_customer,
              style: TextStyle(color: logolightGreen),
            ),
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: logolightGreen,
              ),
              onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => HomeScreen(),
                  ),
                  ModalRoute.withName('/')),
            ),
          ),
          body: widget.isRefresh == true
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : listCustomer != null
                      ? RefreshIndicator(
                          onRefresh: () => listCustomers(20, 1, "", ""),
                          child: Center(
                            child: Container(
                              width: isWeb()
                                  ? widthView(context, 0.5)
                                  : isIphoneX(context)
                                      ? widthView(context, 0.35)
                                      : null,
                              color: Colors.white,
                              child: Center(
                                child: ListView.builder(
                                  itemCount: listCustomer.length,
                                  itemBuilder: (BuildContext ctxt, int index) {
                                    var fetchStatus =
                                        listCustomer[index]['status'];
                                    Color? backgroundcolor = logolightGreen;
                                    if (fetchStatus == "Pedding") {
                                      status =
                                          AppLocalizations.of(context)!.pending;
                                      backgroundcolor = Colors.lightBlueAccent;
                                    }
                                    if (fetchStatus == "FINAL APPROVE") {
                                      status = AppLocalizations.of(context)!
                                          .final_approve;
                                      backgroundcolor = Colors.yellow;
                                    }
                                    if (fetchStatus == "P") {
                                      status = AppLocalizations.of(context)!
                                          .processing;
                                      backgroundcolor = Colors.yellow;
                                    }
                                    if (fetchStatus == "A") {
                                      status = AppLocalizations.of(context)!
                                          .approved;
                                      backgroundcolor = Colors.green;
                                    }
                                    if (fetchStatus == "D") {
                                      status =
                                          AppLocalizations.of(context)!.reject;
                                      backgroundcolor = Colors.red;
                                    }
                                    var assignedUserAcessFinal = false;
                                    var assignedUserAcess = false;

                                    if (listCustomer[index]['u5'] == null) {
                                      assignedUserAcess = true;
                                    } else {
                                      if (listCustomer[index]['u5'] != "") {
                                        var parseToInt = int.parse(
                                            listCustomer[index]['u5']);
                                        if (listCustomer[index]['status'] ==
                                                "FINAL APPROVE" &&
                                            levels == 3 &&
                                            parseToInt == userLogin) {
                                          assignedUserAcessFinal = true;
                                        } else if (parseToInt == userLogin) {
                                          assignedUserAcess = true;
                                        }
                                        if (levels == 4) {
                                          assignedUserAcess = true;
                                        }
                                      } else {
                                        if (levels == 4) {
                                          assignedUserAcess = true;
                                        }
                                      }
                                    }

                                    if (listCustomer[index]['status'] == "A") {
                                      assignedUserAcessFinal = false;
                                      assignedUserAcess = false;
                                    }

                                    return listCustomer.length > 0
                                        ? Container(
                                            margin: EdgeInsets.all(1),
                                            child: Card(
                                              elevation: 4,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: logolightGreen,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: InkWell(
                                                onTap: () {},
                                                child: Container(
                                                  padding: EdgeInsets.all(15),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10,
                                                                top: 0,
                                                                right: 10),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              FontAwesomeIcons
                                                                  .userTag,
                                                              color:
                                                                  logolightGreen,
                                                            ),
                                                            Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10)),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              5),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        "${listCustomer[index]['cname']}",
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                fontWeight700,
                                                                            fontSize:
                                                                                fontSizeXs),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            3)),
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              6),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Icon(
                                                                            FontAwesomeIcons.phone,
                                                                            size:
                                                                                17,
                                                                          ),
                                                                          Padding(
                                                                              padding: EdgeInsets.only(left: 5)),
                                                                          Text(
                                                                            ": ${listCustomer[index]['phone']}",
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              6),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Icon(
                                                                            FontAwesomeIcons.dollarSign,
                                                                            size:
                                                                                17,
                                                                          ),
                                                                          Text(
                                                                            ": ${listCustomer[index]['lamount']}",
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      listCustomer[index][
                                                                      'address'] !=
                                                                  null &&
                                                              listCustomer[
                                                                          index]
                                                                      [
                                                                      'address'] !=
                                                                  ""
                                                          ? Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(6),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Icon(
                                                                    FontAwesomeIcons
                                                                        .addressBook,
                                                                    size: 17,
                                                                  ),
                                                                  Text(" : "),
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.3,
                                                                    child: Text(
                                                                      "${listCustomer[index]['address']}",
                                                                      maxLines:
                                                                          3,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              fontWeight700),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : Text(""),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            FontAwesomeIcons
                                                                .marker,
                                                            size: 17,
                                                          ),
                                                          Text(" : "),
                                                          Container(
                                                            color:
                                                                backgroundcolor,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5),
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 3),
                                                            child: Text(
                                                              "${status}",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      fontWeight700,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .no_data),
                                          );
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(AppLocalizations.of(context)!.no_data),
                        ),
        ),
      ),
    );
  }
}
