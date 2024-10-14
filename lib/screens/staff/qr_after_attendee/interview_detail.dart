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
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/display.dart';
import 'package:wellbee/screens/attendee/attendee_update.dart';

class _Header extends StatelessWidget {
  String title;
  String subtitle;

  _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                Text(
                  title,
                  style:
                      TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
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
                    Navigator.of(context).pop();
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

class InterviewDetailPage extends StatefulWidget {
  Map<String, dynamic> interviewList;
  InterviewDetailPage({Key? key, required this.interviewList})
      : super(key: key);

  @override
  _InterviewDetailPageState createState() => _InterviewDetailPageState();
}

class _InterviewDetailPageState extends State<InterviewDetailPage> {
  String? token = '';

  @override
  void initState() {
    super.initState();
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
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _Header(
                    title: '${widget.interviewList['attendee_name']}',
                    subtitle: 'Interview of Member'),
                Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        Text('Emotion',
                            style: TextStyle(
                                fontSize: 28.sp, fontWeight: FontWeight.bold)),
                        Text(widget.interviewList['emotion_state'],
                            style: TextStyle(fontSize: 20.sp)),
                        SizedBox(height: 30.h),
                        Text('Physic',
                            style: TextStyle(
                                fontSize: 28.sp, fontWeight: FontWeight.bold)),
                        Text(widget.interviewList['physical_state'],
                            style: TextStyle(fontSize: 20.sp)),
                        SizedBox(height: 30.h),
                        Text('Comment',
                            style: TextStyle(
                                fontSize: 28.sp, fontWeight: FontWeight.bold)),
                        Text(
                            widget.interviewList['any_comment'] == null
                                ? 'No comment'
                                : widget.interviewList['any_comment'],
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
