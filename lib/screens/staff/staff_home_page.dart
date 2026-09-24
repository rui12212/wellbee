import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wellbee/services/version_check_service.dart';
import 'package:wellbee/ui_parts/dialogue_awesome.dart';
import 'package:wellbee/screens/staff/calendar/calendar.dart';
import 'package:wellbee/screens/staff/course/course.dart';
import 'package:wellbee/screens/staff/course_add/edit_courses.dart';
import 'package:wellbee/screens/staff/health_survey/health_survey_expirely.dart';
import 'package:wellbee/screens/staff/membership/all_course.dart';
import 'package:wellbee/screens/staff/membership/membership_edit_list.dart';
import 'package:wellbee/screens/staff/qr_after_add_staff/add_staff_user.dart';
import 'package:wellbee/screens/staff/user_password_reset.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage(
      // this.newUser,
      {
    Key? key,
  }) : super(key: key);

  @override
  _StaffHomePageState createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  final Color _primaryColor = Color.fromARGB(255, 97, 198, 187);
  final Color _backgroundColor = Color(0xFFF5F7FA);

  Future<void> _checkVersion() async {
    final status = await VersionCheckService.check();
    if (!mounted) return;
    Future<dynamic> Function() storeUrl = Platform.isIOS
        ? () async {
            await launchUrl(
              Uri.parse('https://apps.apple.com/app/wellbee-app/id6737229335'),
              mode: LaunchMode.externalApplication,
            );
          }
        : () async {
            await launchUrl(
              Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.wellbee.app&pcampaignid=web_share'),
              mode: LaunchMode.externalApplication,
            );
          };
    if (status == VersionStatus.forceUpdate) {
      VersionUpCustomAwesomeDialogue(
        titleText: 'Update Required',
        desc: 'Please update the app to continue.',
        callback: storeUrl,
      ).show(context);
    } else if (status == VersionStatus.updateAvailable) {
      SoftUpdateCustomAwesomeDialogue(
        titleText: 'New Version Available',
        desc: 'A new version of the app is available.',
        onUpdate: storeUrl,
      ).show(context);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkVersion();
    });
  }

  Widget _buildGridTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 24.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダーセクション
                Container(
                  margin: EdgeInsets.only(bottom: 32.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Staff Home',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Access to management',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                // メニューグリッド
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 1.6,
                  children: [
                    _buildGridTile(
                      icon: Icons.calendar_month_outlined,
                      title: 'Calendar',
                      color: const Color(0xFF3B5FCC),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => CalendarPage()),
                      ),
                    ),
                    _buildGridTile(
                      icon: Icons.edit_calendar_outlined,
                      title: 'Course Edit',
                      color: const Color(0xFFC27D1A),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => EditCoursesPage()),
                      ),
                    ),
                    _buildGridTile(
                      icon: Icons.school_outlined,
                      title: 'Slot Add',
                      color: _primaryColor,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AllCoursePage()),
                      ),
                    ),
                    _buildGridTile(
                      icon: Icons.airplane_ticket_outlined,
                      title: 'Check Member',
                      color: const Color(0xFFE8344E),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => CheckExpireMembershipPage()),
                      ),
                    ),
                    _buildGridTile(
                      icon: Icons.edit_note_outlined,
                      title: 'Edit Member',
                      color: const Color(0xFF7B61FF),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const MembershipEditListPage()),
                      ),
                    ),
                    _buildGridTile(
                      icon: Icons.health_and_safety_outlined,
                      title: 'Health Survey',
                      color: const Color(0xFF039674),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => CheckHealthSurveyPage()),
                      ),
                    ),
                    _buildGridTile(
                      icon: Icons.lock_reset_outlined,
                      title: 'Password Reset',
                      color: Colors.grey.shade600,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const UserPasswordResetPage()),
                      ),
                    ),
                    _buildGridTile(
                      icon: Icons.person_add_outlined,
                      title: 'Add Staff',
                      color: const Color(0xFF077CE3),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const AddStaffUserPage()),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
