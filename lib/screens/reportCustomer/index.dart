import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ccf_reseller_web_app/providers/listCustomer/indext.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/screens/reportCustomer/detail.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ReportCustomer extends StatefulWidget {
  @override
  _ReportCustomerState createState() => _ReportCustomerState();
}

class _ReportCustomerState extends State<ReportCustomer> {
  var updateCustomer;
  var sdate = "";
  var edate = "";
  var status = "";
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies

    if (mounted) {
      listCustomers(20, 1, "", "", "", "");
    }

    super.didChangeDependencies();
  }

  int _pageSize = 20;
  int _pageNumber = 1;
  Future listCustomers(_pageSizeParam, _pageNumberParam, sdateParam, edateParam,
      levelParam, statusParam) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Customer>(context, listen: false)
          .getAllReferal(_pageSizeParam, _pageNumberParam, sdateParam,
              edateParam, statusParam)
          .then((value) async => {
                setState(() {
                  _isLoading = false;
                  updateCustomer = value;
                }),
              })
          .catchError((onError) {
        setState(() {
          _isLoading = false;
        });
      });
    } catch (error) {}
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
        "pageSize": "$_pageSizeParam",
        "pageNumber": "$_pageNumberParam",
        "uid": "$uid",
        "sdate": "$sdateParam",
        "edate": "$edateParam",
        "status": "$statusParam",
        "level": level
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final value = jsonDecode(await response.stream.bytesToString());
        setState(() {
          _isLoading = false;
          updateCustomer = value;
        });
      } else {
        print(response.reasonPhrase);
      }
      //
    } catch (error) {
      logger().e("error: $error");
    }
  }

  TextEditingController controllerStartDate = TextEditingController();
  TextEditingController controllerEndDate = TextEditingController();

  void _closeEndDrawer() {
    setState(() {
      controllerEndDate.text = '';
      controllerStartDate.text = '';
      _isLoading = true;
    });
    listCustomers(20, 1, "", "", "", "")
        .then((value) => {
              setState(() {
                _isLoading = false;
              }),
            })
        .catchError((onError) {
      setState(() {
        _isLoading = false;
      });
    });
    Navigator.of(context).pop();
  }

  //
  _applyEndDrawer() async {
    DateTime now = DateTime.now();
    setState(() {
      _isLoading = true;
    });
    var startDate = sdate != null ? sdate : "";
    var endDate = edate != null ? edate : "";

    listCustomers(20, 1, startDate, endDate, "", status)
        .then((value) => {
              setState(() {
                _isLoading = false;
              })
            })
        .catchError((onError) {
      setState(() {
        _isLoading = false;
      });
    });
    Navigator.of(context).pop();
  }

  final _formKey = GlobalKey<FormBuilderState>();

  bool _isSelectedPedding = false;
  bool _isSelectedApproved = false;
  bool _isStatuSelectedReject = false;
  bool _isStatuSelectedReturn = false;
  bool _isStatuSelectedFinalApprove = false;

  //
  TextEditingController controller = new TextEditingController();
  List _searchResult = [];

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    updateCustomer.forEach((updateCustomer) {
      if (updateCustomer['cname'].contains(text) ||
          updateCustomer['phone'].contains(text))
        _searchResult.add(updateCustomer);
    });

    setState(() {});
  }

  //
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return NotificationListener(
      onNotification: (scrollState) {
        if (scrollState is ScrollEndNotification &&
            scrollState.metrics.pixels != 160) {
          Future.delayed(const Duration(milliseconds: 100), () {}).then((s) {
            setState(() {
              _pageSize += 10;
            });
            loadMore(_pageSize, _pageNumber, sdate, edate, status);
          });
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: logolightGreen,
                ),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
          ],
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            AppLocalizations.of(context)!.report_customer,
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
        endDrawer: Drawer(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 35)),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        Icon(Icons.filter_list),
                        Padding(padding: EdgeInsets.only(right: 5)),
                        Text(
                          AppLocalizations.of(context)!.filter,
                          style: TextStyle(
                              fontWeight: fontWeight800, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  //Pick start date
                  Container(
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: FormBuilderDateRangePicker(
                        name: 'date',
                        initialEntryMode: DatePickerEntryMode.input,
                        controller: controllerStartDate,
                        onChanged: (DateTimeRange? v) {
                          setState(() {
                            if (v != null) {
                              String time = v.start.toString();
                              String s = "$time";
                              //end
                              String timeEnd = v.end.toString();
                              String e = "$timeEnd";
                              sdate = s as String;
                              edate = e as String;
                            } else {
                              sdate =
                                  DateTime(now.year, now.month, 1) as String;
                            }
                          });
                        },
                        // initialValue: DateTime(now.year, now.month, 1),
                        format: DateFormat("yyyy-MM-dd"),
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.pick_date,
                        ),
                        firstDate: DateTime(now.year, now.month, 1),
                        lastDate: DateTime.now(),
                      ),
                    ),
                  ),
                  // filter status
                  Card(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isSelectedPedding = !_isSelectedPedding;
                          _isSelectedApproved = false;
                          _isStatuSelectedReject = false;
                          _isStatuSelectedReturn = false;
                          _isStatuSelectedFinalApprove = false;
                          status = 'Pedding';
                        });
                      },
                      child: Container(
                        color:
                            _isSelectedPedding == true ? logolightGreen : null,
                        width: MediaQuery.of(context).size.width * 1,
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.pending,
                            style: TextStyle(
                                color: _isSelectedPedding == true
                                    ? Colors.white
                                    : null),
                          ),
                        ),
                      ),
                    ),
                  ),
                  //
                  Card(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isStatuSelectedReturn = !_isStatuSelectedReturn;
                          _isStatuSelectedReject = false;
                          _isSelectedApproved = false;
                          _isStatuSelectedFinalApprove = false;
                          _isSelectedPedding = false;
                          status = 'P';
                        });
                      },
                      child: Container(
                        color: _isStatuSelectedReturn == true
                            ? logolightGreen
                            : null,
                        width: MediaQuery.of(context).size.width * 1,
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.processing,
                            style: TextStyle(
                                color: _isStatuSelectedReturn == true
                                    ? Colors.white
                                    : null),
                          ),
                        ),
                      ),
                    ),
                  ),
                  //
                  Card(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isStatuSelectedFinalApprove =
                              !_isStatuSelectedFinalApprove;
                          _isStatuSelectedReject = false;
                          _isSelectedApproved = false;
                          _isSelectedPedding = false;
                          _isStatuSelectedReturn = false;
                          status = 'FINAL APPROVE';
                        });
                      },
                      child: Container(
                        color: _isStatuSelectedFinalApprove == true
                            ? logolightGreen
                            : null,
                        width: MediaQuery.of(context).size.width * 1,
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.final_approve,
                            style: TextStyle(
                                color: _isStatuSelectedFinalApprove == true
                                    ? Colors.white
                                    : null),
                          ),
                        ),
                      ),
                    ),
                  ),
                  //FINAL APPROVE

                  //
                  Card(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isSelectedApproved = !_isSelectedApproved;
                          _isStatuSelectedReject = false;
                          _isStatuSelectedReturn = false;
                          _isStatuSelectedFinalApprove = false;
                          _isSelectedPedding = false;
                          status = 'A';
                        });
                      },
                      child: Container(
                        color:
                            _isSelectedApproved == true ? logolightGreen : null,
                        width: MediaQuery.of(context).size.width * 1,
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.approved,
                            style: TextStyle(
                                color: _isSelectedApproved == true
                                    ? Colors.white
                                    : null),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: Container(
                      color: _isStatuSelectedReject == true
                          ? logolightGreen
                          : null,
                      width: MediaQuery.of(context).size.width * 1,
                      padding: EdgeInsets.all(10),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isStatuSelectedReject = !_isStatuSelectedReject;
                            _isSelectedApproved = false;
                            _isStatuSelectedReturn = false;
                            _isStatuSelectedFinalApprove = false;
                            _isSelectedPedding = false;
                            status = 'D';
                          });
                        },
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.reject,
                            style: TextStyle(
                                color: _isStatuSelectedReject == true
                                    ? Colors.white
                                    : null),
                          ),
                        ),
                      ),
                    ),
                  ),
                  //buttom close and apply
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RaisedButton(
                          onPressed: _closeEndDrawer,
                          child: Text(AppLocalizations.of(context)!.reset),
                        ),
                        RaisedButton(
                          color: logolightGreen,
                          onPressed: _applyEndDrawer,
                          child: Text(
                            // AppLocalizations.of(context).translate('apply') ??
                            AppLocalizations.of(context)!.apply,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : updateCustomer.length > 0
                ? RefreshIndicator(
                    onRefresh: () => listCustomers(20, 1, "", "", "", ""),
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
                          child:
                              _searchResult.length != 0 ||
                                      controller.text.isNotEmpty
                                  ? Center(
                                      child: Container(
                                        width: isWeb()
                                            ? widthView(context, 0.5)
                                            : isIphoneX(context)
                                                ? widthView(context, 0.35)
                                                : widthView(context, 0.25),
                                        color: Colors.white,
                                        child: Center(
                                          child: ListView.builder(
                                            itemCount: _searchResult.length,
                                            itemBuilder:
                                                (BuildContext ctxt, int index) {
                                              var fetchStatus =
                                                  _searchResult[index]
                                                      ['status'];
                                              var status = "";
                                              Color? backgroundcolor =
                                                  logolightGreen;
                                              if (fetchStatus == "Pedding") {
                                                status = AppLocalizations.of(
                                                        context)!
                                                    .pending;
                                                backgroundcolor =
                                                    Colors.lightBlueAccent;
                                              }
                                              if (fetchStatus ==
                                                  "FINAL APPROVE") {
                                                status = AppLocalizations.of(
                                                        context)!
                                                    .final_approve;
                                                backgroundcolor = Colors.yellow;
                                              }
                                              if (fetchStatus == "P") {
                                                status = AppLocalizations.of(
                                                        context)!
                                                    .processing;
                                                backgroundcolor = Colors.yellow;
                                              }
                                              if (fetchStatus == "A") {
                                                status = AppLocalizations.of(
                                                        context)!
                                                    .approved;
                                                backgroundcolor = Colors.green;
                                              }
                                              if (fetchStatus == "D") {
                                                status = AppLocalizations.of(
                                                        context)!
                                                    .reject;
                                                backgroundcolor = Colors.red;
                                              }
                                              if (fetchStatus ==
                                                  "Request Disbursement") {
                                                status = "Request Disbursement";
                                                backgroundcolor = logoDarkBlue;
                                              }

                                              return Container(
                                                // margin: EdgeInsets.all(1),
                                                child: Card(
                                                  elevation: 4,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: logolightGreen,
                                                        width: 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        DetailReportScreen(
                                                                          list:
                                                                              _searchResult[index]!,
                                                                        )));
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            5)),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Icon(
                                                                  FontAwesomeIcons
                                                                      .userTag,
                                                                  color:
                                                                      logolightGreen,
                                                                  size: 30,
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
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Container(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.37,
                                                                            child:
                                                                                Text(
                                                                              "${_searchResult[index]['cname']}",
                                                                              style: TextStyle(fontWeight: fontWeight700),
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                              // width: 100,
                                                                              child: Row(
                                                                            children: [
                                                                              Icon(
                                                                                FontAwesomeIcons.phoneSquareAlt,
                                                                                size: 17,
                                                                              ),
                                                                              Center(
                                                                                child: Text(
                                                                                  " ${_searchResult[index]['phone']}",
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          )),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                        padding:
                                                                            EdgeInsets.all(3)),
                                                                    Container(
                                                                      // width:
                                                                      //     MediaQuery.of(context)
                                                                      //             .size
                                                                      //             .width *
                                                                      //         0.8,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Container(
                                                                            // width: MediaQuery.of(
                                                                            //             context)
                                                                            //         .size
                                                                            //         .width *
                                                                            //     0.37,
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                if (_searchResult[index]['curcode'] == "101")
                                                                                  Icon(
                                                                                    FontAwesomeIcons.dollarSign,
                                                                                    size: 17,
                                                                                  ),
                                                                                if (_searchResult[index]['curcode'] == "100")
                                                                                  Image.asset(
                                                                                    'assets/images/khmercurrency.png',
                                                                                    width: 15,
                                                                                  ),
                                                                                Container(
                                                                                  child: Text(
                                                                                    "${numFormat.format(_searchResult[index]['lamount'])}",
                                                                                    style: TextStyle(fontWeight: fontWeight700),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                              // width: 230,
                                                                              child: Row(
                                                                            children: [
                                                                              Icon(
                                                                                FontAwesomeIcons.calendarAlt,
                                                                                size: 17,
                                                                              ),
                                                                              Center(
                                                                                child: Text(
                                                                                  " ${getDateTimeYMD(_searchResult[index]['refdate'])}",
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ),
                                                                              Padding(padding: EdgeInsets.all(1)),
                                                                              Text('at'),
                                                                              Padding(padding: EdgeInsets.all(1)),
                                                                              Text(getTime(_searchResult[index]['refdate']))
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
                                                                    EdgeInsets
                                                                        .all(
                                                                            5)),
                                                            Container(
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
                                                                  Container(
                                                                    // width:
                                                                    //     MediaQuery.of(context)
                                                                    //             .size
                                                                    //             .width *
                                                                    //         0.8,
                                                                    margin: EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                3),
                                                                    child: Text(
                                                                      _searchResult[index]['villageName'] != "null" &&
                                                                              _searchResult[index]['villageName'] !=
                                                                                  null &&
                                                                              _searchResult[index]['villageName'] !=
                                                                                  ""
                                                                          ? "${_searchResult[index]['villageName']}" +
                                                                              ", " +
                                                                              "${_searchResult[index]['communeName']}" +
                                                                              ", " +
                                                                              "${_searchResult[index]['districtName']}" +
                                                                              ", " +
                                                                              "${_searchResult[index]['provinceName']}"
                                                                          : "",
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
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 6),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    FontAwesomeIcons
                                                                        .marker,
                                                                    size: 17,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      // Text(AppLocalizations.of(
                                                                      //             context)!
                                                                      //         .status +
                                                                      //     ": "),
                                                                      Container(
                                                                        color:
                                                                            backgroundcolor,
                                                                        padding:
                                                                            EdgeInsets.all(5),
                                                                        margin: EdgeInsets.only(
                                                                            left:
                                                                                3),
                                                                        child:
                                                                            Text(
                                                                          "${status}",
                                                                          style: TextStyle(
                                                                              fontWeight: fontWeight700,
                                                                              color: Colors.white),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            3)),
                                                            Container(
                                                              alignment: Alignment
                                                                  .bottomRight,
                                                              child: Card(
                                                                color:
                                                                    logoDarkBlue,
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              6),
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                        FontAwesomeIcons
                                                                            .checkSquare,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            17,
                                                                      ),
                                                                      Container(
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            // Text(
                                                                            //   AppLocalizations.of(
                                                                            //           context)!
                                                                            //       .processing_in,
                                                                            //   style: TextStyle(
                                                                            //       color: Colors.white),
                                                                            // ),
                                                                            Text(
                                                                              _searchResult[index]['u1'] != null ? " ${_searchResult[index]['u1']}" : "",
                                                                              style: TextStyle(color: Colors.white),
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
                                            },
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Container(
                                        width: isWeb()
                                            ? widthView(context, 0.5)
                                            : isIphoneX(context)
                                                ? widthView(context, 0.35)
                                                : widthView(context, 0.25),
                                        color: Colors.white,
                                        child: Center(
                                          child: ListView.builder(
                                            itemCount: updateCustomer.length,
                                            itemBuilder:
                                                (BuildContext ctxt, int index) {
                                              var fetchStatus =
                                                  updateCustomer[index]
                                                      ['status'];
                                              var status = "";
                                              Color? backgroundcolor =
                                                  logolightGreen;
                                              if (fetchStatus == "Pedding") {
                                                status = AppLocalizations.of(
                                                        context)!
                                                    .pending;
                                                backgroundcolor =
                                                    Colors.lightBlueAccent;
                                              }
                                              if (fetchStatus ==
                                                  "FINAL APPROVE") {
                                                status = AppLocalizations.of(
                                                        context)!
                                                    .final_approve;
                                                backgroundcolor = Colors.yellow;
                                              }
                                              if (fetchStatus == "P") {
                                                status = AppLocalizations.of(
                                                        context)!
                                                    .processing;
                                                backgroundcolor = Colors.yellow;
                                              }
                                              if (fetchStatus == "A") {
                                                status = AppLocalizations.of(
                                                        context)!
                                                    .approved;
                                                backgroundcolor = Colors.green;
                                              }
                                              if (fetchStatus == "D") {
                                                status = AppLocalizations.of(
                                                        context)!
                                                    .reject;
                                                backgroundcolor = Colors.red;
                                              }
                                              if (fetchStatus ==
                                                  "Request Disbursement") {
                                                status = "Request Disbursement";
                                                backgroundcolor = logoDarkBlue;
                                              }

                                              return Container(
                                                // margin: EdgeInsets.all(1),
                                                child: Card(
                                                  elevation: 4,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: logolightGreen,
                                                        width: 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        DetailReportScreen(
                                                                          list:
                                                                              updateCustomer[index]!,
                                                                        )));
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            5)),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Icon(
                                                                  FontAwesomeIcons
                                                                      .userTag,
                                                                  color:
                                                                      logolightGreen,
                                                                  size: 30,
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
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Container(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.37,
                                                                            child:
                                                                                Text(
                                                                              "${updateCustomer[index]['cname']}",
                                                                              style: TextStyle(fontWeight: fontWeight700),
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                              // width: 100,
                                                                              child: Row(
                                                                            children: [
                                                                              Icon(
                                                                                FontAwesomeIcons.phoneSquareAlt,
                                                                                size: 17,
                                                                              ),
                                                                              Center(
                                                                                child: Text(
                                                                                  " ${updateCustomer[index]['phone']}",
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          )),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                        padding:
                                                                            EdgeInsets.all(3)),
                                                                    Container(
                                                                      // width:
                                                                      //     MediaQuery.of(context)
                                                                      //             .size
                                                                      //             .width *
                                                                      //         0.8,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Container(
                                                                            // width: MediaQuery.of(
                                                                            //             context)
                                                                            //         .size
                                                                            //         .width *
                                                                            //     0.37,
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                if (updateCustomer[index]['curcode'] == "101")
                                                                                  Icon(
                                                                                    FontAwesomeIcons.dollarSign,
                                                                                    size: 17,
                                                                                  ),
                                                                                if (updateCustomer[index]['curcode'] == "100")
                                                                                  Image.asset(
                                                                                    'assets/images/khmercurrency.png',
                                                                                    width: 15,
                                                                                  ),
                                                                                Container(
                                                                                  child: Text(
                                                                                    "${numFormat.format(updateCustomer[index]['lamount'])}",
                                                                                    style: TextStyle(fontWeight: fontWeight700),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                              // width: 230,
                                                                              child: Row(
                                                                            children: [
                                                                              Icon(
                                                                                FontAwesomeIcons.calendarAlt,
                                                                                size: 17,
                                                                              ),
                                                                              Center(
                                                                                child: Text(
                                                                                  " ${getDateTimeYMD(updateCustomer[index]['refdate'])}",
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ),
                                                                              Padding(padding: EdgeInsets.all(1)),
                                                                              Text('at'),
                                                                              Padding(padding: EdgeInsets.all(1)),
                                                                              Text(getTime(updateCustomer[index]['refdate']))
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
                                                                    EdgeInsets
                                                                        .all(
                                                                            5)),
                                                            Container(
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
                                                                  Container(
                                                                    // width:
                                                                    //     MediaQuery.of(context)
                                                                    //             .size
                                                                    //             .width *
                                                                    //         0.8,
                                                                    margin: EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                3),
                                                                    child: Text(
                                                                      updateCustomer[index]['villageName'] != "null" &&
                                                                              updateCustomer[index]['villageName'] !=
                                                                                  null &&
                                                                              updateCustomer[index]['villageName'] !=
                                                                                  ""
                                                                          ? "${updateCustomer[index]['villageName']}" +
                                                                              ", " +
                                                                              "${updateCustomer[index]['communeName']}" +
                                                                              ", " +
                                                                              "${updateCustomer[index]['districtName']}" +
                                                                              ", " +
                                                                              "${updateCustomer[index]['provinceName']}"
                                                                          : "",
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
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 6),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    FontAwesomeIcons
                                                                        .marker,
                                                                    size: 17,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      // Text(AppLocalizations.of(
                                                                      //             context)!
                                                                      //         .status +
                                                                      //     ": "),
                                                                      Container(
                                                                        color:
                                                                            backgroundcolor,
                                                                        padding:
                                                                            EdgeInsets.all(5),
                                                                        margin: EdgeInsets.only(
                                                                            left:
                                                                                3),
                                                                        child:
                                                                            Text(
                                                                          "${status}",
                                                                          style: TextStyle(
                                                                              fontWeight: fontWeight700,
                                                                              color: Colors.white),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            3)),
                                                            Container(
                                                              alignment: Alignment
                                                                  .bottomRight,
                                                              child: Card(
                                                                color:
                                                                    logoDarkBlue,
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              6),
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                        FontAwesomeIcons
                                                                            .checkSquare,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            17,
                                                                      ),
                                                                      Container(
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            // Text(
                                                                            //   AppLocalizations.of(
                                                                            //           context)!
                                                                            //       .processing_in,
                                                                            //   style: TextStyle(
                                                                            //       color: Colors.white),
                                                                            // ),
                                                                            Text(
                                                                              updateCustomer[index]['u1'] != null ? " ${updateCustomer[index]['u1']}" : "",
                                                                              style: TextStyle(color: Colors.white),
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
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Text(AppLocalizations.of(context)!.no_data),
                  ),
      ),
    );
  }
}
