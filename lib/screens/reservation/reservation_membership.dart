import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/home.dart';
import 'package:wellbee/screens/top_page.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/convert.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/dialogue_awesome.dart';

class _Header extends StatelessWidget {
  String title;

  _Header({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
          ),
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(
                    side: BorderSide(
                        color: Color.fromARGB(255, 206, 204, 204), width: 5))),
            child: const Icon(Icons.chevron_left,
                color: Color.fromARGB(255, 155, 152, 152)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}

class ReservationMembershipPage extends StatefulWidget {
  late Map<dynamic, dynamic> membershipList;
  ReservationMembershipPage({Key? key, required this.membershipList})
      : super(key: key);

  @override
  _ReservationMembershipPageState createState() =>
      _ReservationMembershipPageState();
}

class _ReservationMembershipPageState extends State<ReservationMembershipPage> {
  final CalendarWeekController _controller = CalendarWeekController();
  String? token = '';
  late Future<List<dynamic>?> fetchedSlotData;
  bool isAlreadyMax = false;
  String courseId = '';
  // String formattedStartTime = '';
  // final String today = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  @override
  void initState() {
    super.initState();
    // fetchedSlotData = _fetchAvailableCourse() as Future<List<dynamic>?>;
  }

  DateTime selectedDate = DateTime.now();
  String dateTimeForMonth = DateFormat('yyyy-MM').format(DateTime.now());

  String? convertSelectMonth(DateTime date) {
    dateTimeForMonth = DateFormat('yyyy-MM').format(date);
    return dateTimeForMonth;
  }

