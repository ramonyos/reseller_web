import 'dart:convert';

import 'package:ccf_reseller_web_app/screens/updateCustomer/requestDisbursement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ccf_reseller_web_app/providers/listCustomer/indext.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/screens/home/home.dart';
import 'package:ccf_reseller_web_app/screens/updateCustomer/detail.dart';
import 'package:ccf_reseller_web_app/screens/updateCustomer/finalApprove.dart';
import 'package:ccf_reseller_web_app/screens/updateCustomer/detail.dart';
// import 'package:ccf_reseller_web_app/screens/updateCustomer/requestDisbursement.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UpdateCustomer extends StatefulWidget {
  var isRefresh = false;
  UpdateCustomer(this.isRefresh);
  @override
  _UpdateCustomerState createState() => _UpdateCustomerState();
}

class _UpdateCustomerState extends State<UpdateCustomer> {
  //
  dynamic updateCustomer = [];
  @override
  void initState() {
    // TODO: implement initState
    if (mounted) {
      listCustomers(20, 1, "", "", "", "");
    }
    super.initState();
  }

  //
  bool _isLoading = false;
  int _pageSize = 20;
  int _pageNumber = 1;
  var sdate = "";
  var edate = "";
  var levels;
  dynamic userLogin;
  var finalApproveStatus = "";

