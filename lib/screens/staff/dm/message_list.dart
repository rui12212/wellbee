// import 'package:booking_calendar/booking_calendar.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/dialogue_awesome.dart';
import 'package:wellbee/ui_parts/textstyle.dart';
import 'package:wellbee/ui_parts/ticket.dart';

class _Header extends StatelessWidget {
  String title;
  _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 24.w, fontWeight: FontWeight.bold)),
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
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DMListPage extends ConsumerStatefulWidget {
  String userId;
  DMListPage({Key? key, required this.userId});

  @override
  _DMListPageState createState() => _DMListPageState();
}

class _DMListPageState extends ConsumerState<DMListPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
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
    // _fetchMyAllMembership();
  }

  Future<void> _createMessage() async {
    if (_titleController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      CustomAwesomeDialogueForFail(
        titleText: 'Error!',
        desc: 'Title & Message are necessary to be filled',
        // callback: _createReservation,
      ).show(context);
      return;
    } else {
      try {
        token = await SharedPrefs.fetchStaffAccessToken();
        var url =
            Uri.parse('${baseUri}message?id=${widget.userId}?token=$token');
        var response = await Future.any([
          http.post(
            url,
            headers: {
              "Authorization": 'JWT $token',
              "Content-Type": "application/json"
            },
            body: jsonEncode({
              "user_id": widget.userId,
              "title": _titleController,
              "message": _messageController,
              "is_read": false,
            }),
          ),
          Future.delayed(const Duration(seconds: 15),
              () => throw TimeoutException("Request timeout"))
        ]);
        if (response.statusCode == 201) {
          showSnackBar(kColorPrimary, 'Message sent successfully.');
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DMListPage(userId: widget.userId)));
        } else if (response.statusCode >= 400) {
          showSnackBar(Colors.red, 'Error: ${response.body}');
        } else {
          showSnackBar(Colors.red, 'Something went wrong. Try again later');
        }
      } catch (e) {
        showSnackBar(Colors.red, 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final isCanTakeSurvey = ref.watch(isCanTakeSurveyProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: Column(
            children: [
              _Header(
                title: 'DM to Attendee',
              ),
              Container(
                  height: 555.h,
                  child: Column(
                    children: [
                      Container(
                        height: 200.r,
                        width: double.infinity,
                        child: Column(
                          children: [
                            Text('Title'),
                            CustomTextBox(
                              label: '',
                              hintText: '',
                              controller: _titleController,
                            ).textFieldDecoration()
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20.r,
                      ),
                      Container(
                        height: 355.r,
                        width: double.infinity,
                        child: Column(
                          children: [
                            Text('Message'),
                            CustomTextBox(
                              label: '',
                              hintText: '',
                              controller: _messageController,
                            ).textFieldDecoration()
                          ],
                        ),
                      ),
                      Container(
                          child: Column(
                        children: [
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text('Emotional State',
                                  style: TextStyle(
                                      color: kColorTextDarkGrey,
                                      fontSize: 20.r,
                                      fontWeight: FontWeight.w500))),
                          InterviewCustomTextBox(
                            label: '',
                            hintText: '',
                            controller: _messageController,
                          ).textFieldDecoration()
                        ],
                      )),
                      SizedBox(
                        height: 20.r,
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          _createMessage();
                          // print();
                        },
                        icon: const Icon(Icons.mail),
                        label: Text('Send', style: TextStyle(fontSize: 20.sp)),
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all<Size>(
                              Size(300, 80)), // ボタンの幅と高さを設定
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