  Future<List<dynamic>?> _fetchAvailableCourse() async {
    try {
      token = await SharedPrefs.fetchAccessToken();
      final String course = widget.membershipList['course_name'];
      final String formattedDate =
          DateFormat('yyyy-MM-dd').format(selectedDate);
      var url = Uri.parse('${baseUri}reservations/slot/course_slots/')
          .replace(queryParameters: {
        'course_name': course,
        'date': formattedDate,
        'token': token,
      });
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
          // print(data);
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

  Future<void> _createReservation() async {
    try {
      token = await SharedPrefs.fetchAccessToken();
      final String formattedDate =
          DateFormat('yyyy-MM-dd').format(selectedDate);
      var url = Uri.parse('${baseUri}reservations/reservation/?token=$token');
      var response = await Future.any([
        http.post(url,
            body: jsonEncode({
              'membership': widget.membershipList['id'],
              'date': formattedDate.toString(),
              'slot': courseId,
              'attended': false,
              'is_cancelled': false,
            }),
            headers: {
              "Authorization": 'JWT $token',
              'Content-Type': 'application/json',
            }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 201) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          showSnackBar(kColorPrimary, 'Reservation success!');
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (context) {
              return TopPage(0);
            },
          ), ((route) => false));
        } else {
          showSnackBar(Colors.red, 'Some Error occurred.Try again later');
        }
      } else if (response.statusCode >= 400) {
        showSnackBar(Colors.red, 'Error: ${response.body}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong. Try again later')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  bool checkReservationCapacity(int maxPeople, int reservedPeople) {
    // 予約上限に達したかどうかの確認
    final int remainCapacity = maxPeople - reservedPeople;
    if (remainCapacity > 0) {
      setState(() {
        isAlreadyMax = false;
      });
      return isAlreadyMax;
    } else {
      setState(() {
        isAlreadyMax = true;
      });
      return isAlreadyMax;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              _Header(title: '${widget.membershipList['course_name']} '),
              CalendarWeek(
                height: 150.h,
                controller: _controller,
                pressedDateBackgroundColor: kColorPrimary,
                dateStyle: TextStyle(
                  color: Color.fromARGB(255, 92, 88, 88),
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
                dayOfWeekStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: Color.fromARGB(255, 92, 88, 88),
                ),
                weekendsStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17.sp,
                  color: Color.fromARGB(255, 92, 88, 88),
                ),
                todayDateStyle: TextStyle(
                    color: Color.fromARGB(255, 92, 88, 88),
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp),
                todayBackgroundColor: Color.fromARGB(255, 178, 222, 217),
                showMonth: true,
                minDate: DateTime.now().add(
                  Duration(days: 0),
                ),
                maxDate: DateTime.now().add(
                  Duration(days: 365),
                ),
                onDatePressed: (DateTime datetime) async {
                  // bool isAlreadyMax = fetchedSlotData['is_max'];
                  setState(
                    () {
                      selectedDate = datetime;
                    },
                  );
                },
                onDateLongPressed: (DateTime datetime) {},
                onWeekChanged: () {
                  // Do something
                },
                monthViewBuilder: (DateTime time) => Align(
                  alignment: FractionalOffset.center,
                  child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        DateFormat.yMMMM().format(time),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromARGB(255, 92, 88, 88),
                            fontSize: 22.sp),
                      )),
                ),
                decorations: [
                  // DecorationItem(
                  //     decorationAlignment: FractionalOffset.bottomRight,
                  //     date: DateTime.now(),
                  //     decoration: Icon(
                  //       Icons.today,
                  //       color: Colors.blue,
                  //     )),
                  // DecorationItem(
                  //     // expiredayの表示はここで行う
                  //     date: DateTime.now().add(Duration(days: 4)),
                  //     decoration: Text(
                  //       'Holiday',
                  //       style: TextStyle(
                  //         color: Colors.brown,
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     )),
                ],
              ),
              FutureBuilder(
                future: _fetchAvailableCourse(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Container(
                        height: 300.h,
                        child: Center(
                            child: Text('No reservation available.',
                                style: TextStyle(fontSize: 20.h))));
                  } else {
                    final courseSlotList = snapshot.data!;
                    return Container(
                      height: 420.h,
                      child: ListView.builder(
                        itemCount: courseSlotList.length,
                        itemBuilder: (context, index) {
                          // 開始時刻と終了時刻のデータフォーマットをhh:mmで統一
                          String formattedStartTime = IntConverter.formatTime(
                              courseSlotList[index]['start_time']);
                          String formattedEndTime = IntConverter.formatTime(
                              courseSlotList[index]['end_time']);
                          final bool is_cancelled =
                              courseSlotList[index]['is_cancelled'];
                          final bool is_max = courseSlotList[index]['is_max'];
                          // print(courseSlotList[index]['is_max']);
                          return Container(
                            height: 100.h,
                            child: is_cancelled == true || is_max == true
                                ? Opacity(
                                    opacity: 0.3,
                                    child: Column(
                                      children: [
                                        ListTile(
                                            title: Container(
                                              child: Text(
                                                  '$formattedStartTime - $formattedEndTime',
                                                  style: TextStyle(
                                                      fontSize: 20.sp)),
                                            ),
                                            subtitle: Row(
                                              children: [
                                                Text('Avalable Seats: '),
                                                Text(
                                                    '${courseSlotList[index]['reserved_people']}/${courseSlotList[index]['max_people']}'),
                                              ],
                                            ),
                                            trailing: is_cancelled == true &&
                                                    is_max == true
                                                ? Text('Cancelled',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: kColorPrimary))
                                                : is_cancelled == false &&
                                                        is_max == true
                                                    ? Text('Reservation Full',
                                                        style: TextStyle(
                                                            fontSize: 18.sp,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                kColorPrimary))
                                                    : Text('')),
                                        Divider(
                                            thickness: 0.2,
                                            color: kColorTextDarkGrey),
                                      ],
                                    ))
                                : Column(
                                    children: [
                                      ListTile(
                                        title: Container(
                                          child: Text(
                                              '$formattedStartTime - $formattedEndTime',
                                              style:
                                                  TextStyle(fontSize: 20.sp)),
                                        ),
                                        subtitle: Row(
                                          children: [
                                            Text('Avalable Seats:'),
                                            Text(
                                                '${courseSlotList[index]['reserved_people']}/${courseSlotList[index]['max_people']}'),
                                          ],
                                        ),
                                        trailing: ElevatedButton(
                                          onPressed: courseSlotList[index]
                                                      ['is_max'] ==
                                                  false
                                              ? () {
                                                  String date =
                                                      DateFormat('yyyy-MM-dd')
                                                          .format(selectedDate);
                                                  courseId =
                                                      courseSlotList[index]
                                                              ['id']
                                                          .toString();
                                                  // print(courseId);
                                                  CustomAwesomeDialogue(
                                                    titleText:
                                                        'Confirm Reservation\nحجزکرنێ پشت راست بکە',
                                                    desc:
                                                        'Make reservation on \n$date  $formattedStartTime-$formattedEndTime',
                                                    callback:
                                                        _createReservation,
                                                  ).show(context);
                                                }
                                              : null,
                                          child: Text('Reserve\nحجزکرن',
                                              style: TextStyle(
                                                  color: kColorPrimary,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                      ),
                                      Divider(
                                          thickness: 0.2,
                                          color: kColorTextDarkGrey),
                                    ],
                                  ),
                          );
                        },
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
