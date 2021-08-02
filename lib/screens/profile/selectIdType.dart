import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';

class SelectIdType extends StatelessWidget {
  var icons;
  var keys;
  var childs;
  var imageIcon;
  var colors;
  var shapes;
  var imageColor;
  var elevations;
  bool enabled;
  SelectIdType(
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
      padding: const EdgeInsets.fromLTRB(10, 1, 10, 10),
      // width: MediaQuery.of(context).size.width * 0.75,
      // decoration: enabled
      //     ? BoxDecoration(
      //         border: Border.all(
      //           color: logolightGreen,
      //         ),
      //         borderRadius: BorderRadius.circular(0))
      //     : BoxDecoration(
      //         border: Border.all(
      //           color: Colors.grey.shade300,
      //         ),
      //         borderRadius: BorderRadius.circular(0)),
      child: (Container(
        color: colors ?? null,
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FormBuilder(
                key: keys,
                // initialValue: {
                //   'date': DateTime.now(),
                //   'accept_terms': false,
                // },
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        // padding: enabled
                        //     ? EdgeInsets.only(left: 10)
                        //     : EdgeInsets.only(left: 10),
                        width: isWeb()
                            ? widthView(context, 0.67)
                            : isIphoneX(context)
                                ? widthView(context, 0.9)
                                : widthView(context, 0.9),
                        child: childs,
                      ),
                    ])),
          ],
        ),
      )),
    );
  }
}
