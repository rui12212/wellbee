import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/ui_parts/color.dart';

class CustomFilledButton extends StatelessWidget {
  final String labelText;
  final dynamic boolByProvider;
  final dynamic newBoolByProvider;

  CustomFilledButton(
      {super.key,
      required this.labelText,
      required this.boolByProvider,
      required this.newBoolByProvider});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: boolByProvider
          ? () {}
          : () {
              newBoolByProvider;
            },
      style: ButtonStyle(
          backgroundColor: boolByProvider
              ? MaterialStateProperty.all(kColorPrimary)
              : MaterialStateProperty.all(Color.fromARGB(255, 218, 240, 230))),
      child: Text(labelText,
          style: TextStyle(
            color: boolByProvider ? Colors.white : kColorPrimary,
            fontSize: 15.h,
            fontWeight: boolByProvider ? FontWeight.bold : FontWeight.normal,
          )),
    );
  }
}
