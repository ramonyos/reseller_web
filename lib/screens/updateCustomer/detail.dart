import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:ccf_reseller_web_app/components/groupFormBuilder.dart';
import 'package:ccf_reseller_web_app/components/textInputComponent.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ccf_reseller_web_app/providers/assignUser/index.dart';
import 'package:ccf_reseller_web_app/providers/branch/index.dart';
import 'package:ccf_reseller_web_app/providers/customerApprove/index.dart';
import 'package:ccf_reseller_web_app/providers/listCustomer/indext.dart';
import 'package:ccf_reseller_web_app/providers/login/index.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/screens/updateCustomer/index.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:ccf_reseller_web_app/widgets/dropDown.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DetailListCustomer extends StatefulWidget {
  var list;
  DetailListCustomer({this.list});
  @override
  _DetailListCustomerState createState() => _DetailListCustomerState();
}

class _DetailListCustomerState extends State<DetailListCustomer> {
  var _isDropDownSelectedBranch = "";
  String _dropDownValueAssignUserFullName = "";

  // @override
  // void didChangeDependencies() {
  //   // fetchBranch();
  //   super.didChangeDependencies();
  // }

  @override
  void initState() {
    fetchListCustomer(widget.list);
    fetchBranch();
    fetchAddress();
    getCurrencies();
    super.initState();
  }

