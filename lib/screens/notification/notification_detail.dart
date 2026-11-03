import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';

class NotificationDetailPage extends StatefulWidget {
  /// 一覧から受け取った UserNotification のレコード
  final Map<String, dynamic> message;

  const NotificationDetailPage({super.key, required this.message});

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  /// 既読にできたか。一覧に戻すときの結果として返す。
  bool _markedRead = false;

  @override
  void initState() {
    super.initState();
    if (widget.message['is_read'] != true) {
      _markAsRead();
    }
  }

  Future<void> _markAsRead() async {
    try {
      final token = await SharedPrefs.fetchAccessToken();
      final id = widget.message['id'];
      final url = Uri.parse(
          '${baseUri}notifications/user_notification/$id/mark_read/?token=$token');
      final response = await Future.any([
        http.patch(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json",
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request Timeout")),
      ]);

      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          widget.message['is_read'] = true;
          _markedRead = true;
        });
      }
    } catch (_) {
      // 既読化の失敗は画面の表示を妨げない。次回開いたときに再試行される。
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return '';
    final local = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final String? courseName = message['course_name'] as String?;
    final String? imageUrl = message['image_url'] as String?;
    final bool isRead = message['is_read'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(_markedRead),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE4DFD8)),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 15.sp,
                          color: kColorTextDarkGrey,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Notifications',
                    style: TextStyle(fontSize: 14.sp, color: kColorTextDarkGrey),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFE4DFD8)),
                    ),
                    padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 18.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (courseName != null && courseName.isNotEmpty) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 9.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5F0),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  courseName,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: kColorPrimary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                            ],
                            Text(
                              _formatDate(message['notification_created_at']),
                              style:
                                  TextStyle(fontSize: 12.sp, color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          message['title'] ?? '',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF212121),
                            height: 1.45,
                          ),
                        ),
                        if (imageUrl != null && imageUrl.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.network(
                              imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  height: 180.h,
                                  color: const Color(0xFFF0ECE6),
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    color: kColorPrimary,
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              // 画像が開けなくても本文は読めるようにする
                              errorBuilder: (context, error, stack) => Container(
                                height: 120.h,
                                color: const Color(0xFFF0ECE6),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image_outlined,
                                        size: 28.sp, color: Colors.grey),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Image could not be loaded',
                                      style: TextStyle(
                                          fontSize: 12.sp, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 18.h),
                        Text(
                          message['body'] ?? '',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: const Color(0xFF212121),
                            height: 1.85,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Divider(height: 1.h, color: const Color(0xFFE4DFD8)),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Icon(
                              isRead ? Icons.check : Icons.schedule,
                              size: 13.sp,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 7.w),
                            Text(
                              isRead ? 'Read' : 'Marking as read…',
                              style:
                                  TextStyle(fontSize: 12.sp, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
