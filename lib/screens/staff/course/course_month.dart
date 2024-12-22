import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/course/calendar_utils.dart';
import 'package:wellbee/screens/staff/course/course.dart';
import 'package:wellbee/screens/staff/course/course_slot.dart';
import 'package:wellbee/screens/staff/course/select_month.dart';
import 'package:wellbee/ui_function/convert.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/color.dart';
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
            style: title.length > 12
                ? TextStyle(fontSize: 21.sp, fontWeight: FontWeight.bold)
                : TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
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
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                builder: (context) {
                  return AllCoursePage();
                },
              ), ((route) => false));
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

class MonthlySlotPage extends StatefulWidget {
  Map<String, dynamic> courseList;

  MonthlySlotPage({Key? key, required this.courseList}) : super(key: key);

  @override
  _MonthlySlotPageState createState() => _MonthlySlotPageState();
}

class _MonthlySlotPageState extends State<MonthlySlotPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  // DateTime selectedDate = DateTime.now();
  String? token = '';
  List? ferchedCourseList;
  Map<DateTime, List<dynamic>> events = {};
  Map<DateTime, List<dynamic>> kSlotEvents = {};

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  Future<List<dynamic>?> _fetchEachCourseSlots(String courseName) async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse('${baseUri}reservations/slot/each_course_slots/')
          .replace(queryParameters: {
        'token': token,
        'course_name': widget.courseList['course_name'],
      });
      // print(widget.courseList['course_name']);
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

  Future<List?> fetchSlotsEachDays(String course, DateTime? date) async {
    final List<dynamic>? allSlots = await _fetchEachCourseSlots(course);
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date!);
    final slotList = [];

    for (int i = 0; i < allSlots!.length; i++) {
      if (allSlots[i]['date'] == formattedDate) {
        slotList.add(allSlots[i]);
      } else {
        continue;
      }
    }
    return slotList;
  }

  Future _fetchAndBuildEvents() async {
    List<dynamic>? allSlots =
        await _fetchEachCourseSlots(widget.courseList['course_name']);

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

  Future<List<dynamic>?> _deleteSlot(int slotId) async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse(
          '${baseUri}reservations/slot/${slotId}/update_slot/?token=$token');
      var response = await Future.any([
        http.patch(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json"
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 204) {
        showSnackBar(kColorPrimary, 'Slot has been deleted');
        setState(() {
          _fetchAndBuildEvents();
        });

        // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
        //   builder: (context) {
        //     // return AllCoursePage();
        //   },
        // ), ((route) => false));
      } else if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Internet Error. You may not have slots')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong. Try again later')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void showAwesomeDialog(
    int id,
  ) {
    CustomAwesomeDialogueForCancelReservation(
      titleText: 'Cancel Reservation',
      desc: 'Are you sure to cancel?',
      callback: () async {
        await _deleteSlot(id);
      },
    ).show(context);
  }

  @override
  void initState() {
    super.initState();
    _fetchAndBuildEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15.w),
          child: Column(
            children: [
              _Header(title: '${widget.courseList['course_name']}'),
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
                  // Use `selectedDayPredicate` to determine which day is currently selected.
                  // If this returns true, then `day` will be marked as selected.

                  // Using `isSameDay` is recommended to disregard
                  // the time-part of compared DateTime objects.
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) async {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    // Call `setState()` when updating the selected day
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    await fetchSlotsEachDays(
                        widget.courseList['course_name'], _selectedDay);
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
                  future: fetchSlotsEachDays(
                      widget.courseList['course_name'], _selectedDay),
                  builder: (context, snapshot) {
                    // まだデータを取得しきっていない時に表示しようとするとnullが入る。nullで弾かれる
                    // connectionStateを入れて、時間稼ぎしてあげる
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data == null ||
                        snapshot.data == []) {
                      return Center(
                          child: Text('No slot has been set on this day.'));
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final fetchedSlotList = snapshot.data!;
                      // print(fetchedSlotList);
                      return Expanded(
                        child: ListView.builder(
                          itemCount: fetchedSlotList.length,
                          itemBuilder: (context, index) {
                            String formattedStartTime = IntConverter.formatTime(
                                fetchedSlotList[index]['start_time']);
                            String formattedEndTime = IntConverter.formatTime(
                                fetchedSlotList[index]['end_time']);
                            final bool is_cancelled =
                                fetchedSlotList[index]['is_cancelled'];
                            return Container(
                              child: is_cancelled == true
                                  ? Stack(children: [
                                      Container(
                                        height: 100.h,
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('Slot was cancelled',
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 86, 82, 82),
                                                    fontSize: 18.sp,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ],
                                        ),
                                      ),
                                      Opacity(
                                        opacity: 0.4,
                                        child: Container(
                                          height: 90.h,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.black, // 線の色
                                                width: 0.2, // 線の太さ
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 10.h,
                                              ),
                                              ListTile(
                                                title: Container(
                                                  child: Text(
                                                      fetchedSlotList[index]
                                                          ['date'],
                                                      style: TextStyle(
                                                          fontSize: 18.sp)),
                                                ),
                                                subtitle: Row(
                                                  children: [
                                                    Text('Avalable Seats '),
                                                    Text(
                                                        '${fetchedSlotList[index]['reserved_people']}/${fetchedSlotList[index]['max_people']}'),
                                                  ],
                                                ),
                                                trailing: Text(
                                                    '$formattedStartTime - $formattedEndTime',
                                                    style: TextStyle(
                                                        fontSize: 18.sp)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ])
                                  : Slidable(
                                      endActionPane: ActionPane(
                                          motion: ScrollMotion(),
                                          children: [
                                            SlidableAction(
                                              flex: 1,
                                              onPressed: (context) async {
                                                showAwesomeDialog(
                                                    fetchedSlotList[index]
                                                        ['id']);
                                              },
                                              backgroundColor: Colors.amber,
                                              foregroundColor: Colors.white,
                                              icon:
                                                  Icons.delete_forever_outlined,
                                              label: 'Delete',
                                            )
                                          ]),
                                      child: Container(
                                        height: 90.h,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black, // 線の色
                                              width: 0.2, // 線の太さ
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            ListTile(
                                              title: Container(
                                                child: Text(
                                                    fetchedSlotList[index]
                                                        ['date'],
                                                    style: TextStyle(
                                                        fontSize: 18.sp)),
                                              ),
                                              subtitle: Row(
                                                children: [
                                                  Text('Avalable Seats '),
                                                  Text(
                                                      '${fetchedSlotList[index]['reserved_people']}/${fetchedSlotList[index]['max_people']}'),
                                                ],
                                              ),
                                              trailing: Text(
                                                  '$formattedStartTime - $formattedEndTime',
                                                  style: TextStyle(
                                                      fontSize: 18.sp)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            );
                          },
                        ),
                      );
                    }
                  })
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color.fromARGB(255, 65, 174, 147),
        label: Text('Select & Add Slot',
            style: TextStyle(fontSize: 16, color: Colors.white)),
        icon: Icon(Icons.ads_click_outlined, size: 40.h, color: Colors.white),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  MonthlySelectPage(courseList: widget.courseList)));
        },
      ),
    );
  }
}
