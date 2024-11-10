import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/calendar/attendee_detail_page.dart';
import 'package:wellbee/screens/staff/course/course_slot.dart';
import 'package:wellbee/screens/staff/qr_after_attendee/attendee_detail.dart';
import 'package:wellbee/screens/staff/qr_after_attendee/interview_add.dart';
import 'package:wellbee/screens/staff/qr_after_attendee/interview_detail.dart';
import 'package:wellbee/ui_function/convert.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/color.dart';

class _Header extends StatelessWidget {
  String title;
  Map<String, dynamic> attendeeList;

  _Header({
    required this.title,
    required this.attendeeList,
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
                  return StaffAttendeeDetailPage(attendeeList: attendeeList);
                },
              ), ((route) => false));
            },
          )
        ],
      ),
    );
  }
}

class HealthInterviewPage extends StatefulWidget {
  Map<String, dynamic> attendeeList;
  HealthInterviewPage({Key? key, required this.attendeeList}) : super(key: key);

  @override
  _HealthInterviewPageState createState() => _HealthInterviewPageState();
}

class _HealthInterviewPageState extends State<HealthInterviewPage> {
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
        if (data.isNotEmpty) {
          // print(data);
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
              _Header(
                  title: 'All Interview', attendeeList: widget.attendeeList),
              FutureBuilder(
                  future: _fetchInterviews(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Center(
                          child: Text('No interview has been set.',
                              style: TextStyle(fontSize: 20.sp)));
                    } else {
                      final fetchedInterviewList = snapshot.data!;
                      print(fetchedInterviewList);
                      return Expanded(
                        child: ListView.builder(
                          itemCount: fetchedInterviewList.length,
                          itemBuilder: (context, index) {
                            final createdAt = DateTime.parse(
                                fetchedInterviewList[index]['created_at']);
                            final String fotmattedDate =
                                DateFormat('yyyy-MM-dd').format(createdAt);

                            return Container(
                              height: 90.h,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Container(
                                      child: Text(fotmattedDate,
                                          style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    // subtitle: Row(
                                    //   children: [
                                    //     Text(
                                    //         '${fetchedInterviewList[index]['original_price'].toString()}\$/month'),
                                    //   ],
                                    // ),
                                    trailing: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    InterviewDetailPage(
                                                        interviewList:
                                                            fetchedInterviewList[
                                                                index],
                                                        attendeeList: widget
                                                            .attendeeList)));
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
      floatingActionButton: FloatingActionButton.large(
        backgroundColor: Color.fromARGB(255, 65, 174, 147),
        // label: Text('+', style: TextStyle(fontSize: 40)),
        child: Icon(Icons.add, size: 40.h, color: Colors.white),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  InterviewAddPage(attendeeList: widget.attendeeList)));
        },
      ),
    );
  }
}
