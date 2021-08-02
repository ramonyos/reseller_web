import 'package:flutter/material.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:select_dialog/select_dialog.dart';

class DropDownCustomerRegister extends StatelessWidget {
  var selectedValue;
  String texts;
  bool readOnlys;
  String title;
  bool autofocus;

  VoidCallback onInSidePress;
  var onChanged;
  var items;
  var icons;
  var styleTexts;
  var iconsClose;
  var onPressed;
  var validate;
  var validateForm;
  String subTitle;
  bool enabled;
  bool? clear = true;

  DropDownCustomerRegister(
      {required this.readOnlys,
      required this.onInSidePress,
      required this.texts,
      required this.subTitle,
      required this.enabled,
      this.validate,
      this.selectedValue,
      this.onChanged,
      this.items,
      this.validateForm,
      required this.title,
      this.styleTexts,
      this.clear,
      this.iconsClose,
      this.onPressed,
      required this.autofocus,
      this.icons});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      margin: EdgeInsets.only(bottom: 5.0),
      child: InkWell(
        onTap: readOnlys ? onInSidePress : null,
        child: Container(
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
          // margin: EdgeInsets.all(5),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    height: 60,
                    padding:
                        enabled ? EdgeInsets.only(left: 10) : EdgeInsets.all(0),
                    child: Container(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(subTitle,
                            style: TextStyle(color: Colors.grey.shade400)),
                        Center(
                          child: Text(
                              texts != ""
                                  ? texts
                                  : title != ""
                                      ? title
                                      : '',
                              style: styleTexts),
                        ),
                        // Padding(padding: EdgeInsets.all(1)),
                        texts != null
                            ? Padding(padding: EdgeInsets.all(0))
                            : Container(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  validateForm,
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 10),
                                ),
                              ),
                      ],
                    )),
                  ),
                  if (clear == true)
                    Container(
                      child: IconButton(
                        icon: iconsClose ?? Icon(Icons.close),
                        color: Colors.grey,
                        onPressed: onPressed,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
