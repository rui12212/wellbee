import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:survey_kit/survey_kit.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/qr_after_attendee/health_interview.dart';
import 'package:wellbee/screens/top_page.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/dialogue_awesome.dart';
import 'package:wellbee/ui_parts/textstyle.dart';

class _Header extends StatelessWidget {
  String title;
  String subtitle;
  Map<String, dynamic> attendeeList;

  _Header(
      {required this.title,
      required this.subtitle,
      required this.attendeeList});

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
                  style: TextStyle(fontSize: 28.h, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: const CircleBorder(
                          side: BorderSide(
                              color: Color.fromARGB(255, 206, 204, 204),
                              width: 5))),
                  child: const Icon(Icons.chevron_left,
                      color: Color.fromARGB(255, 155, 152, 152)),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                      builder: (context) {
                        return HealthInterviewPage(attendeeList: attendeeList);
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
                  fontSize: 22.h,
                  fontWeight: FontWeight.w300,
                  color: kColorTextDarkGrey),
            ),
          )
        ],
      ),
    );
  }
}

class InterviewAddPage extends StatefulWidget {
  Map<String, dynamic> attendeeList;
  InterviewAddPage({Key? key, required this.attendeeList}) : super(key: key);

  @override
  _InterviewAddPageState createState() => _InterviewAddPageState();
}

class _InterviewAddPageState extends State<InterviewAddPage> {
  final TextEditingController _emotionController = TextEditingController();
  final TextEditingController _physicalController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  String? token = '';
  String isSelectedValue = 'male';
  late DateTime newDate = DateTime.now();

  Future<void> _createAttendee() async {
    if (_emotionController.text.trim().isEmpty ||
        _physicalController.text.trim().isEmpty) {
      CustomAwesomeDialogueForFail(
        titleText: 'Error',
        desc: 'Emotion & Physical state must be filled',
        // callback: _createReservation,
      ).show(context);
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      _commentController.text = '';
    }
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse('${baseUri}attendances/interview/');
      var response = await Future.any([
        http.post(
          url,
          headers: {
            "Authorization": 'JWT $token',
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            'attendee_id': widget.attendeeList['id'],
            "emotion_state": _emotionController.text,
            "physical_state": _physicalController.text,
            "any_comment": _commentController.text,
          }),
        ),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 201) {
        showSnackBar(kColorPrimary, 'Interview created successfully.');
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) {
            return HealthInterviewPage(attendeeList: widget.attendeeList);
          },
        ), ((route) => false));
      } else if (response.statusCode >= 400) {
        showSnackBar(Colors.red, 'Error: ${response.body}');
      } else {
        showSnackBar(Colors.red, 'Something went wrong. Try again later');
      }
    } catch (e) {
      showSnackBar(Colors.red, 'Error: $e');
    }
  }

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
        body: SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _Header(
                title: 'Health Interview',
                subtitle: 'Check body & mind state',
                attendeeList: widget.attendeeList),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 36.h,
                    ),
                    Column(
                      children: [],
                    ),
                    Container(
                        child: Column(
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text('Emotional State',
                                style: TextStyle(
                                    color: kColorTextDarkGrey,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w500))),
                        InterviewCustomTextBox(
                          label: '',
                          hintText:
                              'Any change for the emotional & mind state?',
                          controller: _emotionController,
                        ).textFieldDecoration()
                      ],
                    )),
                    SizedBox(
                      height: 15.h,
                    ),
                    Container(
                        child: Column(
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text('Physical State',
                                style: TextStyle(
                                    color: kColorTextDarkGrey,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w500))),
                        InterviewCustomTextBox(
                          label: '',
                          hintText: 'Any change for the physical & body state?',
                          controller: _physicalController,
                        ).textFieldDecoration()
                      ],
                    )),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                        child: Column(
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text('Comments',
                                style: TextStyle(
                                    color: kColorTextDarkGrey,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w500))),
                        InterviewCustomTextBox(
                          label: '',
                          hintText: 'Anything that Member mentioned?',
                          controller: _commentController,
                        ).textFieldDecoration()
                      ],
                    )),
                    SizedBox(
                      height: 52.h,
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        _createAttendee();
                      },
                      icon: const Icon(Icons.note_alt_outlined),
                      label: Text('Create Interview',
                          style: TextStyle(fontSize: 20.sp)),
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all<Size>(
                            Size(300.h, 80)), // ボタンの幅と高さを設定
                      ),
                    ),
                    SizedBox(
                      height: 52.h,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
