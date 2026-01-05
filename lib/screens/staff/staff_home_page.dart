import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/screens/staff/calendar/calendar.dart';
import 'package:wellbee/screens/staff/course/course.dart';
import 'package:wellbee/screens/staff/course_add/edit_courses.dart';
import 'package:wellbee/screens/staff/dm/attendee_select.dart';
import 'package:wellbee/screens/staff/health_survey/health_survey_expirely.dart';
import 'package:wellbee/screens/staff/membership/all_course.dart';

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

  @override
  void initState() {
    super.initState();
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
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
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 20.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: (iconColor ?? _primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? _primaryColor,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24.sp,
              ),
            ],
          ),
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
                // メニューカード
                _buildMenuCard(
                  icon: Icons.calendar_month_outlined,
                  title: 'All Course Calendar',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => CalendarPage()),
                    );
                  },
                ),
                _buildMenuCard(
                  icon: Icons.edit_calendar_outlined,
                  title: 'Course Edit',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => EditCoursesPage()),
                    );
                  },
                ),
                _buildMenuCard(
                  icon: Icons.school_outlined,
                  title: 'Slot Add',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AllCoursePage()),
                    );
                  },
                ),
                _buildMenuCard(
                  icon: Icons.airplane_ticket_outlined,
                  title: 'Check Membership',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => MembershipAllCoursePage()),
                    );
                  },
                ),
                _buildMenuCard(
                  icon: Icons.health_and_safety_outlined,
                  title: 'Check Health Survey',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => CheckHealthSurveyPage()),
                    );
                  },
                ),
                _buildMenuCard(
                  icon: Icons.message_outlined,
                  title: 'Auto Message',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => MessageAttendeeSelectPage()),
                    );
                  },
                ),
                _buildMenuCard(
                  icon: Icons.notifications_active_outlined,
                  title: 'Course Notification',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => CheckHealthSurveyPage()),
                    );
                  },
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
