import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ccf_reseller_web_app/components/textInputComponent.dart';
import 'package:ccf_reseller_web_app/providers/branch/index.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/screens/register/dropDownRegister.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:ccf_reseller_web_app/widgets/dropDown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:http/http.dart' as http;

class CreateAccountInternal extends StatefulWidget {
  const CreateAccountInternal({Key? key}) : super(key: key);

  @override
  _CreateAccountInternalState createState() => _CreateAccountInternalState();
}

class _CreateAccountInternalState extends State<CreateAccountInternal> {
  final GlobalKey<ScaffoldState> _scaffoldKeyCreateAccountInternal =
      new GlobalKey<ScaffoldState>();

  TextEditingController contorllerNameRegister = new TextEditingController();
  TextEditingController contorllerStaffID = new TextEditingController();

  TextEditingController contorllerPhoneNumberRegister =
      new TextEditingController();

  final positionDummy = [
    "Digital",
    "BM",
    "BTL",
    "CO",
    "SCO",
  ];
  String selectedValuePosition = "";
  int levelUser = 0;
  bool validatePosition = false;
  bool validateBrach = false;

  UnfocusDisposition disposition = UnfocusDisposition.scope;
  var _isDropDownSelectedBranch = "";
  var listBranch;
  bool isDisableDropDownBranch = true;
  bool _isLoading = false;

