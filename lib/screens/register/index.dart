import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ccf_reseller_web_app/components/textInputComponent.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ccf_reseller_web_app/providers/listCustomer/indext.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/screens/register/currency.dart';
import 'package:ccf_reseller_web_app/screens/register/dropDownRegister.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:select_dialog/select_dialog.dart';
import '../../utils/colors.dart';
import 'package:http/http.dart' as http;

class RegisterCustomer extends StatefulWidget {
  @override
  _RegisterCustomerState createState() => _RegisterCustomerState();
}

class _RegisterCustomerState extends State<RegisterCustomer> {
  final GlobalKey<ScaffoldState> _scaffoldKeyRegister =
      new GlobalKey<ScaffoldState>();
  TextEditingController contorllerNameRegister = new TextEditingController();
  TextEditingController contorllerPhoneNumberRegister =
      new TextEditingController();
  TextEditingController controllerAmountRegister = new TextEditingController();
  TextEditingController controllerLoanPourposeRegister =
      new TextEditingController();
  TextEditingController controllerJobRegister = new TextEditingController();
  TextEditingController controllerAddressRgister = TextEditingController();

  bool _isNameCustomer = false;
  bool _isPhoneCustomer = false;
  bool _isLoading = false;
  DateTime now = DateTime.now();
  var sdate;
  //
  var dataCustomer;

