import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/auth/staff_top_page.dart';
import 'package:wellbee/screens/staff/course/course_month.dart';
import 'package:wellbee/screens/staff/membership/check_expire.dart';
import 'package:wellbee/ui_function/convert.dart';
import 'package:wellbee/ui_function/provider.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/check_all_membership.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/course_image.dart';

class _Header extends StatelessWidget {
  String title;

  _Header({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 28.w, fontWeight: FontWeight.bold),
          ),
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(
                    side: BorderSide(
                        color: Color.fromARGB(255, 206, 204, 204), width: 5))),
            child: const Icon(Icons.chevron_left,
                color: Color.fromARGB(255, 155, 152, 152)),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                builder: (context) {
                  return StaffTopPage(0);
                },
              ), ((route) => false));
            },
          )
        ],
      ),
    );
  }
}

class CheckExpireMembershipPage extends ConsumerStatefulWidget {
  CheckExpireMembershipPage({
    Key? key,
  }) : super(key: key);

  @override
  _CheckExpireMembershipPageState createState() =>
      _CheckExpireMembershipPageState();
}

class _CheckExpireMembershipPageState
    extends ConsumerState<CheckExpireMembershipPage> {
  final CalendarWeekController _controller = CalendarWeekController();
  String? token = '';

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  @override
  void initState() {
    super.initState();
    // fetchedSlotData = _fetchAvailableCourse() as Future<List<dynamic>?>;
  }

  Future<List<dynamic>?> _fetchAllAvailableMembership() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse(
          '${baseUri}attendances/membership/all_available_membership?token=$token');
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
        if (data.isNotEmpty) {
          return data;
        } else if (data.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('There is no available membership.')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Some Error occurred.Try again later')));
        }
      } else if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Internet Error occurred.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong. Try again later')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<List<dynamic>?> _fetchAllCourse() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse('${baseUri}attendances/course/?token=$token');
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
        if (data.isNotEmpty) {
          return data;
        }
      } else if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Internet Error occurred.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong. Try again later')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAllCourseSelected = ref.watch(isAllCourseSelectedProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              _Header(title: 'Membership Exp.'),
              Container(
                  height: 45.h,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        FilledButton(
                          onPressed: isAllCourseSelected
                              ? () {}
                              : () {
                                  ref
                                      .read(
                                          isAllCourseSelectedProvider.notifier)
                                      .state = true;
                                },
                          style: ButtonStyle(
                              backgroundColor: isAllCourseSelected
                                  ? MaterialStateProperty.all(kColorPrimary)
                                  : MaterialStateProperty.all(
                                      Color.fromARGB(255, 218, 240, 230))),
                          child: Text('Courses',
                              style: TextStyle(
                                color: isAllCourseSelected
                                    ? Colors.white
                                    : kColorPrimary,
                                fontSize: 15.h,
                                fontWeight: isAllCourseSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              )),
                        ),
                        Text('/',
                            style: TextStyle(
                                fontSize: 20.h, fontWeight: FontWeight.bold)),
                        FilledButton(
                          onPressed: isAllCourseSelected
                              ? () {
                                  ref
                                      .read(
                                          isAllCourseSelectedProvider.notifier)
                                      .state = false;
                                }
                              : () {},
                          style: ButtonStyle(
                              backgroundColor: isAllCourseSelected
                                  ? MaterialStateProperty.all(
                                      Color.fromARGB(255, 218, 240, 230))
                                  : MaterialStateProperty.all(kColorPrimary)),
                          child: Text('All Membership',
                              style: TextStyle(
                                  fontSize: 15.h,
                                  fontWeight: isAllCourseSelected
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  color: isAllCourseSelected
                                      ? kColorPrimary
                                      : Colors.white)),
                        ),
                      ],
                    ),
                  )),
              FutureBuilder(
                  future: isAllCourseSelected
                      ? _fetchAllCourse()
                      : _fetchAllAvailableMembership(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Center(
                          child: Text('No course has been set on this day.'));
                    } else {
                      final fetchedDataList = snapshot.data!;
                      return Expanded(
                          child: isAllCourseSelected
                              ? _buildCourseList(
                                  fetchedDataList: fetchedDataList)
                              : buildCheckAllMembership(
                                  fetchedDataList: fetchedDataList));
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseList({
    required List<dynamic> fetchedDataList,
  }) {
    return ListView.builder(
      itemCount: fetchedDataList.length,
      itemBuilder: (context, index) {
        final course = fetchedDataList[index];
        return _buildCourseCard(
          course: course,
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    CheckMembershipPage(courseName: course['course_name'])));
          },
        );
      },
    );
  }

  Widget _buildCourseCard({
    required Map<String, dynamic> course,
    required VoidCallback onTap,
  }) {
    final String courseName = course['course_name'] ?? '';
    final String? imageUrl = course['image_url'];

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
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: Colors.white,
          ),
          child: Row(
            children: [
              // 左側：画像アイコン
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: buildCourseImage(imageUrl, courseName),
                ),
              ),
              SizedBox(width: 16.w),
              // 中央：テキスト情報
              Expanded(
                child: Text(
                  courseName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 右側：矢印アイコン
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
}
