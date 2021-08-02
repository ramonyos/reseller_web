import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';

class TextInputRegister extends StatelessWidget {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  var hintText;
  var prefixIcon;
  var obscureText;
  var controller;
  TextInputRegister(
      {this.controller,
      this.hintText,
      this.obscureText,
      this.prefixIcon,
      required this.style});

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText ?? true,
      controller: controller,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white,
          ),
          prefixIcon: prefixIcon,
          labelStyle: TextStyle(color: Colors.white),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: logoDarkBlue)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(32.0)),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(32.0))),
    );
  }
}