  Future createUserInternal() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse(baseURLInternal + 'InterUser'));
      request.body = json.encode({
        "uname": "${contorllerNameRegister.text}",
        "uotpcode": "",
        "pwd": "123",
        "level": levelUser,
        "utype": "$selectedValuePosition",
        "staffposition": "$selectedValuePosition",
        "staffid": "${contorllerStaffID.text}",
        "brcode": "${_dropDownValueBranchSubtring}",
        "email": "",
        "phone": "${contorllerPhoneNumberRegister.text}"
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var parsed = jsonDecode(await response.stream.bytesToString());
        setState(() {
          _isLoading = false;
          contorllerStaffID.clear();
          contorllerNameRegister.clear();
          contorllerPhoneNumberRegister.clear();
          selectedValuePosition = "";
          _isDropDownSelectedBranch = "";
        });
      } else {
        logger().e(await response.stream.bytesToString());
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      logger().e("error: $error");
    }
  }

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

  String _dropDownValueBranchSubtring = "";

  void onChangeBranch(value) {
    var subString = value!.substring(0, 4);
    setState(() {
      _dropDownValueBranchSubtring = subString;
      _isDropDownSelectedBranch = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyCreateAccountInternal,
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.create_account_internal,
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
                    ? widthView(context, 0.7)
                    : isIphoneX(context)
                        ? widthView(context, 1)
                        : null,
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.all(10)),
                    TextInputComponent(
                      controller: contorllerStaffID,
                      inputFormatters: [
                        // ignore: deprecated_member_use
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      icons: FontAwesomeIcons.idBadge,
                      hintText: AppLocalizations.of(context)!.staff_id + "*",
                      labelText: "0401",
                    ),
                    Padding(padding: EdgeInsets.all(10)),
                    TextInputComponent(
                      controller: contorllerNameRegister,
                      inputFormatters: [
                        // ignore: deprecated_member_use
                        FilteringTextInputFormatter.deny(
                            RegExp("[0-9/\\\\|!.]")),
                      ],
                      icons: Icons.person,
                      hintText: AppLocalizations.of(context)!.staff_name + "*",
                      labelText: "Sok Ret",
                    ),
                    Padding(padding: EdgeInsets.all(10)),
                    TextInputComponent(
                        controller: contorllerPhoneNumberRegister,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        maxleng: 10,
                        icons: Icons.phone,
                        hintText:
                            AppLocalizations.of(context)!.phone_number + "*",
                        labelText: "093245401"),
                    Padding(padding: EdgeInsets.all(10)),
                    //Position
                    DropDownRegister(
                      selectedValue: selectedValuePosition,
                      icons: Icons.location_on,
                      validate: validatePosition
                          ? RoundedRectangleBorder(
                              side: BorderSide(color: logolightGreen, width: 1),
                              borderRadius: BorderRadius.circular(5),
                            )
                          : RoundedRectangleBorder(
                              side: BorderSide(color: logolightGreen, width: 1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                      onInSidePress: () async {
                        FocusScope.of(context)
                            .unfocus(disposition: disposition);
                        await SelectDialog.showModal<String>(
                          context,
                          label: AppLocalizations.of(context)!.search,
                          items: List.generate(positionDummy.length,
                              (index) => "${positionDummy[index]}"),
                          onChange: (value) async {
                            if (mounted) {
                              FocusScope.of(context)
                                  .unfocus(disposition: disposition);
                              setState(() {
                                selectedValuePosition = value;
                                if (value == "SCO" || value == "CO") {
                                  levelUser = 1;
                                }
                                if (value == "BM") {
                                  levelUser = 3;
                                }
                                if (value == "BTL") {
                                  levelUser = 2;
                                }
                                if (value == "Digital") {
                                  levelUser = 4;
                                }
                              });
                            }
                          },
                        );
                      },
                      texts: selectedValuePosition != ""
                          ? selectedValuePosition
                          : AppLocalizations.of(context)!.positions,
                      title: selectedValuePosition != ""
                          ? selectedValuePosition
                          : AppLocalizations.of(context)!.province,
                      subTitle: AppLocalizations.of(context)!.province,
                      clear: true,
                      readOnlys: true,
                      iconsClose: Icon(
                        Icons.close,
                        color: logolightGreen,
                      ),
                      onPressed: () {
                        if (mounted) {
                          FocusScope.of(context)
                              .unfocus(disposition: disposition);
                          setState(() {
                            selectedValuePosition =
                                AppLocalizations.of(context)!.positions;
                          });
                        }
                      },
                      styleTexts: selectedValuePosition != ''
                          ? TextStyle(
                              fontFamily: fontFamily,
                              fontSize: fontSizeXs,
                              color: Colors.black87,
                              fontWeight: fontWeight500)
                          : TextStyle(
                              fontFamily: fontFamily,
                              fontSize: fontSizeXs,
                              color: Colors.grey.shade500,
                              fontWeight: fontWeight500),
                      autofocus: false,
                    ),
                    Padding(padding: EdgeInsets.all(10)),
                    //
                    //select branch
                    DropDownCustomerRegister(
                      enabled: true,
                      selectedValue: _isDropDownSelectedBranch,
                      validate: validateBrach
                          ? RoundedRectangleBorder(
                              side: BorderSide(color: Colors.red, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            )
                          : RoundedRectangleBorder(
                              side: BorderSide(color: logolightGreen, width: 1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                      clear: true,
                      readOnlys: true,
                      autofocus: false,
                      onInSidePress: () async {
                        FocusScope.of(context)
                            .unfocus(disposition: disposition);
                        await fetchBranch(context);
                        await SelectDialog.showModal<String>(
                          context,
                          label: AppLocalizations.of(context)!.search,
                          items: List.generate(
                              listBranch.length,
                              (index) =>
                                  "${listBranch[index]['brcode'] + " " + listBranch[index]['bname']}"),
                          onChange: onChangeBranch,
                        );
                      },
                      iconsClose: Icon(
                        Icons.close,
                        color: logolightGreen,
                      ),
                      onPressed: () => setState(() {
                        _isDropDownSelectedBranch = 'Branch(*)';
                      }),
                      validateForm: "Branch(*)",
                      styleTexts: _isDropDownSelectedBranch != ''
                          ? TextStyle(
                              fontFamily: fontFamily,
                              fontSize: fontSizeXs,
                              color: Colors.black87,
                              fontWeight: fontWeight500)
                          : TextStyle(
                              fontFamily: fontFamily,
                              fontSize: fontSizeXs,
                              color: Colors.grey.shade500,
                              fontWeight: fontWeight500),
                      texts: _isDropDownSelectedBranch != ''
                          ? _isDropDownSelectedBranch
                          : "Branch" + "*",
                      title: 'Branch' + "*",
                      subTitle: 'Branch' + "*",
                    ),
                    Padding(padding: EdgeInsets.all(10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RaisedButton(
                          onPressed: () {
                            contorllerStaffID.clear();
                            contorllerNameRegister.clear();
                            contorllerPhoneNumberRegister.clear();
                            selectedValuePosition = "";
                            _isDropDownSelectedBranch = "";
                          },
                          color: Colors.grey,
                          child: Container(
                            width: isWeb()
                                ? widthView(context, 0.2)
                                : isIphoneX(context)
                                    ? widthView(context, 0.35)
                                    : widthView(context, 0.35),
                            height: isWeb() ? widthView(context, 0.03) : null,
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.clean,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        // ignore: deprecated_member_use
                        RaisedButton(
                          onPressed: () {
                            if (contorllerStaffID.text.isEmpty) {
                              showInSnackBar(
                                  AppLocalizations.of(context)!.staff_id,
                                  Colors.red,
                                  _scaffoldKeyCreateAccountInternal);
                            }
                            if (contorllerNameRegister.text.isEmpty) {
                              showInSnackBar(
                                  AppLocalizations.of(context)!.staff_name,
                                  Colors.red,
                                  _scaffoldKeyCreateAccountInternal);
                            }
                            if (contorllerPhoneNumberRegister.text.isEmpty) {
                              showInSnackBar(
                                  AppLocalizations.of(context)!.phone_number,
                                  Colors.red,
                                  _scaffoldKeyCreateAccountInternal);
                            }
                            if (selectedValuePosition.isEmpty) {
                              showInSnackBar(
                                  AppLocalizations.of(context)!.positions,
                                  Colors.red,
                                  _scaffoldKeyCreateAccountInternal);
                            }
                            if (_isDropDownSelectedBranch.isEmpty) {
                              showInSnackBar(
                                  AppLocalizations.of(context)!.branch,
                                  Colors.red,
                                  _scaffoldKeyCreateAccountInternal);
                            }
                            if (contorllerStaffID.text.isNotEmpty &&
                                contorllerNameRegister.text.isNotEmpty &&
                                contorllerPhoneNumberRegister.text.isNotEmpty &&
                                selectedValuePosition.isNotEmpty &&
                                _isDropDownSelectedBranch.isNotEmpty)
                              AwesomeDialog(
                                context: context,
                                width: isWeb()
                                    ? widthView(context, 0.3)
                                    : isIphoneX(context)
                                        ? widthView(context, 0.35)
                                        : widthView(context, 0.35),
                                headerAnimationLoop: false,
                                dialogType: DialogType.SUCCES,
                                title:
                                    AppLocalizations.of(context)!.information,
                                desc: AppLocalizations.of(context)!
                                    .do_you_want_to_create_account_internal,
                                btnOkOnPress: () {
                                  // onAssignCoToApprove();
                                  createUserInternal();
                                },
                                btnCancelText: AppLocalizations.of(context)!.no,
                                btnCancelOnPress: () {},
                                btnCancelIcon: Icons.close,
                                btnOkIcon: Icons.check_circle,
                                btnOkColor: logolightGreen,
                                btnOkText: AppLocalizations.of(context)!.yes,
                              )..show();
                          },
                          color: logoDarkBlue,
                          child: Container(
                            width: isWeb()
                                ? widthView(context, 0.2)
                                : isIphoneX(context)
                                    ? widthView(context, 0.35)
                                    : widthView(context, 0.35),
                            height: isWeb() ? widthView(context, 0.03) : null,
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.create_account,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
