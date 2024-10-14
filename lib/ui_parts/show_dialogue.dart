import 'package:flutter/material.dart';

class DialogGenerator {
  static Future<void> showLoadingDialog({
    required BuildContext context,
  }) async {
    showGeneralDialog(
        context: context,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 250),
        barrierColor: Colors.black.withOpacity(0.5), // 画面マスクの透明度
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondaryAnimation) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                Text(
                  'Loading...',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          );
        });
  }
}
