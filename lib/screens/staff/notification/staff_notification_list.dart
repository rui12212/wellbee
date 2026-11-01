import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/notification/staff_notification_target.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';

class StaffNotificationListPage extends StatefulWidget {
  const StaffNotificationListPage({super.key});

  @override
  State<StaffNotificationListPage> createState() =>
      _StaffNotificationListPageState();
}

class _StaffNotificationListPageState extends State<StaffNotificationListPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final token = await SharedPrefs.fetchAccessToken();
      final url =
          Uri.parse('${baseUri}notifications/notification/?token=$token');
      final response = await Future.any([
        http.get(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json",
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request Timeout")),
      ]);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        // ページネーションが有効な場合は results に入る
        final List<dynamic> data =
            decoded is Map ? (decoded['results'] ?? []) : decoded;
        setState(() {
          _messages = data.cast<Map<String, dynamic>>();
          _isLoading = false;
          _errorMessage = null;
        });
      } else if (response.statusCode == 403) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Staff access only.';
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load messages (${response.statusCode}).';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _openCompose() async {
    final sent = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const StaffNotificationTargetPage()),
    );
    if (sent == true && mounted) {
      setState(() => _isLoading = true);
      await _fetchMessages();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: kColorPrimary,
            content: const Text('Message sent.'),
          ),
        );
      }
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
    return '${months[local.month - 1]} ${local.day}';
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'expired':
        return 'Expired';
      case 'none':
        return 'No membership';
      default:
        return 'Any status';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 16.h),
              _buildNewButton(),
              SizedBox(height: 20.h),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Messages',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF212121),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'What you have sent',
                style: TextStyle(fontSize: 14.sp, color: kColorTextDarkGrey),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(23.r),
            child: Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE4DFD8)),
              ),
              child: Icon(Icons.arrow_back_ios_new,
                  size: 15.sp, color: kColorTextDarkGrey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _openCompose,
        style: ElevatedButton.styleFrom(
          backgroundColor: kColorPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 17.sp),
            SizedBox(width: 8.w),
            Text(
              'New Message',
              style: TextStyle(fontSize: 15.5.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: kColorTextDarkGrey),
            ),
            SizedBox(height: 14.h),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _fetchMessages();
              },
              child: Text('Try again',
                  style: TextStyle(fontSize: 14.sp, color: kColorPrimary)),
            ),
          ],
        ),
      );
    }
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_outlined, size: 48.sp, color: Colors.grey.shade300),
            SizedBox(height: 12.h),
            Text(
              'No messages sent yet.',
              style: TextStyle(fontSize: 15.sp, color: kColorTextDarkGrey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: kColorPrimary,
      onRefresh: _fetchMessages,
      child: ListView.separated(
        padding: EdgeInsets.only(bottom: 24.h),
        itemCount: _messages.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (context, index) => _buildRow(_messages[index]),
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> message) {
    final bool isCourse = message['target_type'] == 'course';
    final String scope =
        isCourse ? (message['course_name'] ?? 'Course') : 'All members';
    final bool hasImage =
        (message['image_url'] as String?)?.isNotEmpty ?? false;
    final int delivered = (message['delivered_count'] as num?)?.toInt() ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE4DFD8)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  message['title'] ?? '',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF212121),
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                _formatDate(message['created_at']),
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 9.h),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 7.w,
                  runSpacing: 6.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildTag(scope, highlight: true),
                    _buildTag(_statusLabel(message['membership_status'])),
                    if (hasImage) _buildImageTag(),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Sent to ',
                      style: TextStyle(
                          fontSize: 12.5.sp, color: kColorTextDarkGrey),
                    ),
                    TextSpan(
                      text: '$delivered',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF212121),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, {bool highlight = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFE8F5F0) : const Color(0xFFF0ECE6),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
          color: highlight ? const Color(0xFF0D6650) : kColorTextDarkGrey,
        ),
      ),
    );
  }

  Widget _buildImageTag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0ECE6),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Icon(Icons.image_outlined, size: 11.sp, color: kColorTextDarkGrey),
    );
  }
}
