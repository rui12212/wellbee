import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InterviewDetailPage extends StatelessWidget {
  final Map<String, dynamic> interviewList;
  final Map<String, dynamic> attendeeList;
  const InterviewDetailPage(
      {Key? key, required this.interviewList, required this.attendeeList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      Text('Interview Detail',
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.grey.shade500)),
                      Text(
                        interviewList['attendee_name'] ?? '',
                        style: TextStyle(
                            fontSize: 22.sp, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _sectionCard(
                icon: Icons.sentiment_satisfied_alt_outlined,
                iconColor: const Color(0xFF077CE3),
                title: 'Emotion',
                body: interviewList['emotion_state'] ?? '',
              ),
              SizedBox(height: 12.h),
              _sectionCard(
                icon: Icons.directions_run_outlined,
                iconColor: const Color(0xFF039674),
                title: 'Physical',
                body: interviewList['physical_state'] ?? '',
              ),
              SizedBox(height: 12.h),
              _sectionCard(
                icon: Icons.comment_outlined,
                iconColor: const Color(0xFFD4A017),
                title: 'Comment',
                body: (interviewList['any_comment'] == null ||
                        interviewList['any_comment'] == '')
                    ? 'No comment'
                    : interviewList['any_comment'],
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
            style: TextStyle(
                fontSize: 15.sp, color: Colors.grey.shade700, height: 1.5),
          ),
        ],
      ),
    );
  }
}
