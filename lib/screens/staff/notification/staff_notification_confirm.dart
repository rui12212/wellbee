import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/notification/notification_draft.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';

class StaffNotificationConfirmPage extends StatefulWidget {
  final NotificationDraft draft;

  const StaffNotificationConfirmPage({super.key, required this.draft});

  @override
  State<StaffNotificationConfirmPage> createState() =>
      _StaffNotificationConfirmPageState();
}

class _StaffNotificationConfirmPageState
    extends State<StaffNotificationConfirmPage> {
  bool _checked = false;
  bool _isSending = false;
  String? _errorMessage;

  Future<void> _send() async {
    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    final draft = widget.draft;

    try {
      // スタッフ用トークンは会員用と別のキーに保存されている
      final token = await SharedPrefs.fetchStaffAccessToken();
      final url =
          Uri.parse('${baseUri}notifications/notification/?token=$token');

      // 画像を送るので multipart で組む。画像が無い場合も同じ形で送れる。
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'JWT $token';
      request.fields['title'] = draft.title.trim();
      request.fields['body'] = draft.body.trim();
      request.fields['target_type'] = draft.targetType;
      request.fields['membership_status'] = draft.membershipStatus;
      request.fields['staff_only'] = draft.staffOnly.toString();
      if (draft.targetCourseId != null) {
        request.fields['target_course'] = draft.targetCourseId.toString();
      }
      if (draft.image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', draft.image!.path),
        );
      }

      // 画像のアップロードを含むのでタイムアウトは長めに取る
      final streamed = await Future.any([
        request.send(),
        Future.delayed(const Duration(seconds: 60),
            () => throw TimeoutException("Request Timeout")),
      ]);
      final response = await http.Response.fromStream(streamed);

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.of(context).pop(true);
        return;
      }

      setState(() {
        _isSending = false;
        _errorMessage = _readError(response);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _errorMessage = 'Could not send. Please check your connection.';
      });
    }
  }

  /// サーバーが返したバリデーションエラーを読める形にする。
  String _readError(http.Response response) {
    if (response.statusCode == 403) {
      return 'You do not have permission to send messages.';
    }
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map) {
        final messages = <String>[];
        decoded.forEach((key, value) {
          if (value is List) {
            messages.addAll(value.map((v) => v.toString()));
          } else {
            messages.add(value.toString());
          }
        });
        if (messages.isNotEmpty) return messages.join('\n');
      }
    } catch (_) {
      // 本文が読めない場合は汎用の文言にする
    }
    return 'Could not send (${response.statusCode}).';
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 14.h),
              _buildStepBar(),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCountCard(draft),
                      SizedBox(height: 14.h),
                      _buildPreview(draft),
                      SizedBox(height: 14.h),
                      _buildWarning(),
                      if (_errorMessage != null) ...[
                        SizedBox(height: 14.h),
                        _buildError(),
                      ],
                      SizedBox(height: 14.h),
                      _buildCheckbox(),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              _buildSendButton(draft),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: _isSending ? null : () => Navigator.of(context).pop(),
                child: Text(
                  'Back to edit',
                  style: TextStyle(fontSize: 14.5.sp, color: kColorTextDarkGrey),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isSending ? null : () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(19.r),
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE4DFD8)),
              ),
              child: Icon(Icons.arrow_back_ios_new,
                  size: 14.sp, color: kColorTextDarkGrey),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF212121),
              ),
            ),
            Text(
              'Step 3 of 3 · Check and send',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepBar() {
    return Row(
      children: List.generate(3, (i) {
        return Expanded(
          child: Container(
            height: 3.h,
            margin: EdgeInsets.only(right: i < 2 ? 5.w : 0),
            decoration: BoxDecoration(
              color: kColorPrimary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        );
      }),
    );
  }

  /// 人数を最も大きく出す。文面より先に目に入るべき情報だから。
  Widget _buildCountCard(NotificationDraft draft) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kColorPrimary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      child: Column(
        children: [
          Text(
            'THIS WILL BE DELIVERED TO',
            style: TextStyle(
              fontSize: 12.5.sp,
              color: const Color(0xFFB8E0D4),
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${draft.recipientCount}',
                style: TextStyle(
                  fontSize: 44.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              SizedBox(width: 7.w),
              Text(
                'people',
                style: TextStyle(fontSize: 17.sp, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            draft.targetLabel,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: const Color(0xFFD6EDE5)),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(NotificationDraft draft) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE4DFD8)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PREVIEW',
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            draft.title.trim(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF212121),
              height: 1.45,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            draft.body.trim(),
            style: TextStyle(
              fontSize: 13.5.sp,
              color: kColorTextDarkGrey,
              height: 1.7,
            ),
          ),
          if (draft.image != null) ...[
            SizedBox(height: 11.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF0ECE6),
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_outlined,
                      size: 12.sp, color: kColorTextDarkGrey),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      draft.image!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11.5.sp, color: kColorTextDarkGrey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWarning() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF0C4C4)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 18.sp, color: const Color(0xFFB33232)),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sending cannot be undone',
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFB33232),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'A sent message cannot be edited or recalled. Check the number above before you send.',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    color: const Color(0xFF8C3030),
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD94040)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      child: Text(
        _errorMessage!,
        style: TextStyle(
          fontSize: 13.sp,
          color: const Color(0xFFB33232),
          height: 1.6,
        ),
      ),
    );
  }

  /// 送信ボタンの手前に1つ関門を置く。宛先が all / course しかなく、
  /// 送信を取り消せないため。
  Widget _buildCheckbox() {
    return InkWell(
      onTap: _isSending ? null : () => setState(() => _checked = !_checked),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24.w,
            height: 24.w,
            child: Checkbox(
              value: _checked,
              activeColor: kColorPrimary,
              onChanged: _isSending
                  ? null
                  : (v) => setState(() => _checked = v ?? false),
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                'I checked the recipients and the content',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: const Color(0xFF212121),
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton(NotificationDraft draft) {
    final enabled = _checked && !_isSending;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? _send : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: kColorPrimary,
          disabledBackgroundColor: const Color(0xFFCFD8D4),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: _isSending
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 17.sp),
                  SizedBox(width: 9.w),
                  Text(
                    'Send to ${draft.recipientCount} people',
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}
