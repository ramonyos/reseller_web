import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ccf_reseller_web_app/providers/verifyAccount/index.dart';
import 'package:ccf_reseller_web_app/screens/verifyAccount/detail.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';

class VerifyScreen extends StatefulWidget {
  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  @override
  void initState() {
    // TODO: implement initState
    fetchVerifyAccount();
    super.initState();
  }

  int _pageSize = 20;
  int _pageNumber = 1;
  String _sdate = "";
  String _edate = "";
  String _status = "";
  bool _isLoading = false;

  dynamic listAccountUser;
  fetchVerifyAccount() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<VerifyProvider>(context, listen: false)
          .fetchAllVerifyAccount(_pageSize, _pageNumber, _sdate, _edate, "R")
          .then((value) {
        setState(() {
          listAccountUser = value;
          _isLoading = false;
        });
      }).onError((error, stackTrace) {
        setState(() {
          _isLoading = false;
        });
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  GlobalKey<ScaffoldState> _scaffoldKeyVerify = new GlobalKey<ScaffoldState>();

  TextEditingController controllerStartDate = TextEditingController();
  TextEditingController controllerEndDate = TextEditingController();

  var sdate = "";
  var edate = "";
  var status = "";

  bool _isSelectedPedding = false;
  bool _isSelectedApproved = false;
  bool _isStatuSelectedReject = false;
  bool _isStatuSelectedReturn = false;
  bool _isStatuSelectedFinalApprove = false;

  void _closeEndDrawer() async {
    setState(() {
      controllerEndDate.text = '';
      controllerStartDate.text = '';
      _isLoading = true;
    });
    await Provider.of<VerifyProvider>(context, listen: false)
        .fetchAllVerifyAccount(20, 1, "", "", "")
        .then((value) => {
              setState(() {
                listAccountUser = value;
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

  _applyEndDrawer() async {
    DateTime now = DateTime.now();
    setState(() {
      _isLoading = true;
    });
    var startDate = sdate != null ? sdate : "";
    var endDate = edate != null ? edate : "";

    await Provider.of<VerifyProvider>(context, listen: false)
        .fetchAllVerifyAccount(20, 1, startDate, endDate, status)
        .then((value) => {
              setState(() {
                listAccountUser = value;
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

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    return Scaffold(
        key: _scaffoldKeyVerify,
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
            AppLocalizations.of(context)!.verify_account,
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
                          status = 'R';
                        });
                      },
                      child: Container(
                        color:
                            _isSelectedPedding == true ? logolightGreen : null,
                        width: MediaQuery.of(context).size.width * 1,
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.request,
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
                          status = 'Return';
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
                            AppLocalizations.of(context)!.returns,
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
                          status = 'Verified';
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
                            AppLocalizations.of(context)!.verified_account,
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
                          status = 'Reject';
                        });
                      },
                      child: Container(
                        color:
                            _isSelectedApproved == true ? logolightGreen : null,
                        width: MediaQuery.of(context).size.width * 1,
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.reject,
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
                            status = 'Please verify account';
                          });
                        },
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.pending,
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
            : Center(
                child: Container(
                  width: isWeb()
                      ? widthView(context, 0.5)
                      : isIphoneX(context)
                          ? widthView(context, 0.35)
                          : null,
                  child: ListView.builder(
                      itemCount: listAccountUser.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        var listStatus = listAccountUser[index]['verifystatus'];
                        String status = "";
                        if (listStatus == "R") {
                          status = "Request";
                        } else {
                          status = listAccountUser[index]['verifystatus'] ?? "";
                        }
                        return Card(
                            elevation: 5,
                            child: InkWell(
                              onTap: () {
                                // DetailScreenVerifyDetail
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DetailScreenVerifyDetail(
                                              list: listAccountUser[index],
                                            )));
                              },
                              child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(listAccountUser[index]
                                                      ['uname'] ??
                                                  ""),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 10)),
                                              Text(listAccountUser[index]
                                                      ['gender'] ??
                                                  ""),
                                              Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 5))
                                            ],
                                          ),
                                          Card(
                                            elevation: 5,
                                            margin: EdgeInsets.all(0),
                                            child: Container(
                                                padding: EdgeInsets.all(5),
                                                color: logolightGreen,
                                                child: Text(
                                                  status,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(listAccountUser[index]['dob'] ??
                                              ""),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 5)),
                                          Text(' - '),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 5)),
                                          Text(listAccountUser[index]
                                                  ['phone'] ??
                                              ""),
                                        ],
                                      ),
                                      Padding(padding: EdgeInsets.only(top: 1)),
                                      Text(listAccountUser[index]['idtype'] ??
                                          ""),
                                      Padding(padding: EdgeInsets.only(top: 1)),
                                      Text(listAccountUser[index]['idnumber'] ??
                                          ""),
                                    ],
                                  )),
                            ));
                      }),
                ),
              ));
  }
}
