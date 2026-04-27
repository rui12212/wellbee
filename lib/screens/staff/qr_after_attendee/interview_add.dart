import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/qr_after/user_home.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/dialogue_awesome.dart';
import 'package:wellbee/ui_parts/textstyle.dart';

class InterviewAddPage extends StatefulWidget {
  final Map<String, dynamic> attendeeList;
  const InterviewAddPage({Key? key, required this.attendeeList})
      : super(key: key);

  @override
  _InterviewAddPageState createState() => _InterviewAddPageState();
}

class _InterviewAddPageState extends State<InterviewAddPage> {
  final TextEditingController _emotionController = TextEditingController();
  final TextEditingController _physicalController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  String? token;

  Future<void> _createInterview() async {
    if (_emotionController.text.trim().isEmpty ||
        _physicalController.text.trim().isEmpty) {
      CustomAwesomeDialogueForFail(
        titleText: 'Error',
        desc: 'Emotion & Physical state must be filled',
      ).show(context);
      return;
    }
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse('${baseUri}attendances/interview/?token=$token');
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
        _showSnack(kColorPrimary, 'Interview created successfully.');
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (_) =>
                  UserHomePage(pk: widget.attendeeList['user'].toString())),
          (route) => false,
        );
      } else if (response.statusCode >= 400) {
        _showSnack(Colors.red, 'Error: ${response.body}');
      } else {
        _showSnack(Colors.red, 'Something went wrong. Try again later');
      }
    } catch (e) {
      _showSnack(Colors.red, 'Error: $e');
    }
  }

  void _showSnack(Color color, String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: color, content: Text(text)));
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
                      Text('New Record',
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.grey.shade500)),
                      Text('Health Interview',
                          style: TextStyle(
                              fontSize: 22.sp, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Emotional State'),
                    SizedBox(height: 6.h),
                    InterviewCustomTextBox(
                      label: '',
                      hintText: 'Any change for the emotional & mind state?',
                      controller: _emotionController,
                    ).textFieldDecoration(),
                    SizedBox(height: 20.h),
                    _fieldLabel('Physical State'),
                    SizedBox(height: 6.h),
                    InterviewCustomTextBox(
                      label: '',
                      hintText: 'Any change for the physical & body state?',
                      controller: _physicalController,
                    ).textFieldDecoration(),
                    SizedBox(height: 20.h),
                    _fieldLabel('Comments'),
                    SizedBox(height: 6.h),
                    InterviewCustomTextBox(
                      label: '',
                      hintText: 'Anything that Member mentioned?',
                      controller: _commentController,
                    ).textFieldDecoration(),
                    SizedBox(height: 36.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _createInterview,
                        icon: Icon(Icons.note_alt_outlined, size: 20.sp),
                        label: Text('Create Interview',
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kColorPrimary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(height: 36.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(text,
        style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700));
  }
}
