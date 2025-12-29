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
  final String question;

  _Question({
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: 10.h),
      child: Row(
        children: [
          Text(
            question,
            style: TextStyle(
                fontSize: 30.sp,
                fontWeight: FontWeight.w600,
                color: kColorPrimary),
          ),
        ],
      ),
    );
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
    newDate = DateTime.parse(widget.attendeeList['date_of_birth']);
    _nameController =
        TextEditingController(text: widget.attendeeList['name'] ?? '');
    _reasonController =
        TextEditingController(text: widget.attendeeList['reason'] ?? '');
    _goalController =
        TextEditingController(text: widget.attendeeList['goal'] ?? '');
    _commentController =
        TextEditingController(text: widget.attendeeList['any_comment'] ?? '');

    setState(() {
      isSelectedValue = widget.attendeeList['gender'];
    });
  }

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  String formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  Widget _buildModernTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                color: kColorTextDarkGrey,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 5.h),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(fontSize: 20.sp),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400]),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: kColorTextDarkGrey, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: kColorPrimary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDropdown({
    required String label,
    required String value,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                color: kColorTextDarkGrey,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 5.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.grey[100],
            ),
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey[600], size: 30.sp),
                style: TextStyle(fontSize: 20.sp, color: Colors.black),
                borderRadius: BorderRadius.circular(14),
                items: const [
                  DropdownMenuItem(
                    value: 'male',
                    child: Text('Male'),
                  ),
                  DropdownMenuItem(
                    value: 'female',
                    child: Text('Female'),
                  ),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDatePicker({
    required String label,
    required DateTime date,
    required Function(DateTime) onDateChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                color: kColorTextDarkGrey,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 5.h),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              final DateTime? _selectedDate = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(1940),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: kColorPrimary, // header bg color
                        onPrimary: Colors.white, // header text color
                        onSurface: kColorTextDarkGrey, // body text color
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: kColorPrimary, // button text color
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (_selectedDate != null) {
                setState(() {
                  onDateChanged(_selectedDate);
                });
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 17.h, horizontal: 15.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.cake_outlined, size: 24.sp, color: kColorPrimary),
                  SizedBox(width: 10.w),
                  Text(
                    formatDate(date),
                    style: TextStyle(
                        fontSize: 20.sp,
                        color: kColorTextDarkGrey,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFB),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                _Question(question: 'Update Info'),
                _Header(),
              ]),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(top: 15.h, bottom: 20.h),
                    child: Column(
                      children: [
                        _buildModernTextField(
                          label: 'Name/ناڤ',
                          hintText: widget.attendeeList['name'] ?? '',
                          controller: _nameController,
                        ),
                        _buildModernDropdown(
                          label: 'Gender/رەگەز',
                          value: isSelectedValue,
                          onChanged: (String? value) {
                            setState(() {
                              isSelectedValue = value!;
                            });
                          },
                        ),
                        _buildModernDatePicker(
                          label: 'Birthday/ژدایک بوون',
                          date: newDate,
                          onDateChanged: (DateTime d) {
                            newDate = d;
                          },
                        ),
                        _buildModernTextField(
                          label: 'Purpose/مەبەست',
                          hintText:
                              'Why will you join Wellbee?\nبوچی دێ بەشداربوونێ دگەل وێلبی کەی؟',
                          controller: _reasonController,
                          maxLines: 3,
                        ),
                        _buildModernTextField(
                          label: 'Goals/ئارمانج',
                          hintText: 'How you want to be?\nتە دڤێت یا چاوا بی؟',
                          controller: _goalController,
                          maxLines: 3,
                        ),
                        _buildModernTextField(
                          label: 'Comments/کومێنت',
                          hintText:
                              'Anything that staffs should know?\nهەر تشتەکێ کو کارمەند پێدڤیە بزانن؟',
                          controller: _commentController,
                          maxLines: 3,
                        ),
                        SizedBox(height: 40.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.person,
                                color: Colors.white, size: 26.sp),
                            label: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Text(
                                'Update/نویکرن',
                                style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kColorPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              minimumSize: Size(double.infinity, 60.h),
                              elevation: 2,
                            ),
                            onPressed: _updateAttendee,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
