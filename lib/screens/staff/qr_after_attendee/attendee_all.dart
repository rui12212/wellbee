import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/qr_after_attendee/attendee_detail.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/display.dart';

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
                  onTap: () => Navigator.of(context).pop(),
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

class StaffAttendeeAllPage extends StatefulWidget {
  final String userId;
  const StaffAttendeeAllPage({super.key, required this.userId});

  @override
  State<StaffAttendeeAllPage> createState() => _StaffAttendeeAllPageState();
}

class _StaffAttendeeAllPageState extends State<StaffAttendeeAllPage> {
  String? token;

  Future<List<dynamic>?> _fetchAttendee() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse(
          '${baseUri}attendances/attendee/attendee_by_staff?user_id=${widget.userId}&token=$token');
      var response = await Future.any([
        http.get(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json"
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) return data;
      } else if (response.statusCode >= 400) {
        _showSnack('Internet Error occurred.');
      } else {
        _showSnack('Something went wrong. Try again later');
      }
    } catch (e) {
      _showSnack('Error: $e');
    }
    return null;
  }

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              const _Header(
                title: 'Wellbee Member',
                subtitle: 'Select for Member detail',
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: FutureBuilder<List<dynamic>?>(
                  future: _fetchAttendee(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              kColorPrimaryThin),
                          strokeWidth: 3,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 64.sp,
                                  color: Colors.grey.shade400),
                              SizedBox(height: 16.h),
                              Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    color: kColorTextDarkGrey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_add_outlined,
                                  size: 64.sp,
                                  color: Colors.grey.shade300),
                              SizedBox(height: 16.h),
                              Text(
                                'No attendee registered.',
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    color: kColorTextDarkGrey,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      final attendeeList = snapshot.data!;
                      return ListView.builder(
                        padding: EdgeInsets.only(bottom: 32.h),
                        itemCount: attendeeList.length,
                        itemBuilder: (context, index) {
                          if (attendeeList[index]['goal'] == null) {
                            attendeeList[index]['goal'] = '';
                          }
                          if (attendeeList[index]['reason'] == null) {
                            attendeeList[index]['reason'] = '';
                          }
                          return Padding(
                            padding: EdgeInsets.only(bottom: 4.h),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20.r),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => StaffAttendeeDetailPage(
                                          attendeeList: attendeeList[index])));
                                },
                                child: AttendeeDisplay(
                                  attendeeName: attendeeList[index]['name'],
                                  gender: attendeeList[index]['gender'],
                                  dateOfBirth: attendeeList[index]
                                      ['date_of_birth'],
                                  goal: attendeeList[index]['goal'],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
