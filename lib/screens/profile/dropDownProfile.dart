import 'package:flutter/material.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';
import 'package:select_dialog/select_dialog.dart';

class DropDownProfile extends StatelessWidget {
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
  String textTitle = "";

  bool? clear = true;

  DropDownProfile(
      {required this.readOnlys,
      required this.onInSidePress,
      required this.texts,
      required this.subTitle,
      required this.textTitle,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 1, 8, 10),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                // color: Colors.red,
                padding: EdgeInsets.only(bottom: 25),
                child: Text(
                  textTitle,
                  style: TextStyle(color: Colors.grey),
                )),
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              child: Card(
                elevation: 0.0,
                shape: validate,
                margin: EdgeInsets.only(bottom: 5.0),
                child: InkWell(
                  onTap: readOnlys ? onInSidePress : null,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                      //                   <--- left side
                      color: Colors.grey.shade500,
                      width: 0.0,
                    ))),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              height: 62,
                              child: Container(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text(
                                        texts != ""
                                            ? texts
                                            : title != ""
                                                ? title
                                                : '',
                                        style: styleTexts),
                                  ),
                                  texts != null
                                      ? Padding(padding: EdgeInsets.all(0))
                                      : Container(
                                          alignment: Alignment.bottomCenter,
                                          child: Text(
                                            validateForm,
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 10),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