  String storeBM = "";
  String storeBTL = "";
  String storeCO = "";
  String fetchUidLoan = "";
  bool enabledSubmit = false;
  fetchListCustomer(list) async {
    final storage = await SharedPreferences.getInstance();

    levels = await storage.getString('level');
    // getReferalById
    setState(() {
      _isLoading = true;
    });
    await Provider.of<Customer>(context, listen: false)
        .getReferalById(list['id'])
        .then((valuse) async {
      setState(() {
        _isLoading = false;
      });
      if (valuse['province'] != "null") {
        setState(() {
          provinceReadOnlys = false;
          validateVillage = false;
          districtreadOnlys = false;
          communereadOnlys = false;
          villagereadOnlys = false;
        });
      } else {
        setState(() {
          provinceReadOnlys = true;
          enabledAddress = true;
        });
      }

      if (valuse['curcode'] == null) {
        setState(() {
          enabledCurrency = true;
        });
      }
      if (valuse['br'] == "") {
        setState(() {
          enabledBranch = true;
          isDisableDropDownBranch = true;
        });
      } else {
        setState(() {
          isDisableDropDownBranch = false;
        });
      }
      if (valuse['idtype'] != null && valuse['idtype'] != "") {
        setState(() {
          enabledIdType = false;
        });
      }
      if (int.parse(levels) == 0) {
        setState(() {
          enabledIdType = true;
        });
      }
      setState(() {
        selectedIDType = valuse['idtype'] != null ? valuse['idtype'] : "";
        selectedValueProvince =
            valuse['province'] != "null" ? valuse['provinceName'] : "";
        selectedValueDistrict =
            valuse['district'] != "null" ? valuse['districtName'] : "";
        selectedValueCommune =
            valuse['commune'] != "null" ? valuse['communeName'] : "";
        selectedValueVillage =
            valuse['village'] != "null" ? valuse['villageName'] : "";
        selectedValueCurrencies =
            valuse['currency'] != null ? valuse['currency'] : "";

        province = valuse['province'] != null && valuse['province'] != ""
            ? valuse['province']
            : "";
        district = valuse['district'] != null && valuse['district'] != ""
            ? valuse['district']
            : "";
        commune = valuse['commune'] != null && valuse['commune'] != ""
            ? valuse['commune']
            : "";
        village = valuse['village'] != null && valuse['village'] != ""
            ? valuse['village']
            : "";
        curcode = valuse['curcode'];
        contorllerNameDetailCustomer.text = valuse['cname'];
        contorllerPhoneNumberDetailCustomer.text = valuse['phone'];
        controllerBalanceDetailCustomer.text = valuse['lamount'].toString();
        controllerLpourposeCustomer.text = valuse['lpourpose'];
        controllerAddressDetailCustomer.text = valuse['address'];
        controllerNID.text = valuse['u2'];
        controllerJobDetailCustomer.text = valuse['job'];
        fetchUidLoan = valuse['u3'];
        id = valuse['id'];
        cidCustmer = valuse['cid'];
        storeBM =
            valuse['bm'] != null || valuse['bm'] != "" ? valuse['bm'] : "";
        storeBTL =
            valuse['btl'] != null || valuse['btl'] != "" ? valuse['btl'] : "";
        storeCO =
            valuse['co'] != null || valuse['co'] != "" ? valuse['co'] : "";
      });

      var useid = await storage.getString('user_id');
      String useAssigned = valuse['u5'] != null ? valuse['u5'] : "";
      String branchID = valuse['br'] != "" && valuse['br'] != null
          ? valuse['br']!.substring(0, 4)
          : "";
      int convertAssigned = 0;
      int convertUserID = 0;
      if (valuse['u5'] != null && valuse['br'] != "") {
        convertAssigned = int.parse(useAssigned);
        convertUserID = int.parse(useid!);
        if (convertUserID == convertAssigned) {
          setState(() {
            enabledAssign = true;
            _dropDownValueAssignUserFullName = valuse['u1'];
            isDisableDropDown = false;
          });
          fetchAssignUser(branchID);
        }
      }
      if (valuse['u3'] == "") {
        isDisableDropDownBranch = false;
        isDisableDropDown = false;
      }
      if (valuse['u4'] == 't') {
        setState(() {
          enabled = false;
        });
      }
      // getUserById
      await Provider.of<RegisterRef>(context, listen: false)
          .getUserById("")
          .then((valueUser) {
        if (valueUser['level'] == 4) {
          setState(() {
            _isLoading = false;

            isDisableDropDownBranch = false;
          });
        } else if (valueUser['uid'] == valuse['u3']) {
          setState(() {
            // isDisableDropDownBranch = true;
            isDisableDropDown = true;
            enabledSubmit = true;
          });
        }
      }).catchError((onError) {
        setState(() {
          _isLoading = false;
        });
      });
    }).catchError((onError) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  var listBranch;
  var levels;
  bool enabled = true;
  bool enabledIdType = true;

  bool isDisableDropDown = true;
  bool isDisableDropDownBranch = true;
  bool _isSelectIDType = false;

  Future fetchBranch() async {
    final storage = await SharedPreferences.getInstance();

    levels = await storage.getString('level');
    try {
      await Provider.of<BranchProvider>(context, listen: false)
          .fetchBranch()
          .then((value) {
        setState(() {
          listBranch = value;
        });
        //
        if (widget.list['br'] != null && widget.list['br'] != "") {
          _isDropDownSelectedBranch = widget.list['br'];
          // setState(() {
          //   isDisableDropDownBranch = true;
          // });
        }
        //
        if (int.parse(levels) == 4) {
          if (widget.list['bm'] != "") {
            _dropDownValueAssignUserFullName =
                _dropDownValueAssignUserFullName = widget.list['bm'];
            isDisableDropDown = true;
          }
        }
        if (int.parse(levels) == 3) {
          if (widget.list['btl'] != "") {
            _dropDownValueAssignUserFullName = widget.list['btl'];
            isDisableDropDown = true;
          } else {
            setState(() {
              isDisableDropDown = false;
            });
          }
        }
        if (int.parse(levels) == 2) {
          if (widget.list['co'] != "") {
            _dropDownValueAssignUserFullName = widget.list['co'];
            isDisableDropDown = true;
          } else {
            setState(() {
              isDisableDropDown = false;
            });
          }
        }
        if (int.parse(levels) == 1) {
          setState(() {
            _isSelectIDType = true;
          });
          if (widget.list['co'] != "") {
            _dropDownValueAssignUserFullName = widget.list['co'];
            isDisableDropDown = true;
          } else {
            setState(() {
              isDisableDropDown = false;
            });
          }
        }
      }).catchError((onError) {
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

  GlobalKey<ScaffoldState> _scaffoldKeyDetailListCustomer =
      new GlobalKey<ScaffoldState>();
  TextEditingController contorllerNameDetailCustomer =
      new TextEditingController();
  TextEditingController contorllerPhoneNumberDetailCustomer =
      new TextEditingController();
  TextEditingController controllerBalanceDetailCustomer =
      new TextEditingController();
  TextEditingController controllerAddressDetailCustomer =
      new TextEditingController();
  TextEditingController controllerNID = new TextEditingController();
  TextEditingController controllerIdtype = new TextEditingController();

  TextEditingController controllerLpourposeCustomer =
      new TextEditingController();
  TextEditingController controllerJobDetailCustomer =
      new TextEditingController();

  //
  String _dropDownValue = "";
  String _dropDownValueBranchSubtring = "";

  String _dropDownValueAssignUser = "";

  bool _isLoading = false;
  var listCustomer;
  var pageSize = 20;
  var pageNumber = 1;
  var sdate = "";
  var edate = "";
  var status = "";
  var cidCustmer = "";
  var id = "";
  //
  String province = "";
  String district = "";
  String commune = "";
  String village = "";
  Future upDateCustomers() async {
    // setState(() {
    //   _isLoading = true;
    // });
    var cname = contorllerNameDetailCustomer.text;
    var phone = contorllerPhoneNumberDetailCustomer.text;

    var lamount = controllerBalanceDetailCustomer.text;

    var lpourpose = controllerLpourposeCustomer.text;
    var nid = controllerNID.text;
    String address = "";
    if (selectedValueVillage != "") {
      address = selectedValueVillage +
          ", " +
          selectedValueCommune +
          ", " +
          selectedValueDistrict +
          ", " +
          selectedValueProvince;
    }
    String curcodes = "";
    if (curcode == "") {
      curcodes = curcode;
    } else {
      curcodes = curcode;
    }
    var job = controllerJobDetailCustomer.text;

    //All ready update
    if (selectedValueVillage != "") {
      province = province;
      district = district;
      commune = commune;
      village = village;
    } else {
      //update from digital
      province = idProvince != "" ? idProvince : selectedValueProvince;
      district = idDistrict != "" ? idDistrict : selectedValueDistrict;
      commune = idCommune != "" ? idCommune : selectedValueCommune;
      village = idVillage != "" ? idVillage : selectedValueVillage;
    }
    //
    var bm = "";
    var btl = "";
    var co = "";
    if (int.parse(levels) == 4) {
      if (_dropDownValueAssignUserFullName != "") {
        bm = storeBM != "" ? storeBM : _dropDownValueAssignUserFullName;
      }
    }
    if (int.parse(levels) == 3) {
      if (_dropDownValueAssignUserFullName != "") {
        btl = storeBTL != "" ? storeBTL : _dropDownValueAssignUserFullName;
      }
    }
    if (int.parse(levels) == 2) {
      if (_dropDownValueAssignUserFullName != "") {
        co = storeCO != "" ? storeCO : _dropDownValueAssignUserFullName;
      }
    }
    if (int.parse(levels) == 1) {
      if (_dropDownValueAssignUserFullName != "") {
        co = _dropDownValueAssignUserFullName;
      }
    }
    String idtype = "";
    String numberIdCard = "";

    if (selectedIDType != "" && controllerNID.text == "") {
      idtype = "";
      numberIdCard = "";
    } else {
      idtype = selectedIDType;
      numberIdCard = controllerNID.text;
    }
    var convertInt = int.parse(lamount);
    try {
      await Provider.of<Customer>(context, listen: false)
          .updateListCustomer(
              widget.list['uid'],
              id,
              cidCustmer,
              cname,
              phone,
              convertInt,
              address,
              idtype,
              job,
              lpourpose,
              bm,
              btl,
              co,
              _isDropDownSelectedBranch,
              _dropDownValueAssignUser,
              province,
              district,
              commune,
              village,
              curcodes,
              numberIdCard)
          .then((value) async => {
                if (value['cid'] != null)
                  {
                    assignStaff(widget.list['cid'], _dropDownValueAssignUser),
                    setState(() {
                      _isLoading = false;
                    }),
                  }
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
  }

  Future assignStaff(cid, tuid) async {
    try {
      final storage = await SharedPreferences.getInstance();
      var uid = await storage.getString('user_id');
      var level = await storage.getString('level');
      var convertToInt = int.parse(level!);
      String status = "";
      if (convertToInt == 1) {
        status = 'FINAL APPROVE';
      } else {
        status = 'P';
      }
      //
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse(baseURLInternal + 'CcfcustAsigs'));

      request.body = json.encode({
        "cid": "$cid",
        "fuid": "$uid",
        "tuid": "$tuid",
        "status": "$status"
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 201) {
        var parsed = jsonDecode(await response.stream.bytesToString());
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => UpdateCustomer(
                true,
              ),
            ),
            ModalRoute.withName('/'));
      } else {
        print(response.reasonPhrase);
      }
    } catch (error) {
      logger().e("error: ${error}");
    }
  }

  //
  var selectedValue;
  //
  var listAssignUser;
  Future fetchAssignUser(idBranch) async {
    await Provider.of<AssignUserProvider>(context, listen: false)
        .fetchAssignUser(idBranch)
        .then((value) {
      // listAssignUser
      setState(() {
        listAssignUser = value;
        isDisableDropDown = false;
      });
    }).catchError((onError) {});
  }

  void onChange(v) {
    var subStringAssingUser = v!.substring(0, 6);
    setState(
      () {
        _dropDownValueAssignUser = subStringAssingUser;
        _dropDownValueAssignUserFullName = v;
      },
    );
  }

  void onChangeBranch(value) {
    var subString = value!.substring(0, 4);
    setState(() {
      _dropDownValueBranchSubtring = subString;
      _isDropDownSelectedBranch = value;
      _dropDownValueAssignUserFullName = "";
    });
    fetchAssignUser(subString);
  }

  bool validateCustomer = false;

  UnfocusDisposition disposition = UnfocusDisposition.scope;
  //
  String selectedValueProvince = "";
  String selectedValueDistrict = "";
  String selectedValueCommune = "";
  String selectedValueVillage = "";
  //
  //
  bool validateVillage = false;
  bool districtreadOnlys = false;
  bool communereadOnlys = false;
  bool villagereadOnlys = false;
  bool provinceReadOnlys = false;
  var stateProvince;
  var list;
  fetchAddress() async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'GET', Uri.parse(baseURLInternal + 'addresses/provinces'));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final lists = jsonDecode(await response.stream.bytesToString());
        setState(() {
          stateProvince = lists;
          list = lists;
        });
      } else {
        print(response.reasonPhrase);
      }
    } catch (error) {
      logger().e("error: ${error}");
    }
  }

  //
  var idProvince;
  var idDistrict;
  var idCommune;
  var idVillage;
  //
  var listID = [];
  var listProvince = [];
  var getProvinceID;
  var listDistricts = [];
  var listComunes = [];
  var listVillages = [];

  //getDistrict
  getDistrict(stateProvince) async {
    stateProvince.forEach((item) async {
      if (selectedValueProvince == item['prodes']) {
        setState(() {
          idProvince = item['procode'];
        });
      }
    });
    try {
      final Response response = await api().get(
        Uri.parse(baseURLInternal + 'addresses/districts/' + idProvince),
        headers: {
          "Content-Type": "application/json",
        },
      );
      final parsed = jsonDecode(response.body);
      setState(() {
        listDistricts = parsed;
      });
    } catch (error) {
      print('error $error');
    }
  }

  //
  getCommune() async {
    listDistricts.forEach((item) async {
      if (selectedValueDistrict == item['disdes']) {
        setState(() {
          idDistrict = item['discode'];
        });
      }
    });

    try {
      final Response response = await api().get(
        Uri.parse(baseURLInternal + 'addresses/communes/' + idDistrict),
        headers: {
          "Ccontent-type": "application/json",
        },
      );
      final parsed = jsonDecode(response.body);
      setState(() {
        listComunes = parsed;
      });
    } catch (error) {}
  }

  //getVillage
  getVillage() async {
    listComunes.forEach((item) async {
      if (selectedValueCommune == item['comdes']) {
        setState(() {
          idCommune = item['comcode'];
        });
      }
    });
    try {
      final Response response = await api().get(
        Uri.parse(baseURLInternal + 'addresses/Villages/' + idCommune),
        headers: {
          "Content-Type": "application/json",
        },
      );
      final parsed = jsonDecode(response.body);
      setState(() {
        listVillages = parsed;
      });
    } catch (error) {}
  }

  final GlobalKey<FormBuilderState> currenciesKeyDetails =
      GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> idTypeKey = GlobalKey<FormBuilderState>();
  String selectedValueCurrencies = "";
  String curcode = "";
  String selectedIDType = "";
  //
  TextEditingController contorllerRemark = new TextEditingController();

  //on reject loan
  Future onReject() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<CustomerApprove>(context, listen: false)
          .clickApproveOrDisApprove("D", widget.list['cid'],
              contorllerRemark.text, '', '', "", "", "")
          .then((value) {
        setState(() {
          _isLoading = false;
        });
        if (value != null && value['aprcode'] != "") {
          showInSnackBar(AppLocalizations.of(context)!.successfully,
              logolightGreen, _scaffoldKeyDetailListCustomer);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => UpdateCustomer(
                  true,
                ),
              ),
              ModalRoute.withName('/'));
        } else {
          showInSnackBar(AppLocalizations.of(context)!.error, Colors.red,
              _scaffoldKeyDetailListCustomer);
        }
      }).catchError((onError) {
        setState(() {
          _isLoading = false;
        });
        showInSnackBar(AppLocalizations.of(context)!.error, Colors.red,
            _scaffoldKeyDetailListCustomer);
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showInSnackBar(AppLocalizations.of(context)!.error, Colors.red,
          _scaffoldKeyDetailListCustomer);
    }
  }

  //
  var listCurrencies = [];
  getCurrencies() async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'GET', Uri.parse(baseURLInternal + 'Currency/currencies'));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final list = jsonDecode(await response.stream.bytesToString());
        logger().e("list curency: $list");

