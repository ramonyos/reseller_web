import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';

class TextInputProfile extends StatelessWidget {
  var enabled;
  var hintText;
  var hintStyle;
  var fontAwesomeIcons;
  var controller;
  var onChanged;
  var text;
  var inputFormatters;
  var style;

  dynamic textInputAction;

  TextInputProfile(
      {this.hintText,
      this.hintStyle,
      this.style,
      this.fontAwesomeIcons,
      this.enabled,
      this.controller,
      this.onChanged,
      this.text,
      this.inputFormatters,
      this.textInputAction,
      required TextInputType keyboardType});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 1, 10, 10),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Container(
            //     // color: Colors.red,
            //     padding: EdgeInsets.only(bottom: 25),
            //     child: Text(
            //       text,
            //       style: TextStyle(color: Colors.grey),
            //     )),
            Container(
              width: isWeb()
                  ? widthView(context, 0.67)
                  : isIphoneX(context)
                      ? widthView(context, 0.9)
                      : widthView(context, 0.9),
              child: TextField(
                textInputAction: TextInputAction.next,
                inputFormatters: inputFormatters,
                onChanged: onChanged,
                controller: controller,
                enabled: enabled ?? false,
                style: style,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      // borderRadius: BorderRadius.all(Radius.circular(0.0)),
                      // borderSide: BorderSide(color: Color(0xff0ABAB5))

                      ),
                  enabledBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0.0)),
                      borderSide: BorderSide(color: Color(0xff0ABAB5))),
                  labelStyle: TextStyle(
                      color: Color(0xff0ABAB5), fontWeight: FontWeight.w600),
                  border: UnderlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0.0)),
                      borderSide: BorderSide(color: Color(0xff0ABAB5))),
                  // suffixIcon: Icon(
                  //   fontAwesomeIcons,
                  //   color: logolightGreen,
                  // ),
                  prefixIcon: Icon(
                    fontAwesomeIcons,
                    color: logolightGreen,
                  ),
                  hintText: hintText ?? "John Kim",
                  // helperText: "Name",

                  hintStyle: hintStyle,
                  // TextStyle(
                  //     color: Colors.black, fontWeight: FontWeight.w600)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
