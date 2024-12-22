import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
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

class AttendeeDetailPage extends StatefulWidget {
  Map<String, dynamic> fetchedReservationList;

  AttendeeDetailPage({Key? key, required this.fetchedReservationList})
      : super(key: key);

  @override
  _AttendeeDetailPageState createState() => _AttendeeDetailPageState();
}

class _AttendeeDetailPageState extends State<AttendeeDetailPage> {
  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  DateTime selectedDate = DateTime.now();
  String dateTimeForMonth = DateFormat('yyyy-MM').format(DateTime.now());

  String? convertSelectMonth(DateTime date) {
    dateTimeForMonth = DateFormat('yyyy-MM').format(date);
    return dateTimeForMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _Header(title: 'Goal & Reason'),
                Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        Text('Goal',
                            style: TextStyle(
                                fontSize: 28.sp, fontWeight: FontWeight.bold)),
                        Text(
                            widget.fetchedReservationList['attendee_goal'] ==
                                        null ||
                                    widget.fetchedReservationList[
                                            'attendee_goal'] ==
                                        ''
                                ? 'No comment'
                                : widget
                                    .fetchedReservationList['attendee_goal'],
                            style: TextStyle(fontSize: 20.sp)),
                        SizedBox(height: 30.h),
                        Text('Reason',
                            style: TextStyle(
                                fontSize: 28.sp, fontWeight: FontWeight.bold)),
                        Text(
                            widget.fetchedReservationList['attendee_reason'] ==
                                        null ||
                                    widget.fetchedReservationList[
                                            'attendee_reason'] ==
                                        ''
                                ? 'No comment'
                                : widget
                                    .fetchedReservationList['attendee_reason'],
                            style: TextStyle(fontSize: 20.sp)),
                        SizedBox(height: 30.h),
                        Text('Comment',
                            style: TextStyle(
                                fontSize: 28.sp, fontWeight: FontWeight.bold)),
                        Text(
                            widget.fetchedReservationList[
                                            'attendee_any_comment'] ==
                                        null ||
                                    widget.fetchedReservationList[
                                            'attendee_any_comment'] ==
                                        ''
                                ? 'No comment'
                                : widget.fetchedReservationList[
                                    'attendee_any_comment'],
                            style: TextStyle(fontSize: 20.sp)),
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
