import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextScaleFactor extends StatelessWidget {
  TextScaleFactor({
    super.key,
    required this.child,
  });
  final Widget child;
  // 上限値
  static const _maxTextScaleFactor = 1.0;
  static const _midTextScaleFactor = 1.0;
  static const _minTextScaleFactor = 1.0;
  // 端末サイズ(横幅)
  static final _minDeviceSizeWidth = 350.0;
  static final _maxDeviceSizeWidth = 400.0;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidthSize = MediaQuery.of(context).size.width;
    // print(mediaQuery);
    // 倍率の上限値
    double upperTextScaleFactor;
    // 400px以上の端末
    if (screenWidthSize >= _maxDeviceSizeWidth) {
      upperTextScaleFactor = _maxTextScaleFactor;
      // 380以上400px未満の端末
    } else if (screenWidthSize >= _minDeviceSizeWidth) {
      upperTextScaleFactor = _midTextScaleFactor;
      // 380px未満の端末
    } else {
      upperTextScaleFactor = _minTextScaleFactor;
    }
    final textScaleFactor =
        mediaQuery.textScaleFactor.clamp(0.0, upperTextScaleFactor);
    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaleFactor: textScaleFactor,
      ),
      child: child,
    );
  }
}
