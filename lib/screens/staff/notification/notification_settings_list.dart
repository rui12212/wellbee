import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/screens/staff/notification/notification_setting_edit.dart';
import 'package:http/http.dart' as http;

class NotificationSettingsListPage extends StatefulWidget {
  const NotificationSettingsListPage({Key? key}) : super(key: key);

  @override
  _NotificationSettingsListPageState createState() =>
      _NotificationSettingsListPageState();
}

class _NotificationSettingsListPageState
    extends State<NotificationSettingsListPage> {
  Future<List<dynamic>?> _fetchSettings() async {
    try {
      final token = await SharedPrefs.fetchStaffAccessToken();
      var url =
          Uri.parse('${baseUri}attendances/notification-settings/?token=$token');
      var response = await Future.any([
        http.get(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json"
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error fetching settings.')));
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
        title: Text('Days Settings',
            style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: kColorPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kColorPrimary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => const NotificationSettingEditPage()),
          );
          setState(() {});
        },
      ),
      body: FutureBuilder<List<dynamic>?>(
        future: _fetchSettings(),
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
                  Icon(Icons.notifications_off_outlined,
                      size: 64.sp, color: Colors.grey[400]),
                  SizedBox(height: 16.h),
                  Text('No settings yet',
                      style:
                          TextStyle(fontSize: 18.sp, color: Colors.grey[600])),
                  SizedBox(height: 8.h),
                  Text('Tap + to create a new setting',
                      style:
                          TextStyle(fontSize: 14.sp, color: Colors.grey[400])),
                ],
              ),
            );
          } else {
            final settings = snapshot.data!;
            return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: settings.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, index) {
                final s = settings[index];
                return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  leading: Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: kColorPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        '${s['days_before_expire']}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: kColorPrimary,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    '${s['days_before_expire']} days before expiry',
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    s['message'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  trailing: Icon(Icons.chevron_right,
                      color: Colors.grey[400], size: 20.sp),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NotificationSettingEditPage(
                          settingId: s['id'],
                          daysBeforeExpire: s['days_before_expire'],
                          message: s['message'] ?? '',
                          isActive: s['is_active'] ?? true,
                        ),
                      ),
                    );
                    setState(() {});
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
