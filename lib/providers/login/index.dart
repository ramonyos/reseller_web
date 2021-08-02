import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class RegisterRef with ChangeNotifier {
  //Edit User
  Future editUser(uname, phone, email, address, job, nid) async {
    final storage = await SharedPreferences.getInstance();

    String uid = (await storage.getString('user_id'))!;
    final Map<String, dynamic> bodyRaw = {
      "uid": "$uid",
      "uname": "$uname",
      "phone": "$phone",
      "email": "$email",
      "u4": "$nid",
      "job": "$job",
      "address": "$address"
    };
    try {
      final Response response = await api().put(
        Uri.parse(baseURLInternal + 'CcfuserRes/' + uid),
        headers: {
          "content-type": "application/json",
        },
        body: json.encode(bodyRaw),
      );
      final parsed = jsonDecode(response.body);
      notifyListeners();
      return parsed;
    } catch (error) {
      logger().e("error: $error");
    }
  }

  //
  Future getReferer() async {
    final storage = await SharedPreferences.getInstance();

    String uid = (await storage.getString('user_id'))!;
    try {
      // final Response response = await api().get(
      //   Uri.parse(baseURLInternal + 'CcfreferalRes/' + uid),
      // );
      var request = http.Request(
          'GET', Uri.parse(baseURLInternal + 'CcfreferalRes/$uid'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var parsed = jsonDecode(await response.stream.bytesToString());
        notifyListeners();
        return parsed;
      } else {
        print(response.reasonPhrase);
      }
    } catch (error) {
      logger().e("error: $error");
    }
  }

  //get user by id
  Future getUserById(uidParam) async {
    final storage = await SharedPreferences.getInstance();

    String uid = "";
    if (uidParam != "") {
      uid = uidParam;
    } else {
      uid = (await storage.getString('user_id'))!;
    }
    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('GET', Uri.parse(baseURLInternal + 'CcfuserRes/' + uid));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final parsed = jsonDecode(await response.stream.bytesToString());
        notifyListeners();
        return parsed;
      } else {
        print(response.reasonPhrase);
      }
      //
    } catch (error) {
      logger().e("error: $error");
    }
  }

  Future loginReferer(phone, pwd) async {
    final Map<String, dynamic> bodyRaw = {"phone": "$phone", "pwd": "$pwd"};
    Uri url = Uri.parse(baseURLInternal + 'token');
    try {
      final Response response = await http.post(
        url,
        headers: {"content-type": "application/json"},
        body: json.encode(bodyRaw),
      );

      final parsed = jsonDecode(response.body);
      //L is mean login
      postInAppLog("LogIn");
      notifyListeners();
      return parsed;
    } catch (error) {
      logger().e("error: $error");
      // _isFetching = false;
    }
  }

  Future userLogIn() async {
    final storage = await SharedPreferences.getInstance();

    String uid = (await storage.getString('user_id'))!;

    final Map<String, dynamic> bodyRaw = {
      "uid": "$uid",
      "fdevice": "Emulator",
      "iostatus": "A",
      "ldate": ""
    };
    Uri url = Uri.parse(baseURLInternal + 'token');
    try {
      final Response response = await http.post(
        url,
        headers: {"content-type": "application/json"},
        body: json.encode(bodyRaw),
      );

      final parsed = jsonDecode(response.body);
      //L is mean login
      postInAppLog("LogIn");
      notifyListeners();
      return parsed;
    } catch (error) {
      logger().e("error: $error");
      // _isFetching = false;
    }
  }

  Future loginForStaff(phone, pwd) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('POST',
          Uri.parse(baseURLInternal + 'InterUser/$phone/loginInternal'));
      request.body = json.encode({"staffid": "$phone", "pwd": "$pwd"});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var parsed = jsonDecode(await response.stream.bytesToString());
        notifyListeners();
        return parsed;
      } else {
        print(response.reasonPhrase);
      }
    } catch (error) {
      logger().e("error: $error");
    }
  }
  //function createloginphone

  Future createLoginPhone(unameOTP, passwords, phoneOTP, otp, otpID) async {
    var uname = unameOTP;
    var uotpcode = otp;
    var phone = phoneOTP;
    var pwd = passwords;
    var u3 = otpID;
    final Map<String, dynamic> bodyRaw = {
      "uname": "$uname",
      "uotpcode": "$uotpcode",
      "phone": "$phone",
      "pwd": "$pwd",
      "u3": "$u3"
    };
    try {
      final Response response = await api().post(
        Uri.parse(baseURLInternal + 'CcfuserRes'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json'
        },
        body: json.encode(bodyRaw),
      );
      final parsed = jsonDecode(response.body);
      //L is mean login
      postInAppLog("LogIn");
      notifyListeners();
      return parsed;
    } catch (error) {
      logger().e("error: $error");
    }
  }

  Future createLoginFacebook(values, termAndCondition) async {
    var uname = values['name'];
    var uotpcode = "";
    var phone = "0";
    var pwd = "1234";
    var u1 = values['picture']['data']['url'];
    var u2 = values['email'];
    var ufacebook = values['id'];

    final Map<String, dynamic> bodyRaw = {
      "uname": "$uname",
      "uotpcode": "$uotpcode",
      "phone": "$phone",
      "pwd": "$pwd",
      "ufacebook": "$ufacebook",
      "u1": "$u1",
      "u2": "$u2",
      "u4": "${termAndCondition.toString()}"
    };

    try {
      final Response response = await api().post(
        Uri.parse(baseURLInternal + 'CcfuserRes/facebook'),
        headers: {
          "content-type": "application/json",
          "accept": "*/*",
        },
        body: json.encode(bodyRaw),
      );
      final parsed = jsonDecode(response.body);
      //L is mean login
      postInAppLog("LogIn");
      notifyListeners();
      return parsed;
    } catch (error) {
      logger().e("error: $error");
    }
  }

  //
  Future postInAppLog(status) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String fdevice = "";

    if (kIsWeb) {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      fdevice = webBrowserInfo.browserName.toString() +
          webBrowserInfo.userAgent.toString();
    } else {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        fdevice = androidInfo.model.toString();
      }
      if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        fdevice = iosInfo.utsname.machine.toString() + iosInfo.name.toString();
      }
    }

    final storage = await SharedPreferences.getInstance();
    String uid = (await storage.getString('user_id'))!;

    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse(baseURLInternal + 'CcflogRes'));
      request.body = json.encode({
        "uid": "$uid",
        "fdevice": "$fdevice",
        "iostatus": "A",
        "u1": "$status"
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var parsed = jsonDecode(await response.stream.bytesToString());
        notifyListeners();
        return parsed;
      } else {
        print(response.reasonPhrase);
      }
    } catch (error) {
      logger().e("error: $error");
    }
  }

  //
  Future resetPassword(phone) async {
    var request = http.Request(
        'GET', Uri.parse(baseURLInternal + 'CcfuserRes/$phone/phone'));

    http.StreamedResponse response = await request.send();
    // final respStr = await response.stream.bytesToString();
    // var json = jsonDecode(respStr);
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      // notifyListeners();
      // return json;
    } else {
      print(response.reasonPhrase);
    }
  }
  //
}
