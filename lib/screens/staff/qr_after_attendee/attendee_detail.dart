import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/attendee/attendee_add.dart';
import 'package:wellbee/screens/staff/qr_after_attendee/attendee_all.dart';
import 'package:wellbee/screens/staff/qr_after_attendee/health_interview.dart';
import 'package:wellbee/screens/staff/qr_after_attendee/interview_detail.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/display.dart';
import 'package:wellbee/screens/attendee/attendee_update.dart';

class _Header extends StatelessWidget {
  String title;
  String subtitle;
  String userId;

  _Header({required this.title, required this.subtitle, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 30.h, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: const CircleBorder(
                          side: BorderSide(
                              color: Color.fromARGB(255, 216, 214, 214),
                              width: 5))),
                  child: const Icon(Icons.chevron_left,
                      color: Color.fromARGB(255, 155, 152, 152)),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                      builder: (context) {
                        return StaffAttendeeAllPage(userId: userId);
                      },
                    ), ((route) => false));
                  },
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              subtitle,
              style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w300,
                  color: kColorTextDarkGrey),
            ),
          )
        ],
      ),
    );
  }
}

class StaffAttendeeDetailPage extends StatefulWidget {
  Map<String, dynamic> attendeeList;
  StaffAttendeeDetailPage({Key? key, required this.attendeeList})
      : super(key: key);

  @override
  _StaffAttendeeDetailPageState createState() =>
      _StaffAttendeeDetailPageState();
}

class _StaffAttendeeDetailPageState extends State<StaffAttendeeDetailPage> {
  String? token = '';

  // Future<List<dynamic>?> _fetchAttendee() async {
  //   try {
  //     token = await SharedPrefs.fetchAccessToken();
  //     var url = Uri.parse('${baseUri}attendances/attendee/staff_attendee/');
  //     var response = await Future.any([
  //       http.get(url, headers: {"Authorization": 'JWT $token'}),
  //       Future.delayed(const Duration(seconds: 15),
  //           () => throw TimeoutException("Request timeout"))
  //     ]);
  //     if (response.statusCode == 200) {
  //       List<dynamic> data = jsonDecode(response.body);
  //       if (data.isNotEmpty) {
  //         return data;
  //       }
  //     } else if (response.statusCode >= 400) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Internet Error occurred.')));
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //           content: Text('Something went wrong. Try again later')));
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('Error: $e')));
  //   }
  // }

  @override
  void initState() {
    super.initState();
    print(widget.attendeeList);
  }

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _Header(
                  title: '${widget.attendeeList['name']}',
                  subtitle: 'Goal & Reason of joining',
                  userId: widget.attendeeList['user'],
                ),
                Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        Text('Goal',
                            style: TextStyle(
                                fontSize: 28.sp, fontWeight: FontWeight.bold)),
                        Text(
                            widget.attendeeList['goal'] == null ||
                                    widget.attendeeList['goal'] == ''
                                ? 'No comment'
                                : widget.attendeeList['goal'],
                            style: TextStyle(fontSize: 20.sp)),
                        SizedBox(height: 30.h),
                        Text('Reason',
                            style: TextStyle(
                                fontSize: 28.sp, fontWeight: FontWeight.bold)),
                        Text(
                            widget.attendeeList['reason'] == null ||
                                    widget.attendeeList['reason'] == ''
                                ? 'No comment'
                                : widget.attendeeList['any_comment'],
                            style: TextStyle(fontSize: 20.sp)),
                        SizedBox(height: 30.h),
                        Text('Comment',
                            style: TextStyle(
                                fontSize: 28.sp, fontWeight: FontWeight.bold)),
                        Text(
                            widget.attendeeList['any_comment'] == null ||
                                    widget.attendeeList['any_comment'] == ''
                                ? 'No comment'
                                : widget.attendeeList['any_comment'],
                            style: TextStyle(fontSize: 20.sp)),
                        SizedBox(height: 30.h),
                        ElevatedButton(
                            child: Text('Health Interview',
                                style: TextStyle(
                                    color: kColorPrimary, fontSize: 20.sp)),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => HealthInterviewPage(
                                      attendeeList: widget.attendeeList)));
                            }),
                        SizedBox(height: 30.h),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
