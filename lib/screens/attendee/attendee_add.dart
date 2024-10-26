import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:survey_kit/survey_kit.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/top_page.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/dialogue_awesome.dart';
import 'package:wellbee/ui_parts/textstyle.dart';

class _Header extends StatelessWidget {
  String title;
  String subtitle;

  _Header({required this.title, required this.subtitle});

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
                  style:
                      TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold),
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
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              subtitle,
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w300,
                  color: kColorTextDarkGrey),
            ),
          )
        ],
      ),
    );
  }
}

class AttendeeAddPage extends StatefulWidget {
  const AttendeeAddPage({Key? key}) : super(key: key);

  @override
  _AttendeeAddPageState createState() => _AttendeeAddPageState();
}

class _AttendeeAddPageState extends State<AttendeeAddPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  String? token = '';
  String isSelectedValue = 'male';
  late DateTime newDate = DateTime.now();

  Future<void> _createAttendee() async {
    if (_nameController.text.trim().isEmpty ||
        (newDate.year == DateTime.now().year &&
            newDate.month == DateTime.now().month &&
            newDate.day == DateTime.now().day)) {
      CustomAwesomeDialogueForFail(
        titleText: 'Error',
        desc: 'Name & Birthday are necessary to be filled',
        // callback: _createReservation,
      ).show(context);
      return;
    } else if (newDate.isAfter(DateTime.now())) {
      CustomAwesomeDialogueForFail(
        titleText: 'Error',
        desc: 'Birthday should not be after today',
      ).show(context);
    }
    try {
      token = await SharedPrefs.fetchAccessToken();
      final String formattedDate = DateFormat('yyyy-MM-dd').format(newDate);
      var url = Uri.parse('${baseUri}attendances/attendee/');
      var response = await Future.any([
        http.post(
          url,
          headers: {
            "Authorization": 'JWT $token',
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            "name": _nameController.text,
            "gender": isSelectedValue,
            "date_of_birth": formattedDate.toString(),
            "any_comment": _commentController.text,
            "reason": _reasonController.text,
            "goal": _goalController.text,
          }),
        ),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 201) {
        showSnackBar(kColorPrimary, 'Attendee created successfully.');
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => TopPage(0)));
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                _Header(
                    title: 'Add Wellbee Member',
                    subtitle: 'Put info of a new participant'),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 36.h,
                        ),
                        Container(
                            child: Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text('Name',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            CustomTextBox(
                              label: '',
                              hintText: '',
                              controller: _nameController,
                            ).textFieldDecoration()
                          ],
                        )),
                        SizedBox(
                          height: 15.h,
                        ),
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text('Gender',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  border:
                                      Border.all(color: kColorTextDarkGrey)),
                              child: DropdownButton(
                                underline: SizedBox.shrink(),
                                itemHeight: 75.h,
                                isExpanded: true,
                                style: TextStyle(
                                    fontSize: 22.sp, color: Colors.black),
                                items: [
                                  DropdownMenuItem(
                                    value: 'male',
                                    child: Text('Male'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'female',
                                    child: Text('Female'),
                                  ),
                                ],
                                value: isSelectedValue,
                                onChanged: (String? value) {
                                  setState(() {
                                    isSelectedValue = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text('Birthday',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            Container(
                              width: 390.w,
                              height: 65.h,
                              child: TextButton(
                                style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all<Size>(
                                      Size(150, 50)), // ボタンのサイズを設定
                                  side: MaterialStateProperty.all<BorderSide>(
                                    BorderSide(
                                        color: kColorTextDarkGrey,
                                        width: 1), // 枠線の色と幅を設定
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10), // 枠線の角を丸くする
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  final DateTime? _selectedDate =
                                      await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(2000),
                                    firstDate: DateTime(1940),
                                    lastDate: DateTime.now(),
                                  );
                                  if (_selectedDate != null) {
                                    setState(
                                      () {
                                        newDate = _selectedDate;
                                      },
                                    );
                                  }
                                },
                                child: Text(
                                  newDate == DateTime.now()
                                      ? 'Choose Your Birthday'
                                      : '${newDate.year}/${newDate.month}/${newDate.day}',
                                  style: TextStyle(
                                      fontSize: 22.sp,
                                      color:
                                          Color.fromARGB(255, 161, 154, 154)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Container(
                            child: Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text('Difficulties',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            LongCustomTextBox(
                              label: '',
                              hintText: 'Why will you join Wellbee?',
                              controller: _reasonController,
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
                                child: Text('Goals',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            LongCustomTextBox(
                              label: '',
                              hintText: 'How you want to be?',
                              controller: _goalController,
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
                                child: Text('Comments',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            LongCustomTextBox(
                              label: '',
                              hintText: 'Anything that staffs should know??',
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
                          icon: const Icon(Icons.person),
                          label: Text('Add Member',
                              style: TextStyle(fontSize: 20.sp)),
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all<Size>(
                                Size(300, 80)), // ボタンの幅と高さを設定
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
