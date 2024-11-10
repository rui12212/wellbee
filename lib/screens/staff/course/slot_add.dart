import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:survey_kit/survey_kit.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_function/convert.dart';
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
                  style: TextStyle(fontSize: 30.h, fontWeight: FontWeight.bold),
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

class SlotAddPage extends StatefulWidget {
  String courseName;
  SlotAddPage({Key? key, required this.courseName}) : super(key: key);

  @override
  _SlotAddPageState createState() => _SlotAddPageState();
}

class _SlotAddPageState extends State<SlotAddPage> {
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  String? token = '';
  String selectedStartTime = '08:00';
  String selectedEndTime = '09:00';
  late DateTime newDate = DateTime.now();

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  Future<void> _createSlot() async {
    if ((newDate.year == DateTime.now().year &&
        newDate.month == DateTime.now().month &&
        newDate.day == DateTime.now().day)) {
      CustomAwesomeDialogueForFail(
        titleText: 'Error',
        desc: 'Date is necessary to be filled',
        // callback: _createReservation,
      ).show(context);
      return;
    }
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      final String formattedDate = DateFormat('yyyy-MM-dd').format(newDate);
      int convertedCourseId =
          IntConverter.convertCourseToNum(widget.courseName);

      var url = Uri.parse('${baseUri}reservations/slot/?token=$token');
      var response = await Future.any([
        http.post(
          url,
          headers: {
            "Authorization": 'JWT $token',
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            "course": convertedCourseId,
            "date": formattedDate,
            "start_time": selectedStartTime,
            "end_time": selectedEndTime,
          }),
        ),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 201) {
        showSnackBar(kColorPrimary, 'Slot created successfully.');
        Navigator.pop(context);
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
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.h),
            child: Column(
              children: [
                _Header(
                    title: 'Add Slot', subtitle: 'put schedule 2 month ahead'),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 36.h,
                        ),
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text('Date of Course Time',
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
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2040),
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
                                      ? 'Choose Your Slot Date'
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
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text('Start Time',
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
                                items: const [
                                  DropdownMenuItem(
                                    value: '08:00',
                                    child: Text('8:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '09:00',
                                    child: Text('9:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '10:00',
                                    child: Text('10:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '11:00',
                                    child: Text('11:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '12:00',
                                    child: Text('12:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '13:00',
                                    child: Text('13:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '14:00',
                                    child: Text('14:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '15:00',
                                    child: Text('15:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '16:00',
                                    child: Text('16:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '17:00',
                                    child: Text('17:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '18:00',
                                    child: Text('18:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '19:00',
                                    child: Text('19:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '20:00',
                                    child: Text('20:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '21:00',
                                    child: Text('21:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '22:00',
                                    child: Text('22:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '23:00',
                                    child: Text('23:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '24:00',
                                    child: Text('24:00'),
                                  ),
                                ],
                                value: selectedStartTime,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedStartTime = value!;
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
                                child: Text('End Time',
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
                                items: const [
                                  DropdownMenuItem(
                                    value: '08:00',
                                    child: Text('8:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '09:00',
                                    child: Text('9:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '10:00',
                                    child: Text('10:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '11:00',
                                    child: Text('11:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '12:00',
                                    child: Text('12:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '13:00',
                                    child: Text('13:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '14:00',
                                    child: Text('14:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '15:00',
                                    child: Text('15:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '16:00',
                                    child: Text('16:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '17:00',
                                    child: Text('17:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '18:00',
                                    child: Text('18:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '19:00',
                                    child: Text('19:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '20:00',
                                    child: Text('20:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '21:00',
                                    child: Text('21:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '22:00',
                                    child: Text('22:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '23:00',
                                    child: Text('23:00'),
                                  ),
                                  DropdownMenuItem(
                                    value: '24:00',
                                    child: Text('24:00'),
                                  ),
                                ],
                                value: selectedEndTime,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedEndTime = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        SizedBox(
                          height: 52.h,
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            _createSlot();
                            // Navigator.pop(context);
                          },
                          icon: const Icon(Icons.person),
                          label: Text('Add Slot',
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
