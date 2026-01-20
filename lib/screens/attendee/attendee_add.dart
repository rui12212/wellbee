import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/top_page.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/dialogue_awesome.dart';

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) {
                        return TopPage(0);
                      },
                    ));
                  },
                  borderRadius: BorderRadius.circular(24.r),
                  child: Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20.sp,
                      color: kColorTextDarkGrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: kColorText,
              height: 1.4,
            ),
          ),
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
        titleText: 'Error!',
        desc: 'Name & Birthday are necessary to be filled',
        // callback: _createReservation,
      ).show(context);
      return;
    } else if (newDate.isAfter(DateTime.now())) {
      CustomAwesomeDialogueForFail(
        titleText: 'Error',
        desc: 'Birthday should not be after today',
      ).show(context);
      return;
    }
    try {
      token = await SharedPrefs.fetchAccessToken();
      final String formattedDate = DateFormat('yyyy-MM-dd').format(newDate);
      var url = Uri.parse('${baseUri}attendances/attendee/?token=$token');
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
                initialDate: date == DateTime.now() ? DateTime(2000) : date,
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
                    date == DateTime.now()
                        ? 'Choose Your Birthday'
                        : formatDate(date),
                    style: TextStyle(
                        fontSize: 20.sp,
                        color: date == DateTime.now()
                            ? Color.fromARGB(255, 161, 154, 154)
                            : kColorTextDarkGrey,
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
              _Header(
                title: 'Add Member',
                subtitle: 'Fill in the member information',
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(top: 15.h, bottom: 20.h),
                    child: Column(
                      children: [
                        _buildModernTextField(
                          label: 'Name/ناڤ',
                          hintText: '',
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
                                'Add/زێدەکرن',
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
                            onPressed: _createAttendee,
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
