import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider with ChangeNotifier {
  var successfully = false;

  Future fetchNotification(_pageSize, _pageNumber) async {
    final storage = await SharedPreferences.getInstance();

    var user_ucode = await storage.getString("user_id");

    Map<String, String> headers = {
      "content-type": "application/json",
    };
    final Map<String, dynamic> bodyRaw = {
      "pageSize": "$_pageSize",
      "pageNumber": "$_pageNumber",
      "uid": "$user_ucode",
    };
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'POST', Uri.parse(baseURLInternal + 'CcfmessagesRes/ByUser'));
      request.body = json.encode({
        "pageSize": _pageSize,
        "pageNumber": _pageNumber,
        "uid": "$user_ucode"
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

  //Read Notification
  Future postNotificationRead(id) async {
    try {
      final Response response = await api().post(
        Uri.parse(baseURLInternal + 'CcfmessagesRes/read/' + id),
        headers: {
          "contentType": "application/json",
        },
      );
      final list = jsonDecode(response.body);
      if (response.statusCode == 200) {
        successfully = true;
      } else {
        successfully = false;
      }
      notifyListeners();
      return list;
    } catch (error) {
      logger().i('error: ${error}');
    }
  }

  bool get isFetchingSuccessfullyNotification => successfully;
}
