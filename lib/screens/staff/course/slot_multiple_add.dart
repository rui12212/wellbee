import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/course/course_month.dart';
import 'package:wellbee/ui_function/provider.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/dialogue_awesome.dart';
import 'package:http/http.dart' as http;

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

class AddSlotPage extends ConsumerStatefulWidget {
  List<dynamic> slotList;
  Map<String, dynamic> courseList;

  AddSlotPage({required this.slotList, required this.courseList});

  @override
  _AddSlotPageState createState() => _AddSlotPageState();
}

class _AddSlotPageState extends ConsumerState<AddSlotPage> {
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  List<DropdownMenuItem<int>> maxPeopleItems = List.generate(20, (index) {
    int numPeople = index + 1;
    return DropdownMenuItem<int>(
        value: numPeople,
        child: Padding(
            padding: const EdgeInsets.all(10), child: Text('$numPeople ppl')));
  });

  @override
  void initState() {
    super.initState();
    // 基本、riverpodはinitStateで使用できない。画面が構築される前にWidgetの情報を
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(slotListProvider.notifier).state = widget.slotList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final startTime = ref.watch(startTimeProvider);
    final endTime = ref.watch(endTimeProvider);
    final riverSlotList = ref.watch(slotListProvider);
    final maxPeople = ref.watch(maxCapacityProvider);

    Future<void> _createSlot() async {
      try {
        final token = await SharedPrefs.fetchStaffAccessToken();
        final List<String> formattedSlotList = [];
        riverSlotList.forEach((dateTime) {
          final String formattedDate =
              DateFormat('yyyy-MM-dd').format(dateTime);
          formattedSlotList.add(formattedDate);
        });
        var url = Uri.parse('${baseUri}reservations/slot/?token=$token');

        for (int i = 0; i < formattedSlotList.length; i++) {
          var response = await Future.any([
            http.post(
              url,
              headers: {
                "Authorization": "JWT $token",
                "Content-Type": "application/json"
              },
              body: jsonEncode({
                "course": widget.courseList['course_name'],
                "date": formattedSlotList[i],
                "start_time": startTime,
                "end_time": endTime,
                'max_people': maxPeople,
              }),
            ),
            Future.delayed(const Duration(seconds: 15),
                () => throw TimeoutException('Request timeout'))
          ]);
          if (response.statusCode == 201) {
            showSnackBar(kColorPrimary, 'Slot created successfully.');

            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
              builder: (context) {
                return MonthlySlotPage(courseList: widget.courseList);
              },
            ), ((route) => false));
          } else if (response.statusCode >= 400) {
            showSnackBar(Colors.red, 'Error: ${response.body}');
          } else {
            showSnackBar(Colors.red, 'Something went wrong. Try again later');
          }
        }
      } catch (e) {
        showSnackBar(Colors.red, '$e');
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(15.w),
            child: Column(
              children: [
                _Header(title: 'Add Slots'),
                Container(
                  height: 270.h,
                  child: ListView.builder(
                      itemCount: riverSlotList.length,
                      itemBuilder: (context, index) {
                        final DateTime dateTime = riverSlotList[index];
                        final String stringDate = DateFormat('yyyy-MM-dd')
                            .format(dateTime)
                            .toString();
                        String formattedDateOfWeek =
                            DateFormat.EEEE('en').format(dateTime);
                        return Slidable(
                            closeOnScroll: true,
                            endActionPane:
                                ActionPane(motion: ScrollMotion(), children: [
                              SlidableAction(
                                flex: 1,
                                onPressed: (context) async {
                                  ref
                                      .read(slotListProvider.notifier)
                                      .update((state) {
                                    final newList = List<dynamic>.from(state);
                                    newList.removeAt(index);
                                    // print(newList);
                                    return newList;
                                  });
                                },
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.white,
                                icon: Icons.delete_forever_outlined,
                                label: 'Delete',
                              )
                            ]),
                            child: Container(
                              height: 55.h,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.black, width: 0.2.h))),
                              child: Row(
                                // crossAxisAlignment: MAxisAlignment.center,
                                children: [
                                  SizedBox(width: 20.w),
                                  Text(stringDate,
                                      style: TextStyle(fontSize: 20.h)),
                                  Text(':  $formattedDateOfWeek',
                                      style: TextStyle(fontSize: 18.h)),
                                ],
                              ),
                            ));
                      }),
                ),
                Container(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20.h,
                      ),
                      Column(
                        children: [
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text('Start Time',
                                  style: TextStyle(
                                      color: kColorTextDarkGrey,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w500))),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                border: Border.all(color: kColorTextDarkGrey)),
                            child: DropdownButton(
                              underline: SizedBox.shrink(),
                              itemHeight: 50.h,
                              isExpanded: true,
                              style: TextStyle(
                                  fontSize: 22.sp, color: Colors.black),
                              items: const [
                                DropdownMenuItem(
                                  value: '11:00',
                                  child: Text('11:00'),
                                ),
                                DropdownMenuItem(
                                  value: '12:00',
                                  child: Text('12:00'),
                                ),
                                DropdownMenuItem(
                                  value: '13:00',
                                  child: Text('13:00'),
                                ),
                                DropdownMenuItem(
                                  value: '14:00',
                                  child: Text('14:00'),
                                ),
                                DropdownMenuItem(
                                  value: '15:00',
                                  child: Text('15:00'),
                                ),
                                DropdownMenuItem(
                                  value: '16:00',
                                  child: Text('16:00'),
                                ),
                                DropdownMenuItem(
                                  value: '17:00',
                                  child: Text('17:00'),
                                ),
                                DropdownMenuItem(
                                  value: '18:00',
                                  child: Text('18:00'),
                                ),
                                DropdownMenuItem(
                                  value: '19:00',
                                  child: Text('19:00'),
                                ),
                                DropdownMenuItem(
                                  value: '20:00',
                                  child: Text('20:00'),
                                ),
                              ],
                              value: startTime,
                              onChanged: (value) {
                                if (value != null) {
                                  ref.read(startTimeProvider.notifier).state =
                                      value;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text('End Time',
                                  style: TextStyle(
                                      color: kColorTextDarkGrey,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w500))),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                border: Border.all(color: kColorTextDarkGrey)),
                            child: DropdownButton(
                              underline: SizedBox.shrink(),
                              itemHeight: 50.h,
                              isExpanded: true,
                              style: TextStyle(
                                  fontSize: 22.sp, color: Colors.black),
                              items: const [
                                DropdownMenuItem(
                                  value: '11:00',
                                  child: Text('11:00'),
                                ),
                                DropdownMenuItem(
                                  value: '12:00',
                                  child: Text('12:00'),
                                ),
                                DropdownMenuItem(
                                  value: '13:00',
                                  child: Text('13:00'),
                                ),
                                DropdownMenuItem(
                                  value: '14:00',
                                  child: Text('14:00'),
                                ),
                                DropdownMenuItem(
                                  value: '15:00',
                                  child: Text('15:00'),
                                ),
                                DropdownMenuItem(
                                  value: '16:00',
                                  child: Text('16:00'),
                                ),
                                DropdownMenuItem(
                                  value: '17:00',
                                  child: Text('17:00'),
                                ),
                                DropdownMenuItem(
                                  value: '18:00',
                                  child: Text('18:00'),
                                ),
                                DropdownMenuItem(
                                  value: '19:00',
                                  child: Text('19:00'),
                                ),
                                DropdownMenuItem(
                                  value: '20:00',
                                  child: Text('20:00'),
                                ),
                              ],
                              value: endTime,
                              onChanged: (value) {
                                if (value != null) {
                                  ref.read(endTimeProvider.notifier).state =
                                      value;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text('Max Capacity',
                                  style: TextStyle(
                                      color: kColorTextDarkGrey,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w500))),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                border: Border.all(color: kColorTextDarkGrey)),
                            child: DropdownButton<int>(
                              underline: SizedBox.shrink(),
                              itemHeight: 50.h,
                              isExpanded: true,
                              style: TextStyle(
                                  fontSize: 22.sp, color: Colors.black),
                              items: maxPeopleItems,
                              value: maxPeople,
                              onChanged: (value) {
                                if (value != null) {
                                  ref.read(maxCapacityProvider.notifier).state =
                                      value;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          if (riverSlotList.isNotEmpty) {
                            CustomAwesomeDialogue(
                              titleText: 'Confirm',
                              desc: 'Push "OK" to add slots',
                              callback: () {
                                _createSlot();
                              },
                            ).show(context);
                          } else {
                            showSnackBar(
                                Colors.red, 'No slot has been selected');
                            return;
                          }

                          // Navigator.pop(context);
                        },
                        icon: const Icon(Icons.add),
                        label:
                            Text('Add Slot', style: TextStyle(fontSize: 20.sp)),
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all<Size>(
                              Size(300, 60)), // ボタンの幅と高さを設定
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
