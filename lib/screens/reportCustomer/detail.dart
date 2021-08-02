import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ccf_reseller_web_app/providers/assignUser/index.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';

class DetailReportScreen extends StatefulWidget {
  var list;
  DetailReportScreen({this.list});
  @override
  _DetailReportScreenState createState() => _DetailReportScreenState();
}

class _DetailReportScreenState extends State<DetailReportScreen> {
  @override
  void initState() {
    // TODO: implement initState
    fetchDatail();
    super.initState();
  }

  bool _isLoading = false;
  var detailCustomer;

  fetchDatail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<AssignUserProvider>(context, listen: false)
          .getDetail(widget.list['cid'])
          .then((value) async => {
                setState(() {
                  _isLoading = false;
                  detailCustomer = value;
                }),
              })
          .catchError((onError) {
        setState(() {
          _isLoading = false;
        });
      });
    } catch (error) {}
  }

  double padding = 3.0;
  @override
  Widget build(BuildContext context) {
    var fetchStatus = widget.list['status'];
    var status = "";
    Color? backgroundcolor = logolightGreen;
    if (fetchStatus == "Pedding") {
      status = AppLocalizations.of(context)!.pending;
      backgroundcolor = Colors.lightBlueAccent;
    }
    if (fetchStatus == "FINAL APPROVE") {
      status = AppLocalizations.of(context)!.final_approve;
      backgroundcolor = Colors.yellow;
    }
    if (fetchStatus == "P") {
      status = AppLocalizations.of(context)!.processing;
      backgroundcolor = Colors.yellow;
    }
    if (fetchStatus == "A") {
      status = AppLocalizations.of(context)!.approved;
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: logolightGreen,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.report_detail,
          style: TextStyle(color: logolightGreen),
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
                padding: EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.list['cname'],
                              style: mainTitleBlack,
                            ),
                            Padding(padding: EdgeInsets.all(padding)),
                            Text(
                              widget.list['phone'],
                              style: mainTitleBlack,
                            ),
                            Padding(padding: EdgeInsets.all(padding)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.list['curcode'] == "101")
                                  Icon(
                                    FontAwesomeIcons.dollarSign,
                                    size: 17,
                                  ),
                                if (widget.list['curcode'] == "100")
                                  Image.asset(
                                    'assets/images/khmercurrency.png',
                                    width: 15,
                                  ),
                                Text(
                                  numFormat.format(widget.list['lamount']),
                                  style: mainTitleBlack,
                                ),
                              ],
                            ),
                            Padding(padding: EdgeInsets.all(padding)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  getDateTimeYMD(widget.list['refdate']),
                                  style: mainTitleBlack,
                                ),
                                Padding(padding: EdgeInsets.all(1)),
                                Text(
                                  AppLocalizations.of(context)!.at,
                                  style: mainTitleBlack,
                                ),
                                Text(
                                  getTime(widget.list['refdate']),
                                  style: mainTitleBlack,
                                ),
                              ],
                            ),
                            Padding(padding: EdgeInsets.all(padding)),
                            Container(
                              child: Text(
                                widget.list['villageName'] != "null" &&
                                        widget.list['villageName'] != null &&
                                        widget.list['villageName'] != ""
                                    ? "${widget.list['villageName']}" +
                                        ", " +
                                        "${widget.list['communeName']}" +
                                        ", " +
                                        "${widget.list['districtName']}" +
                                        ", " +
                                        "${widget.list['provinceName']}"
                                    : "",
                                style: mainTitleBlack,
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(padding)),
                            Container(
                                color: backgroundcolor,
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  status,
                                  style: TextStyle(color: Colors.white),
                                )),
                          ],
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(5)),
                    Expanded(
                        flex: 0,
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            AppLocalizations.of(context)!.summary_report,
                            style: TextStyle(color: Colors.grey.shade800),
                          ),
                        )),
                    Padding(padding: EdgeInsets.all(5)),
                    Expanded(
                        child: ListView.builder(
                            itemCount: detailCustomer.length,
                            itemBuilder: (BuildContext ctxt, int index) {
                              var fetchStatus = detailCustomer[index]['status'];
                              var statuses = "";
                              Color? backgroundcolor = logolightGreen;
                              if (fetchStatus == "Pedding") {
                                statuses =
                                    AppLocalizations.of(context)!.pending;
                                backgroundcolor = Colors.lightBlueAccent;
                              }
                              if (fetchStatus == "FINAL APPROVE") {
                                statuses =
                                    AppLocalizations.of(context)!.final_approve;
                                backgroundcolor = Colors.yellow;
                              }
                              if (fetchStatus == "ASSIGN") {
                                statuses =
                                    AppLocalizations.of(context)!.processing;
                                backgroundcolor = Colors.yellow;
                              }
                              if (fetchStatus == "P") {
                                statuses =
                                    AppLocalizations.of(context)!.processing;
                                backgroundcolor = Colors.yellow;
                              }
                              if (fetchStatus == "A") {
                                statuses =
                                    AppLocalizations.of(context)!.approved;
                                backgroundcolor = Colors.green;
                              }
                              if (fetchStatus == "D") {
                                statuses = AppLocalizations.of(context)!.reject;
                                backgroundcolor = Colors.red;
                              }
                              if (fetchStatus == "Request Disbursement") {
                                status = "Request Disbursement";
                                backgroundcolor = logoDarkBlue;
                              }
                              return Card(
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.calendarAlt,
                                            size: 17,
                                          ),
                                          Padding(padding: EdgeInsets.all(3)),
                                          Text(getDateTimeYMD(
                                              detailCustomer[index]['date'])),
                                          Padding(padding: EdgeInsets.all(1)),
                                          Text(
                                            " at ",
                                          ),
                                          Text(
                                            getTime(
                                                detailCustomer[index]['date']),
                                          ),
                                        ],
                                      ),
                                      Padding(padding: EdgeInsets.all(3)),
                                      Row(
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.peopleArrows,
                                            size: 17,
                                          ),
                                          Padding(padding: EdgeInsets.all(3)),
                                          Row(
                                            children: [
                                              Text(detailCustomer[index]
                                                  ['ccfuserReFu']['uname']),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 3, right: 3),
                                                child: Icon(
                                                  FontAwesomeIcons
                                                      .longArrowAltRight,
                                                  size: 17,
                                                ),
                                              ),
                                              Text(detailCustomer[index]
                                                  ['ccfuserReTu']['uname']),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Padding(padding: EdgeInsets.all(3)),
                                      Row(
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.marker,
                                            size: 17,
                                          ),
                                          Padding(padding: EdgeInsets.all(3)),
                                          Text(statuses),
                                        ],
                                      ),
                                      Padding(padding: EdgeInsets.all(3)),
                                      if (detailCustomer[index]['remark'] !=
                                          null)
                                        Row(
                                          children: [
                                            // Text(AppLocalizations.of(context)!
                                            //         .remark +
                                            //     " : "),
                                            Icon(
                                              FontAwesomeIcons.bookmark,
                                              size: 17,
                                            ),
                                            Padding(padding: EdgeInsets.all(3)),
                                            Text(detailCustomer[index]
                                                ['remark']),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            })),
                  ],
                ),
              ),
            ),
    );
  }
}
