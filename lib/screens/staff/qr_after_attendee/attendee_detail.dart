import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/screens/staff/qr_after_attendee/health_interview.dart';
import 'package:wellbee/ui_parts/color.dart';

class StaffAttendeeDetailPage extends StatefulWidget {
  final Map<String, dynamic> attendeeList;
  const StaffAttendeeDetailPage({Key? key, required this.attendeeList})
      : super(key: key);

  @override
  _StaffAttendeeDetailPageState createState() =>
      _StaffAttendeeDetailPageState();
}

class _StaffAttendeeDetailPageState extends State<StaffAttendeeDetailPage> {
  @override
  Widget build(BuildContext context) {
    final a = widget.attendeeList;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.chevron_left,
                          color: Colors.grey.shade600, size: 22.sp),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Member Detail',
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.grey.shade500)),
                      Text(
                        a['name'] ?? '',
                        style: TextStyle(
                            fontSize: 22.sp, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _sectionCard(
                icon: Icons.flag_outlined,
                iconColor: kColorPrimary,
                title: 'Goal',
                body: (a['goal'] == null || a['goal'] == '')
                    ? 'No comment'
                    : a['goal'],
              ),
              SizedBox(height: 12.h),
              _sectionCard(
                icon: Icons.lightbulb_outline,
                iconColor: const Color(0xFFD4A017),
                title: 'Reason',
                body: (a['reason'] == null || a['reason'] == '')
                    ? 'No comment'
                    : a['reason'],
              ),
              SizedBox(height: 12.h),
              _sectionCard(
                icon: Icons.comment_outlined,
                iconColor: const Color(0xFF039674),
                title: 'Comment',
                body: (a['any_comment'] == null || a['any_comment'] == '')
                    ? 'No comment'
                    : a['any_comment'],
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            HealthInterviewPage(attendeeList: a)));
                  },
                  icon: Icon(Icons.health_and_safety_outlined, size: 20.sp),
                  label: Text('Health Interview',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kColorPrimary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                    elevation: 0,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16.sp),
              ),
              SizedBox(width: 10.w),
              Text(title,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700)),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            body,
            style:
                TextStyle(fontSize: 15.sp, color: Colors.grey.shade700, height: 1.5),
          ),
        ],
      ),
    );
  }
}
