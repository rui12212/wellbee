import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/calendar/attendee_detail_page.dart';
import 'package:wellbee/screens/staff/course/calendar_utils.dart';
import 'package:wellbee/screens/staff/course/course.dart';
import 'package:wellbee/screens/staff/course/slot_add.dart';
import 'package:wellbee/screens/staff/course/slot_multiple_add.dart';
import 'package:wellbee/ui_function/convert.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/dialogue_awesome.dart';

import 'package:table_calendar/table_calendar.dart';

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

class MonthlySelectPage extends StatefulWidget {
  Map<String, dynamic> courseList;

  MonthlySelectPage({Key? key, required this.courseList}) : super(key: key);

  @override
  _MonthlySelectPageState createState() => _MonthlySelectPageState();
}

class _MonthlySelectPageState extends State<MonthlySelectPage> {
  // late final ValueNotifier<List<dynamic>> _selectedEvents;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  late PageController _pageController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  List<dynamic> listSelectedDays = [];

  String? token = '';
  Map<DateTime, List<dynamic>> events = {};
  Map<DateTime, List<dynamic>> kSlotEvents = {};

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    // _selectedEvents.dispose();
    super.dispose();
  }

  // bool get canClearSelection =>
  //     _selectedDays.isNotEmpty || _rangeStart != null || _rangeEnd != null;

  Future<List<dynamic>?> _fetchEachCourseSlots(String courseName) async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse('${baseUri}reservations/slot/each_course_slots/')
          .replace(queryParameters: {
        'token': token,
        'course_name': widget.courseList['course_name'],
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

  List<Event> _getEventsForDays(Iterable<DateTime> days) {
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    return _getEventsForDays(days);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (_selectedDays.contains(selectedDay)) {
        _selectedDays.remove(selectedDay);
      } else {
        // String formattedDateOfWeek = DateFormat.EEEE('en').format(selectedDay);
        _selectedDays.add(selectedDay);
      }
      listSelectedDays = _selectedDays.toList();

      _focusedDay.value = focusedDay;
      _rangeStart = null;
      _rangeEnd = null;
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
    });

    // _selectedEvents.value = _getEventsForDays(_selectedDays);
  }

  // void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
  //   setState(() {
  //     _focusedDay.value = focusedDay;
  //     _rangeStart = start;
  //     _rangeEnd = end;
  //     _selectedDays.clear();
  //     _rangeSelectionMode = RangeSelectionMode.toggledOn;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _fetchAndBuildEvents();
    // _selectedDays.add(_focusedDay.value);
    // _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay.value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text('Slot Calender'),
      // ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15.w),
          child: Column(
            children: [
              _Header(title: 'Select&Add Slot'),
              TableCalendar(
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: _focusedDay.value,
                selectedDayPredicate: (day) => _selectedDays.contains(day),
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                calendarFormat: _calendarFormat,
                rangeSelectionMode: _rangeSelectionMode,
                eventLoader: _getEventsForDay,
                // holidayPredicate: (day) {
                //   // Every 20th day of the month will be treated as a holiday
                //   return day.day == 20;
                // },
                onDaySelected: _onDaySelected,
                // onRangeSelected: _onRangeSelected,
                onCalendarCreated: (controller) => _pageController = controller,
                onPageChanged: (focusedDay) => _focusedDay.value = focusedDay,
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() => _calendarFormat = format);
                  }
                },
                calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, eventsList) {
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
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: listSelectedDays.length,
                  itemBuilder: (context, index) {
                    final DateTime dateTime = listSelectedDays[index];
                    final String stringDate =
                        DateFormat('yyyy-MM-dd').format(dateTime).toString();
                    // String fotmattedDate = listSelectedDays[index].toString();
                    String formattedDateOfWeek =
                        DateFormat.EEEE('en').format(dateTime);
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        title: Row(
                          children: [
                            Text(stringDate, style: TextStyle(fontSize: 16.h)),
                            Text(':  $formattedDateOfWeek',
                                style: TextStyle(fontSize: 14.h)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        backgroundColor: Color.fromARGB(255, 65, 174, 147),
        // label: Text('+', style: TextStyle(fontSize: 40)),
        child: Icon(Icons.add, size: 40.h, color: Colors.white),
        onPressed: () {
          if (listSelectedDays.isEmpty) {
            showSnackBar(Colors.red, 'There is no selected days');
            return;
          } else {
            listSelectedDays.sort();
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddSlotPage(
                    slotList: listSelectedDays,
                    courseList: widget.courseList)));
          }
        },
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;
  final VoidCallback onClearButtonTap;
  final bool clearButtonVisible;

  const _CalendarHeader({
    Key? key,
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
    required this.onTodayButtonTap,
    required this.onClearButtonTap,
    required this.clearButtonVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMM().format(focusedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          SizedBox(
            width: 120.0,
            child: Text(
              headerText,
              style: TextStyle(fontSize: 26.0),
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today, size: 20.0),
            visualDensity: VisualDensity.compact,
            onPressed: onTodayButtonTap,
          ),
          if (clearButtonVisible)
            IconButton(
              icon: Icon(Icons.clear, size: 20.0),
              visualDensity: VisualDensity.compact,
              onPressed: onClearButtonTap,
            ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: onLeftArrowTap,
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: onRightArrowTap,
          ),
        ],
      ),
    );
  }
}
