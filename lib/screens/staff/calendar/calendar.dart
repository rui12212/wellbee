import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/calendar/calendar_reserved_people.dart';
import 'package:wellbee/screens/staff/course/calendar_utils.dart';
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

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month, kToday.day);
final kLastDay = DateTime(kToday.year + 1, kToday.month, kToday.day);

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
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  Map<DateTime, List<dynamic>> events = {};
  Map<DateTime, List<dynamic>> kSlotEvents = {};

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchAndBuildEvents();
    // fetchedSlotData = _fetchAvailableCourse() as Future<List<dynamic>?>;
  }

  DateTime selectedDate = DateTime.now();
  String dateTimeForMonth = DateFormat('yyyy-MM').format(DateTime.now());

  String? convertSelectMonth(DateTime date) {
    dateTimeForMonth = DateFormat('yyyy-MM').format(date);
    return dateTimeForMonth;
  }

  Future _fetchAndBuildEvents() async {
    List<dynamic>? allSlots = await _fetchSlot();

    if (allSlots != null) {
      setState(() {
        events.clear();
        for (var slot in allSlots) {
          DateTime date = DateTime.parse(slot['date']);
          // MapのKeyにすでに同じ日付のKeyがあったら、日付：List[slot]あらたに作りなさい
          if (events[date] != null) {
            events[date]!.add(slot);
          } else {
            // MapのKeyにすでに同じ日付のKeyがなかったら、日付：List[slot]あらたに作りなさい
            events[date] = [slot];
          }
        }
        if (events == null || events == {}) {
          kSlotEvents = {};
        } else {
          kSlotEvents = LinkedHashMap<DateTime, List<dynamic>>(
            equals: isSameDay,
            hashCode: getHashCode,
          )..addAll(events);
        }
      });
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return kSlotEvents[day] ?? [];
  }

  Future<List?> fetchSlotsEachDays(DateTime? date) async {
    final List<dynamic>? allSlots = await _fetchSlot();
    final formattedDate = DateFormat('yyyy-MM-dd').format(date!);
    final List slotsForDays = [];
    if (allSlots!.isNotEmpty) {
      for (int i = 0; i < allSlots.length; i++) {
        if (allSlots[i]['date'] == formattedDate) {
          slotsForDays.add(allSlots[i]);
        }
      }
      return slotsForDays;
    } else {
      showSnackBar(Colors.red, 'No slot has been set');
      return [];
    }
  }

  Future<List<dynamic>?> _fetchSlot() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse('${baseUri}reservations/slot/all_slots/')
          .replace(queryParameters: {'token': token});
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong. Try again later')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
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
              _Header(title: 'Course Calendar'),
              TableCalendar(
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay,
                calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, eventsList) {
                  // print(eventsList.length);
                  if (eventsList.isNotEmpty && eventsList.length < 4) {
                    return Positioned(
                        bottom: 1,
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(eventsList.length, (index) {
                              return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 1),
                                  width: 7.w,
                                  height: 7.h,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: kColorPrimary));
                            })));
                  } else if (eventsList.isNotEmpty && eventsList.length >= 4) {
                    return Positioned(
                        bottom: 1,
                        child: Row(
                          children: [
                            Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(3, (index) {
                                  return Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 1),
                                      width: 7.w,
                                      height: 7.h,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: kColorPrimary));
                                })),
                            Text('...',
                                style: TextStyle(
                                    color: kColorPrimary, fontSize: 5.h))
                          ],
                        ));
                  }
                }),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) async {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    // Call `setState()` when updating the selected day
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    await fetchSlotsEachDays(_selectedDay);
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    // Call `setState()` when updating calendar format
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  // No need to call `setState()` here
                  _focusedDay = focusedDay;
                },
              ),
              FutureBuilder(
                future: fetchSlotsEachDays(_selectedDay),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Center(
                        child: Text('No slot has been set on this day.'));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final courseSlotList = snapshot.data!;
                    return Expanded(
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
                                      print(courseSlotList[index]);
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ReservedPeoplePage(
                                                      courseSlot:
                                                          courseSlotList[
                                                              index])));
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
