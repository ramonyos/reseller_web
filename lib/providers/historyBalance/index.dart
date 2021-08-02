import 'dart:convert';

import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistroyBalance with ChangeNotifier {
  //
  Future fetchAllBalanceByID(pageSize, pageNumber, sdate, edate) async {
    final storage = await SharedPreferences.getInstance();

    var uid = await storage.getString('user_id');
    var refcode = await storage.getString('refcode');
    String level = (await storage.getString('level'))!;
    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse(baseURLInternal + 'transition/all'));
      request.body = json.encode({
        "pageSize": pageSize,
        "pageNumber": pageNumber,
        "uid": "$uid",
        "sdate": "",
        "edate": "",
        "status": "",
        "refcode": "$refcode",
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
