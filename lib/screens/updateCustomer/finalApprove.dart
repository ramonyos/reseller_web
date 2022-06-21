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

class FinalApproveLoan extends StatefulWidget {
  var list;
  FinalApproveLoan({this.list});

  @override
  _FinalApproveLoanState createState() => _FinalApproveLoanState();
}

class _FinalApproveLoanState extends State<FinalApproveLoan> {
  @override
  void didChangeDependencies() {
    fetchListCustomer(widget.list);
    fetchUser(widget.list['u3']);
    super.didChangeDependencies();
  }

  Future fetchUser(uidParam) async {
    // getUserById
    await Provider.of<RegisterRef>(context, listen: false)
        .getUserById(uidParam)
        .then((valueUser) {
      setState(() {
        _dropDownValueAssignUserFullName =
            valueUser['uid'] + " - " + valueUser['uname'];
        _dropDownValueAssignUser = valueUser['uid'];
      });
    }).catchError((onError) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  TextEditingController contorllerNameDetailCustomer =
      new TextEditingController();
  TextEditingController contorllerPhoneNumberDetailCustomer =
      new TextEditingController();
  TextEditingController controllerBalanceDetailCustomer =
      new TextEditingController();
  TextEditingController controllerAddressDetailCustomer =
      new TextEditingController();
  TextEditingController controllerNID = new TextEditingController();
  TextEditingController controllerLpourposeCustomer =
      new TextEditingController();
  TextEditingController controllerJobDetailCustomer =
      new TextEditingController();
  TextEditingController controllerCurrency = new TextEditingController();
  TextEditingController contorllerRemark = new TextEditingController();
  TextEditingController contorllerLoanID = new TextEditingController();
  TextEditingController contorllerOther = new TextEditingController();

  //
  String storeBM = "";
  String storeBTL = "";
  String storeCO = "";
  String fetchUidLoan = "";
  String id = "";
  String cidCustmer = "";
  bool isDisableDropDown = true;
  bool isDisableDropDownBranch = true;
  bool enabled = false;
  String _isDropDownSelectedBranch = "";
  String _dropDownValueAssignUserFullName = "";
  bool _isLoading = false;
  //
  bool enabledAddress = true;
  bool enabledBranch = true;
  bool enabledAssign = true;
  bool enabledCurrency = true;
  bool provinceReadOnlys = true;
  //
  fetchListCustomer(list) async {
    // getReferalById
    await Provider.of<Customer>(context, listen: false)
        .getReferalById(list['id'])
        .then((valuse) {
      setState(() {
        controllerCurrency.text = valuse['currency'];
        provinceReadOnlys = false;
        validateVillage = false;
        districtreadOnlys = false;
        communereadOnlys = false;
        villagereadOnlys = false;
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
        _isDropDownSelectedBranch = valuse['br'];
      });
      // if (valuse['br'] != "") {
      //   var subString = valuse['br'].substring(0, 4);
      //   fetchAssignUser(subString);
      // }
    }).catchError((onError) {});
  }

  //If BM Approve, Request CO to insert Loan ID, Currency, Amount, and Approve or Reject.
  var listCustomer;
  String selectedValueCurrencies = "";
  String curcode = "";
  String selectedIDType = "";
  String province = "";
  String district = "";
  String commune = "";
  String village = "";
  var levels;
  String _dropDownValueAssignUser = "";

  Future onAssignCoToApprove() async {
    final storage = await SharedPreferences.getInstance();

    levels = await storage.getString('level');

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
          .requestCOFinal(
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
                setState(() {
                  _isLoading = false;
                }),
                if (value['cid'] != null)
                  {
                    setState(() {
                      listCustomer = value;
                    }),
                    await Provider.of<AssignUserProvider>(context,
                            listen: false)
                        .requestAssignDisbursement(
                            widget.list['cid'], _dropDownValueAssignUser)
                        .then((value) {
                      setState(() {
                        _isLoading = false;
                      });
                      if (value != null) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => UpdateCustomer(
                                true,
                              ),
                            ),
                            ModalRoute.withName('/'));
                      }
                    }).catchError((onError) {
                      logger().e("onError: $onError");
                      setState(() {
                        _isLoading = false;
                      });
                    }),
                  },
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

  //on approve loan or disapprove
  Future onClickApproveOrDisApprove(status) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<CustomerApprove>(context, listen: false)
          .clickApproveOrDisApprove(
              status,
              widget.list['cid'],
              contorllerRemark.text,
              contorllerLoanID.text,
              contorllerOther.text,
              "",
              "",
              "")
          .then((value) {
        setState(() {
          _isLoading = false;
        });
        if (value != null && value['aprcode'] != "") {
          showInSnackBar(AppLocalizations.of(context)!.successfully,
              logolightGreen, _scaffoldKeyApproveOrDisApproveCustomer);
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
              _scaffoldKeyApproveOrDisApproveCustomer);
        }
      }).catchError((onError) {
        setState(() {
          _isLoading = false;
        });
        showInSnackBar(AppLocalizations.of(context)!.error, Colors.red,
            _scaffoldKeyApproveOrDisApproveCustomer);
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showInSnackBar(AppLocalizations.of(context)!.error, Colors.red,
          _scaffoldKeyApproveOrDisApproveCustomer);
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKeyApproveOrDisApproveCustomer =
      new GlobalKey<ScaffoldState>();
  //
  UnfocusDisposition disposition = UnfocusDisposition.scope;
  //
  String selectedValueProvince = "";
  String selectedValueDistrict = "";
  String selectedValueCommune = "";
  String selectedValueVillage = "";
  //
  bool validateVillage = false;
  bool districtreadOnlys = false;
  bool communereadOnlys = false;
  bool villagereadOnlys = false;
  var stateProvince;
  var list;
  //
  fetchAddress() async {
    try {
      final Response response = await api().get(
        Uri.parse(baseURLInternal + 'addresses/provinces'),
        headers: {
          "content-type": "application/json",
        },
      );
      var lists = jsonDecode(response.body);
      setState(() {
        stateProvince = lists;
        list = lists;
      });
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

  final GlobalKey<FormBuilderState> idTypeKey = GlobalKey<FormBuilderState>();

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKeyApproveOrDisApproveCustomer,
        backgroundColor: Colors.white,
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          title: Text(
            AppLocalizations.of(context)!.final_approve,
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
                        ? widthView(context, 0.7)
                        : isIphoneX(context)
                            ? widthView(context, 1)
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
                              FilteringTextInputFormatter.allow(
                                RegExp("[a-z A-Z]"),
                              ),
                            ],
                            icons: FontAwesomeIcons.user,
                            hintText:
                                AppLocalizations.of(context)!.name_customer,
                            labelText:
                                AppLocalizations.of(context)!.name_customer,
                          ),
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
                                AppLocalizations.of(context)!.phone_number,
                            labelText:
                                AppLocalizations.of(context)!.phone_number,
                          ),
                          // Padding(padding: EdgeInsets.all(10)),
                          TextInputComponent(
                            enabled: enabled,
                            controller: controllerJobDetailCustomer,
                            icons: FontAwesomeIcons.briefcase,
                            hintText: AppLocalizations.of(context)!.currencies,
                            labelText: AppLocalizations.of(context)!.currencies,
                            // AppLocalizations.of(context)!
                            //         .translate("job_titile") ??
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          TextInputComponent(
                            enabled: enabled,
                            controller: controllerCurrency,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                            icons: FontAwesomeIcons.moneyBillAlt,
                            hintText: AppLocalizations.of(context)!.amount,
                            labelText: AppLocalizations.of(context)!.amount,
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          TextInputComponent(
                            enabled: enabled,
                            controller: controllerAddressDetailCustomer,
                            icons: FontAwesomeIcons.home,
                            hintText: AppLocalizations.of(context)!.address,
                            labelText: AppLocalizations.of(context)!.address,
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          //National ID Type
                          GroupFromBuilder(
                            enabled: enabled,
                            keys: idTypeKey,
                            elevations: 0.0,
                            childs: FormBuilderDropdown(
                              iconDisabledColor: logolightGreen,
                              iconEnabledColor: logolightGreen,
                              enabled: enabled,
                              icon: Icon(null),
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.id_type,
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
                                  style:
                                      TextStyle(color: Colors.grey.shade800)),
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
                          if (selectedIDType != "" && selectedIDType != null)
                            Padding(padding: EdgeInsets.all(10)),
                          if (selectedIDType != "" && selectedIDType != null)
                            TextInputComponent(
                              enabled: enabled,
                              controller: controllerNID,
                              icons: FontAwesomeIcons.idCard,
                              hintText: AppLocalizations.of(context)!
                                  .nationalidentification,
                              labelText: AppLocalizations.of(context)!
                                  .nationalidentification,
                            ),
                          Padding(padding: EdgeInsets.all(10)),
                          TextInputComponent(
                            enabled: enabled,
                            controller: controllerJobDetailCustomer,
                            icons: FontAwesomeIcons.briefcase,
                            hintText: AppLocalizations.of(context)!.job_titile,
                            labelText: AppLocalizations.of(context)!.job_titile,
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          TextInputComponent(
                            enabled: enabled,
                            controller: controllerLpourposeCustomer,
                            icons: FontAwesomeIcons.file,
                            hintText:
                                AppLocalizations.of(context)!.loan_purpose,
                            labelText:
                                AppLocalizations.of(context)!.loan_purpose,
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          //Province
                          DropDownCustomerRegister(
                            enabled: false,
                            selectedValue: selectedValueProvince,
                            icons: Icons.location_on,
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
                                          AppLocalizations.of(context)!
                                              .district;
                                      selectedValueCommune =
                                          AppLocalizations.of(context)!.commune;
                                      selectedValueVillage =
                                          AppLocalizations.of(context)!.village;
                                      districtreadOnlys = true;
                                    });
                                  }
                                },
                              );
                            },
                            texts: selectedValueProvince != ""
                                ? selectedValueProvince
                                : AppLocalizations.of(context)!.province,
                            title: selectedValueProvince != ""
                                ? selectedValueProvince
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
                                  selectedValueProvince =
                                      AppLocalizations.of(context)!.province;
                                  selectedValueDistrict =
                                      AppLocalizations.of(context)!.district;
                                  selectedValueCommune =
                                      AppLocalizations.of(context)!.commune;
                                  selectedValueVillage =
                                      AppLocalizations.of(context)!.village;
                                  districtreadOnlys = false;
                                  communereadOnlys = false;
                                  villagereadOnlys = false;
                                });
                              }
                            },
                            styleTexts: selectedValueProvince != ''
                                ? TextStyle(
                                    fontFamily: fontFamily,
                                    fontSize: fontSizeXs,
                                    color: Colors.black87,
                                  )
                                : TextStyle(
                                    fontFamily: fontFamily,
                                    fontSize: fontSizeXs,
                                    color: Colors.grey,
                                  ),
                            autofocus: false,
                          ),
                          //District
                          Padding(padding: EdgeInsets.only(top: 10)),
                          Container(
                            // color: Colors.red,
                            child: DropDownCustomerRegister(
                              enabled: false,
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
                                  :
                                  // AppLocalizations.of(context)
                                  //         .translate('district_code') ??
                                  AppLocalizations.of(context)!.district,
                              title: selectedValueDistrict != ""
                                  ? selectedValueDistrict
                                  : AppLocalizations.of(context)!.district,
                              subTitle: AppLocalizations.of(context)!.district,
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
                                      label:
                                          AppLocalizations.of(context)!.search,
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
                              onPressed: () {
                                if (mounted) {
                                  setState(() {
                                    selectedValueDistrict =
                                        selectedValueCommune =
                                            AppLocalizations.of(context)!
                                                .commune;
                                    selectedValueVillage =
                                        AppLocalizations.of(context)!.village;
                                    villagereadOnlys = false;
                                    communereadOnlys = false;
                                  });
                                }
                              },
                              readOnlys: districtreadOnlys,
                              styleTexts: selectedValueDistrict != ''
                                  ? TextStyle(
                                      fontFamily: fontFamily,
                                      fontSize: fontSizeXs,
                                      color: Colors.black87,
                                    )
                                  : TextStyle(
                                      fontFamily: fontFamily,
                                      fontSize: fontSizeXs,
                                      color: Colors.grey,
                                    ),
                              autofocus: false,
                            ),
                          ),
                          //Commune
                          Padding(padding: EdgeInsets.only(top: 10)),
                          DropDownCustomerRegister(
                            enabled: false,
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
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  selectedValueCommune =
                                      AppLocalizations.of(context)!.commune;
                                  selectedValueVillage =
                                      AppLocalizations.of(context)!.village;
                                  villagereadOnlys = false;
                                });
                              }
                            },
                            texts: selectedValueCommune != ''
                                ? selectedValueCommune
                                : AppLocalizations.of(context)!.commune,
                            title: selectedValueCommune != ''
                                ? selectedValueCommune
                                : AppLocalizations.of(context)!.commune,
                            subTitle: AppLocalizations.of(context)!.commune,
                            clear: true,
                            styleTexts: selectedValueCommune != ''
                                ? TextStyle(
                                    fontFamily: fontFamily,
                                    fontSize: fontSizeXs,
                                    color: Colors.black87,
                                  )
                                : TextStyle(
                                    fontFamily: fontFamily,
                                    fontSize: fontSizeXs,
                                    color: Colors.grey,
                                  ),
                            readOnlys: communereadOnlys,
                            autofocus: false,
                          ),
                          //
                          Padding(padding: EdgeInsets.only(top: 10)),
                          DropDownCustomerRegister(
                            enabled: false,
                            icons: Icons.location_on,
                            selectedValue: selectedValueVillage,
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
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  selectedValueVillage =
                                      AppLocalizations.of(context)!.village;
                                  villagereadOnlys = true;
                                });
                              }
                            },
                            styleTexts: selectedValueVillage != ''
                                ? TextStyle(
                                    fontFamily: fontFamily,
                                    fontSize: fontSizeXs,
                                    color: Colors.black87,
                                  )
                                : TextStyle(
                                    fontFamily: fontFamily,
                                    fontSize: fontSizeXs,
                                    color: Colors.grey,
                                  ),
                            texts: selectedValueVillage != ""
                                ? selectedValueVillage
                                : AppLocalizations.of(context)!.village,
                            title: selectedValueVillage != ""
                                ? selectedValueVillage
                                : AppLocalizations.of(context)!.village,
                            subTitle: AppLocalizations.of(context)!.village,
                            readOnlys: villagereadOnlys,
                            autofocus: false,
                          ),
                          //End
                          Padding(padding: EdgeInsets.all(10)),
                          //select branch first
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Row(
                              children: [
                                Container(
                                  width: isWeb()
                                      ? widthView(context, 0.67)
                                      : isIphoneX(context)
                                          ? widthView(context, 0.9)
                                          : widthView(context, 0.9),
                                  height: isWeb()
                                      ? widthView(context, 0.03)
                                      : isIphoneX(context)
                                          ? widthView(context, 0.15)
                                          : widthView(context, 0.15),
                                  child: DropdownButtonFormField(
                                    elevation: 0,
                                    iconEnabledColor: logolightGreen,
                                    iconDisabledColor: logolightGreen,
                                    decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300))),
                                    hint: _isDropDownSelectedBranch == ""
                                        ? Text(
                                            AppLocalizations.of(context)!
                                                .choose_branch,
                                            style:
                                                TextStyle(color: Colors.grey),
                                          )
                                        : Text(
                                            "${_isDropDownSelectedBranch}",
                                            style: TextStyle(
                                                color: Colors.black87),
                                          ),
                                    isExpanded: true,
                                    iconSize: 30.0,
                                    style: TextStyle(color: logolightGreen),
                                    items: [].map(
                                      (val) {
                                        return DropdownMenuItem<String>(
                                          value: val,
                                          child: Text(val),
                                        );
                                      },
                                    ).toList(),
                                    onChanged: null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          //select user to assign
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Row(
                              children: [
                                Container(
                                  width: isWeb()
                                      ? widthView(context, 0.67)
                                      : isIphoneX(context)
                                          ? widthView(context, 0.9)
                                          : widthView(context, 0.9),
                                  height: isWeb()
                                      ? widthView(context, 0.03)
                                      : isIphoneX(context)
                                          ? widthView(context, 0.15)
                                          : widthView(context, 0.15),
                                  child: DropdownButtonFormField(
                                    elevation: 0,
                                    iconEnabledColor: logolightGreen,
                                    iconDisabledColor: logolightGreen,
                                    decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300))),
                                    hint: _dropDownValueAssignUserFullName == ""
                                        ? Text(
                                            AppLocalizations.of(context)!
                                                    .assign_staff +
                                                "*",
                                            style: TextStyle(
                                                color: Colors.black87),
                                          )
                                        : Text(
                                            "${_dropDownValueAssignUserFullName}",
                                            style: TextStyle(
                                                color: Colors.black87),
                                          ),
                                    isExpanded: true,
                                    iconSize: 30.0,
                                    style: TextStyle(color: logolightGreen),
                                    items: [].map(
                                      (val) {
                                        return DropdownMenuItem<String>(
                                          value: val,
                                          child: Text(val),
                                        );
                                      },
                                    ).toList(),
                                    onChanged: null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RaisedButton(
                                onPressed: () {
                                  AwesomeDialog(
                                    context: context,
                                    width: isWeb()
                                        ? widthView(context, 0.3)
                                        : isIphoneX(context)
                                            ? widthView(context, 0.35)
                                            : widthView(context, 0.35),
                                    headerAnimationLoop: false,
                                    dialogType: DialogType.SUCCES,
                                    title: AppLocalizations.of(context)!
                                        .information,
                                    desc: AppLocalizations.of(context)!
                                        .do_you_want_to_reject_this_application,
                                    btnOkOnPress: () {
                                      onClickApproveOrDisApprove("D");
                                    },
                                    btnCancelText:
                                        AppLocalizations.of(context)!.no,
                                    btnCancelOnPress: () {
                                      // if (selectedValueCustomer == false) {
                                      //   setState(() {
                                      //     validateCustomer = true;
                                      //   });
                                      // } else {
                                      //   setState(() {
                                      //     statusEdit = 'save';
                                      //   });
                                      //   await onSubmit(context);
                                      //   setState(() {
                                      //     validateCustomer = false;
                                      //   });
                                      // }
                                    },
                                    btnCancelIcon: Icons.close,
                                    btnOkIcon: Icons.check_circle,
                                    btnOkColor: logolightGreen,
                                    btnOkText:
                                        AppLocalizations.of(context)!.yes,
                                  )..show();
                                },
                                color: Colors.grey,
                                child: Container(
                                  width: isWeb()
                                      ? widthView(context, 0.2)
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
                                onPressed: () {
                                  AwesomeDialog(
                                    context: context,
                                    width: isWeb()
                                        ? widthView(context, 0.3)
                                        : isIphoneX(context)
                                            ? widthView(context, 0.35)
                                            : widthView(context, 0.35),
                                    headerAnimationLoop: false,
                                    dialogType: DialogType.SUCCES,
                                    title: AppLocalizations.of(context)!
                                        .information,
                                    desc: AppLocalizations.of(context)!
                                        .do_you_want_to_approve_this_application,
                                    btnOkOnPress: () {
                                      onAssignCoToApprove();
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
                                },
                                color: logoDarkBlue,
                                child: Container(
                                  width: isWeb()
                                      ? widthView(context, 0.2)
                                      : isIphoneX(context)
                                          ? widthView(context, 0.35)
                                          : widthView(context, 0.35),
                                  height:
                                      isWeb() ? widthView(context, 0.03) : null,
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.approve,
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
              ));
  }
}
