import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';

class GroupFromBuilder extends StatelessWidget {
  var icons;
  var keys;
  var childs;
  var imageIcon;
  var colors;
  var shapes;
  var imageColor;
  var elevations;
  bool enabled;
  GroupFromBuilder(
      {this.icons,
      required this.enabled,
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
      decoration: enabled
          ? BoxDecoration(
              border: Border.all(
                color: logolightGreen,
              ),
              borderRadius: BorderRadius.circular(5.0))
          : BoxDecoration(
              border: Border(
                  bottom: BorderSide(
              //                   <--- left side
              color: Colors.grey.shade500,
              width: 0.0,
            ))),
      child: (Container(
        color: colors ?? null,
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FormBuilder(
                key: keys,
                // initialValue: {
                //   'date': DateTime.now(),
                //   'accept_terms': false,
                // },
                child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: enabled
                            ? EdgeInsets.only(left: 10)
                            : EdgeInsets.all(0),
                        // width: isWeb() ? widthView(context, 0.5) : 350,
                        child: childs,
                      ),
                    ])),
          ],
        ),
      )),
    );
  }
}
