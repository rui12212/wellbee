import 'dart:async';
import 'dart:convert';
import 'dart:ui';
// import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/questionnaire/questionnaire_base.dart';
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
                  onTap: () {
                    Navigator.of(context).pop();
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

class SurveyAttendeePage extends StatefulWidget {
  const SurveyAttendeePage({Key? key}) : super(key: key);

  @override
  _SurveyAttendeePageState createState() => _SurveyAttendeePageState();
}

class _SurveyAttendeePageState extends State<SurveyAttendeePage> {
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
          print(data);
          return data;
        }
      } else if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Internet Error occurred.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong. Try again later')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Future<List<dynamic>?> _fetchLastSurveyResult() async {
  //   try {
  //     token = await SharedPrefs.fetchAccessToken();
  //     var url = Uri.parse('${baseUri}attendances/attendee/my_attendee/');
  //     var response = await Future.any([
  //       http.get(url, headers: {"Authorization": 'JWT $token'}),
  //       Future.delayed(const Duration(seconds: 15),
  //           () => throw TimeoutException("Request timeout"))
  //     ]);
  //     if (response.statusCode == 200) {
  //       List<dynamic> data = jsonDecode(response.body);
  //       if (data.isNotEmpty) {
  //         return data;
  //       }
  //     } else if (response.statusCode >= 400) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Internet Error occurred.')));
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //           content: Text('Something went wrong. Try again later')));
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('Error: $e')));
  //   }
  // }

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
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const _Header(
                title: 'Health Survey',
                subtitle: 'Choose a member to take the survey',
              ),
              FutureBuilder(
                future: _fetchAttendee(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No attendee registered.'));
                  } else {
                    final attendeeList = snapshot.data!;
                    return Expanded(
                      child: ListView.builder(
                        itemCount: attendeeList.length,
                        itemBuilder: (context, index) {
                          if (attendeeList[index]['goal'] == null) {
                            attendeeList[index]['goal'] = '';
                          }
                          if (attendeeList[index]['reason'] == null) {
                            attendeeList[index]['reason'] = '';
                          }
                          final lastSurveyDate = DateTime.parse(
                              attendeeList[index]['last_survey_date']);
                          final currentDate = DateTime.now();
                          final differenceInDays =
                              currentDate.difference(lastSurveyDate).inDays;
                          final leftDays = 30 - differenceInDays;
                          final isWithinOneMonth = differenceInDays < 30;

                          return InkWell(
                              child: isWithinOneMonth
                                  ? Stack(
                                      children: [
                                        Container(
                                          height: 170.h,
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text('You can take a survey',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 22.sp,
                                                      fontWeight:
                                                          FontWeight.w800)),
                                              Text('after ${leftDays} days',
                                                  style: TextStyle(
                                                      color: kColorPrimary,
                                                      fontSize: 22.sp,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                        Opacity(
                                          opacity: 0.2,
                                          child: AttendeeDisplay(
                                              attendeeName: attendeeList[index]
                                                  ['name'],
                                              gender: attendeeList[index]
                                                  ['gender'],
                                              dateOfBirth: attendeeList[index]
                                                  ['date_of_birth'],
                                              goal: attendeeList[index]
                                                  ['goal']),
                                        )
                                      ],
                                    )
                                  : AttendeeDisplay(
                                      attendeeName: attendeeList[index]['name'],
                                      gender: attendeeList[index]['gender'],
                                      dateOfBirth: attendeeList[index]
                                          ['date_of_birth'],
                                      goal: attendeeList[index]['goal']),
                              onTap: isWithinOneMonth
                                  ? null
                                  : () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  QuestionnairePage(
                                                      attendeeList:
                                                          attendeeList[
                                                              index])));
                                    });
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
