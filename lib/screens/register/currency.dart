import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';

class CurrencyComponent extends StatelessWidget {
  var icons;
  var keys;
  var childs;
  var imageIcon;
  var colors;
  var shapes;
  var imageColor;
  var elevations;
  CurrencyComponent(
      {this.icons,
      this.childs,
      this.keys,
      this.imageIcon,
      this.colors,
      this.shapes,
      this.imageColor,
      this.elevations});
  @override
  Widget build(BuildContext context) {
    return Container(
      // elevation: elevations,
      // shape: shapes ?? null,
      // color: Colors.red,
      decoration: BoxDecoration(
          border: Border.all(
            color: logolightGreen,
          ),
          borderRadius: BorderRadius.circular(5.0)),
      child: (Container(
        // color: colors ?? null,
        // decoration: BoxDecoration(
        //     border: Border(
        //         bottom: BorderSide(
        //   //                   <--- left side
        //   color: Colors.grey.shade500,
        //   width: 0.0,
        // ))),
        margin: EdgeInsets.all(0),
        padding: EdgeInsets.all(0),
        child: Container(
          padding: EdgeInsets.only(left: 10),
          height: 62,
          // width: 350,
          child: childs,
        ),
      )),
    );
  }
}
