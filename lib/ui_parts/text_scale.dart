import 'package:flutter/material.dart';

/// アプリ全体で OS の文字サイズ拡大設定を無効化するラッパー。
///
/// `MaterialApp.builder` で全画面をラップして使う。`textScaler` を
/// 1.0 までにクランプすることで、ユーザーの OS 設定（Android Font size /
/// iOS Dynamic Type）でテキストが拡大してもレイアウトが崩れないようにする。
///
/// Flutter 3.16+ で deprecated になった `textScaleFactor` ではなく、
/// 新しい `TextScaler` API を使用している。
class TextScaleFactor extends StatelessWidget {
  const TextScaleFactor({
    super.key,
    required this.child,
  });

  final Widget child;

  /// 許容する最大スケール。1.0 = 拡大不可。
  static const double _maxScale = 1.0;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: mediaQuery.textScaler.clamp(
          maxScaleFactor: _maxScale,
        ),
      ),
      child: child,
    );
  }
}
