import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/qr_after_attendee/interview_add.dart';
import 'package:wellbee/screens/staff/qr_after_attendee/interview_detail.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/color.dart';

class HealthInterviewPage extends StatefulWidget {
  final Map<String, dynamic> attendeeList;
  const HealthInterviewPage({Key? key, required this.attendeeList})
      : super(key: key);

  @override
  _HealthInterviewPageState createState() => _HealthInterviewPageState();
}

class _HealthInterviewPageState extends State<HealthInterviewPage> {
  String? token;

  Future<List<dynamic>?> _fetchInterviews() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse(
          '${baseUri}attendances/interview/interview_by_staff?attendee_id=${widget.attendeeList['id']}&token=$token');
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
        if (data.isNotEmpty) return data;
      } else if (response.statusCode >= 400) {
        _showSnack('Internet Error occurred.');
      } else {
        _showSnack('Something went wrong. Try again later');
      }
    } catch (e) {
      _showSnack('Error: $e');
    }
    return null;
  }

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
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
                      Text('Health Records',
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.grey.shade500)),
                      Text('All Interviews',
                          style: TextStyle(
                              fontSize: 22.sp, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>?>(
                future: _fetchInterviews(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Center(
                      child: Text('No interview has been set.',
                          style: TextStyle(
                              fontSize: 16.sp, color: Colors.grey.shade500)),
                    );
                  } else {
                    final list = snapshot.data!;
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 8.h),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final createdAt =
                            DateTime.parse(list[index]['created_at']);
                        final formattedDate =
                            DateFormat('yyyy-MM-dd').format(createdAt);
                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 14.h),
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
                          child: Row(
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color:
                                      kColorPrimary.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.health_and_safety_outlined,
                                    color: kColorPrimary, size: 20.sp),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Text(
                                  formattedDate,
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => InterviewDetailPage(
                                            interviewList: list[index],
                                            attendeeList:
                                                widget.attendeeList))),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color:
                                        kColorPrimary.withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(10.r),
                                  ),
                                  child: Text('Detail',
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: kColorPrimary)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kColorPrimary,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                InterviewAddPage(attendeeList: widget.attendeeList))),
        child: Icon(Icons.add, size: 28.sp, color: Colors.white),
      ),
    );
  }
}
