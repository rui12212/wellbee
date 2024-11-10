import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/calendar/calendar_reserved_people.dart';
import 'package:wellbee/ui_function/convert.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/color.dart';

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
            style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
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

class CalendarPage extends StatefulWidget {
  CalendarPage({
    Key? key,
  }) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarWeekController _controller = CalendarWeekController();
  String? token = '';
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

  Future<List<dynamic>?> _fetchSlot() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      final String formattedDate =
          DateFormat('yyyy-MM-dd').format(selectedDate);
      var url = Uri.parse('${baseUri}reservations/slot/slots_for_calendar/')
          .replace(queryParameters: {'date': formattedDate, 'token': token});
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

  // bool checkReservationCapacity(int maxPeople, int reservedPeople) {
  //   // 予約上限に達したかどうかの確認
  //   final int remainCapacity = maxPeople - reservedPeople;
  //   if (remainCapacity > 0) {
  //     setState(() {
  //       isAlreadyMax = false;
  //     });
  //     return isAlreadyMax;
  //   } else {
  //     setState(() {
  //       isAlreadyMax = true;
  //     });
  //     return isAlreadyMax;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              _Header(title: 'Course Calendar'),
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
                  // dynamic fetchedSlotData = _fetchAvailableCourse();
                  // bool isAlreadyMax = fetchedSlotData['is_max'];
                  setState(
                    () {
                      selectedDate = datetime;
                    },
                  );
                  await _fetchSlot();
                  setState(
                    () {},
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
                            fontSize: 18.sp),
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
                future: _fetchSlot(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Center(
                        child: Text('No slot has been set on this day.'));
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
                          return Container(
                            height: 100.h,
                            child: Column(
                              children: [
                                ListTile(
                                  title: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            courseSlotList[index]
                                                ['slot_course_name'],
                                            style: TextStyle(fontSize: 18.sp)),
                                        Text(
                                            '$formattedStartTime - $formattedEndTime',
                                            style: TextStyle(fontSize: 16.sp)),
                                      ],
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Text('Reservation:'),
                                      Text(
                                          '${courseSlotList[index]['reserved_people']}/${courseSlotList[index]['max_people']}'),
                                    ],
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ReservedPeoplePage(
                                                      date:
                                                          courseSlotList[index]
                                                              ['date'])));
                                    },
                                    child: Text('Detail',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: kColorPrimary)),
                                  ),
                                ),
                                Divider(
                                    thickness: 0.2, color: kColorTextDarkGrey),
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
