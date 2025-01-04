import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/auth/staff_top_page.dart';
import 'package:wellbee/screens/staff/course/course_month.dart';
import 'package:wellbee/screens/staff/membership/check_expire.dart';
import 'package:wellbee/ui_function/convert.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;

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
            style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
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

class MembershipAllCoursePage extends StatefulWidget {
  MembershipAllCoursePage({
    Key? key,
  }) : super(key: key);

  @override
  _MembershipAllCoursePageState createState() =>
      _MembershipAllCoursePageState();
}

class _MembershipAllCoursePageState extends State<MembershipAllCoursePage> {
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              _Header(title: 'Check Membership'),
              FutureBuilder(
                  future: _fetchAllCourse(),
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
                      final fetchedCourseList = snapshot.data!;
                      return Expanded(
                          child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16.0,
                                mainAxisSpacing: 16.0,
                              ),
                              itemCount: fetchedCourseList.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CheckMembershipPage(
                                                    courseName:
                                                        fetchedCourseList[
                                                            index]
                                                            ['course_name'])));
                                  },
                                  child: _buildGridItem(
                                      title: fetchedCourseList[index]
                                          ['course_name'],
                                      image: fetchedCourseList[index]['course_name'] == 'Yoga' ||
                                              fetchedCourseList[index]['course_name'] ==
                                                  'Kids Yoga(A)' ||
                                              fetchedCourseList[index]['course_name'] ==
                                                  'Kids Yoga(B)' ||
                                              fetchedCourseList[index]
                                                      ['course_name'] ==
                                                  'Kids Yoga KG'
                                          ? Image.asset(
                                              'lib/assets/invi_course_pic/invi_yoga.png')
                                          : fetchedCourseList[index]['course_name'] == 'Dance' ||
                                                  fetchedCourseList[index]
                                                          ['course_name'] ==
                                                      'Kids Zumba' ||
                                                  fetchedCourseList[index]
                                                          ['course_name'] ==
                                                      'Zumba'
                                              ? Image.asset(
                                                  'lib/assets/invi_course_pic/invi_dance.png')
                                              : fetchedCourseList[index]['course_name'] == 'Karate' ||
                                                      fetchedCourseList[index]
                                                              ['course_name'] ==
                                                          'Kids Karate'
                                                  ? Image.asset('lib/assets/invi_course_pic/invi_karate.png')
                                                  : fetchedCourseList[index]['course_name'] == 'Music' || fetchedCourseList[index]['course_name'] == 'Kids Music'
                                                      ? Image.asset('lib/assets/invi_course_pic/invi_music.png')
                                                      : fetchedCourseList[index]['course_name'] == 'Kids Gym(A)' || fetchedCourseList[index]['course_name'] == 'Kids Gym(B)'
                                                          ? Image.asset('lib/assets/invi_course_pic/male_fitness.png')
                                                          : fetchedCourseList[index]['course_name'] == 'Pilates'
                                                              ? Image.asset('lib/assets/invi_course_pic/invi_pilates.png')
                                                              : fetchedCourseList[index]['course_name'] == 'Family Pilates'
                                                                  ? Image.asset('lib/assets/invi_course_pic/invi_family_pilates.png')
                                                                  : fetchedCourseList[index]['course_name'] == 'Family Yoga'
                                                                      ? Image.asset('lib/assets/invi_course_pic/invi_family_yoga.png')
                                                                      : fetchedCourseList[index]['course_name'] == 'Private Yoga@Studio' || fetchedCourseList[index]['course_name'] == 'Private Yoga@Home'
                                                                          ? Image.asset('lib/assets/invi_course_pic/private_yoga.png')
                                                                          : fetchedCourseList[index]['course_name'] == 'Private Pilates@Studio' || fetchedCourseList[index]['course_name'] == 'Private Pilates@Home'
                                                                              ? Image.asset('lib/assets/invi_course_pic/private_pilates.png')
                                                                              : Image.asset('lib/assets/invi_course_pic/female_fitness.png')),
                                );
                              })
                          // child: ListView.builder(
                          //   itemCount: fetchedCourseList.length,
                          //   itemBuilder: (context, index) {
                          //     return Container(
                          //       height: 90.h,
                          //       child: Column(
                          //         children: [
                          //           ListTile(
                          //             title: Container(
                          //               child: Text(
                          //                   fetchedCourseList[index]
                          //                       ['course_name'],
                          //                   style: TextStyle(
                          //                       fontSize: 18.sp,
                          //                       fontWeight: FontWeight.bold)),
                          //             ),
                          //             // subtitle: Row(
                          //             //   children: [
                          //             //     Text(
                          //             //         '${fetchedCourseList[index]['original_price'].toString()}\$/month'),
                          //             //   ],
                          //             // ),
                          //             trailing: ElevatedButton(
                          //               onPressed: () {
                          //                 Navigator.of(context).push(
                          //                     MaterialPageRoute(
                          //                         builder: (context) =>
                          //                             MonthlySlotPage(
                          //                                 courseList:
                          //                                     fetchedCourseList[
                          //                                         index])));
                          //               },
                          //               child: Text('Detail',
                          //                   style: TextStyle(
                          //                       fontWeight: FontWeight.w700,
                          //                       color: kColorPrimary)),
                          //             ),
                          //           ),
                          //           Divider(
                          //               thickness: 0.2,
                          //               color: kColorTextDarkGrey),
                          //         ],
                          //       ),
                          //     );
                          //   },
                          // ),
                          );
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required Widget image,
    required String title,
  }) {
    return Container(
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //     begin: FractionalOffset.bottomRight,
        //     end: FractionalOffset.topLeft,
        //     colors: [
        //       // kColorPrimary,
        //       // Color.fromARGB(255, 188, 250, 216),
        //     ],
        //     stops: const [
        //       0.7,
        //       1.0
        //     ]),
        boxShadow: [
          // BoxShadow(
          //   color: Colors.black.withOpacity(0.8), // 影の色（半透明）
          //   spreadRadius: 1, // 影の広がり
          //   blurRadius: 10, // ぼかし具合
          //   offset: Offset(2, 4), // 影の位置（X方向、Y方向）
          // ),
        ],
        color: Color.fromARGB(255, 77, 156, 125),
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8.0.h),
          Container(
            child: image,
            height: 80.h,
            width: double.infinity.w,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.0.h,
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
    );
  }
}
