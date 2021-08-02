import 'dart:async';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ccf_reseller_web_app/providers/login/index.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/screens/home/home.dart';
import 'package:ccf_reseller_web_app/screens/profile/cardImage.dart';
import 'package:ccf_reseller_web_app/screens/profile/selectIdType.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:ccf_reseller_web_app/screens/home/home.dart';
import 'package:http/http.dart' as http;
import 'package:ccf_reseller_web_app/widgets/text_input_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as Path;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController contorllerNameProfile = new TextEditingController();
  TextEditingController controllerPhoneProfile = new TextEditingController();
  TextEditingController controllerEmailProfile = new TextEditingController();
  //
  TextEditingController controllerAddress = new TextEditingController();
  TextEditingController controllerJob = new TextEditingController();
  TextEditingController controllerNID = new TextEditingController();
  TextEditingController controllerStartDate = new TextEditingController();
  TextEditingController controllerAccountBank = new TextEditingController();

  //
  bool _isEnable = false;

  String? email;

  Future<Null> validateEmail(String value) async {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value) || value == null)
      print("invalid email");
    else
      print("valid email");
  }

  bool _isLoading = false;
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    getUser();
    super.didChangeDependencies();
  }

  Future getDocumentById() async {
    final storage = await SharedPreferences.getInstance();
    try {
      String uid = (await storage.getString('user_id'))!;
      var request = http.Request(
          'GET', Uri.parse(baseURLInternal + 'Document/ByLoan/' + uid));
      http.StreamedResponse response = await request.send();
      final respStr = await response.stream.bytesToString();
      var json = jsonDecode(respStr);

      if (response.statusCode == 200 || response.statusCode == 201) {
        for (var item in json) {
          switch (item['type']) {
            case '101':
              var uri = item['filepath'];
              var _bytes = base64.decode(uri.split(',').last);
              setState(() {
                _image1 = _bytes;
              });
              image1 = Image.memory(_bytes);

              break;
            case '102':
              var uri = item['filepath'];
              var _bytes = base64.decode(uri.split(',').last);
              setState(() {
                _image2 = _bytes;
              });
              image2 = Image.memory(_bytes);

              break;
            case '103':
              var uri = item['filepath'];
              var _bytes = base64.decode(uri.split(',').last);
              setState(() {
                _image3 = _bytes;
              });
              image3 = Image.memory(_bytes);

              break;
          }
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      logger().e("Error: $error");
    }
  }

  var listUser;
  getUser() async {
    // getReferer
    setState(() {
      _isLoading = true;
    });
    final storage = await SharedPreferences.getInstance();

    try {
      await Provider.of<RegisterRef>(context, listen: false)
          .getReferer()
          .then((value) async {
        setState(() {
          listUser =
              value != null || value[0] != null ? value[0]['ccfreferalRe'] : [];
          selectedGender = value[0]['ccfreferalRe']['gender'] == null ||
                  value[0]['ccfreferalRe']['gender'] == "null" ||
                  value[0]['ccfreferalRe']['gender'] == ""
              ? ""
              : value[0]['ccfreferalRe']['gender'];
          selectedIDType = value[0]['ccfreferalRe']['idtype'] == null ||
                  value[0]['ccfreferalRe']['idtype'] == "null" ||
                  value[0]['ccfreferalRe']['idtype'] == ""
              ? ""
              : value[0]['ccfreferalRe']['idtype'];
          controllerNID.text = value[0]['ccfreferalRe']['idnumber'] == null ||
                  value[0]['ccfreferalRe']['idnumber'] == "null" ||
                  value[0]['ccfreferalRe']['idnumber'] == ""
              ? ""
              : value[0]['ccfreferalRe']['idnumber'];
          dateOfBirth = value[0]['ccfreferalRe']['dob'] == null ||
                  value[0]['ccfreferalRe']['dob'] == "null" ||
                  value[0]['ccfreferalRe']['dob'] == ""
              ? ""
              : value[0]['ccfreferalRe']['dob'];
          controllerPhoneProfile.text =
              value[0]['ccfreferalRe']['refphone'] != null
                  ? value[0]['ccfreferalRe']['refphone']
                  : "";
          // _isSelectedBank = listUser['typeaccountbank'];
          controllerAccountBank.text =
              value[0]['ccfreferalRe']['typeaccountnumber'] == null ||
                      value[0]['ccfreferalRe']['typeaccountnumber'] == "null" ||
                      value[0]['ccfreferalRe']['typeaccountnumber'] == ""
                  ? ""
                  : value[0]['ccfreferalRe']['typeaccountnumber'];
        });
        var refererCode = value[0]['ccfreferalRe']['refcode'] != null
            ? value[0]['ccfreferalRe']['refcode']
            : "";
        await storage.setString("refcode", refererCode);
        getDocumentById();
      }).catchError((onError) {
        logger().e("onError: ${onError}");
      });
    } catch (error) {
      logger().e("error: ${error}");
    }
  }

  final StreamController<bool> streamController =
      StreamController<bool>.broadcast();
  Future<dynamic> updateUserProfile() async {
    var name = contorllerNameProfile.text != ""
        ? contorllerNameProfile.text
        : listUser['refname'];

    setState(() {
      _isLoading = true;
    });
    try {
      final storage = await SharedPreferences.getInstance();

      var uid = await storage.getString('user_id');
      var dob;
      if (dateOfBirth == null || dateOfBirth == "") {
        dob = "";
      } else {
        dob = getDateTimeYMD(dateOfBirth.toString());
      }

      var phone;
      // if (listUser['refphone'] != 0 ||
      //     listUser['refphone'] != "" ||
      //     listUser['refphone'] != null) {
      //   phone = listUser['refphone'];
      // } else {
      //   phone = controllerPhoneProfile.text;
      // }

      if (controllerPhoneProfile.text == "") {
        phone = listUser['refphone'];
      } else {
        phone = controllerPhoneProfile.text;
      }

      var gender;
      if (selectedGender != "") {
        gender = selectedGender;
      } else {
        gender = listUser['gender'];
      }
      var typeBank = _isSelectedBank != null
          ? _isSelectedBank['name']
          : listUser["typeaccountbank"];
      var request = http.MultipartRequest(
          'POST', Uri.parse(baseURLInternal + 'Document'));
      request.fields.addAll({
        'ucode': '${uid}',
        'typeaccountbank': '${typeBank}',
        'typeaccountnumber': '${controllerAccountBank.text}',
        'idtype': '$selectedIDType',
        'idnumber': '${controllerNID.text}',
        'dob': '$dob',
        'phone': '$phone',
        'username': '$name',
        'gender': '$gender'
      });
      Map<String, String> mediaType = {
        'image': "jpg",
        'image': "jpeg",
        'image': "jpe"
      };
      //
      var stream;
      int length;
      if (_image1 != null) {
        stream =
            // ignore: deprecated_member_use
            new http.ByteStream(DelegatingStream.typed(_image1.openRead()));
        length = fileName1.length;
        request.files.add(new http.MultipartFile('kyc[101]', stream, length,
            filename: Path.basename(fileName1),
            contentType: MediaType('image', 'png', mediaType)));
      }
      var stream2;
      var length2;
      if (_image2 != null) {
        stream2 =
            // ignore: deprecated_member_use
            new http.ByteStream(DelegatingStream.typed(_image2!.openRead()));
        length2 = fileName2.length;
        request.files.add(new http.MultipartFile('kyc[102]', stream2, length2,
            filename: Path.basename(fileName2),
            contentType: MediaType('image', 'png', mediaType)));
      }
      var stream3;
      int length3;
      if (_image3 != null) {
        stream3 =
            // ignore: deprecated_member_use
            new http.ByteStream(DelegatingStream.typed(_image3!.openRead()));
        length3 = fileName3.length;
        request.files.add(new http.MultipartFile('kyc[103]', stream3, length3,
            filename: Path.basename(fileName3),
            contentType: MediaType('image', 'png', mediaType)));
      }
      await request.send().then((http.StreamedResponse response) async {
        // ignore: unnecessary_null_comparison
        if (response != null) {
          setState(() {
            _isLoading = false;
          });
          if (response.statusCode == 200 || response.statusCode == 201) {
            showInSnackBar(AppLocalizations.of(context)!.successfully,
                logolightGreen, _scaffoldKeyProfile);
          } else {
            var json = jsonDecode(await response.stream.bytesToString());

            showInSnackBar(json['value'], Colors.red, _scaffoldKeyProfile);
          }
        }
      }).catchError((onError) {
        setState(() {
          _isLoading = false;
        });
        showInSnackBar(onError.toString(), Colors.red, _scaffoldKeyProfile);
      });
    } catch (error) {
      showInSnackBar(error.toString(), Colors.red, _scaffoldKeyProfile);
      setState(() {
        _isLoading = false;
      });
      showInSnackBar(
          AppLocalizations.of(context)!.error, Colors.red, _scaffoldKeyProfile);
    }
  }

  GlobalKey<ScaffoldState> _scaffoldKeyProfile = new GlobalKey<ScaffoldState>();
  //
  String selectedIDType = "";
  String selectedGender = "";

  final GlobalKey<FormBuilderState> idTypeKey = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> genderKey = GlobalKey<FormBuilderState>();

  UnfocusDisposition disposition = UnfocusDisposition.scope;

  //show dailog input account bank
  bool _isSelectedBankAccountPPCBank = false;
  bool _isSelectedBankAccountWing = false;
  bool _isSelectedBankAccountAcleda = false;

  String codeDialogPPCBank = "";
  String codeDialogWing = "";
  String codeDialogAcleda = "";

  String valueTextPPCBank = "";
  String valueTextWing = "";
  String valueTextAcleda = "";

  // ignore: unused_element
  Future _onBackPressed() async {
    AwesomeDialog(
        context: context,
        // animType: AnimType.LEFTSLIDE,
        headerAnimationLoop: false,
        dialogType: DialogType.INFO,
        title: AppLocalizations.of(context)!.information,
        desc: AppLocalizations.of(context)!.do_you_want_to_leave,
        btnOkOnPress: () async {
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => HomeScreen()),
                ModalRoute.withName('/'));
          });
        },
        btnCancelText: AppLocalizations.of(context)!.no,
        btnCancelOnPress: () {},
        btnCancelIcon: Icons.close,
        btnOkIcon: Icons.check_circle,
        btnOkColor: logolightGreen,
        btnOkText: AppLocalizations.of(context)!.yes)
      ..show();
  }

  //Select Date of Birth
  showPickerDate(BuildContext context) {
    Picker(
        confirmTextStyle:
            TextStyle(color: logolightGreen, fontSize: fontSizeSm),
        cancelTextStyle: TextStyle(fontSize: fontSizeSm, color: logoDarkBlue),
        hideHeader: true,
        adapter: DateTimePickerAdapter(
          yearEnd: 2003,
        ),
        title: Text(AppLocalizations.of(context)!.select_date_of_birth),
        selectedTextStyle: TextStyle(
          color: logolightGreen,
        ),
        onConfirm: (Picker picker, List value) {
          setState(() {
            dateOfBirth = (picker.adapter as DateTimePickerAdapter).value;
          });
        }).showDialog(context);
  }

  dynamic dateOfBirth = "";
  //

  var _isSelectedBank;
  //

  List user = [
    {
      "name": "PPCBank",
      "image": "assets/images/ppcbank.png",
    },
    {
      "name": "ACLEDA Bank",
      "image": "assets/images/acleda.png",
    },
    {
      "name": "Wing",
      "image": "assets/images/wing.png",
    },
  ];
  //upload image
  // ignore: unnecessary_question_mark
  dynamic? _image1;
  // ignore: unnecessary_question_mark
  dynamic? _image2;
  // ignore: unnecessary_question_mark
  dynamic? _image3;
  String option1Text = "";
  String option2Text = "";
  String option3Text = "";
  dynamic url;
  dynamic fileName1;
  dynamic fileName2;
  dynamic fileName3;
  String? path1;
  String? path2;
  String? path3;
  dynamic image1;
  dynamic image2;
  dynamic image3;

  uploadImage1() async {
    //
    final PickedFile? pickedFile =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        if (isWeb()) {
          _image1 = PickedFile(pickedFile.path); // Exception occurred here
          fileName1 = pickedFile.path;
          // Check if this is a browser session
          image1 = Image.network(pickedFile.path);
          print("fileName1 : ${fileName1.length}");
        } else {
          // image1 = Image.file(File(pickedFile.path));
        }
      } else {
        print("No image selected");
      }
    });
    return null;
    //
  }

  //upload image 2
  uploadImage2() async {
    //
    final PickedFile? pickedFile =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        if (isWeb()) {
          _image2 = PickedFile(pickedFile.path);
          // Check if this is a browser session
          fileName2 = pickedFile.path;

          image2 = Image.network(pickedFile.path);
        } else {
          // image2 = Image.file(PickedFile(pickedFile.path));
        }
      } else {
        print("No image selected");
      }
    });
    return null;
    //
  }

  uploadImage3() async {
    final PickedFile? pickedFile =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        // Check if this is a browser session
        if (isWeb()) {
          _image3 = PickedFile(pickedFile.path);
          fileName3 = pickedFile.path;
          image3 = Image.network(pickedFile.path);
        } else {
          // image3 = Image.file(File(pickedFile.path));`
        }
      } else {
        print("No image selected");
      }
    });
    return null;
  }

  //
  @override
  Widget build(BuildContext context) {
    String status = "GG";
    if (listUser != null) {
      if (listUser != null || listUser['verifystatus'] == "R") {
        status = AppLocalizations.of(context)!.request;
      } else if (listUser['verifystatus'] != "R") {
        status = listUser['verifystatus'];
      } else {
        status = AppLocalizations.of(context)!.not_yet_verify;
      }
    }

    return Scaffold(
        key: _scaffoldKeyProfile,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            AppLocalizations.of(context)!.update_profile,
            style: TextStyle(color: logolightGreen),
          ),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: logolightGreen,
              ),
              onPressed: () {
                if (_isEnable == true) {
                  _onBackPressed();
                } else {
                  Navigator.pop(context);
                }
              }),
          actions: <Widget>[
            // ignore: deprecated_member_use
            _isLoading || listUser == null
                ? Center()
                // : Image.memory(_image1)
                : Container(
                    // color: Colors.blue,
                    width: 100,
                    alignment: Alignment.center,
                    child: Text(
                      status,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: listUser != null &&
                                  listUser['verifystatus'] == "R"
                              ? logoDarkBlue
                              : logolightGreen),
                    ),
                  ),
          ],
        ),
        body: _isLoading || listUser == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            // : Image.memory(_image1)
            : SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: isWeb()
                        ? widthView(context, 0.7)
                        : isIphoneX(context)
                            ? widthView(context, 1)
                            : null,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          flex: 0,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                            child: Stack(
                              children: <Widget>[
                                Card(
                                  elevation: 10.0,
                                  shape: CircleBorder(),
                                  clipBehavior: Clip.antiAlias,
                                  child: CircleAvatar(
                                    radius: 70,
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/1024.png',
                                        height: 150,
                                        width: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Colors.white, Colors.white],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  padding: EdgeInsets.only(left: 0, bottom: 10),
                                  child: Text(
                                      AppLocalizations.of(context)!.profile,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: fontSizeXs))),
                              Card(
                                elevation: 5.0,
                                child: Container(
                                  child: Column(
                                    children: [
                                      //Text Input Profile
                                      TextInputProfile(
                                        fontAwesomeIcons: FontAwesomeIcons.user,
                                        style: TextStyle(
                                            fontSize: fontSizeXs,
                                            color: Colors.black,
                                            fontWeight: listUser != null &&
                                                    listUser['refname'] != "" &&
                                                    listUser['refname'] !=
                                                        "null" &&
                                                    listUser['refname'] != null
                                                ? FontWeight.w600
                                                : FontWeight.w400),
                                        hintText: listUser != null &&
                                                listUser['refname'] != "" &&
                                                listUser['refname'] != null
                                            ? listUser['refname']
                                            : "",
                                        hintStyle: TextStyle(
                                            fontSize: fontSizeXs,
                                            color: listUser['refname'] != "" &&
                                                    listUser['refname'] != null
                                                ? Colors.black
                                                : null),
                                        text:
                                            AppLocalizations.of(context)!.name,
                                        enabled: _isEnable,
                                        controller: contorllerNameProfile,
                                        inputFormatters: [
                                          // ignore: deprecated_member_use
                                          WhitelistingTextInputFormatter(
                                            RegExp("[a-z A-Z]"),
                                          ),
                                        ],
                                        keyboardType: TextInputType.name,
                                      ),
                                      //Phone
                                      TextInputProfile(
                                        controller: controllerPhoneProfile,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]')),
                                        ],
                                        fontAwesomeIcons:
                                            FontAwesomeIcons.phoneAlt,
                                        hintText: listUser != null
                                            ? listUser['refphone']
                                            : "",
                                        hintStyle: TextStyle(
                                            fontSize: fontSizeXs,
                                            color: listUser != null &&
                                                    listUser['refphone'] != ""
                                                ? Colors.black
                                                : null),
                                        style: TextStyle(
                                            fontSize: fontSizeXs,
                                            color: Colors.black,
                                            fontWeight: listUser != null &&
                                                    listUser['refphone'] != ""
                                                ? FontWeight.w600
                                                : null),
                                        text:
                                            AppLocalizations.of(context)!.phone,
                                        enabled: _isEnable,
                                      ),
                                      // //Gender
                                      SelectIdType(
                                        enabled: _isEnable,
                                        keys: genderKey,
                                        elevations: 0.0,
                                        childs: FormBuilderDropdown(
                                          enabled: _isEnable,
                                          decoration: InputDecoration(
                                            focusedBorder:
                                                UnderlineInputBorder(),
                                            enabledBorder: UnderlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(0.0)),
                                                borderSide: BorderSide(
                                                    color: _isEnable
                                                        ? logolightGreen
                                                        : Colors
                                                            .grey.shade300)),
                                            border: UnderlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(0.0)),
                                                borderSide: BorderSide(
                                                    color: Color(0xff0ABAB5))),
                                            prefixIcon: Icon(
                                              FontAwesomeIcons.venusDouble,
                                              color: logolightGreen,
                                            ),
                                            // labelText: AppLocalizations.of(context)!
                                            //     .gender,
                                          ),
                                          validator:
                                              FormBuilderValidators.compose([
                                            FormBuilderValidators.required(
                                                context,
                                                errorText: AppLocalizations.of(
                                                            context)!
                                                        .gender +
                                                    "*"),
                                          ]),
                                          icon: Icon(
                                            FontAwesomeIcons.edit,
                                            color: Colors.white,
                                          ),
                                          hint: Text(
                                            selectedGender != "" &&
                                                    selectedGender != null
                                                ? selectedGender.toString()
                                                : AppLocalizations.of(context)!
                                                    .gender,
                                            style: TextStyle(
                                                fontSize: fontSizeXs,
                                                color: selectedGender != "" &&
                                                            selectedGender !=
                                                                null ||
                                                        listUser != null &&
                                                            listUser[
                                                                    'gender'] !=
                                                                "" &&
                                                            listUser[
                                                                    'gender'] !=
                                                                null
                                                    ? Colors.black
                                                    : _isEnable == true
                                                        ? Colors.grey.shade700
                                                        : Colors.grey,
                                                fontWeight: selectedGender !=
                                                            "" &&
                                                        selectedGender != null
                                                    ? FontWeight.w600
                                                    : null),
                                          ),
                                          items: ['Female', 'Male']
                                              .map((e) => DropdownMenuItem(
                                                    value: e.toString(),
                                                    onTap: () => {
                                                      if (mounted)
                                                        {
                                                          setState(() {
                                                            selectedGender = e;
                                                          }),
                                                          FocusScope.of(context)
                                                              .unfocus(
                                                                  disposition:
                                                                      disposition),
                                                        }
                                                    },
                                                    child: Text("${e}"),
                                                  ))
                                              .toList(),
                                          name: 'name',
                                        ),
                                      ),
                                      // //ID Type
                                      SelectIdType(
                                        enabled: _isEnable,
                                        keys: idTypeKey,
                                        elevations: 0.0,
                                        childs: FormBuilderDropdown(
                                          iconDisabledColor: logolightGreen,
                                          iconEnabledColor: logolightGreen,
                                          enabled: _isEnable,
                                          decoration: InputDecoration(
                                            focusedBorder:
                                                UnderlineInputBorder(),
                                            enabledBorder: UnderlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(0.0)),
                                                borderSide: BorderSide(
                                                    color: _isEnable
                                                        ? logolightGreen
                                                        : Colors
                                                            .grey.shade300)),
                                            border: UnderlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(0.0)),
                                                borderSide: BorderSide(
                                                    color: Color(0xff0ABAB5))),
                                            prefixIcon: Icon(
                                              FontAwesomeIcons.idCardAlt,
                                              color: logolightGreen,
                                            ),
                                            // labelText: AppLocalizations.of(context)!
                                            //     .id_type,
                                          ),
                                          validator:
                                              FormBuilderValidators.compose([
                                            FormBuilderValidators.required(
                                                context,
                                                errorText: AppLocalizations.of(
                                                            context)!
                                                        .id_type +
                                                    "*"),
                                          ]),
                                          icon: Icon(FontAwesomeIcons.list,
                                              color: Colors.white),
                                          hint: Text(
                                            selectedIDType != "" &&
                                                    selectedIDType != null
                                                ? selectedIDType
                                                : AppLocalizations.of(context)!
                                                    .id_type,
                                            style: TextStyle(
                                                fontSize: fontSizeXs,
                                                color: selectedIDType != "" &&
                                                        selectedIDType != null
                                                    ? Colors.black
                                                    : _isEnable
                                                        ? Colors.grey.shade700
                                                        : Colors.grey,
                                                fontWeight: selectedIDType !=
                                                            "" &&
                                                        selectedIDType != null
                                                    ? FontWeight.w600
                                                    : null),
                                          ),
                                          items: [
                                            'National Identity',
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
                                                          FocusScope.of(context)
                                                              .unfocus(
                                                                  disposition:
                                                                      disposition),
                                                        }
                                                    },
                                                    child: Text("${e}"),
                                                  ))
                                              .toList(),
                                          name: 'name',
                                        ),
                                      ),
                                      TextInputProfile(
                                        style: TextStyle(
                                            fontSize: fontSizeXs,
                                            color: Colors.black,
                                            fontWeight: listUser != null &&
                                                    listUser['idnumber'] != ""
                                                ? FontWeight.w600
                                                : null),
                                        fontAwesomeIcons:
                                            FontAwesomeIcons.idBadge,
                                        hintText: AppLocalizations.of(context)!
                                            .id_number,
                                        text: AppLocalizations.of(context)!
                                            .id_number,
                                        // AppLocalizations.of(context)!.name,
                                        enabled: _isEnable,
                                        controller: controllerNID,
                                        inputFormatters: [
                                          // ignore: deprecated_member_use
                                          WhitelistingTextInputFormatter(
                                            RegExp("[0-9]"),
                                          ),
                                        ],
                                        keyboardType: TextInputType.datetime,
                                      ),
                                      // //Date of birth
                                      Container(
                                        padding: EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                      bottom: 15),
                                              width: isWeb()
                                                  ? widthView(context, 0.67)
                                                  : isIphoneX(context)
                                                      ? widthView(context, 0.9)
                                                      : widthView(context, 0.9),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                    //                   <--- left side
                                                    color: _isEnable
                                                        ? logolightGreen
                                                        : Colors.grey.shade400,
                                                    width: _isEnable == false
                                                        ? 0.5
                                                        : 0.9,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                    left: isWeb() ? 10 : 10,
                                                  )),
                                                  Icon(
                                                    FontAwesomeIcons
                                                        .calendarAlt,
                                                    color: logolightGreen,
                                                  ),
                                                  TextButton(
                                                    onPressed:
                                                        _isEnable == false
                                                            ? null
                                                            : () {
                                                                showPickerDate(
                                                                    context);
                                                              },
                                                    child: Container(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          dateOfBirth != null &&
                                                                  dateOfBirth !=
                                                                      ""
                                                              ? getDateTimeYMD(
                                                                  dateOfBirth
                                                                      .toString())
                                                              : AppLocalizations
                                                                      .of(context)!
                                                                  .date_of_birth,
                                                          style: TextStyle(
                                                              color: _isEnable ==
                                                                      true
                                                                  ? Colors.grey
                                                                      .shade700
                                                                  : dateOfBirth == null ||
                                                                          dateOfBirth ==
                                                                              "null" ||
                                                                          dateOfBirth ==
                                                                              ""
                                                                      ? Colors
                                                                          .grey
                                                                          .shade700
                                                                      : Colors
                                                                          .black,
                                                              fontWeight: dateOfBirth !=
                                                                          null &&
                                                                      dateOfBirth !=
                                                                          ""
                                                                  ? fontWeight700
                                                                  : fontWeight400,
                                                              fontSize:
                                                                  fontSizeXs),
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(padding: EdgeInsets.all(5)),
                                      //select bank
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10, bottom: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(
                                                left: isWeb() ? 10 : 15,
                                              ),
                                              decoration: BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                //                   <--- left side
                                                color: _isEnable
                                                    ? logolightGreen
                                                    : Colors.grey.shade400,
                                                width: _isEnable == false
                                                    ? 0.5
                                                    : 0.9,
                                              ))),
                                              width: isWeb()
                                                  ? widthView(context, 0.67)
                                                  : isIphoneX(context)
                                                      ? widthView(context, 0.9)
                                                      : widthView(context, 0.9),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        right: 13),
                                                    child: Icon(
                                                      FontAwesomeIcons.landmark,
                                                      color: logolightGreen,
                                                      size: 20.09,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: DropdownButton(
                                                      // underline: ,
                                                      underline: Container(),
                                                      icon: Icon(
                                                        FontAwesomeIcons.list,
                                                        color: Colors.white,
                                                      ),
                                                      hint: Text(
                                                        listUser != null &&
                                                                listUser[
                                                                        'typeaccountbank'] !=
                                                                    "null" &&
                                                                listUser[
                                                                        'typeaccountbank'] !=
                                                                    "" &&
                                                                listUser[
                                                                        'typeaccountbank'] !=
                                                                    null
                                                            ? listUser[
                                                                'typeaccountbank']
                                                            : AppLocalizations
                                                                    .of(context)!
                                                                .select_your_bank_account,
                                                        style: TextStyle(
                                                            color: _isEnable ==
                                                                    true
                                                                ? Colors.grey
                                                                    .shade700
                                                                : listUser !=
                                                                            null &&
                                                                        listUser['typeaccountbank'] !=
                                                                            "null" &&
                                                                        listUser['typeaccountbank'] !=
                                                                            "" &&
                                                                        listUser['typeaccountbank'] !=
                                                                            null
                                                                    ? Colors
                                                                        .black
                                                                    : Colors
                                                                        .grey,
                                                            fontWeight: listUser['typeaccountbank'] !=
                                                                        "" &&
                                                                    listUser[
                                                                            'typeaccountbank'] !=
                                                                        "null" &&
                                                                    listUser[
                                                                            'typeaccountbank'] !=
                                                                        null
                                                                ? fontWeight700
                                                                : fontWeight400,
                                                            fontSize:
                                                                fontSizeXs),
                                                      ),
                                                      value: _isSelectedBank,
                                                      items: user.map((user) {
                                                        return DropdownMenuItem(
                                                          value: user,
                                                          child: Row(
                                                            children: [
                                                              Image.asset(
                                                                user['image'],
                                                                width: 30,
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(user['name']
                                                                  // style: TextStyle(
                                                                  //     color:
                                                                  //         Colors.red),
                                                                  ),
                                                            ],
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged:
                                                          _isEnable == false
                                                              ? null
                                                              : (value) {
                                                                  setState(() {
                                                                    _isSelectedBank =
                                                                        value;
                                                                  });
                                                                },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextInputProfile(
                                        style: TextStyle(
                                            fontSize: fontSizeXs,
                                            color: Colors.black,
                                            fontWeight: listUser != null &&
                                                    listUser[
                                                            'typeaccountnumber'] !=
                                                        ""
                                                ? FontWeight.w600
                                                : null),
                                        fontAwesomeIcons:
                                            FontAwesomeIcons.creditCard,
                                        hintText: AppLocalizations.of(context)!
                                            .account_number,
                                        text: AppLocalizations.of(context)!
                                            .account_number,
                                        enabled: _isEnable,
                                        controller: controllerAccountBank,
                                        inputFormatters: [
                                          // ignore: deprecated_member_use
                                          WhitelistingTextInputFormatter(
                                            RegExp("[0-9]"),
                                          ),
                                        ],
                                        keyboardType: TextInputType.datetime,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              //
                              Padding(padding: EdgeInsets.all(10)),
                              //
                              Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                      AppLocalizations.of(context)!.photos,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: fontSizeXs))),

                              Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CardImage(
                                            borderColor: _isEnable
                                                ? logolightGreen
                                                : Colors.white,
                                            text: AppLocalizations.of(context)!
                                                .upload_ID_card_front,
                                            onTaps: _isEnable == true
                                                ? () {
                                                    uploadImage1();
                                                  }
                                                : null,
                                            isImage: image1,
                                            image: _image1,
                                            onClearImage: _isEnable == true
                                                ? () {
                                                    setState(() {
                                                      _image1 = null;
                                                    });
                                                  }
                                                : null),
                                        CardImage(
                                            borderColor: _isEnable
                                                ? logolightGreen
                                                : Colors.white,
                                            text: AppLocalizations.of(context)!
                                                .upload_ID_card_back,
                                            onTaps: _isEnable == true
                                                ? () {
                                                    uploadImage2();
                                                  }
                                                : null,
                                            isImage: image2,
                                            image: _image2,
                                            onClearImage: _isEnable == true
                                                ? () {
                                                    setState(() {
                                                      _image2 = null;
                                                    });
                                                  }
                                                : null),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CardImage(
                                            borderColor: _isEnable
                                                ? logolightGreen
                                                : Colors.white,
                                            text: AppLocalizations.of(context)!
                                                .upload_ID_card_with_selfie,
                                            onTaps: _isEnable == true
                                                ? () {
                                                    uploadImage3();
                                                  }
                                                : null,
                                            isImage: image3,
                                            image: _image3,
                                            onClearImage: _isEnable == true
                                                ? () {
                                                    setState(() {
                                                      _image3 = null;
                                                    });
                                                  }
                                                : null),
                                        Text("")
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              //
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (_isEnable)
                                    Container(
                                      padding: EdgeInsets.only(
                                        right: 20,
                                      ),
                                      alignment: Alignment.centerRight,
                                      child: InkWell(
                                        onLongPress: () {},
                                        child: Text(
                                          AppLocalizations.of(context)!.cancel,
                                          style: TextStyle(
                                            fontSize: fontSizeSm,
                                            fontWeight: fontWeight700,
                                            color: logoDarkBlue,
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _isEnable = false;
                                          });
                                        },
                                      ),
                                    ),
                                  Container(
                                    padding: EdgeInsets.only(
                                      right: 20,
                                    ),
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onLongPress: () {},
                                      child: Text(
                                        _isEnable == true
                                            ? AppLocalizations.of(context)!.save
                                            : AppLocalizations.of(context)!
                                                .edit,
                                        style: TextStyle(
                                          fontSize: fontSizeSm,
                                          fontWeight: fontWeight700,
                                          color: logoDarkBlue,
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _isEnable = !_isEnable;
                                        });

                                        if (_isEnable == false) {
                                          // call api
                                          updateUserProfile();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Padding(padding: EdgeInsets.all(20)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
  }
}
