import 'package:flutter/material.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';

class CardImageVerifyAccount extends StatelessWidget {
  var text;
  var onTaps;
  var image;
  var onClearImage;
  var imageText;
  var validateImage;
  var imageDocumented;
  var borderColor;
  dynamic isImage;

  CardImageVerifyAccount(
      {this.validateImage,
      this.borderColor,
      this.text,
      this.onTaps,
      this.image,
      this.imageDocumented,
      this.onClearImage,
      this.imageText,
      this.isImage});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTaps,
      child: Container(
        alignment: Alignment.center,
        width: isWeb() ? widthView(context, 0.85) : widthView(context, 0.95),
        height: isWeb() ? widthView(context, 0.37) : widthView(context, 0.7),
        decoration: BoxDecoration(
          // border: Border.all(
          //   color: borderColor,
          // ),
          // color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0)),
          boxShadow: [
            BoxShadow(
              color: validateImage ?? Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 7,
              offset: Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: image != null || imageDocumented != null
            ? Container(child: isImage)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 110,
                    alignment: Alignment.center,
                    child: Text(
                      text,
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                  ),
                  Icon(
                    Icons.add_a_photo,
                    color: logolightGreen,
                  )
                ],
              ),
      ),
    );
  }
}
