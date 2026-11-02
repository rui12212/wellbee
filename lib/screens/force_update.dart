import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wellbee/ui_parts/color.dart';

/// 強制アップデートのゲート画面。
///
/// ダイアログではなく画面そのものを置き換えるのは、ダイアログだと「更新」を
/// 押してストアへ移動した時点で閉じてしまい、戻ってきたときに裏の画面が
/// そのまま操作できてしまうため。古いアプリは新しいAPIパスを持たないので、
/// 操作させても失敗するだけで、理由も伝わらない。
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  /// ゲートを表示する。スタックを空にするので、戻る操作でも元の画面には
  /// 戻れない。開いたままのローディングダイアログもここで一緒に消える。
  /// ストアで更新するとアプリのプロセスごと入れ替わるため、この画面から
  /// 自力で抜ける経路は用意しない。
  static void replaceWith(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ForceUpdateScreen()),
      (route) => false,
    );
  }

  Future<void> _openStore(BuildContext context) async {
    final uri = Platform.isIOS
        ? Uri.parse('https://apps.apple.com/app/wellbee-app/id6737229335')
        : Uri.parse(
            'https://play.google.com/store/apps/details?id=com.wellbee.app');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the store. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // canPop: false で戻るキーとスワイプバックを無効にする
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F5F2),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 32.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88.w,
                    height: 88.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE4DFD8)),
                    ),
                    child: Icon(
                      Icons.system_update,
                      size: 42.sp,
                      color: kColorPrimary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Update Required',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                      color: kColorTextDark,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'This version of Wellbee is no longer supported.\n'
                    'Please update to continue using the app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1.6,
                      color: kColorTextDarkGrey,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: () => _openStore(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kColorPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        Platform.isIOS
                            ? 'Update on the App Store'
                            : 'Update on Google Play',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'After updating, reopen the app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.sp, color: kColorText),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
