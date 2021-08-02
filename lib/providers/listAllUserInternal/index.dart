import 'dart:convert';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:http/http.dart' as http;
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListAllUserInternalProvider with ChangeNotifier {
  Future getAllUserInternal(_pageSizeParam, _pageNumberParam, sdateParam,
      edateParam, statusParam, searchParam) async {
    final storage = await SharedPreferences.getInstance();

    var levels = await storage.getString('level');

    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse(baseURLInternal + 'InterUser/all'));
      request.body = json.encode({
        "pageSize": _pageSizeParam,
        "pageNumber": _pageNumberParam,
        "uid": "",
        "sdate": "$sdateParam",
        "edate": "$edateParam",
        "status": "$statusParam",
        "level": int.parse(levels.toString()),
        "search": "$searchParam"
      });
      logger().e({
        "pageSize": _pageSizeParam,
        "pageNumber": _pageNumberParam,
        "uid": "",
        "sdate": "$sdateParam",
        "edate": "$edateParam",
        "status": "$statusParam",
        "level": int.parse(levels.toString()),
        "search": ""
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final parsed = jsonDecode(await response.stream.bytesToString());
        notifyListeners();
        return parsed;
      } else {
        logger().e(response.reasonPhrase);
      }
    } catch (error) {
      logger().e(error);
    }
  }
}