        setState(() {
          listCurrencies = list;
        });
      } else {
        print(response.reasonPhrase);
        logger().e("response.reasonPhrase: ${response.reasonPhrase}");
      }
      //
    } catch (error) {
      logger().e("error curency: $error");
    }
  }

  bool enabledAddress = false;
  bool enabledBranch = false;
  bool enabledAssign = false;
  bool enabledCurrency = false;
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyDetailListCustomer,
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  width: isWeb()
                      ? widthView(context, 0.5)
                      : isIphoneX(context)
                          ? widthView(context, 0.35)
                          : null,
                  color: Colors.white,
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        TextInputComponent(
                            enabled: enabled,
                            controller: contorllerNameDetailCustomer,
                            inputFormatters: [
                              // ignore: deprecated_member_use
                              WhitelistingTextInputFormatter(
                                RegExp("[a-z A-Z]"),
                              ),
                            ],
                            icons: FontAwesomeIcons.user,
                            hintText:
                                AppLocalizations.of(context)!.name_customer +
                                    "*",
                            labelText:
                                AppLocalizations.of(context)!.name_customer +
                                    "*"),
                        Padding(padding: EdgeInsets.all(10)),
                        TextInputComponent(
                            enabled: enabled,
                            controller: contorllerPhoneNumberDetailCustomer,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                            maxleng: 12,
                            icons: FontAwesomeIcons.phoneSquare,
                            hintText:
                                AppLocalizations.of(context)!.phone_number +
                                    "*",
                            labelText:
                                AppLocalizations.of(context)!.phone_number +
                                    "*"),
                        Padding(padding: EdgeInsets.all(10)),
                        TextInputComponent(
                            enabled: enabled,
                            controller: controllerBalanceDetailCustomer,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                            icons: FontAwesomeIcons.moneyBillAlt,
                            hintText:
                                AppLocalizations.of(context)!.amount + "*",
                            labelText:
                                AppLocalizations.of(context)!.amount + "*"),
                        Padding(padding: EdgeInsets.all(10)),
                        // GroupFromBuilder(
                        //   // icons: Icons.check,
                        //   keys: currenciesKeyDetails,
                        //   elevations: 0.0,
                        //   // shapes: RoundedRectangleBorder(
                        //   //   side: BorderSide(color: logolightGreen, width: 1),
                        //   //   borderRadius: BorderRadius.circular(5),
                        //   // ),
                        //   enabled: enabled,
                        //   childs: FormBuilderDropdown(
                        //     enabled: enabledCurrency,
                        //     // iconDisabledColor: logolightGreen,
                        //     // iconEnabledColor: logolightGreen,
                        //     // ic
                        //     icon: Icon(null),
                        //     decoration: InputDecoration(
                        //       labelText:
                        //           AppLocalizations.of(context)!.currencies +
                        //               "*",
                        //       border: InputBorder.none,
                        //     ),
                        //     validator: FormBuilderValidators.compose([
                        //       FormBuilderValidators.required(context,
                        //           errorText: AppLocalizations.of(context)!
                        //                   .currencies_required +
                        //               "*"),
                        //     ]),
                        //     hint: Text(
                        //       selectedValueCurrencies != ""
                        //           ? selectedValueCurrencies
                        //           : AppLocalizations.of(context)!.currencies +
                        //               "*",
                        //       style: TextStyle(color: Colors.grey.shade800),
                        //     ),
                        //     items: listCurrencies
                        //         .map((e) => DropdownMenuItem(
                        //               value: e['curname'].toString(),
                        //               onTap: () => {
                        //                 if (mounted)
                        //                   {
                        //                     setState(() {
                        //                       selectedValueCurrencies =
                        //                           e['curname'];
                        //                       curcode = e['curcode'];
                        //                     }),
                        //                     FocusScope.of(context).unfocus(
                        //                         disposition: disposition),
                        //                   }
                        //               },
                        //               child: Text("${e['curname']}"),
                        //             ))
                        //         .toList(),
                        //     name: 'name',
                        //   ),
                        // ),
                        Padding(padding: EdgeInsets.all(10)),
                        //National ID Type
                        GroupFromBuilder(
                          enabled: enabledIdType,
                          keys: idTypeKey,
                          elevations: 0.0,
                          childs: FormBuilderDropdown(
                            iconDisabledColor: logolightGreen,
                            iconEnabledColor: logolightGreen,
                            enabled: enabledIdType,
                            icon: Icon(null),
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.id_type,
                              border: InputBorder.none,
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(context,
                                  errorText: AppLocalizations.of(context)!
                                          .currencies_required +
                                      "*"),
                            ]),
                            hint: Text(
                                // AppLocalizations.of(context)!.currencies,
                                selectedIDType != "" && selectedIDType != null
                                    ? selectedIDType
                                    : AppLocalizations.of(context)!.id_type,
                                style: TextStyle(color: Colors.grey.shade800)),
                            items: [
                              'National Identity Card',
                              'Birth Certificate',
                              'Family Book',
                              'Passport'
                            ]
                                .map((e) => DropdownMenuItem(
                                      value: e.toString(),
                                      onTap: () => {
                                        if (mounted)
                                          {
                                            setState(() {
                                              selectedIDType = e;
                                            }),
                                            FocusScope.of(context).unfocus(
                                                disposition: disposition),
                                          }
                                      },
                                      child: Text("${e}"),
                                    ))
                                .toList(),
                            name: 'name',
                          ),
                        ),
                        if (selectedIDType != "")
                          Padding(padding: EdgeInsets.all(10)),
                        //National ID Number
                        if (selectedIDType != "")
                          TextInputComponent(
                              enabled: enabledIdType,
                              controller: controllerNID,
                              keyboardType: TextInputType.number,
                              icons: FontAwesomeIcons.idCard,
                              hintText: AppLocalizations.of(context)!
                                  .nationalidentification,
                              labelText: AppLocalizations.of(context)!
                                  .nationalidentification),
                        Padding(padding: EdgeInsets.all(10)),
                        //Job
                        TextInputComponent(
                            enabled: enabled,
                            controller: controllerJobDetailCustomer,
                            icons: FontAwesomeIcons.briefcase,
                            hintText:
                                AppLocalizations.of(context)!.job_titile + "*",
                            labelText:
                                AppLocalizations.of(context)!.job_titile + "*"),
                        Padding(padding: EdgeInsets.all(10)),
                        //loan purpose
                        TextInputComponent(
                            enabled: enabled,
                            controller: controllerLpourposeCustomer,
                            icons: FontAwesomeIcons.file,
                            hintText:
                                AppLocalizations.of(context)!.loan_purpose +
                                    "*",
                            labelText:
                                AppLocalizations.of(context)!.loan_purpose +
                                    "*"),
                        Padding(padding: EdgeInsets.all(10)),
                        // Province
                        //Province
                        DropDownCustomerRegister(
                          enabled: enabledAddress,
                          selectedValue: selectedValueProvince,
                          icons: Icons.location_on,
                          onInSidePress: () async {
                            FocusScope.of(context)
                                .unfocus(disposition: disposition);
                            await fetchAddress();
                            await SelectDialog.showModal<String>(
                              context,
                              label: AppLocalizations.of(context)!.search,
                              items: List.generate(list.length,
                                  (index) => "${list[index]['prodes']}"),
                              onChange: (value) async {
                                if (mounted) {
                                  FocusScope.of(context)
                                      .unfocus(disposition: disposition);
                                  setState(() {
                                    selectedValueProvince = value;
                                    selectedValueDistrict =
                                        AppLocalizations.of(context)!.district +
                                            "*";
                                    selectedValueCommune =
                                        AppLocalizations.of(context)!.commune +
                                            "*";
                                    selectedValueVillage =
                                        AppLocalizations.of(context)!.village +
                                            "*";
                                    districtreadOnlys = true;
                                  });
                                }
                              },
                            );
                          },
                          texts: selectedValueProvince != ""
                              ? selectedValueProvince
                              : AppLocalizations.of(context)!.province + "*",
                          title: selectedValueProvince != ""
                              ? selectedValueProvince
                              : AppLocalizations.of(context)!.province + "*",
                          clear: true,
                          readOnlys: provinceReadOnlys,
                          iconsClose: Icon(
                            Icons.close,
                            color: logolightGreen,
                          ),
                          onPressed: provinceReadOnlys
                              ? () {
                                  if (mounted) {
                                    FocusScope.of(context)
                                        .unfocus(disposition: disposition);
                                    setState(() {
                                      selectedValueProvince =
                                          AppLocalizations.of(context)!
                                                  .province +
                                              "*";
                                      selectedValueDistrict =
                                          AppLocalizations.of(context)!
                                                  .district +
                                              "*";
                                      selectedValueCommune =
                                          AppLocalizations.of(context)!
                                                  .commune +
                                              "*";
                                      selectedValueVillage =
                                          AppLocalizations.of(context)!.village;
                                      districtreadOnlys = false;
                                      communereadOnlys = false;
                                      villagereadOnlys = false;
                                    });
                                  }
                                }
                              : null,
                          styleTexts: selectedValueProvince != ''
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
                          subTitle:
                              AppLocalizations.of(context)!.province + "*",
                        ),
                        //District
                        Padding(padding: EdgeInsets.only(top: 10)),
                        Container(
                          // color: Colors.red,
                          child: DropDownCustomerRegister(
                            enabled: enabledAddress,
                            icons: Icons.location_on,
                            selectedValue: selectedValueDistrict,
                            validate: validateVillage
                                ? RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: logolightGreen, width: 1),
                                    borderRadius: BorderRadius.circular(5),
                                  )
                                : RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: logolightGreen, width: 1),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                            texts: selectedValueDistrict != ""
                                ? selectedValueDistrict
                                : AppLocalizations.of(context)!.district + "*",
                            title: selectedValueDistrict != ""
                                ? selectedValueDistrict
                                : AppLocalizations.of(context)!.district + "*",
                            clear: true,
                            iconsClose: Icon(
                              Icons.close,
                              color: logolightGreen,
                            ),
                            onInSidePress: () async {
                              if (mounted) {
                                FocusScope.of(context)
                                    .unfocus(disposition: disposition);
                                if (districtreadOnlys == true) {
                                  await getDistrict(stateProvince);
                                  await SelectDialog.showModal<String>(
                                    context,
                                    label: AppLocalizations.of(context)!.search,
                                    items: List.generate(
                                        listDistricts.length,
                                        (index) =>
                                            "${listDistricts[index]['disdes']}"),
                                    onChange: (value) {
                                      setState(() {
                                        selectedValueDistrict = value;
                                        communereadOnlys = true;
                                      });
                                    },
                                  );
                                }
                              }
                            },
                            onPressed: provinceReadOnlys
                                ? () {
                                    if (mounted) {
                                      setState(() {
                                        selectedValueDistrict =
                                            selectedValueCommune =
                                                AppLocalizations.of(context)!
                                                        .commune +
                                                    "*";
                                        selectedValueVillage =
                                            AppLocalizations.of(context)!
                                                    .village +
                                                "*";
                                        villagereadOnlys = false;
                                        communereadOnlys = false;
                                      });
                                    }
                                  }
                                : null,
                            readOnlys: districtreadOnlys,
                            styleTexts: selectedValueDistrict != ''
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
                            subTitle:
                                AppLocalizations.of(context)!.district + "*",
                          ),
                        ),
                        //Commune
                        Padding(padding: EdgeInsets.only(top: 10)),
                        DropDownCustomerRegister(
                          enabled: enabledAddress,
                          icons: Icons.location_on,
                          selectedValue: selectedValueCommune,
                          validate: validateVillage
                              ? RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: logolightGreen, width: 1),
                                  borderRadius: BorderRadius.circular(5),
                                )
                              : RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: logolightGreen, width: 1),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                          iconsClose: Icon(
                            Icons.close,
                            color: logolightGreen,
                          ),
                          onInSidePress: () async {
                            if (mounted) {
                              FocusScope.of(context)
                                  .unfocus(disposition: disposition);
                              if (communereadOnlys == true) {
                                await getCommune();
                                SelectDialog.showModal<String>(
                                  context,
                                  label: AppLocalizations.of(context)!.search,
                                  items: List.generate(
                                      listComunes.length,
                                      (index) =>
                                          "${listComunes[index]['comdes']}"),
                                  onChange: (value) {
                                    setState(() {
                                      selectedValueCommune = value;
                                      villagereadOnlys = true;
                                    });
                                  },
                                );
                              }
                            }
                          },
                          onPressed: provinceReadOnlys
                              ? () {
                                  if (mounted) {
                                    setState(() {
                                      selectedValueCommune =
                                          AppLocalizations.of(context)!
                                                  .commune +
                                              "*";
                                      selectedValueVillage =
                                          AppLocalizations.of(context)!
                                                  .village +
                                              "*";
                                      villagereadOnlys = false;
                                    });
                                  }
                                }
                              : null,
                          texts: selectedValueCommune != ''
                              ? selectedValueCommune
                              : AppLocalizations.of(context)!.commune + "*",
                          title: selectedValueCommune != ''
                              ? selectedValueCommune
                              : AppLocalizations.of(context)!.commune + "*",
                          clear: true,
                          styleTexts: selectedValueCommune != ''
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
                          readOnlys: communereadOnlys,
                          autofocus: false,
                          subTitle: AppLocalizations.of(context)!.commune + "*",
                        ),
                        //
                        Padding(padding: EdgeInsets.only(top: 10)),
                        //Village
                        DropDownCustomerRegister(
                          enabled: enabledAddress,
                          icons: Icons.location_on,
                          selectedValue: selectedValueVillage,
                          // validate: validateVillage
                          //     ? RoundedRectangleBorder(
                          //         side:
                          //             BorderSide(color: logolightGreen, width: 1),
                          //         borderRadius: BorderRadius.circular(5),
                          //       )
                          //     : RoundedRectangleBorder(
                          //         side:
                          //             BorderSide(color: logolightGreen, width: 1),
                          //         borderRadius: BorderRadius.circular(2),
                          //       ),
                          clear: true,
                          onInSidePress: () async {
                            FocusScope.of(context)
                                .unfocus(disposition: disposition);
                            if (villagereadOnlys == true) {
                              await getVillage();
                              SelectDialog.showModal<String>(
                                context,
                                label: AppLocalizations.of(context)!.search,
                                items: List.generate(
                                    listVillages.length,
                                    (index) =>
                                        "${listVillages[index]['vildes']}"),
                                onChange: (value) async {
                                  setState(() {
                                    selectedValueVillage = value;
                                  });
                                  listVillages.forEach((item) {
                                    if (selectedValueVillage ==
                                        item['vildes']) {
                                      setState(() {
                                        idVillage = item['vilcode'];
                                      });
                                    }
                                  });
                                },
                              );
                            }
                          },
                          iconsClose: Icon(
                            Icons.close,
                            color: logolightGreen,
                          ),
                          onPressed: provinceReadOnlys
                              ? () {
                                  if (mounted) {
                                    setState(() {
                                      selectedValueVillage =
                                          AppLocalizations.of(context)!
                                                  .village +
                                              "*";
                                      villagereadOnlys = true;
                                    });
                                  }
                                }
                              : null,
                          styleTexts: selectedValueVillage != ''
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
                          texts: selectedValueVillage != ""
                              ? selectedValueVillage
                              : AppLocalizations.of(context)!.village + "*",
                          title: selectedValueVillage != ""
                              ? selectedValueVillage
                              : AppLocalizations.of(context)!.village + "*",
                          readOnlys: villagereadOnlys,
                          autofocus: false,
                          subTitle: AppLocalizations.of(context)!.village + "*",
                        ),
                        //End
                        Padding(padding: EdgeInsets.all(10)),
                        //
                        //select branch
                        DropDownCustomerRegister(
                          enabled: enabledBranch,
                          selectedValue: _isDropDownSelectedBranch,
                          validate: validateCustomer
                              ? RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.red, width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                )
                              : RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: logolightGreen, width: 1),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                          clear: true,
                          readOnlys: enabledBranch,
                          autofocus: false,
                          onInSidePress: () async {
                            FocusScope.of(context)
                                .unfocus(disposition: disposition);
                            await SelectDialog.showModal<String>(
                              context,
                              label: AppLocalizations.of(context)!.search,
                              items: List.generate(
                                  listBranch.length,
                                  (index) =>
                                      "${listBranch[index]['brcode'] + " " + listBranch[index]['bname']}"),
                              onChange: isDisableDropDownBranch == true
                                  ? null
                                  : onChangeBranch,
                            );
                          },
                          iconsClose: Icon(
                            Icons.close,
                            color: logolightGreen,
                          ),
                          onPressed: enabledBranch
                              ? () {
                                  if (mounted) {
                                    setState(() {
                                      _isDropDownSelectedBranch = 'Branch(*)';
                                    });
                                  }
                                }
                              : null,
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
                        //select assign user
                        if (_dropDownValueAssignUserFullName != "" ||
                            listAssignUser != null)
                          DropDownCustomerRegister(
                            enabled: enabledAssign,
                            selectedValue: _dropDownValueAssignUserFullName,
                            validate: validateCustomer
                                ? RoundedRectangleBorder(
                                    side:
                                        BorderSide(color: Colors.red, width: 1),
                                    borderRadius: BorderRadius.circular(10),
                                  )
                                : RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: logolightGreen, width: 1),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                            clear: true,
                            readOnlys: true,
                            autofocus: false,
                            onInSidePress: () async {
                              await SelectDialog.showModal<String>(
                                context,
                                label: AppLocalizations.of(context)!.search,
                                items: List.generate(
                                    listAssignUser.length,
                                    (index) =>
                                        "${listAssignUser[index]['uid'] + " - " + listAssignUser[index]['uname'] + " - " + listAssignUser[index]['staffposition']}"),
                                onChange:
                                    isDisableDropDown == true ? null : onChange,
                              );
                            },
                            iconsClose: Icon(
                              Icons.close,
                              color: logolightGreen,
                            ),
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  _dropDownValueAssignUserFullName =
                                      'Assign Staff' + "*";
                                });
                              }
                            },
                            validateForm: "Assign Staff(*)",
                            styleTexts: _dropDownValueAssignUserFullName != ''
                                ? TextStyle(
                                    fontFamily: fontFamily,
                                    fontSize: fontSizeXs,
                                    color: Colors.black87,
                                    fontWeight: fontWeight500)
                                : TextStyle(
                                    fontFamily: fontFamily,
                                    fontSize: fontSizeXs,
                                    fontWeight: fontWeight500),
                            texts: _dropDownValueAssignUserFullName != ''
                                ? _dropDownValueAssignUserFullName
                                : "Assign Staff" + "*",
                            title: 'Assign Staff' + "*",
                            subTitle: 'Assign Staff' + "*",
                          ),
                        if (_dropDownValueAssignUserFullName != "" ||
                            listAssignUser != null)
                          Padding(padding: EdgeInsets.all(10)),
                        //Remark
                        TextInputComponent(
                            controller: contorllerRemark,
                            icons: FontAwesomeIcons.book,
                            hintText: AppLocalizations.of(context)!.remark,
                            labelText: ""),
                        Padding(padding: EdgeInsets.all(10)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RaisedButton(
                              onPressed: () {
                                contorllerNameDetailCustomer.clear();
                                controllerAddressDetailCustomer.clear();
                                controllerBalanceDetailCustomer.clear();
                                controllerJobDetailCustomer.clear();
                                controllerLpourposeCustomer.clear();
                                contorllerPhoneNumberDetailCustomer.clear();
                                controllerLpourposeCustomer.clear();
                              },
                              color: Colors.grey,
                              child: Container(
                                width: isWeb()
                                    ? widthView(context, 0.1)
                                    : isIphoneX(context)
                                        ? widthView(context, 0.35)
                                        : null,
                                height:
                                    isWeb() ? widthView(context, 0.03) : null,
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.cancel,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            // ignore: deprecated_member_use
                            RaisedButton(
                              onPressed: () {
                                if (contorllerRemark.text == "") {
                                  showInSnackBar(
                                      AppLocalizations.of(context)!
                                          .please_remark,
                                      Colors.red,
                                      _scaffoldKeyDetailListCustomer);
                                } else {
                                  AwesomeDialog(
                                    context: context,
                                    // animType: AnimType.LEFTSLIDE,
                                    width: isWeb()
                                        ? widthView(context, 0.1)
                                        : isIphoneX(context)
                                            ? widthView(context, 0.35)
                                            : widthView(context, 0.35),
                                    headerAnimationLoop: false,
                                    dialogType: DialogType.INFO,
                                    title: AppLocalizations.of(context)!
                                        .information,
                                    desc: AppLocalizations.of(context)!
                                        .do_you_want_to_reject_this_application,
                                    btnOkOnPress: () {
                                      // upDateCustomers();
                                      onReject();
                                    },
                                    btnCancelText:
                                        AppLocalizations.of(context)!.no,
                                    btnCancelOnPress: () {},
                                    btnCancelIcon: Icons.close,
                                    btnOkIcon: Icons.check_circle,
                                    btnOkColor: logolightGreen,
                                    btnOkText:
                                        AppLocalizations.of(context)!.yes,
                                  )..show();
                                }
                              },
                              color: Colors.red,
                              child: Container(
                                width: isWeb()
                                    ? widthView(context, 0.1)
                                    : isIphoneX(context)
                                        ? widthView(context, 0.35)
                                        : widthView(context, 0.35),
                                height:
                                    isWeb() ? widthView(context, 0.03) : null,
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.reject,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            // ignore: deprecated_member_use
                            RaisedButton(
                              onPressed: enabledSubmit == true
                                  ? null
                                  : () {
                                      if (contorllerNameDetailCustomer.text ==
                                          "") {
                                        showInSnackBar(
                                            AppLocalizations.of(context)!
                                                .please_fill_full_name,
                                            Colors.red,
                                            _scaffoldKeyDetailListCustomer);
                                      }
                                      if (contorllerPhoneNumberDetailCustomer
                                          .text.isEmpty) {
                                        showInSnackBar(
                                            AppLocalizations.of(context)!
                                                .please_fill_full_phone,
                                            Colors.red,
                                            _scaffoldKeyDetailListCustomer);
                                      }

                                      // if (controllerNID.text.isEmpty) {
                                      //   showInSnackBar(
                                      //       "Please fill full nationval id",
                                      //       Colors.red,
                                      //       _scaffoldKeyDetailListCustomer);
                                      // }

                                      // if (selectedIDType == "") {
                                      //   showInSnackBar(
                                      //       "Please select ID Type.",
                                      //       Colors.red,
                                      //       _scaffoldKeyDetailListCustomer);
                                      // }

                                      if (controllerJobDetailCustomer
                                          .text.isEmpty) {
                                        showInSnackBar(
                                            AppLocalizations.of(context)!
                                                .please_fill_full_job,
                                            Colors.red,
                                            _scaffoldKeyDetailListCustomer);
                                      }
                                      if (controllerLpourposeCustomer
                                          .text.isEmpty) {
                                        showInSnackBar(
                                            AppLocalizations.of(context)!
                                                .please_fill_full_loan_purpose,
                                            Colors.red,
                                            _scaffoldKeyDetailListCustomer);
                                      }
                                      // if (_dropDownValueAssignUserFullName ==
                                      //     "") {
                                      //   showInSnackBar(
                                      //       AppLocalizations.of(context)!
                                      //           .please_fill_select_drop_down,
                                      //       Colors.red,
                                      //       _scaffoldKeyDetailListCustomer);
                                      // }
                                      if (_isDropDownSelectedBranch == "") {
                                        showInSnackBar(
                                            AppLocalizations.of(context)!
                                                .please_fill_select_drop_down_branch,
                                            Colors.red,
                                            _scaffoldKeyDetailListCustomer);
                                      }
                                      if (selectedValueVillage == "" ||
                                          selectedValueVillage ==
                                              "Village Code") {
                                        setState(() {
                                          validateVillage = true;
                                        });
                                        showInSnackBar(
                                            AppLocalizations.of(context)!
                                                .address_require,
                                            Colors.red,
                                            _scaffoldKeyDetailListCustomer);
                                      }
                                      if (curcode == "") {
                                        showInSnackBar(
                                            AppLocalizations.of(context)!
                                                .currency_require,
                                            Colors.red,
                                            _scaffoldKeyDetailListCustomer);
                                      }
                                      if (_dropDownValueAssignUser == "") {
                                        showInSnackBar(
                                            AppLocalizations.of(context)!
                                                .please_assign_user,
                                            Colors.red,
                                            _scaffoldKeyDetailListCustomer);
                                      }
                                      if (contorllerNameDetailCustomer
                                              .text.isNotEmpty &&
                                          contorllerPhoneNumberDetailCustomer
                                              .text.isNotEmpty &&
                                          controllerBalanceDetailCustomer
                                              .text.isNotEmpty &&
                                          controllerLpourposeCustomer
                                              .text.isNotEmpty &&
                                          // selectedIDType != "" &&
                                          // controllerNID.text.isNotEmpty &&
                                          controllerJobDetailCustomer
                                              .text.isNotEmpty &&
                                          _isDropDownSelectedBranch != "" &&
                                          _dropDownValueAssignUserFullName !=
                                              "" &&
                                          selectedValueVillage != "" &&
                                          selectedValueVillage !=
                                              "Village Code") {
                                        AwesomeDialog(
                                          context: context,
                                          // animType: AnimType.LEFTSLIDE,
                                          width: isWeb()
                                              ? widthView(context, 0.1)
                                              : isIphoneX(context)
                                                  ? widthView(context, 0.35)
                                                  : widthView(context, 0.35),

                                          headerAnimationLoop: false,
                                          dialogType: DialogType.SUCCES,
                                          title: AppLocalizations.of(context)!
                                              .information,
                                          desc: AppLocalizations.of(context)!
                                              .do_you_want_to,
                                          btnOkOnPress: () {
                                            upDateCustomers();
                                          },
                                          btnCancelText:
                                              AppLocalizations.of(context)!.no,
                                          btnCancelOnPress: () {},
                                          btnCancelIcon: Icons.close,
                                          btnOkIcon: Icons.check_circle,
                                          btnOkColor: logolightGreen,
                                          btnOkText:
                                              AppLocalizations.of(context)!.yes,
                                        )..show();
                                      } else {
                                        logger().e("error ");
                                      }
                                    },
                              color: logoDarkBlue,
                              child: Container(
                                width: isWeb()
                                    ? widthView(context, 0.1)
                                    : isIphoneX(context)
                                        ? widthView(context, 0.35)
                                        : widthView(context, 0.35),
                                height:
                                    isWeb() ? widthView(context, 0.03) : null,
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.submit,
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
              ),
            ),
    );
  }
}
