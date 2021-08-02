import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';

class TextInputComponent extends StatelessWidget {
  TextInputComponent({
    this.hintText,
    @required this.labelText,
    this.icons,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onSaved,
    this.maxleng,
    this.controller,
    this.textInputAction,
    this.onChanged,
    this.enabled,
  });
  String? hintText;
  String? labelText;
  IconData? icons;
  TextInputType? keyboardType;
  var inputFormatters;
  var validator;
  var onSaved;
  int? maxleng;
  TextEditingController? controller;
  bool _isfocusedBorder = false;
  bool isEnabledBorder = false;
  dynamic textInputAction;
  var onChanged;
  bool? enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      textInputAction: TextInputAction.next,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onSaved: onSaved,
      maxLength: maxleng,
      autocorrect: false,
      autofocus: false,
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.example + ": " + labelText!,
        labelText: hintText,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(
                color: _isfocusedBorder ? Colors.red : Color(0xff0ABAB5))),
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: isEnabledBorder ? Colors.red : Color(0xff0ABAB5))),
        suffixIcon: Icon(
          icons,
          color: logolightGreen,
        ),
      ),
    );
  }
}
