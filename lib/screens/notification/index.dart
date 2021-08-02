import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ccf_reseller_web_app/providers/notification/index.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/screens/reportCustomer/index.dart';
import 'package:ccf_reseller_web_app/screens/updateCustomer/index.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    // TODO: implement initState
    if (mounted) {
      listNotification();
    }
    super.initState();
  }

  int _pageSize = 10;
  int _pageNumber = 1;
  bool _isLoading = false;
  var listNotificationData;
  var totalMessage;
  var totalUnread;
  var totalRead;
  var levels;
  Future listNotification() async {
    final storage = await SharedPreferences.getInstance();

    setState(() {
      _isLoading = true;
    });
    levels = await storage.getString('level');
    try {
      await Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotification(_pageSize, _pageNumber)
          .then((value) {
        setState(() {
          _isLoading = false;
        });
        for (var item in value) {
          setState(() {
            totalMessage = item['totalMessage'];
            totalUnread = item['totalUnread'];
            totalRead = item['totalRead'];
            notificatonCustomer = item['listMessages'];
          });
        }
      }).catchError((onError) {
        logger().e("onError: ${onError}");

        setState(() {
          _isLoading = false;
        });
      });
    } catch (error) {
      logger().e("catch onError: ${error}");

      setState(() {
        _isLoading = false;
      });
    }
  }

  var notificatonCustomer = [];
  Future loadMore(_pageSize, _pageNumber) async {
    final storage = await SharedPreferences.getInstance();

    var user_ucode = await storage.getString("user_id");

    Map<String, String> headers = {
      "content-type": "application/json",
    };

    final Map<String, dynamic> bodyRaw = {
      "pageSize": "$_pageSize",
      "pageNumber": "$_pageNumber",
      "uid": "$user_ucode",
    };
    try {
      final Response response = await api().post(
          Uri.parse(baseURLInternal + 'CcfmessagesRes/ByUser'),
          headers: headers,
          body: json.encode(bodyRaw));
      var parsed = jsonDecode(response.body);
      setState(() {
        _isLoading = false;
      });
      for (var item in parsed) {
        setState(() {
          totalMessage = item['totalMessage'];
          totalUnread = item['totalUnread'];
          totalRead = item['totalRead'];
          notificatonCustomer = item['listMessages'];
        });
      }
      return parsed;
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  onReadInformation(id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<NotificationProvider>(context, listen: false)
          .postNotificationRead(id)
          .then((value) => setState(() {
                _isLoading = false;
              }))
          .catchError((error) {
        setState(() {
          _isLoading = false;
        });
      });
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  GlobalKey<ScaffoldState> _scaffoldKeyNotification =
      new GlobalKey<ScaffoldState>();
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (ScrollNotification? scrollInfo) {
        if (scrollInfo?.metrics.pixels == scrollInfo?.metrics.maxScrollExtent) {
          // start loading data
          setState(() {
            _pageSize += 10;
          });
          loadMore(_pageSize, _pageNumber);
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKeyNotification,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            AppLocalizations.of(context)!.notification_screen,
            style: TextStyle(color: logolightGreen),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: logolightGreen,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : notificatonCustomer != null && notificatonCustomer.length > 0
                ? Center(
                    child: Container(
                        width: isWeb()
                            ? widthView(context, 0.5)
                            : isIphoneX(context)
                                ? widthView(context, 0.35)
                                : null,
                        margin: EdgeInsets.all(5),
                        color: Colors.white,
                        child: Center(
                          child: RefreshIndicator(
                            onRefresh: () => listNotification(),
                            child: ListView.builder(
                              itemCount: notificatonCustomer.length,
                              itemBuilder: (BuildContext ctxt, int index) {
                                //it was wrong from API. lamount it will status.
                                var fetchStatus =
                                    notificatonCustomer[index]['lamount'];

                                var status = "";
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
                                  status =
                                      AppLocalizations.of(context)!.processing;
                                  backgroundcolor = Colors.yellow;
                                }
                                if (fetchStatus == "A") {
                                  status =
                                      AppLocalizations.of(context)!.approved;
                                  backgroundcolor = Colors.green;
                                }
                                if (fetchStatus == "D") {
                                  status = AppLocalizations.of(context)!.reject;
                                  backgroundcolor = Colors.red;
                                }
                                if (fetchStatus == "Request Disbursement") {
                                  status = "Request Disbursement";
                                  backgroundcolor = logoDarkBlue;
                                }
                                return Container(
                                  // margin: EdgeInsets.all(5),
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: logolightGreen, width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if (levels == 0) {
                                          onReadInformation(
                                              notificatonCustomer[index]["id"]);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ReportCustomer()));
                                        } else {
                                          onReadInformation(
                                              notificatonCustomer[index]["id"]);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      UpdateCustomer(true)));
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              // padding: EdgeInsets.only(
                                              //     left: 10, top: 0, right: 5),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    FontAwesomeIcons.userTag,
                                                    color: logolightGreen,
                                                  ),
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.all(10)),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 5),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              FontAwesomeIcons
                                                                  .addressBook,
                                                              size: 17,
                                                            ),
                                                            Text(" : "),
                                                            Text(
                                                              "${notificatonCustomer[index]['cname']}",
                                                              style:
                                                                  mainTitleBlack,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  3)),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(6),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              FontAwesomeIcons
                                                                  .idCard,
                                                              size: 17,
                                                            ),
                                                            Text(" : "),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                    "${notificatonCustomer[index]['id']}")
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    6),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  FontAwesomeIcons
                                                                      .phoneSquareAlt,
                                                                  size: 17,
                                                                ),
                                                                Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                5)),
                                                                Row(
                                                                  children: [
                                                                    Text(" : "),
                                                                    Text(
                                                                        "${notificatonCustomer[index]['phone']}")
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    6),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  FontAwesomeIcons
                                                                      .marker,
                                                                  size: 17,
                                                                ),
                                                                Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                5)),
                                                                Container(
                                                                  color:
                                                                      backgroundcolor,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              3),
                                                                  child: Text(
                                                                      status,
                                                                      style: TextStyle(
                                                                          color: backgroundcolor == Colors.yellow
                                                                              ? Colors.black
                                                                              : Colors.white)),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Card(
                                                        color: logoDarkBlue,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(6),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Icon(
                                                                FontAwesomeIcons
                                                                    .chartLine,
                                                                color: Colors
                                                                    .white,
                                                                size: 17,
                                                              ),
                                                              Container(
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                      child:
                                                                          Text(
                                                                        ": ${notificatonCustomer[index]['body']}",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                        maxLines:
                                                                            2,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (notificatonCustomer[index]
                                                          ['mstatus'] ==
                                                      1)
                                                    Icon(
                                                      Icons.done_all,
                                                      size: 15,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )),
                  )
                : Center(
                    child: Container(
                      child: Text(
                        AppLocalizations.of(context)!.no_notification,
                      ),
                    ),
                  ),
      ),
    );
  }
}
