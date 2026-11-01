import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/notification/notification_detail.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';

class NotificationListPage extends StatefulWidget {
  /// プッシュ通知から開かれたときに、そのメッセージの詳細を自動で開く。
  /// 一覧の取得後に突き合わせるので、見つからなければ一覧のまま止まる。
  final int? openNotificationId;

  const NotificationListPage({super.key, this.openNotificationId});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _messages = [];

  /// 一覧が変わったかどうか。ホーム画面の未読バッジを更新させるために返す。
  bool _didChange = false;

  /// プッシュから指定されたメッセージを開いたか。引っ張って更新したときに
  /// 再度開かないよう、1回だけに制限する。
  bool _openedFromPush = false;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final token = await SharedPrefs.fetchAccessToken();
      final url = Uri.parse(
          '${baseUri}notifications/user_notification/my_notifications/?token=$token');
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
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _messages = data.cast<Map<String, dynamic>>();
          _isLoading = false;
          _errorMessage = null;
        });
        _openRequestedIfAny();
      } else if (response.statusCode >= 400) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Internet Error occurred';
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Something went wrong. Try again later';
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

  int get _unreadCount =>
      _messages.where((m) => m['is_read'] != true).length;

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

  /// プッシュ通知から指定されたメッセージを開く。1回だけ実行する。
  void _openRequestedIfAny() {
    final wanted = widget.openNotificationId;
    if (wanted == null || _openedFromPush) return;
    _openedFromPush = true;

    final target = _messages.firstWhere(
      (m) => m['notification_id'] == wanted,
      orElse: () => const {},
    );
    // 配信レコードが見つからない場合は一覧のまま止める。
    // 既に削除された、別アカウント宛だった、といったケース。
    if (target.isEmpty) return;

    // 一覧の描画が終わってから遷移する
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openDetail(target);
    });
  }

  Future<void> _openDetail(Map<String, dynamic> message) async {
    final wasRead = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NotificationDetailPage(message: message),
      ),
    );
    if (wasRead == true && mounted) {
      // 既読になったので一覧とバッジを作り直す
      setState(() {
        message['is_read'] = true;
        _didChange = true;
      });
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
              SizedBox(height: 18.h),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF212121),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(_didChange),
                borderRadius: BorderRadius.circular(24.r),
                child: Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE4DFD8)),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20.sp,
                    color: kColorTextDarkGrey,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!_isLoading && _errorMessage == null && _messages.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Row(
            children: [
              if (_unreadCount > 0) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: kColorPrimary,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    '$_unreadCount unread',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Text(
                '${_messages.length} messages',
                style: TextStyle(fontSize: 14.sp, color: kColorTextDarkGrey),
              ),
            ],
          ),
        ],
      ],
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
            Icon(Icons.mail_outline, size: 48.sp, color: Colors.grey.shade300),
            SizedBox(height: 12.h),
            Text(
              'No messages yet.',
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
    final bool isUnread = message['is_read'] != true;
    final bool hasImage = (message['image_url'] as String?)?.isNotEmpty ?? false;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: () => _openDetail(message),
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFE4DFD8)),
          ),
          padding: EdgeInsets.fromLTRB(12.w, 14.h, 14.w, 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 未読の印。読んだ行は同じ幅の余白を残して文字位置を揃える
              Container(
                width: 8.w,
                height: 8.w,
                margin: EdgeInsets.only(top: 6.h),
                decoration: BoxDecoration(
                  color: isUnread ? kColorPrimary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
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
                              fontWeight:
                                  isUnread ? FontWeight.w700 : FontWeight.w500,
                              color: isUnread
                                  ? const Color(0xFF212121)
                                  : kColorTextDarkGrey,
                              height: 1.4,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _formatDate(message['notification_created_at']),
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      message['body'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isUnread ? kColorTextDarkGrey : Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    if (hasImage) ...[
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0ECE6),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_outlined,
                                size: 12.sp, color: kColorTextDarkGrey),
                            SizedBox(width: 5.w),
                            Text(
                              'Image',
                              style: TextStyle(
                                  fontSize: 11.sp, color: kColorTextDarkGrey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
