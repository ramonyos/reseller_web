import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyProvider with ChangeNotifier {
  //
  Future fetchAllVerifyAccount(
      pageSize, pageNumber, sdate, edate, status) async {
    final storage = await SharedPreferences.getInstance();

    var uid = await storage.getString('user_id');
    String level = (await storage.getString('level'))!;

    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse(baseURLInternal + 'CcfuserRes/all'));
      String changeStatus = "";
      if (status != null || status != "") {
        changeStatus = status;
      } else {
        changeStatus = "R";
      }
      request.body = json.encode({
        "pageSize": pageSize,
        "pageNumber": pageNumber,
        "uid": "",
        "sdate": "",
        "edate": "",
        "status": "",
        "level": level
      });
      request.headers.addAll(headers);
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
}
