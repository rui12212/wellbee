import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:http/http.dart' as http;

class MailboxDetailPage extends StatefulWidget {
  final int messageId;
  final String title;
  final String content;
  final String createdAt;
  final bool isRead;

  const MailboxDetailPage({
    Key? key,
    required this.messageId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isRead,
  }) : super(key: key);

  @override
  _MailboxDetailPageState createState() => _MailboxDetailPageState();
}

class _MailboxDetailPageState extends State<MailboxDetailPage> {
  @override
  void initState() {
    super.initState();
    if (!widget.isRead) {
      _markAsRead();
    }
  }

  Future<void> _markAsRead() async {
    try {
      final token = await SharedPrefs.fetchAccessToken();
      var url = Uri.parse(
          '${baseUri}attendances/mailbox/${widget.messageId}/read/?token=$token');
      await http.post(url, headers: {
        "Authorization": 'JWT $token',
        "Content-Type": "application/json"
      });
    } catch (e) {
      print('Mark as read error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = '';
    if (widget.createdAt.isNotEmpty) {
      final dt = DateTime.tryParse(widget.createdAt);
      if (dt != null) {
        formattedDate =
            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Message',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        backgroundColor: kColorPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 24.h),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 24.h),
            Text(
              widget.content,
              style: TextStyle(
                fontSize: 16.sp,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