  //
  Future listCustomers(_pageSizeParam, _pageNumberParam, sdateParam, edateParam,
      levelParam, statusParam) async {
    final storage = await SharedPreferences.getInstance();

    //
    setState(() {
      _isLoading = true;
    });
    var level = await storage.getString('level');
    var user_id = await storage.getString('user_id');

    try {
      await Provider.of<Customer>(context, listen: false)
          .getAllReferal(_pageSize, _pageNumber, sdate, edate, statusParam)
          .then((value) async => {
                setState(() {
                  _isLoading = false;
                  updateCustomer = value;
                  userLogin = int.parse(user_id!);
                  levels = int.parse(level!);
                }),
                if (value['status'] == "FINAL APPROVE")
                  {
                    setState(() {
                      finalApproveStatus = value['status'];
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

  //
  void onLoading() async {
    if (mounted)
      await new Future.delayed(new Duration(seconds: 3), () {
        widget.isRefresh = false;
      });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // widget.isRefresh
    new Future.delayed(new Duration(seconds: 0), () {});
    super.dispose();
  }

  Future loadMore(
      int _pageSizeParam, int _pageNumberParam, sdate, edate, status) async {
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
        "edate": "$edate",
        "status": "$status"
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final value = jsonDecode(await response.stream.bytesToString());
        setState(() {
          _isLoading = false;
          updateCustomer = value;
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

  var status = "";

  //
  _applyEndDrawer() async {
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

  TextEditingController controllerStartDate = TextEditingController();
  TextEditingController controllerEndDate = TextEditingController();
  //
  bool _isSelectedPedding = false;
  bool _isSelectedApproved = false;
  bool _isStatuSelectedReject = false;
  bool _isStatuSelectedReturn = false;
  bool _isStatuSelectedFinalApprove = false;
  //
  void _closeEndDrawer() {
    setState(() {
      controllerEndDate.text = '';
      controllerStartDate.text = '';
      _isLoading = true;
      status = "";
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

  _drawerList(context) {
    DateTime now = DateTime.now();
    return Drawer(
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
                      style: TextStyle(fontWeight: fontWeight800, fontSize: 15),
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
                          sdate = DateTime(now.year, now.month, 1) as String;
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
                    color: _isSelectedPedding == true ? logolightGreen : null,
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
                    color:
                        _isStatuSelectedReturn == true ? logolightGreen : null,
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
                    color: _isSelectedApproved == true ? logolightGreen : null,
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
                  color: _isStatuSelectedReject == true ? logolightGreen : null,
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
    );
  }

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
    if (widget.isRefresh == true) {
      onLoading();
    }
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
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          title: Text(
            AppLocalizations.of(context)!.update_customer,
            style: TextStyle(color: logolightGreen),
          ),
          elevation: 0,
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
        endDrawer: _drawerList(context),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
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
                                hintText: 'Search', border: InputBorder.none),
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
                  new Expanded(
                    flex: 1,
                    //search cutomer
                    child:
                        _searchResult.length != 0 || controller.text.isNotEmpty
                            ? new Center(
                                child: Container(
                                  width: isWeb()
                                      ? widthView(context, 0.5)
                                      : isIphoneX(context)
                                          ? widthView(context, 0.35)
                                          : null,
                                  margin: EdgeInsets.all(0),
                                  color: Colors.white,
                                  child: Center(
                                    child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: _searchResult.length,
                                      itemBuilder:
                                          (BuildContext ctxt, int index) {
                                        var fetchStatus =
                                            _searchResult[index]['status'];
                                        var status = "";
                                        bool _isReject = false;
                                        bool _isRequestDisbursement = false;
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
                                          _isReject = true;
                                        }
                                        if (fetchStatus ==
                                            "Request Disbursement") {
                                          _isRequestDisbursement = true;
                                          backgroundcolor = logoDarkBlue;
                                          status = AppLocalizations.of(context)!
                                              .request_Disbursement;
                                        }
                                        var assignedUserAcessFinal = false;
                                        var assignedUserAcess = false;

                                        if (_searchResult[index]['u5'] ==
                                            null) {
                                          assignedUserAcess = true;
                                        } else {
                                          if (_searchResult[index]['u5'] !=
                                              "") {
                                            var parseToInt = int.parse(
                                                _searchResult[index]['u5']);
                                            if (_searchResult[index]
                                                        ['status'] ==
                                                    "FINAL APPROVE" &&
                                                levels == 3 &&
                                                parseToInt == userLogin) {
                                              assignedUserAcessFinal = true;
                                            } else if (parseToInt ==
                                                userLogin) {
                                              assignedUserAcess = true;
                                            }
                                            if (levels == 4) {
                                              assignedUserAcess = true;
                                            }
                                          }
                                        }

                                        if (_searchResult[index]['status'] ==
                                            "A") {
                                          assignedUserAcessFinal = false;
                                          assignedUserAcess = false;
                                        }
                                        return Container(
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
                                              onTap: _isRequestDisbursement ==
                                                      true
                                                  ? () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  RequestDisbursement(
                                                                    list: _searchResult[
                                                                        index],
                                                                  )));
                                                    }
                                                  : _isReject == true
                                                      ? null
                                                      : assignedUserAcessFinal ==
                                                              true
                                                          ? () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          FinalApproveLoan(
                                                                            list:
                                                                                _searchResult[index],
                                                                          )));
                                                            }
                                                          : fetchStatus ==
                                                                      "Pedding" &&
                                                                  levels < 4
                                                              ? null
                                                              : assignedUserAcess ==
                                                                      true
                                                                  ? () {
                                                                      if (_searchResult != null &&
                                                                          _searchResult.length !=
                                                                              null &&
                                                                          _searchResult.length >
                                                                              0)
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) => DetailListCustomer(
                                                                                      list: _searchResult[index]!,
                                                                                    )));
                                                                    }
                                                                  : null,
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 0,
                                                                  top: 0,
                                                                  right: 0),
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
                                                                          AppLocalizations.of(context)!
                                                                              .name,
                                                                          style: TextStyle(
                                                                              fontWeight: fontWeight700,
                                                                              fontSize: fontSizeXs),
                                                                        ),
                                                                        Text(
                                                                          " : ${_searchResult[index]['cname']}",
                                                                          style:
                                                                              TextStyle(fontWeight: fontWeight700),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                FontAwesomeIcons.phone,
                                                                                size: 17,
                                                                              ),
                                                                              Padding(padding: EdgeInsets.only(left: 5)),
                                                                              Text(
                                                                                ": ${_searchResult[index]['phone']}",
                                                                                style: TextStyle(fontWeight: fontWeight700),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          width: isWeb()
                                                                              ? widthView(context, 0.1)
                                                                              : isIphoneX(context)
                                                                                  ? widthView(context, 0.30)
                                                                                  : null,
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
                                                                                  width: isWeb() ? 15 : 15,
                                                                                ),
                                                                              Text(
                                                                                ": ${numFormat.format(_searchResult[index]['lamount'])}",
                                                                                style: TextStyle(fontWeight: fontWeight700),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10,
                                                                  top: 5),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(AppLocalizations
                                                                      .of(context)!
                                                                  .register_date),
                                                              Container(
                                                                width: 150,
                                                                child: Text(
                                                                  ": ${getDateTimeYMD(_searchResult[index]['refdate'])}",
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
                                                                  left: 10,
                                                                  top: 5),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(AppLocalizations
                                                                      .of(context)!
                                                                  .address),
                                                              Container(
                                                                width: 150,
                                                                child: Text(
                                                                  _searchResult[index]['villageName'] != "null" &&
                                                                          _searchResult[index]['villageName'] !=
                                                                              null &&
                                                                          _searchResult[index]['villageName'] !=
                                                                              ""
                                                                      ? ": ${_searchResult[index]['villageName']}" +
                                                                          ", " +
                                                                          "${_searchResult[index]['communeName']}" +
                                                                          ", " +
                                                                          "${_searchResult[index]['districtName']}" +
                                                                          ", " +
                                                                          "${_searchResult[index]['provinceName']}"
                                                                      : "",
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
                                                                  left: 10,
                                                                  top: 5),
                                                          child: Row(
                                                            children: [
                                                              Text(AppLocalizations.of(
                                                                          context)!
                                                                      .status +
                                                                  ": "),
                                                              Container(
                                                                color:
                                                                    backgroundcolor,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                child: Text(
                                                                  "${status}",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        fontWeight700,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        if (_searchResult[index]
                                                                    ['u1'] !=
                                                                null &&
                                                            _searchResult[index]
                                                                    ['u1'] !=
                                                                "")
                                                          Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 10,
                                                                    top: 5),
                                                            child: Row(
                                                              children: [
                                                                Text(AppLocalizations.of(
                                                                            context)!
                                                                        .assigned +
                                                                    ": "),
                                                                Container(
                                                                  color:
                                                                      backgroundcolor,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5),
                                                                  child: Text(
                                                                    "${_searchResult[index]['u1'] != null ? _searchResult[index]['u1'] : ""}",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          fontWeight700,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                      ],
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      margin: EdgeInsets.all(0),
                                                      width: widthView(
                                                          context, 0.2),
                                                      // ignore: deprecated_member_use
                                                      child: RaisedButton(
                                                        padding:
                                                            EdgeInsets.all(0),
                                                        color: logoDarkBlue,
                                                        onPressed: _isReject ==
                                                                true
                                                            ? null
                                                            : assignedUserAcessFinal ==
                                                                    true
                                                                ? () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => FinalApproveLoan(
                                                                                  list: _searchResult[index],
                                                                                )));
                                                                  }
                                                                : fetchStatus ==
                                                                            "Pedding" &&
                                                                        levels <
                                                                            4
                                                                    ? null
                                                                    : assignedUserAcess ==
                                                                            true
                                                                        ? () {
                                                                            if (_searchResult != null &&
                                                                                _searchResult.length != null &&
                                                                                _searchResult.length > 0)
                                                                              Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                      builder: (context) => DetailListCustomer(
                                                                                            list: _searchResult[index]!,
                                                                                          )));
                                                                          }
                                                                        : null,
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .update,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
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
                                ),
                              )
                            :
                            // Default customer
                            Center(
                                child: Container(
                                  width: isWeb()
                                      ? widthView(context, 0.5)
                                      : isIphoneX(context)
                                          ? widthView(context, 0.35)
                                          : null,
                                  margin: EdgeInsets.all(0),
                                  color: Colors.white,
                                  child: Center(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: updateCustomer.length,
                                      itemBuilder:
                                          (BuildContext ctxt, int index) {
                                        var fetchStatus =
                                            updateCustomer[index]['status'];
                                        var status = "";
                                        bool _isReject = false;
                                        bool _isRequestDisbursement = false;
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
                                          _isReject = true;
                                        }
                                        if (fetchStatus ==
                                            "Request Disbursement") {
                                          _isRequestDisbursement = true;
                                          backgroundcolor = logoDarkBlue;
                                          status = AppLocalizations.of(context)!
                                              .request_Disbursement;
                                        }
                                        var assignedUserAcessFinal = false;
                                        var assignedUserAcess = false;

                                        if (updateCustomer[index]['u5'] ==
                                            null) {
                                          assignedUserAcess = true;
                                        } else {
                                          if (updateCustomer[index]['u5'] !=
                                              "") {
                                            var parseToInt = int.parse(
                                                updateCustomer[index]['u5']);
                                            if (updateCustomer[index]
                                                        ['status'] ==
                                                    "FINAL APPROVE" &&
                                                levels == 3 &&
                                                parseToInt == userLogin) {
                                              assignedUserAcessFinal = true;
                                            } else if (parseToInt ==
                                                userLogin) {
                                              assignedUserAcess = true;
                                            }
                                            if (levels == 4) {
                                              assignedUserAcess = true;
                                            }
                                          }
                                        }

                                        if (updateCustomer[index]['status'] ==
                                            "A") {
                                          assignedUserAcessFinal = false;
                                          assignedUserAcess = false;
                                        }
                                        return Container(
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
                                              onTap: _isRequestDisbursement ==
                                                      true
                                                  ? () {
                                                      // Navigator.push(
                                                      //     context,
                                                      //     MaterialPageRoute(
                                                      //         builder: (context) =>
                                                      //             RequestDisbursement(
                                                      //               list: updateCustomer[
                                                      //                   index],
                                                      //             )));
                                                    }
                                                  : _isReject == true
                                                      ? null
                                                      : assignedUserAcessFinal ==
                                                              true
                                                          ? () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          FinalApproveLoan(
                                                                            list:
                                                                                updateCustomer[index],
                                                                          )));
                                                            }
                                                          : fetchStatus ==
                                                                      "Pedding" &&
                                                                  levels < 4
                                                              ? null
                                                              : assignedUserAcess ==
                                                                      true
                                                                  ? () {
                                                                      if (updateCustomer != null &&
                                                                          updateCustomer.length !=
                                                                              null &&
                                                                          updateCustomer.length >
                                                                              0)
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) => DetailListCustomer(
                                                                                      list: updateCustomer[index]!,
                                                                                    )));
                                                                    }
                                                                  : null,
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 0,
                                                                  top: 0,
                                                                  right: 0),
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
                                                                          AppLocalizations.of(context)!
                                                                              .name,
                                                                          style: TextStyle(
                                                                              fontWeight: fontWeight700,
                                                                              fontSize: fontSizeXs),
                                                                        ),
                                                                        Text(
                                                                          " : ${updateCustomer[index]['cname']}",
                                                                          style:
                                                                              TextStyle(fontWeight: fontWeight700),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                FontAwesomeIcons.phone,
                                                                                size: 17,
                                                                              ),
                                                                              Padding(padding: EdgeInsets.only(left: 5)),
                                                                              Text(
                                                                                ": ${updateCustomer[index]['phone']}",
                                                                                style: TextStyle(fontWeight: fontWeight700),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          width: isWeb()
                                                                              ? widthView(context, 0.1)
                                                                              : isIphoneX(context)
                                                                                  ? widthView(context, 0.30)
                                                                                  : null,
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
                                                                                  width: isWeb() ? 15 : 15,
                                                                                ),
                                                                              Text(
                                                                                ": ${numFormat.format(updateCustomer[index]['lamount'])}",
                                                                                style: TextStyle(fontWeight: fontWeight700),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10,
                                                                  top: 5),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(AppLocalizations
                                                                      .of(context)!
                                                                  .register_date),
                                                              Container(
                                                                width: 150,
                                                                child: Text(
                                                                  ": ${getDateTimeYMD(updateCustomer[index]['refdate'])}",
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
                                                                  left: 10,
                                                                  top: 5),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(AppLocalizations
                                                                      .of(context)!
                                                                  .address),
                                                              Container(
                                                                width: 150,
                                                                child: Text(
                                                                  updateCustomer[index]['villageName'] != "null" &&
                                                                          updateCustomer[index]['villageName'] !=
                                                                              null &&
                                                                          updateCustomer[index]['villageName'] !=
                                                                              ""
                                                                      ? ": ${updateCustomer[index]['villageName']}" +
                                                                          ", " +
                                                                          "${updateCustomer[index]['communeName']}" +
                                                                          ", " +
                                                                          "${updateCustomer[index]['districtName']}" +
                                                                          ", " +
                                                                          "${updateCustomer[index]['provinceName']}"
                                                                      : "",
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
                                                                  left: 10,
                                                                  top: 5),
                                                          child: Row(
                                                            children: [
                                                              Text(AppLocalizations.of(
                                                                          context)!
                                                                      .status +
                                                                  ": "),
                                                              Container(
                                                                color:
                                                                    backgroundcolor,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                child: Text(
                                                                  "${status}",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        fontWeight700,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        if (updateCustomer[
                                                                        index]
                                                                    ['u1'] !=
                                                                null &&
                                                            updateCustomer[
                                                                        index]
                                                                    ['u1'] !=
                                                                "")
                                                          Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 10,
                                                                    top: 5),
                                                            child: Row(
                                                              children: [
                                                                Text(AppLocalizations.of(
                                                                            context)!
                                                                        .assigned +
                                                                    ": "),
                                                                Container(
                                                                  color:
                                                                      backgroundcolor,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5),
                                                                  child: Text(
                                                                    "${updateCustomer[index]['u1'] != null ? updateCustomer[index]['u1'] : ""}",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          fontWeight700,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                      ],
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      margin: EdgeInsets.all(0),
                                                      width: widthView(
                                                          context, 0.2),
                                                      // ignore: deprecated_member_use
                                                      child: RaisedButton(
                                                        padding:
                                                            EdgeInsets.all(0),
                                                        color: logoDarkBlue,
                                                        onPressed: _isReject ==
                                                                true
                                                            ? null
                                                            : assignedUserAcessFinal ==
                                                                    true
                                                                ? () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => FinalApproveLoan(
                                                                                  list: updateCustomer[index],
                                                                                )));
                                                                  }
                                                                : fetchStatus ==
                                                                            "Pedding" &&
                                                                        levels <
                                                                            4
                                                                    ? null
                                                                    : assignedUserAcess ==
                                                                            true
                                                                        ? () {
                                                                            if (updateCustomer != null &&
                                                                                updateCustomer.length != null &&
                                                                                updateCustomer.length > 0)
                                                                              Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                      builder: (context) => DetailListCustomer(
                                                                                            list: updateCustomer[index]!,
                                                                                          )));
                                                                          }
                                                                        : null,
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .update,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
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
                                ),
                              ),
                  ),
                ],
              ),
      ),
    );
  }
}
