import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/screens/staff/notification/notification_settings_list.dart';
import 'package:wellbee/screens/staff/notification/notification_send.dart';

class NotificationHomePage extends StatelessWidget {
  const NotificationHomePage({Key? key}) : super(key: key);

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      margin: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: kColorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: kColorPrimary, size: 28.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        )),
                    SizedBox(height: 4.h),
                    Text(subtitle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                        )),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 24.sp),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: const CircleBorder(
                            side: BorderSide(
                                color: Color.fromARGB(255, 206, 204, 204),
                                width: 5)),
                      ),
                      child: const Icon(Icons.chevron_left,
                          color: Color.fromARGB(255, 155, 152, 152)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    SizedBox(width: 8.w),
                    Text('Notification',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        )),
                  ],
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.only(left: 56.w),
                  child: Text('Manage notification settings',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                ),
                SizedBox(height: 32.h),
                _buildMenuCard(
                  icon: Icons.settings_outlined,
                  title: 'Days Settings',
                  subtitle: 'Set days before expiry and messages',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              const NotificationSettingsListPage()),
                    );
                  },
                ),
                _buildMenuCard(
                  icon: Icons.send_outlined,
                  title: 'Send Message',
                  subtitle: 'Send bulk message to target users',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const NotificationSendPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
