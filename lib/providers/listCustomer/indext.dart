import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ccf_reseller_web_app/providers/service/index.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Customer with ChangeNotifier {
  Future getReferalById(id) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'GET', Uri.parse(baseURLInternal + 'CcfreferalCusUps/' + id));
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

  Future getAllReferal(pageSize, pageNumber, sdate, edate, statusParam) async {
    final storage = await SharedPreferences.getInstance();

    var uid = await storage.getString('user_id');
    var level = await storage.getString('level');

    // ignore: unrelated_type_equality_checks
    String status = statusParam != null && statusParam != "" ? statusParam : "";
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'POST', Uri.parse(baseURLInternal + 'CcfreferalCusUps/all'));
      request.body = json.encode({
        "pageSize": "$pageSize",
        "pageNumber": "$pageNumber",
        "uid": "$uid",
        "sdate": "$sdate",
        "edate": "$edate",
        "status": "$status",
        "level": "$level"
      });
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

//
  Future requestCOFinal(
      userReferer,
      id,
      cidCustmer,
      custmerName,
      phoneCustomer,
      lamountCustomer,
      addressCustomer,
      nid,
      jobCustomer,
      lpourposeCustomer,
      bmCus,
      btlCus,
      coCus,
      brCus,
      tid,
      province,
      district,
      commune,
      village,
      curcodes,
      idType) async {
    logger().e("requestCOFinal:");
    final storage = await SharedPreferences.getInstance();

    //
    var uid = await storage.getString('user_id');
    //
    //
    var cname = custmerName != "" || custmerName != null ? custmerName : "";

    var cid = cidCustmer != "" || cidCustmer != null ? cidCustmer : "";
    var phone =
        phoneCustomer != "" || phoneCustomer != null ? phoneCustomer : "";

    var lamount =
        lamountCustomer != "" || lamountCustomer != null ? lamountCustomer : "";

    var lpourpose = lpourposeCustomer != "" || lpourposeCustomer != null
        ? lpourposeCustomer
        : "";

    var address =
        addressCustomer != "" || addressCustomer != null ? addressCustomer : "";
    var nationID = nid != "" || nid != null ? nid : "";
    var job = jobCustomer != "" || jobCustomer != null ? jobCustomer : "";

    //

    var btl = btlCus != "" || btlCus != null ? btlCus : "";
    var co = coCus != "" || coCus != null ? coCus : "";
    var br = brCus != "" || brCus != null ? brCus : "";

    final Map<String, dynamic> bodyRaw = {};
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'PUT', Uri.parse(baseURLInternal + 'CcfreferalCusUps/' + id));
      request.body = json.encode({
        "id": "$id",
        "uid": "$userReferer",
        "cid": "$cid",
        "cname": "$cname",
        "status": "Request Disbursement",
        "phone": "$phone",
        "lamount": lamount,
        "lpourpose": "$lpourpose",
        "address": "$address",
        "job": "$job",
        "bm": "$bmCus",
        "btl": "$btl",
        "br": "$br",
        "co": "$co",
        "u2": "$nationID",
        "u3": "$uid",
        "u4": "t",
        "u5": "$tid",
        "province": "$province",
        "district": "$district",
        "commune": "$commune",
        "village": "$village",
        "curcode": "$curcodes",
        "idtype": "$idType"
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
      // _isFetching = false;
    }
  }

  //
  Future updateListCustomer(
      userReferer,
      id,
      cidCustmer,
      custmerName,
      phoneCustomer,
      lamountCustomer,
      addressCustomer,
      nid,
      jobCustomer,
      lpourposeCustomer,
      bmCus,
      btlCus,
      coCus,
      brCus,
      tid,
      province,
      district,
      commune,
      village,
      curcodes,
      idType) async {
    final storage = await SharedPreferences.getInstance();

    //
    var uid = await storage.getString('user_id');
    //
    //
    var cname = custmerName != "" || custmerName != null ? custmerName : "";

    var cid = cidCustmer != "" || cidCustmer != null ? cidCustmer : "";
    var phone =
        phoneCustomer != "" || phoneCustomer != null ? phoneCustomer : "";

    var lamount =
        lamountCustomer != "" || lamountCustomer != null ? lamountCustomer : "";

    var lpourpose = lpourposeCustomer != "" || lpourposeCustomer != null
        ? lpourposeCustomer
        : "";

    var address =
        addressCustomer != "" || addressCustomer != null ? addressCustomer : "";
    var nationID = nid != "" || nid != null ? nid : "";
    var job = jobCustomer != "" || jobCustomer != null ? jobCustomer : "";

    //

    var btl = btlCus != "" || btlCus != null ? btlCus : "";
    var co = coCus != "" || coCus != null ? coCus : "";
    var br = brCus != "" || brCus != null ? brCus : "";
    var toUser = null;
    if (tid == null || tid == "") {
      toUser == null;
    } else {
      toUser = tid;
    }

    final Map<String, dynamic> bodyRaw = {
      "id": "$id",
      "uid": "$userReferer",
      "cid": "$cid",
      "cname": "$cname",
      "status": "P",
      "phone": "$phone",
      "lamount": lamount,
      "lpourpose": "$lpourpose",
      "address": "$address",
      "job": "$job",
      "bm": "$bmCus",
      "btl": "$btl",
      "br": "$br",
      "co": "$co",
      "u2": "$nationID",
      "u3": "$uid",
      "u4": "t",
      "u5": toUser,
      "province": "$province",
      "district": "$district",
      "commune": "$commune",
      "village": "$village",
      "curcode": "$curcodes",
      "idtype": "$idType"
    };
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'PUT', Uri.parse(baseURLInternal + 'CcfreferalCusUps/' + id));
      request.body = json.encode({
        "id": "$id",
        "uid": "$userReferer",
        "cid": "$cid",
        "cname": "$cname",
        "status": "P",
        "phone": "$phone",
        "lamount": lamount,
        "lpourpose": "$lpourpose",
        "address": "$address",
        "job": "$job",
        "bm": "$bmCus",
        "btl": "$btl",
        "br": "$br",
        "co": "$co",
        "u2": "$nationID",
        "u3": "$uid",
        "u4": "t",
        "u5": "$tid",
        "province": "$province",
        "district": "$district",
        "commune": "$commune",
        "village": "$village",
        "curcode": "$curcodes",
        "idtype": "$idType"
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
      return error;
    }
  }

  //Create customer
  Future createReferalCustomer(
      custmerName,
      phoneCustomer,
      lamountCustomer,
      lpourposeCustomer,
      addressCustomer,
      province,
      district,
      commune,
      village,
      curcode) async {
    final storage = await SharedPreferences.getInstance();

    //
    var uid = await storage.getString('user_id');
    var refcode = await storage.getString('refcode');
    //
    var cname = custmerName != "" || custmerName != null ? custmerName : "";
    var phone =
        phoneCustomer != "" || phoneCustomer != null ? phoneCustomer : "";

    int lamount = lamountCustomer != "" && lamountCustomer != null
        ? int.parse(lamountCustomer)
        : 0;

    var lpourpose = lpourposeCustomer != "" || lpourposeCustomer != null
        ? lpourposeCustomer
        : "";

    var address =
        addressCustomer != "" || addressCustomer != null ? addressCustomer : "";

    // var bodyRaw =
    //     '''{\n    "refcode":"$refcode",\n    "uid":"$uid",\n    "cname":"$cname",\n    "phone":"$phone",\n    "lamount":$lamount,\n    "lpourpose":"$lpourpose",\n    "u4":"$address"\n\n}''';
    final Map<String, dynamic> bodyRaw = {
      "refcode": "$refcode",
      "uid": "$uid",
      "cname": "$cname",
      "phone": "$phone",
      "lamount": lamount,
      "lpourpose": "$lpourpose",
      "u4": "$address",
      "province": "$province",
      "district": "$district",
      "commune": "$commune",
      "village": "$village",
      "curcode": "$curcode"
    };
    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse(baseURLInternal + 'CcfreferalCus'));
      request.body = json.encode({
        "refcode": "$refcode",
        "uid": "$uid",
        "cname": "$cname",
        "phone": "$phone",
        "lamount": lamount,
        "lpourpose": "$lpourpose",
        "u4": "$address",
        "province": "$province",
        "district": "$district",
        "commune": "$commune",
        "village": "$village",
        "curcode": "$curcode"
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
      // _isFetching = false;
    }
  }
}
