import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/ui_parts/color.dart';

class CustomAwesomeDialogue {
  String titleText = '';
  String desc = '';
  final VoidCallback callback;

  CustomAwesomeDialogue({
    required this.titleText,
    required this.desc,
    required this.callback,
  });

  void show(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      borderSide: BorderSide(
        color: kColorPrimary,
        width: 2,
      ),
      width: 400,
      buttonsBorderRadius: const BorderRadius.all(
        Radius.circular(2),
      ),
      dismissOnTouchOutside: true,
      dismissOnBackKeyPress: false,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: titleText,
      desc: desc,
      showCloseIcon: true,
      btnCancelColor: kColorSecondary,
      btnCancelOnPress: () {},
      btnOkColor: kColorPrimary,
      btnOkOnPress: () {
        callback();
      },
    ).show();
  }
}

class CustomAwesomeDialogueForSuccess {
  String titleText = '';
  String desc = '';
  // final VoidCallback callback;

  CustomAwesomeDialogueForSuccess({
    Key? key,
    required this.titleText,
    required this.desc,
    // required this.callback,
  });

  void show(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      borderSide: BorderSide(
        color: kColorPrimary,
        width: 2,
      ),
      width: 400,
      buttonsBorderRadius: const BorderRadius.all(
        Radius.circular(2),
      ),
      dismissOnTouchOutside: true,
      dismissOnBackKeyPress: false,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: titleText,
      desc: desc,
      showCloseIcon: true,
      // btnCancelColor: kColorSecondary,
      // btnCancelOnPress: () {},
      btnOkColor: kColorPrimary,
      btnOkOnPress: () {},
    ).show();
  }
}

class CustomAwesomeDialogueForFail {
  String titleText = '';
  String desc = '';
  // final VoidCallback callback;

  CustomAwesomeDialogueForFail({
    Key? key,
    required this.titleText,
    required this.desc,
    // required this.callback,
  });

  void show(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      borderSide: BorderSide(
        color: kColorPrimary,
        width: 2,
      ),
      width: 400,
      buttonsBorderRadius: const BorderRadius.all(
        Radius.circular(2),
      ),
      dismissOnTouchOutside: true,
      dismissOnBackKeyPress: false,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: titleText,
      desc: desc,
      showCloseIcon: true,
      btnCancelColor: kColorSecondary,
      btnCancelOnPress: () {},
      // btnOkColor: kColorPrimary,
      // btnOkOnPress: () {
      // callback();
      // },
    ).show();
  }
}

class CustomAwesomeDialogueForCancelReservation {
  String titleText = '';
  String desc = '';
  final Future<List<dynamic>?> Function() callback;

  CustomAwesomeDialogueForCancelReservation({
    required this.titleText,
    required this.desc,
    required this.callback,
  });

  show(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      borderSide: BorderSide(
        color: kColorPrimary,
        width: 2,
      ),
      width: 400,
      buttonsBorderRadius: const BorderRadius.all(
        Radius.circular(2),
      ),
      dismissOnTouchOutside: true,
      dismissOnBackKeyPress: false,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: titleText,
      desc: desc,
      showCloseIcon: true,
      btnCancelColor: kColorSecondary,
      btnCancelOnPress: () {},
      btnOkColor: kColorPrimary,
      btnOkOnPress: () async {
        await callback();
      },
    ).show();
  }
}

class VersionUpCustomAwesomeDialogue {
  String titleText = '';
  String desc = '';
  final VoidCallback callback;

  VersionUpCustomAwesomeDialogue({
    required this.titleText,
    required this.desc,
    required this.callback,
  });

  void show(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      borderSide: BorderSide(
        color: kColorPrimary,
        width: 2.w,
      ),
      width: 400.w,
      buttonsBorderRadius: const BorderRadius.all(
        Radius.circular(2),
      ),
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: titleText,
      desc: desc,
      // showCloseIcon: true,
      // btnCancelColor: kColorSecondary,
      // btnCancelOnPress: () {},
      btnOkColor: kColorPrimary,
      btnOkOnPress: () {
        callback();
      },
    ).show();
  }
}
