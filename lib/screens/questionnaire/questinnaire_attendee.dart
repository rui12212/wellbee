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
                style: TextStyle(fontSize: 26.h, fontWeight: FontWeight.w300))
          ],
        ));
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
              _Header(),
              _Question(question: 'Who will take the survey?'),
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
