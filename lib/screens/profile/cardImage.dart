import 'package:flutter/material.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'package:ccf_reseller_web_app/utils/const.dart';

class CardImage extends StatelessWidget {
  var text;
  var onTaps;
  var image;
  var onClearImage;
  var imageText;
  var validateImage;
  var imageDocumented;
  var borderColor;
  dynamic isImage;

  CardImage(
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
    return Container(
      width: isWeb()
          ? widthView(context, 0.3)
          : isIphoneX(context)
              ? null
              : null,
      height: isWeb()
          ? widthView(context, 0.3)
          : isIphoneX(context)
              ? null
              : null,
      child: InkWell(
        onTap: onTaps,
        child: Container(
          alignment: Alignment.center,
          // width: widthView(context, 0.45),
          // height: widthView(context, 0.41),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
            ),
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: validateImage ?? Colors.grey.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: image != null || imageDocumented != null
              ? Stack(children: <Widget>[
                  imageDocumented != null
                      ? Container(
                          height: widthView(context, 0.28),
                          child: Image.memory(imageDocumented))
                      : Container(child: isImage),
                  Positioned(
                      top: 0,
                      right: 5,
                      child: GestureDetector(
                        onTap: onClearImage,
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ))
                ])
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
      ),
    );
  }
}