  get floatingActionButtonLocation => null;
  Future createCustomer() async {
    var name = contorllerNameRegister.text;
    var phone = contorllerPhoneNumberRegister.text;
    int amount = 0;
    if (controllerAmountRegister.text != "") {
      var convertAmount = controllerAmountRegister.text;
      NumberFormat format = NumberFormat.compact();
      var amountConvertToInt = format.parse(convertAmount);
      amount = amountConvertToInt.toInt();
    }
    String address = "";
    if (selectedValueVillage != "") {
      address = selectedValueProvince +
          ", " +
          selectedValueDistrict +
          ", " +
          selectedValueCommune +
          ", " +
          selectedValueVillage;
    }

    var province = idProvince != "" ? idProvince : "";
    var district = idDistrict != "" ? idDistrict : "";
    var commune = idCommune != "" ? idCommune : "";
    var village = idVillage != "" ? idVillage : "";

    var loanPourpose = controllerLoanPourposeRegister.text;
    var currency = curcode != "" ? curcode : "";
    //
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Customer>(context, listen: false)
          .createReferalCustomer(name, phone, amount.toString(), loanPourpose,
              address, province, district, commune, village, currency)
          .then((value) {
        setState(() {
          _isLoading = false;
        });
        if (value != null || value['cid'] != null) {
          setState(() {
            dataCustomer = value;
            selectedValueProvince = "";
            selectedValueDistrict = "";
            selectedValueCommune = "";
            selectedValueVillage = "";
          });
          showInSnackBar(AppLocalizations.of(context)!.successfully,
              logolightGreen, _scaffoldKeyRegister);
          clear();
        } else {
          showInSnackBar(AppLocalizations.of(context)!.error, Colors.red,
              _scaffoldKeyRegister);
        }
      }).catchError((onError) {
        logger().e("catchError: ${onError}");

        setState(() {
          _isLoading = false;
        });
        showInSnackBar(AppLocalizations.of(context)!.error, Colors.red,
            _scaffoldKeyRegister);
      });
    } catch (error) {
      logger().e("catch: ${error}");

      setState(() {
        _isLoading = false;
      });
      showInSnackBar(AppLocalizations.of(context)!.error, Colors.red,
          _scaffoldKeyRegister);
    }
  }

  clear() {
    contorllerPhoneNumberRegister.clear();
    controllerAmountRegister.clear();
    controllerJobRegister.clear();
    controllerLoanPourposeRegister.clear();
    contorllerNameRegister.clear();
  }

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
  //
  UnfocusDisposition disposition = UnfocusDisposition.scope;
  var stateProvince;
  var list;

  fetchAddress() async {
    try {
      var request = http.Request(
          'GET', Uri.parse(baseURLInternal + 'addresses/provinces/'));

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var lists = jsonDecode(await response.stream.bytesToString());
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

  @override
  void initState() {
    // TODO: implement initState
    fetchAddress();
    getCurrencies();
    super.initState();
  }

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
      var request = http.Request('GET',
          Uri.parse(baseURLInternal + 'addresses/districts/' + idProvince));

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var parsed = jsonDecode(await response.stream.bytesToString());
        setState(() {
          listDistricts = parsed;
        });
      } else {
        print(response.reasonPhrase);
      }
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
      var request = http.Request('GET',
          Uri.parse(baseURLInternal + 'addresses/communes/' + idDistrict));

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var parsed = jsonDecode(await response.stream.bytesToString());
        setState(() {
          listComunes = parsed;
        });
      } else {
        print(response.reasonPhrase);
      }
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
      var request = http.Request('GET',
          Uri.parse(baseURLInternal + 'addresses/Villages/' + idCommune));

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var parsed = jsonDecode(await response.stream.bytesToString());
        setState(() {
          listVillages = parsed;
        });
      } else {
        print(response.reasonPhrase);
      }
    } catch (error) {}
  }

  final GlobalKey<FormBuilderState> currenciesKey =
      GlobalKey<FormBuilderState>();
  String selectedValueCurrencies = "";
  String curcode = "";
  var listCurrencies = [];
  getCurrencies() async {
    try {
      var request = http.Request(
          'GET', Uri.parse(baseURLInternal + 'Currency/currencies'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var list = jsonDecode(await response.stream.bytesToString());
        setState(() {
          listCurrencies = list;
        });
      } else {
        print(response.reasonPhrase);
      }
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyRegister,
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.register_customer,
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
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        TextInputComponent(
                          controller: contorllerNameRegister,
                          inputFormatters: [
                            // ignore: deprecated_member_use
                            FilteringTextInputFormatter.deny(
                                RegExp("[0-9/\\\\|!.]")),
                          ],
                          icons: Icons.person,
                          hintText:
                              AppLocalizations.of(context)!.name_customer + "*",
                          labelText: "Sok Ret ",
                        ),
                        Padding(padding: EdgeInsets.all(10)),
                        TextInputComponent(
                            controller: contorllerPhoneNumberRegister,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                            maxleng: 10,
                            icons: Icons.phone,
                            hintText:
                                AppLocalizations.of(context)!.phone_number +
                                    "*",
                            labelText: "093245401"),
                        Padding(padding: EdgeInsets.all(10)),
                        CurrencyComponent(
                          // icons: Icons.check,
                          keys: currenciesKey,
                          shapes: RoundedRectangleBorder(
                            side: BorderSide(color: logolightGreen, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          childs: FormBuilderDropdown(
                            iconDisabledColor: logolightGreen,
                            iconEnabledColor: logolightGreen,
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.currencies,
                              border: InputBorder.none,
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(context,
                                  errorText: AppLocalizations.of(context)!
                                          .currencies_required +
                                      "*"),
                            ]),
                            hint: Text(
                              AppLocalizations.of(context)!.currencies,
                            ),
                            items: listCurrencies
                                .map((e) => DropdownMenuItem(
                                      value: e['curname'].toString(),
                                      onTap: () => {
                                        if (mounted)
                                          {
                                            setState(() {
                                              selectedValueCurrencies =
                                                  e['curname'];
                                              curcode = e['curcode'];
                                            }),
                                            FocusScope.of(context).unfocus(
                                                disposition: disposition),
                                          }
                                      },
                                      child: Text("${e['curname']}"),
                                    ))
                                .toList(),
                            name: 'name',
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(15)),
                        TextInputComponent(
                            controller: controllerAmountRegister,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9 ,]')),
                            ],
                            icons: Icons.monetization_on,
                            hintText: AppLocalizations.of(context)!.amount,

                            // AppLocalizations.of(context)!.amount + "*",
                            labelText: "..."),
                        Padding(padding: EdgeInsets.all(10)),
                        TextInputComponent(
                            controller: controllerLoanPourposeRegister,
                            icons: Icons.branding_watermark,
                            hintText:
                                AppLocalizations.of(context)!.loan_purpose,
                            // AppLocalizations.of(context)!.loan_purpose + "*",
                            labelText:
                                AppLocalizations.of(context)!.buy_house_or),
                        Padding(padding: EdgeInsets.all(10)),
                        //Province
                        DropDownRegister(
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
                                        AppLocalizations.of(context)!.district;
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
                                  fontWeight: fontWeight500)
                              : TextStyle(
                                  fontFamily: fontFamily,
                                  fontSize: fontSizeXs,
                                  color: Colors.grey.shade500,
                                  fontWeight: fontWeight500),
                          autofocus: false,
                        ),
                        //District
                        Padding(padding: EdgeInsets.only(top: 15)),
                        Container(
                          // color: Colors.red,
                          child: DropDownRegister(
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
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  selectedValueDistrict =
                                      // AppLocalizations.of(context)
                                      //         .translate('district_code') ??
                                      //     'District';
                                      selectedValueCommune =
                                          AppLocalizations.of(context)!.commune;
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
                                    fontWeight: fontWeight500)
                                : TextStyle(
                                    fontFamily: fontFamily,
                                    fontSize: fontSizeXs,
                                    color: Colors.grey.shade500,
                                    fontWeight: fontWeight500),
                            autofocus: false,
                          ),
                        ),
                        //Commune
                        Padding(padding: EdgeInsets.only(top: 15)),

                        DropDownRegister(
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
                                  fontWeight: fontWeight500)
                              : TextStyle(
                                  fontFamily: fontFamily,
                                  fontSize: fontSizeXs,
                                  color: Colors.grey.shade500,
                                  fontWeight: fontWeight500),
                          readOnlys: communereadOnlys,
                          autofocus: false,
                        ),
                        //
                        Padding(padding: EdgeInsets.only(top: 15)),

                        DropDownRegister(
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
                                  fontWeight: fontWeight500)
                              : TextStyle(
                                  fontFamily: fontFamily,
                                  fontSize: fontSizeXs,
                                  color: Colors.grey.shade500,
                                  fontWeight: fontWeight500),
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
                        Padding(padding: EdgeInsets.only(top: 15)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // ignore: deprecated_member_use
                            RaisedButton(
                              onPressed: () => clear(),
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
                                    AppLocalizations.of(context)!.clean,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            // ignore: deprecated_member_use
                            RaisedButton(
                              onPressed: () {
                                if (contorllerNameRegister.text == "") {
                                  showInSnackBar(
                                      AppLocalizations.of(context)!
                                          .name_customer_require,
                                      Colors.red,
                                      _scaffoldKeyRegister);
                                }
                                if (contorllerPhoneNumberRegister.text == "") {
                                  showInSnackBar(
                                      AppLocalizations.of(context)!
                                          .phone_customer_require,
                                      Colors.red,
                                      _scaffoldKeyRegister);
                                }
                                if (selectedValueCurrencies == "") {
                                  showInSnackBar(
                                      AppLocalizations.of(context)!
                                          .currency_require,
                                      Colors.red,
                                      _scaffoldKeyRegister);
                                }
                                if (controllerAmountRegister.text == "") {
                                  showInSnackBar(
                                      AppLocalizations.of(context)!
                                          .amount_customer_require,
                                      Colors.red,
                                      _scaffoldKeyRegister);
                                }
                                if (controllerLoanPourposeRegister.text == "") {
                                  showInSnackBar(
                                      AppLocalizations.of(context)!
                                          .loan_purpose_require,
                                      Colors.red,
                                      _scaffoldKeyRegister);
                                }
                                if (selectedValueVillage == "" ||
                                    selectedValueVillage == "Village Code") {
                                  setState(() {
                                    validateVillage = true;
                                  });
                                  showInSnackBar(
                                      AppLocalizations.of(context)!
                                          .address_require,
                                      Colors.red,
                                      _scaffoldKeyRegister);
                                }
                                if (contorllerNameRegister.text != "" &&
                                    contorllerPhoneNumberRegister.text != "" &&
                                    selectedValueCurrencies != "" &&
                                    controllerAmountRegister.text != "" &&
                                    controllerLoanPourposeRegister.text != "" &&
                                    selectedValueVillage != "" &&
                                    selectedValueVillage != "Village Code") {
                                  AwesomeDialog(
                                    width: isWeb()
                                        ? widthView(context, 0.3)
                                        : isIphoneX(context)
                                            ? widthView(context, 0.35)
                                            : widthView(context, 0.35),
                                    context: context,
                                    // animType: AnimType.LEFTSLIDE,
                                    headerAnimationLoop: false,
                                    dialogType: DialogType.SUCCES,
                                    title: AppLocalizations.of(context)!
                                        .information,
                                    desc: AppLocalizations.of(context)!
                                        .do_you_want_to,
                                    btnOkOnPress: () {
                                      createCustomer();
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
                                        // AppLocalizations.of(context)
                                        //         .translate('yes') ??
                                        AppLocalizations.of(context)!.yes,
                                  )..show();
                                }
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
                                    AppLocalizations.of(context)!.register,
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
