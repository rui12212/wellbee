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
import 'package:wellbee/screens/staff/health_survey/attendee_factory.dart';
// import 'package:wellbee/screens/reservation/reservation_create.dart';

import 'package:wellbee/ui_function/provider.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/ticket.dart';

class _Header extends StatelessWidget {
  String title;
  _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 50.h,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                Text(title,
                    style:
                        TextStyle(fontSize: 24.w, fontWeight: FontWeight.bold)),
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

class CheckHealthSurveyPage extends ConsumerStatefulWidget {
  CheckHealthSurveyPage({
    Key? key,
  });

  @override
  _CheckHealthSurveyPageState createState() => _CheckHealthSurveyPageState();
}

class _CheckHealthSurveyPageState extends ConsumerState<CheckHealthSurveyPage> {
  String? token = '';
  final ScrollController scrollControllerOne = ScrollController();
  final ScrollController scrollControllerTwo = ScrollController();
  final ScrollController scrollControllerThree = ScrollController();
  final ScrollController scrollControllerFour = ScrollController();

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

  Future<List<dynamic>?> _fetchAttendeeWithHealthSurvey() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse(
          '${baseUri}attendances/attendee/attendee_health_survey?token=$token');
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
          // List<dynamic> data = json.decode(response.body);
          return data;
        } else if (data.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('There is no available membership.')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Some Error occurred.Try again later')));
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

  createSurveyAvailabilityList() async {
    final List<dynamic>? fetchedAttendeeData =
        await _fetchAttendeeWithHealthSurvey();
    List surveyAvailableList = [];
    List surveyNotAvailableList = [];
    final today = DateTime.now();

    try {
      if (fetchedAttendeeData!.isEmpty) {
        return [];
      } else {
        for (var e in fetchedAttendeeData) {
          if (!e.containsKey('last_survey_date')) {
            print(('Missing last survey date'));
            continue;
          }
          DateTime lastSurveyDate;
          try {
            lastSurveyDate = DateTime.parse(e['last_survey_date']);
          } catch (e) {
            print('Date parsing error: $e');
            continue;
          }
          final differenceByToday = today.difference(lastSurveyDate);
          if (differenceByToday.inDays >= 30) {
            surveyAvailableList.add(e);
          } else {
            surveyNotAvailableList.add(e);
          }
        }
        return {
          'canTakeSurveyList': surveyAvailableList,
          'cannotTakeSurveyList': surveyNotAvailableList,
        };
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    // final isCanTakeSurvey = ref.watch(isCanTakeSurveyProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
            ),
            child: Column(
              children: [
                _Header(
                  title: 'Check Health Survey',
                ),
                SingleChildScrollView(
                  child: Container(
                    height: 555.h,
                    child: FutureBuilder<dynamic>(
                      future: createSurveyAvailabilityList(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                  child: Text('No Attendee Shown',
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                      ))),
                            ],
                          );
                        } else {
                          final canTakeSurveyList =
                              snapshot.data!['canTakeSurveyList'];
                          final cannotTakeSurveyList =
                              snapshot.data!['cannotTakeSurveyList'];

                          return SingleChildScrollView(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                buildSurveyCategorySection(
                                  'Available',
                                  canTakeSurveyList!,
                                  scrollControllerOne,
                                  // membershipList['is_available'],
                                ),
                                buildSurveyCategorySection(
                                  'Not Available',
                                  cannotTakeSurveyList!,
                                  scrollControllerTwo,
                                  // membershipList['is_available'],
                                ),
                              ]));
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSurveyCategorySection(
    String title,
    List attendeeList,
    ScrollController scrollController,
  ) {
    if (attendeeList.isEmpty) {
      return Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Divider(
              thickness: 0.5,
              color: Color.fromARGB(255, 80, 79, 79),
            ),
          ),
        ],
      );
    }
    // itemの一つの高さ。ここはこれから作∏るItemの大きさによる
    double itemHeight = 150.h;
    double listHeight = attendeeList.length * itemHeight;
    double maxListHeight = 450.h;
    listHeight = listHeight > maxListHeight ? maxListHeight : listHeight;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        height: 40.h,
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color:
                    title == 'Available' ? kColorPrimary : Colors.red.shade700,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Divider(
                thickness: 1,
                color: Color.fromARGB(255, 138, 130, 130),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 8.h),
      // メンバーシップリスト
      SizedBox(
          height: listHeight,
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: ListView.builder(
                // physics: NeverScrollableScrollPhysics(),
                controller: scrollController,
                itemCount: attendeeList.length,
                itemBuilder: (context, index) {
                  // print(index);
                  final attendees = attendeeList[index];
                  final memberships = attendees['membership'] as List<dynamic>;

                  DateTime today = DateTime.now();
                  // 'last_survey_date' が存在するかチェック
                  if (!attendees.containsKey('last_survey_date')) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Text('Missing last_survey_date for attendee'),
                    );
                  }
                  // lastSurveyDateが30日いないか、以降かの確認

                  DateTime lastSurveyDate;
                  try {
                    lastSurveyDate =
                        DateTime.parse(attendees['last_survey_date']);
                  } catch (e) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Text('Invalid last_survey_date format'),
                    );
                  }
                  final differenceByToday = today.difference(lastSurveyDate);

                  bool isAvailable = differenceByToday.inDays >= 30;
                  attendees['is_available'] = isAvailable;

                  // membershipsがから出ないかを確認
                  if (memberships.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Text('No memberships found for attendee'),
                    );
                  }

                  // membershipが複数ある場合は、一番目を取得（djangoで取得した時点でexpireが今日に近いものが先頭で取得）
                  final membership = memberships[0];
                  return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: HealthSurveyTicketList(
                        membershipList: membership,
                        last_survey_date:
                            DateFormat('yyyy-MM-dd').format(lastSurveyDate),
                        isCanTakeSurvey: isAvailable,
                      ));
                }),
          ))
    ]);
  }
}

// Widget buildSurveyNotAvailableCategorySection(
//   String title,
//   List attendeeList,
//   ScrollController scrollController,
// ) {
//   if (attendeeList.isEmpty) {
//     return Row(
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 20.sp,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Expanded(
//           child: Divider(
//             thickness: 0.5,
//             color: Color.fromARGB(255, 80, 79, 79),
//           ),
//         ),
//       ],
//     );
//   }
//   // itemの一つの高さ。ここはこれから作るItemの大きさによる
//   double itemHeight = 150.h;
//   double listHeight = attendeeList.length * itemHeight;
//   double maxListHeight = 450.h;
//   listHeight = listHeight > maxListHeight ? maxListHeight : listHeight;

//   return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//     Container(
//       height: 40.h,
//       child: Row(
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               color: title == 'Available' ? kColorPrimary : Colors.red.shade700,
//               fontSize: 20.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Expanded(
//             child: Divider(
//               thickness: 1,
//               color: Color.fromARGB(255, 138, 130, 130),
//             ),
//           ),
//         ],
//       ),
//     ),
//     SizedBox(height: 8.h),
//     // メンバーシップリスト
   
//   ]);
// }
