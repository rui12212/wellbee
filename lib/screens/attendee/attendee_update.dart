import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:survey_kit/survey_kit.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/attendee/attendee.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/dialogue_awesome.dart';
import 'package:wellbee/ui_parts/textstyle.dart';

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: TextButton(
        style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            shape: const CircleBorder(
                side: BorderSide(
                    color: Color.fromARGB(255, 216, 214, 214), width: 5))),
        child: const Icon(Icons.chevron_left,
            color: Color.fromARGB(255, 155, 152, 152)),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _Question extends StatelessWidget {
  String question;

  _Question({
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 40.h,
        child: Column(
          children: [
            Text(question,
                style: TextStyle(fontSize: 28.h, fontWeight: FontWeight.w300))
          ],
        ));
  }
}

class AttendeeUpdatePage extends StatefulWidget {
  late Map<dynamic, dynamic> attendeeList;

  AttendeeUpdatePage({
    Key? key,
    required this.attendeeList,
  }) : super(key: key);

  @override
  _AttendeeUpdatePageState createState() => _AttendeeUpdatePageState();
}

class _AttendeeUpdatePageState extends State<AttendeeUpdatePage> {
  late TextEditingController _nameController;
  late TextEditingController _reasonController;
  late TextEditingController _goalController;
  late TextEditingController _commentController;

  String? token = '';
  String isSelectedValue = 'male';
  String originalText = '';
  late DateTime newDate;

  Future<void> _updateAttendee() async {
    final attendee = widget.attendeeList;
    final name = _nameController.text.trim().isEmpty
        ? attendee['name']
        : _nameController.text.trim();
    final dateOfBirth = newDate == attendee['date_of_birth']
        ? attendee['date_of_birth']
        : newDate;
    final gender = isSelectedValue == attendee['gender']
        ? attendee['gender']
        : isSelectedValue;
    final comment = _commentController.text.trim().isEmpty
        ? attendee['any_comment']
        : _commentController.text.trim();
    final goal = _goalController.text.trim().isEmpty
        ? attendee['goal']
        : _goalController.text.trim();
    final reason = _reasonController.text.trim().isEmpty
        ? attendee['reason']
        : _reasonController.text;
    try {
      // final date_of_birth = formatDate(dateOfBirth);
      final String formattedDate = DateFormat('yyyy-MM-dd').format(dateOfBirth);
      token = await SharedPrefs.fetchAccessToken();
      var url = Uri.parse(
          '${baseUri}attendances/attendee/${attendee['id']}/?token=$token');
      var response = await Future.any([
        http.patch(
          url,
          headers: {
            "Authorization": 'JWT $token',
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            "name": name,
            "gender": gender,
            "date_of_birth": formattedDate,
            "any_comment": comment,
            "reason": reason,
            "goal": goal,
          }),
        ),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 200) {
        showSnackBar(kColorPrimary, 'Update successfully.');
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AttendeePage()));
      } else if (response.statusCode >= 350) {
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
    // 一番最初にwidget.attendeeにアクセスできないから、initStateでアクセス
    // 最後に表示する時（DatePickerのText）はDateTime型なので、ここでparse変換
    newDate = DateTime.parse(widget.attendeeList['date_of_birth']);
    _nameController =
        TextEditingController(text: widget.attendeeList['name'] ?? '');
    _reasonController =
        TextEditingController(text: widget.attendeeList['reason'] ?? '');
    _goalController =
        TextEditingController(text: widget.attendeeList['goal'] ?? '');
    _commentController =
        TextEditingController(text: widget.attendeeList['any_comment'] ?? '');
  }

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  // DateTimeを文字列に変換。_selectedDateで選択したばかりの時はDateTime型。それをTextにいれるため
  String formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    isSelectedValue = widget.attendeeList['gender'];
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                _Header(),
                _Question(question: 'Update Member Info'),
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
                                child: Text('Name/ناڤ',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            CustomTextBox(
                              label: '',
                              hintText: widget.attendeeList['name'],
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
                                child: Text('Gender/رەگەز',
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
                                child: Text('Birthday/ژدایک بوون',
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
                                    initialDate: newDate,
                                    firstDate: DateTime(1940),
                                    lastDate: DateTime.now(),
                                  );
                                  if (_selectedDate != null) {
                                    setState(
                                      () {
                                        // 値が変化したら＝onPressedされたらnewDateを新しい日付に更新。
                                        newDate = _selectedDate;
                                      },
                                    );
                                    // ここまではnewDateをDateTimeとして扱う
                                  }
                                },
                                child: Text(
                                  // 最後にStringに。
                                  formatDate(newDate),
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
                                child: Text('Purpose/مەبەست',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            LongCustomTextBox(
                              label: '',
                              hintText:
                                  'Why will you join Wellbee?\nبوچی دێ بەشداربوونێ دگەل وێلبی کەی؟',
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
                                child: Text('Goals/ئارمانج',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            LongCustomTextBox(
                              label: '',
                              hintText:
                                  'How you want to be?\nتە دڤێت یا چاوا بی؟',
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
                                child: Text('Comments/کومێنت',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            LongCustomTextBox(
                              label: '',
                              hintText:
                                  'Anything that staffs should know?\nهەر تشتەکێ کو کارمەند پێدڤیە بزانن؟',
                              controller: _commentController,
                            ).textFieldDecoration()
                          ],
                        )),
                        SizedBox(
                          height: 52.h,
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            _updateAttendee();
                            // print();
                          },
                          icon: const Icon(Icons.person),
                          label: Text('Update/نویکرن',
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
