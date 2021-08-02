import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AssignUserProvider with ChangeNotifier {
  Future fetchAssignUser(idBranch) async {
    final storage = await SharedPreferences.getInstance();

    String level = (await storage.getString('level'))!;
    // final Map<String, dynamic> bodyRaw = {
    //   "idBranch": "$idBranch",
    //   "levelUser": "$level"
    // };
    try {
      // final Response response = await api().post(
      //   Uri.parse(baseURLInternal + 'CcfcustAsigs/' + idBranch + "/" + level),
      //   headers: {
      //     "content-type": "application/json",
      //     "accept": "*/*",
      //   },
      //   body: json.encode(bodyRaw),
      // );
      // final parsed = jsonDecode(response.body);
      // notifyListeners();
      // return parsed;

      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'POST',
          Uri.parse(
              baseURLInternal + 'CcfcustAsigs/' + idBranch + "/" + level));
      request.body =
          json.encode({"idBranch": "$idBranch", "levelUser": "$level"});
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

  Future insertInToTableAssignUser(cid, tuid) async {
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
    try {
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

  Future requestAssignDisbursement(cid, tuid) async {
    final storage = await SharedPreferences.getInstance();

    var uid = await storage.getString('user_id');

    final Map<String, dynamic> bodyRaw = {
      "cid": "$cid",
      "fuid": "$uid",
      "tuid": "$tuid",
      "status": "Request Disbursement"
    };
    try {
      //
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse(baseURLInternal + 'CcfcustAsigs'));

      request.body = json.encode({
        "cid": "$cid",
        "fuid": "$uid",
        "tuid": "$tuid",
        "status": "Request Disbursement"
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 201) {
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

  Future getDetail(cid) async {
    try {
      // final Response response = await api().get(
      //   Uri.parse(baseURLInternal + 'CcfcustAsigs/' + cid),
      //   headers: {
      //     "content-type": "application/json",
      //     "accept": "*/*",
      //   },
      // );
      // final parsed = jsonDecode(response.body);
      // return parsed;

      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'GET', Uri.parse(baseURLInternal + 'CcfcustAsigs/' + cid));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final parsed = jsonDecode(await response.stream.bytesToString());

        notifyListeners();
        return parsed;
      } else {
        print(response.reasonPhrase);
      }
    } catch (error) {
      logger().e("error: $error");
    }
  }
}
