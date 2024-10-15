import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/calendar/attendee_detail_page.dart';
import 'package:wellbee/screens/staff/course/course_slot.dart';
import 'package:wellbee/ui_function/convert.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
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
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}

class AllCoursePage extends StatefulWidget {
  AllCoursePage({
    Key? key,
  }) : super(key: key);

  @override
  _AllCoursePageState createState() => _AllCoursePageState();
}

class _AllCoursePageState extends State<AllCoursePage> {
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
      var url = Uri.parse('${baseUri}attendances/course/');
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
              _Header(title: 'All Course'),
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
                        child: ListView.builder(
                          itemCount: fetchedCourseList.length,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 90.h,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Container(
                                      child: Text(
                                          fetchedCourseList[index]
                                              ['course_name'],
                                          style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    // subtitle: Row(
                                    //   children: [
                                    //     Text(
                                    //         '${fetchedCourseList[index]['original_price'].toString()}\$/month'),
                                    //   ],
                                    // ),
                                    trailing: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) => SlotPage(
                                                    courseList:
                                                        fetchedCourseList[
                                                            index])));
                                      },
                                      child: Text('Detail',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: kColorPrimary)),
                                    ),
                                  ),
                                  Divider(
                                      thickness: 0.2,
                                      color: kColorTextDarkGrey),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}