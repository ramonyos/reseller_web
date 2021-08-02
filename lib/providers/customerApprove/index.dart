import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerApprove with ChangeNotifier {
  Future clickApproveOrDisApprove(status, cid, remark, loanid, other,
      loanAmount, currencyID, currencyName) async {
    final storage = await SharedPreferences.getInstance();

    var uid = await storage.getString('user_id');
    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse(baseURLInternal + 'CcfcustApr'));
      request.body = json.encode({
        "status": "$status",
        "cid": "$cid",
        "uid": "$uid",
        "remark": "$remark",
        "u1": "$loanid",
        "u2": "$other",
        "u3": "$loanAmount",
        "u4": "$currencyID",
        "u5": "$currencyName"
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
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
