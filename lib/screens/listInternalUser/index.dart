import 'dart:convert';

import 'package:ccf_reseller_web_app/providers/branch/index.dart';
import 'package:ccf_reseller_web_app/providers/listAllUserInternal/index.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'editUserInternal.dart';

class ListAllUserInternal extends StatefulWidget {
  const ListAllUserInternal({Key? key}) : super(key: key);

  @override
  _ListAllUserInternalState createState() => _ListAllUserInternalState();
}

class _ListAllUserInternalState extends State<ListAllUserInternal> {
  final GlobalKey<ScaffoldState> _scaffoldKeyCreateAccountInternal =
      new GlobalKey<ScaffoldState>();
  List _searchResult = [];
  List listUserInternal = [];
  TextEditingController controller = new TextEditingController();
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    fetchUserInternal(20, 1, "", "", "");
    fetchBranch(context);
    super.didChangeDependencies();
  }

  List listBranch = [];

  Future fetchBranch(context) async {
    try {
      await Provider.of<BranchProvider>(context, listen: false)
          .fetchBranch()
          .then((value) {
        setState(() {
          listBranch = value;
        });
      }).catchError((onError) {
        logger().e("onError: $onError");
      });
    } catch (error) {
      logger().e("error: $error");
    }
  }

  //
  Future fetchUserInternal(
    _pageSizeParam,
    _pageNumberParam,
    sdateParam,
    edateParam,
    statusParam,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<ListAllUserInternalProvider>(context, listen: false)
          .getAllUserInternal(_pageSizeParam, _pageNumberParam, sdateParam,
              edateParam, statusParam, "")
          .then((value) async => {
                setState(() {
                  _isLoading = false;
                  listUserInternal = value;
                }),
              })
          .catchError((onError) {
        setState(() {
          _isLoading = false;
        });
      });
    } catch (error) {}
  }

  //
  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      try {
        await Provider.of<ListAllUserInternalProvider>(context, listen: false)
            .getAllUserInternal(20, 1, "", "", "", "")
            .then((value) async => {
                  listUserInternal = value,
                })
            .catchError((onError) {
          setState(() {
            _isLoading = false;
          });
        });
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      await Provider.of<ListAllUserInternalProvider>(context, listen: false)
          .getAllUserInternal(20, 1, "", "", "", text)
          .then((value) async => {
                listUserInternal = value,
              })
          .catchError((onError) {
        setState(() {
          _isLoading = false;
        });
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }

    setState(() {});
  }

  int _pageSize = 20;
  int _pageNumber = 1;
  String sdate = "";
  String edate = "";
  String status = "";
  Future loadMore(_pageSizeParam, _pageNumberParam, sdateParam, edateParam,
      statusParam, searchParam) async {
    final storage = await SharedPreferences.getInstance();

    var levels = await storage.getString('level');
    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse(baseURLInternal + 'InterUser/all'));
      request.body = json.encode({
        "pageSize": _pageSizeParam,
        "pageNumber": _pageNumberParam,
        "uid": "",
        "sdate": "$sdateParam",
        "edate": "$edateParam",
        "status": "$statusParam",
        "level": levels,
        "search": "$searchParam"
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final parsed = jsonDecode(await response.stream.bytesToString());
        setState(() {
          listUserInternal = parsed;
        });
      } else {
        logger().e(response.reasonPhrase);
      }
    } catch (error) {
      logger().e(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (scrollState) {
        if (scrollState is ScrollEndNotification &&
            scrollState.metrics.pixels != 160) {
          setState(() {
            _pageSize += 10;
          });
          loadMore(_pageSize, _pageNumber, sdate, edate, status, "");
        }
        return false;
      },
      child: Scaffold(
          key: _scaffoldKeyCreateAccountInternal,
          backgroundColor: Colors.white,
          appBar: AppBar(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            title: Text(
              "List All User Internal",
              style: TextStyle(color: logolightGreen),
            ),
            elevation: 0,
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
              : Center(
                  child: Container(
                    width: isWeb()
                        ? widthView(context, 0.5)
                        : isIphoneX(context)
                            ? widthView(context, 0.35)
                            : widthView(context, 0.25),
                    child: Center(
                        child: Column(
                      children: [
                        new Container(
                          width: isWeb()
                              ? widthView(context, 0.5)
                              : isIphoneX(context)
                                  ? widthView(context, 0.35)
                                  : null,
                          child: new Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: new Card(
                              elevation: 3,
                              child: new ListTile(
                                leading: new Icon(Icons.search),
                                title: new TextField(
                                  controller: controller,
                                  decoration: new InputDecoration(
                                      hintText: 'Search',
                                      border: InputBorder.none),
                                  onChanged: onSearchTextChanged,
                                ),
                                trailing: new IconButton(
                                  icon: new Icon(Icons.cancel),
                                  onPressed: () {
                                    controller.clear();
                                    onSearchTextChanged('');
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                              width: isWeb()
                                  ? widthView(context, 0.5)
                                  : isIphoneX(context)
                                      ? widthView(context, 0.35)
                                      : widthView(context, 0.25),
                              color: Colors.white,
                              child: Center(
                                  child: ListView.builder(
                                      itemCount: listUserInternal.length,
                                      itemBuilder:
                                          (BuildContext ctxt, int index) {
                                        var fetchStatus =
                                            listUserInternal[index]['status'];
                                        var status = "";
                                        Color? backgroundcolor = logolightGreen;
                                        if (fetchStatus == "Pedding") {
                                          status = AppLocalizations.of(context)!
                                              .pending;
                                          backgroundcolor =
                                              Colors.lightBlueAccent;
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
                                          status = AppLocalizations.of(context)!
                                              .reject;
                                          backgroundcolor = Colors.red;
                                        }
                                        if (fetchStatus ==
                                            "Request Disbursement") {
                                          status = "Request Disbursement";
                                          backgroundcolor = logoDarkBlue;
                                        }
                                        dynamic nameBrnach = "";

                                        listBranch.forEach((element) {
                                          if (listUserInternal[index]
                                                  ['brcode'] ==
                                              element['brcode']) {
                                            nameBrnach = element['bname'];
                                          }
                                        });

                                        return Container(
                                          // margin: EdgeInsets.all(1),
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
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditUserInternal(
                                                                list:
                                                                    listUserInternal[
                                                                        index]!,
                                                              )));
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(5),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  5)),
                                                      Row(
                                                        // mainAxisAlignment:
                                                        //     MainAxisAlignment
                                                        //         .spaceBetween,
                                                        children: [
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    right: 14),
                                                            child: Icon(
                                                              FontAwesomeIcons
                                                                  .userTag,
                                                              color:
                                                                  logolightGreen,
                                                              size: 30,
                                                            ),
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                // width: isWeb()
                                                                //     ? widthView(
                                                                //         context, 0.25)
                                                                //     : isIphoneX(context)
                                                                //         ? widthView(
                                                                //             context, 0.30)
                                                                //         : null,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.37,
                                                                      child:
                                                                          Text(
                                                                        "${listUserInternal[index]['uname']}",
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                fontWeight700),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                        // width: 100,
                                                                        child:
                                                                            Row(
                                                                      children: [
                                                                        Icon(
                                                                          FontAwesomeIcons
                                                                              .phoneSquareAlt,
                                                                          size:
                                                                              17,
                                                                        ),
                                                                        Center(
                                                                          child:
                                                                              Text(
                                                                            " ${listUserInternal[index]['phone']}",
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              3)),
                                                              Container(
                                                                // width:
                                                                //     MediaQuery.of(context)
                                                                //             .size
                                                                //             .width *
                                                                //         0.8,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Icon(
                                                                            FontAwesomeIcons.idBadge,
                                                                            size:
                                                                                17,
                                                                          ),
                                                                          Container(
                                                                            child:
                                                                                Text(
                                                                              "${listUserInternal[index]['staffid']}",
                                                                              style: TextStyle(fontWeight: fontWeight700),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                              padding: EdgeInsets.only(left: 10)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                        // width: 230,
                                                                        child:
                                                                            Row(
                                                                      children: [
                                                                        Icon(
                                                                          FontAwesomeIcons
                                                                              .calendarAlt,
                                                                          size:
                                                                              17,
                                                                        ),
                                                                        Center(
                                                                          child:
                                                                              Text(
                                                                            " ${getDateTimeYMD(listUserInternal[index]['datecreate'])}",
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                            padding:
                                                                                EdgeInsets.all(1)),
                                                                        Text(
                                                                            'at'),
                                                                        Padding(
                                                                            padding:
                                                                                EdgeInsets.all(1)),
                                                                        Text(getTime(listUserInternal[index]
                                                                            [
                                                                            'datecreate']))
                                                                      ],
                                                                    )),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Text("")
                                                        ],
                                                      ),
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  5)),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(6),
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
                                                                  .idCard,
                                                              size: 17,
                                                            ),
                                                            Container(
                                                              // width:
                                                              //     MediaQuery.of(context)
                                                              //             .size
                                                              //             .width *
                                                              //         0.8,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 5),
                                                              child: Text(
                                                                // "KK"
                                                                listUserInternal[index]['staffposition'] != "null" &&
                                                                        listUserInternal[index]['staffposition'] !=
                                                                            null &&
                                                                        listUserInternal[index]['staffposition'] !=
                                                                            ""
                                                                    ? "${listUserInternal[index]['staffposition']}"
                                                                    : "",
                                                                maxLines: 3,
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
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 6),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              FontAwesomeIcons
                                                                  .envelope,
                                                              size: 17,
                                                            ),
                                                            if (listUserInternal[
                                                                            index]
                                                                        [
                                                                        'email'] !=
                                                                    "" &&
                                                                listUserInternal[
                                                                            index]
                                                                        [
                                                                        'email'] !=
                                                                    null &&
                                                                listUserInternal[
                                                                            index]
                                                                        [
                                                                        'email'] !=
                                                                    "null")
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    color:
                                                                        backgroundcolor,
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(5),
                                                                    margin: EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                3),
                                                                    child: Text(
                                                                      "${listUserInternal[index]['email']}",
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              fontWeight700,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  3)),
                                                      Container(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child: Card(
                                                          color: logoDarkBlue,
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    6),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  FontAwesomeIcons
                                                                      .building,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 17,
                                                                ),
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              10),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        "${nameBrnach}",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                          ),
                                        );
                                      }))),
                        ),
                      ],
                    )),
                  ),
                )),
    );
  }
}
