import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:http/http.dart' as http;

class BranchProvider with ChangeNotifier {
  Future fetchBranch() async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('GET', Uri.parse(baseURLInternal + 'Branch/all'));
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
