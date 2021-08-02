import 'dart:convert';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/screens/verifyAccount/cardImage.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as Io;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DetailScreenVerifyDetail extends StatefulWidget {
  var list;
  DetailScreenVerifyDetail({this.list});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreenVerifyDetail> {
  GlobalKey<ScaffoldState> _scaffoldKeyVerifyDetail =
      new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    getDocumentById();
    getUser();
    super.initState();
  }

  bool _isLoading = false;
  var userDetail;

  getUser() async {
    try {
      //
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('GET',
          Uri.parse(baseURLInternal + 'CcfreferalRes/' + widget.list['uid']));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var parsed = jsonDecode(await response.stream.bytesToString());
        setState(() {
          userDetail = parsed[0]['ccfreferalRe'];
        });
      } else {
        print(response.reasonPhrase);
      }
      //
    } catch (error) {
      logger().e("error: $error");
    }
  }

  dynamic? _image1;
  dynamic? _image2;
  dynamic? _image3;
  dynamic image1;
  dynamic image2;
  dynamic image3;
  String? path1;
  String? path2;
  String? path3;

  Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  Future getDocumentById() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var request = http.Request('GET',
          Uri.parse(baseURLInternal + 'Document/ByLoan/' + widget.list['uid']));
      http.StreamedResponse response = await request.send();
      final respStr = await response.stream.bytesToString();
      var json = jsonDecode(respStr);
      if (response.statusCode == 200) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          for (var item in json) {
            switch (item['type']) {
              case '101':
                var uri = item['filepath'];
                var _bytes = base64.decode(uri.split(',').last);
                setState(() {
                  _image1 = _bytes;
                });
                image1 = Image.memory(
                  _bytes,
                  fit: BoxFit.fill,
                );

                // final directory = await getApplicationDocumentsDirectory();
                // var file = Io.File('${directory.path}/101.png');
                // file.writeAsBytesSync(List.from(_bytes));

                // var file = base64Decode(item['filepath']);
                // logger().e("file: ${file}");

                break;
              case '102':
                var uri = item['filepath'];
                var _bytes = base64.decode(uri.split(',').last);
                setState(() {
                  _image2 = _bytes;
                });
                image2 = Image.memory(
                  _bytes,
                  fit: BoxFit.fill,
                );

                break;
              case '103':
                var uri = item['filepath'];
                var _bytes = base64.decode(uri.split(',').last);
                setState(() {
                  _image3 = _bytes;
                });
                image3 = Image.memory(
                  _bytes,
                  fit: BoxFit.fill,
                );

                break;
            }
          }
          setState(() {
            _isLoading = false;
          });
        }
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      logger().e("error: $error}");
    }
  }

  Future<dynamic> updateUserProfile(status) async {
    setState(() {
      _isLoading = true;
    });
    try {
      //
      var headers = {'Content-Type': 'application/json'};

      var request = http.Request(
          'PUT',
          Uri.parse(baseURLInternal +
              'InterUser/verifyaccount/' +
              widget.list['uid']));
      request.body = json.encode({'verifystatus': '${status}'});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final value = jsonDecode(await response.stream.bytesToString());
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _isLoading = false;
        });
        showInSnackBar(AppLocalizations.of(context)!.successfully,
            logolightGreen, _scaffoldKeyVerifyDetail);
        Navigator.of(context).pop();
      } else {
        setState(() {
          _isLoading = false;
        });
        showInSnackBar(AppLocalizations.of(context)!.error, Colors.red,
            _scaffoldKeyVerifyDetail);
      }
    } catch (error) {
      logger().e('error: ${error}');

      setState(() {
        _isLoading = false;
      });
      showInSnackBar(AppLocalizations.of(context)!.error, Colors.red,
          _scaffoldKeyVerifyDetail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyVerifyDetail,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.verify_account_detail,
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 20),
              child: Center(
                child: Container(
                  width: isWeb()
                      ? widthView(context, 0.5)
                      : isIphoneX(context)
                          ? widthView(context, 0.9)
                          : widthView(context, 0.8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(AppLocalizations.of(context)!.profile,
                            style: TextStyle(
                                color: Colors.black, fontSize: fontSizeXs)),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        child: Card(
                          child: Container(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.user,
                                      size: 18,
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(right: 10)),
                                    Text("${userDetail['refname']}"),
                                    Padding(
                                        padding: EdgeInsets.only(right: 10)),
                                    Text("${userDetail['refphone']}"),
                                    Padding(
                                        padding: EdgeInsets.only(right: 10)),
                                    Text("${userDetail['dob']}"),
                                    Padding(
                                        padding: EdgeInsets.only(right: 10)),
                                    Text("${userDetail['gender']}"),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(top: 10)),
                                Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.list,
                                      size: 18,
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(right: 10)),
                                    Text("${userDetail['typeaccountbank']}"),
                                    Padding(
                                        padding: EdgeInsets.only(right: 10)),
                                    Text("${userDetail['typeaccountnumber']}"),
                                    Padding(
                                        padding: EdgeInsets.only(right: 10)),
                                    Text("${userDetail['idtype']}"),
                                    Padding(
                                        padding: EdgeInsets.only(right: 10)),
                                    Text("${userDetail['idnumber']}"),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(top: 10)),
                                Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.clock,
                                      size: 18,
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(right: 10)),
                                    Text(
                                      getDateTimeYMD(userDetail['regdate']),
                                    ),
                                    Padding(padding: EdgeInsets.all(1)),
                                    Text(
                                      AppLocalizations.of(context)!.at,
                                    ),
                                    Text(
                                      getTime(userDetail['regdate']),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(AppLocalizations.of(context)!.image,
                            style: TextStyle(
                                color: Colors.black, fontSize: fontSizeXs)),
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      Center(
                        child: Container(
                          child: CardImageVerifyAccount(
                              borderColor: logolightGreen,
                              text: AppLocalizations.of(context)!
                                  .upload_ID_card_with_selfie,
                              onTaps: null,
                              isImage: image1,
                              image: _image1,
                              onClearImage: null),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      Center(
                        child: Container(
                          child: CardImageVerifyAccount(
                              borderColor: logolightGreen,
                              text: AppLocalizations.of(context)!
                                  .upload_ID_card_with_selfie,
                              onTaps: null,
                              isImage: image2,
                              image: _image2,
                              onClearImage: null),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      Center(
                        child: Container(
                          child: CardImageVerifyAccount(
                              borderColor: logolightGreen,
                              text: AppLocalizations.of(context)!
                                  .upload_ID_card_with_selfie,
                              onTaps: null,
                              isImage: image3,
                              image: _image3,
                              onClearImage: null),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(""),
                            // ignore: deprecated_member_use
                            RaisedButton(
                              onPressed: () {
                                updateUserProfile("Reject");
                              },
                              child: Container(
                                width:
                                    isWeb() ? widthView(context, 0.08) : null,
                                height:
                                    isWeb() ? widthView(context, 0.03) : null,
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.reject,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              color: Colors.red,
                            ),
                            // ignore: deprecated_member_use
                            RaisedButton(
                              onPressed: () {
                                updateUserProfile("Return");
                              },
                              child: Container(
                                width:
                                    isWeb() ? widthView(context, 0.08) : null,
                                height:
                                    isWeb() ? widthView(context, 0.03) : null,
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.returns,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              color: logoDarkBlue,
                            ),
                            // ignore: deprecated_member_use
                            RaisedButton(
                              onPressed: () {
                                updateUserProfile("Verified");
                              },
                              child: Container(
                                width:
                                    isWeb() ? widthView(context, 0.08) : null,
                                height:
                                    isWeb() ? widthView(context, 0.03) : null,
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.approve,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              color: logolightGreen,
                            ),
                            Text(""),
                          ],
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 10)),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
