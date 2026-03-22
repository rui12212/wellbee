import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/screens/mailbox/mailbox_detail.dart';
import 'package:http/http.dart' as http;

class MailboxListPage extends StatefulWidget {
  const MailboxListPage({Key? key}) : super(key: key);

  @override
  _MailboxListPageState createState() => _MailboxListPageState();
}

class _MailboxListPageState extends State<MailboxListPage> {
  Future<List<dynamic>?> _fetchMessages() async {
    try {
      final token = await SharedPrefs.fetchAccessToken();
      var url = Uri.parse('${baseUri}attendances/mailbox/?token=$token');
      var response = await Future.any([
        http.get(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json"
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Internet Error occurred.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Mailbox',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        backgroundColor: kColorPrimary,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>?>(
        future: _fetchMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail_outline, size: 64.sp, color: Colors.grey[400]),
                  SizedBox(height: 16.h),
                  Text('No Messages',
                      style: TextStyle(fontSize: 18.sp, color: Colors.grey[600])),
                ],
              ),
            );
          } else {
            final messages = snapshot.data!;
            return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: messages.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, index) {
                final msg = messages[index];
                final bool isRead = msg['is_read'] ?? false;
                final String createdAt = msg['created_at'] ?? '';
                String formattedDate = '';
                if (createdAt.isNotEmpty) {
                  final dt = DateTime.tryParse(createdAt);
                  if (dt != null) {
                    formattedDate =
                        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
                  }
                }

                return Container(
                  color: isRead ? Colors.white : Color(0xFFF0FAF7),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    leading: Icon(
                      isRead ? Icons.mail_outline : Icons.mark_email_unread,
                      color: isRead ? Colors.grey[400] : kColorPrimary,
                      size: 28.sp,
                    ),
                    title: Text(
                      msg['title'] ?? '',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4.h),
                        Text(
                          msg['content'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.chevron_right,
                        color: Colors.grey[400], size: 20.sp),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MailboxDetailPage(
                            messageId: msg['id'],
                            title: msg['title'] ?? '',
                            content: msg['content'] ?? '',
                            createdAt: createdAt,
                            isRead: isRead,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
