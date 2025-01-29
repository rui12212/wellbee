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

class MembershipAllCoursePage extends ConsumerStatefulWidget {
  MembershipAllCoursePage({
    Key? key,
  }) : super(key: key);

  @override
  _MembershipAllCoursePageState createState() =>
      _MembershipAllCoursePageState();
}

class _MembershipAllCoursePageState
    extends ConsumerState<MembershipAllCoursePage> {
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              _Header(title: 'Check Membership'),
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
                                  // Navigator.of(context).push(
                                  //     MaterialPageRoute(builder: (context) {
                                  //   return CheckLastCheckInPage(
                                  //       courseName: widget.courseName);
                                  // }));
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
                              ? _buildGridItem(fetchedDataList: fetchedDataList)
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

  Widget _buildGridItem({
    required List<dynamic> fetchedDataList,
  }) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: fetchedDataList.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CheckMembershipPage(
                    courseName: fetchedDataList[index]['course_name'])));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 77, 156, 125),
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 8.0.h),
                Container(
                    height: 80.h,
                    width: double.infinity.w,
                    child: fetchedDataList[index]['course_name'] == 'Yoga' ||
                            fetchedDataList[index]['course_name'] ==
                                'Kids Yoga(A)' ||
                            fetchedDataList[index]['course_name'] ==
                                'Kids Yoga(B)' ||
                            fetchedDataList[index]['course_name'] ==
                                'Kids Yoga KG'
                        ? Image.asset(
                            'lib/assets/invi_course_pic/invi_yoga.png')
                        : fetchedDataList[index]['course_name'] == 'Dance' ||
                                fetchedDataList[index]['course_name'] ==
                                    'Kids Zumba' ||
                                fetchedDataList[index]['course_name'] == 'Zumba'
                            ? Image.asset(
                                'lib/assets/invi_course_pic/invi_dance.png')
                            : fetchedDataList[index]['course_name'] == 'Karate' ||
                                    fetchedDataList[index]['course_name'] ==
                                        'Kids Karate'
                                ? Image.asset(
                                    'lib/assets/invi_course_pic/invi_karate.png')
                                : fetchedDataList[index]['course_name'] == 'Music' ||
                                        fetchedDataList[index]['course_name'] ==
                                            'Kids Music'
                                    ? Image.asset(
                                        'lib/assets/invi_course_pic/invi_music.png')
                                    : fetchedDataList[index]['course_name'] ==
                                                'Kids Gym(A)' ||
                                            fetchedDataList[index]
                                                    ['course_name'] ==
                                                'Kids Gym(B)'
                                        ? Image.asset(
                                            'lib/assets/invi_course_pic/male_fitness.png')
                                        : fetchedDataList[index]['course_name'] ==
                                                'Pilates'
                                            ? Image.asset('lib/assets/invi_course_pic/invi_pilates.png')
                                            : fetchedDataList[index]['course_name'] == 'Family Pilates'
                                                ? Image.asset('lib/assets/invi_course_pic/invi_family_pilates.png')
                                                : fetchedDataList[index]['course_name'] == 'Family Yoga'
                                                    ? Image.asset('lib/assets/invi_course_pic/invi_family_yoga.png')
                                                    : fetchedDataList[index]['course_name'] == 'Private Yoga@Studio' || fetchedDataList[index]['course_name'] == 'Private Yoga@Home'
                                                        ? Image.asset('lib/assets/invi_course_pic/private_yoga.png')
                                                        : fetchedDataList[index]['course_name'] == 'Private Pilates@Studio' || fetchedDataList[index]['course_name'] == 'Private Pilates@Home'
                                                            ? Image.asset('lib/assets/invi_course_pic/private_pilates.png')
                                                            : Image.asset('lib/assets/invi_course_pic/female_fitness.png')),
                Text(
                  fetchedDataList[index]['course_name'],
                  style: TextStyle(
                    fontSize: fetchedDataList[index]['course_name'].length >= 13
                        ? 13.w
                        : 18.w,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 20,
                      ),
                    ],
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.0.h),
                Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }
}
