import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/attendee/attendee_add.dart';
import 'package:wellbee/screens/top_page.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/display.dart';
import 'package:wellbee/screens/attendee/attendee_update.dart';

import '../../ui_parts/color.dart';

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
                      color: kColorPrimary),
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
          // SizedBox(height: 4.h),
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

class AttendeePage extends StatefulWidget {
  const AttendeePage({Key? key}) : super(key: key);

  @override
  _AttendeePageState createState() => _AttendeePageState();
}

class _AttendeePageState extends State<AttendeePage> {
  String? token = '';

  Future<List<dynamic>?> _fetchAttendee() async {
    try {
      token = await SharedPrefs.fetchAccessToken();
      var url =
          Uri.parse('${baseUri}attendances/attendee/my_attendee/?token=$token');
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
        if (data.isNotEmpty) {
          return data;
        }
      } else if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Internet Error occurred.')));
        return null;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong. Try again later')));
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
      return null;
    }
    return null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              _Header(
                  title: 'Wellbee Member',
                  subtitle: 'You can add Member up to 10!'),
              SizedBox(height: 8.h),
              Expanded(
                child: FutureBuilder(
                  future: _fetchAttendee(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(kColorPrimaryThin),
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
                              Icon(
                                Icons.error_outline,
                                size: 64.sp,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: kColorTextDarkGrey,
                                ),
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
                              Icon(
                                Icons.person_add_outlined,
                                size: 64.sp,
                                color: Colors.grey.shade300,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'No attendee registered.',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: kColorTextDarkGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Tap the + button to add a member',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: kColorText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      final attendeeList = snapshot.data!;
                      return ListView.builder(
                        padding: EdgeInsets.only(bottom: 100.h),
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
                                      builder: (context) => AttendeeUpdatePage(
                                          attendeeList: attendeeList[index])));
                                },
                                child: AttendeeDisplay(
                                    attendeeName: attendeeList[index]['name'],
                                    gender: attendeeList[index]['gender'],
                                    dateOfBirth: attendeeList[index]
                                        ['date_of_birth'],
                                    goal: attendeeList[index]['goal']),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AttendeeAddPage()));
        },
        backgroundColor: kColorPrimaryThin,
        elevation: 4,
        extendedPadding: EdgeInsets.symmetric(horizontal: 24.w),
        icon: Icon(Icons.add, size: 28.sp, color: Colors.white),
        label: Text(
          'Add Member',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
