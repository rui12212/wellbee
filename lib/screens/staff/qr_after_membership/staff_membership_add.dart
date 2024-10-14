// import 'package:booking_calendar/booking_calendar.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/membership/membership_attendee.dart';
import 'package:wellbee/screens/membership/membership_confirm.dart';
import 'package:wellbee/screens/staff/qr_after_membership/staff_membership_confirm.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/convert.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:wellbee/ui_parts/textstyle.dart';
import 'package:wellbee/ui_parts/ticket.dart';

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
  String name;

  _Question({required this.question, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100.h,
        child: Column(
          children: [
            Text(question,
                style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w300)),
            Text(name,
                style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w600))
          ],
        ));
  }
}

class StaffMembershipAddPage extends StatefulWidget {
  late Map<dynamic, dynamic> attendeeList;
  String userId;

  StaffMembershipAddPage({
    Key? key,
    required this.attendeeList,
    required this.userId,
  }) : super(key: key);

  @override
  _StaffMembershipAddPageState createState() => _StaffMembershipAddPageState();
}

class _StaffMembershipAddPageState extends State<StaffMembershipAddPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  String? token = '';
  String selectedCourse = 'Yoga';
  int selectedTimesPerWeek = 1;
  int selectedDuration = 1;
  late DateTime newDate = DateTime(2000);
  int selectedPrice = 10;
  double selectedDiscountRate = 1.0;
  int selectedNumPerson = 1;

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  @override
  void initState() {
    super.initState();
    // _fetchMyAllMembershipAdd();
  }

  List<DropdownMenuItem> originalPriceItems = List.generate(15, (index) {
    int price = (index + 1) * 10;
    return DropdownMenuItem(
        value: price,
        child: Padding(
            padding: const EdgeInsets.all(10), child: Text('${price}\$')));
  });

  List<DropdownMenuItem<dynamic>> discountRateItems =
      List.generate(13, (index) {
    List discountItems = [
      1.0,
      0.95,
      0.9,
      0.85,
      0.8,
      0.75,
      0.7,
      0.65,
      0.6,
      0.55,
      0.5,
      0.45,
      0.4
    ];
    double rate = (discountItems[index]);
    double discountPercentage = 100 - rate * 100;

    return DropdownMenuItem(
        value: rate,
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text('${discountPercentage.toStringAsFixed(1)}\%')));
  });

  List<DropdownMenuItem<dynamic>> numPersonItems = List.generate(5, (index) {
    List numItems = [
      1,
      2,
      3,
      4,
      5,
    ];
    int numPerson = (numItems[index]);
    return DropdownMenuItem(
        value: numPerson,
        child: Padding(
            padding: const EdgeInsets.all(10), child: Text('$numPerson')));
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _Header(),
                _Question(
                  question: 'Buy Membership for',
                  name: widget.attendeeList['name'],
                ),
                Container(
                  height: 580.h,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 36.h,
                        ),
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text('Course',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  border:
                                      Border.all(color: kColorTextDarkGrey)),
                              child: DropdownButton(
                                itemHeight: 75.h,
                                isExpanded: true,
                                style: TextStyle(
                                    fontSize: 22.sp, color: Colors.black),
                                items: [
                                  DropdownMenuItem(
                                    value: 'Yoga',
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('Yoga'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Kids Yoga',
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('Kids Yoga'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Zumba',
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('Zumba'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Dance',
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('Dance'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Kids Dance',
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('Kids Dance'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Karate',
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('Karate'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Kids Karate',
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('Kids Karate'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Music',
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('Music'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Kids Music',
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('Kids Music'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Kids Taiso',
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('Kids Taiso'),
                                    ),
                                  ),
                                ],
                                value: selectedCourse,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedCourse = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25.h,
                        ),
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text('Price/Month',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  border:
                                      Border.all(color: kColorTextDarkGrey)),
                              child: DropdownButton(
                                  value: selectedPrice,
                                  isExpanded: true,
                                  style: TextStyle(
                                      fontSize: 22.sp, color: Colors.black),
                                  hint: Text('Select an original price'),
                                  items: originalPriceItems,
                                  onChanged: (dynamic newValue) {
                                    setState(() {
                                      selectedPrice = newValue as int;
                                    });
                                  }),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25.h,
                        ),
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text('Months',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  border:
                                      Border.all(color: kColorTextDarkGrey)),
                              child: DropdownButton(
                                itemHeight: 75.h,
                                isExpanded: true,
                                style: TextStyle(
                                    fontSize: 22.sp, color: Colors.black),
                                items: [
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('1 month'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('3 months'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 6,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('6 months'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 12,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('1 year'),
                                    ),
                                  ),
                                ],
                                value: selectedDuration,
                                onChanged: (value) {
                                  setState(() {
                                    selectedDuration = value as int;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25.h,
                        ),
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text('Times per a week',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  border:
                                      Border.all(color: kColorTextDarkGrey)),
                              child: DropdownButton(
                                itemHeight: 75.h,
                                isExpanded: true,
                                style: TextStyle(
                                    fontSize: 22.sp, color: Colors.black),
                                items: [
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('1 time in a week'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('2 times in a week'),
                                    ),
                                  ),
                                ],
                                value: selectedTimesPerWeek,
                                onChanged: (value) {
                                  setState(() {
                                    selectedTimesPerWeek = value as int;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25.h,
                        ),
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text('Number of People',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  border:
                                      Border.all(color: kColorTextDarkGrey)),
                              child: DropdownButton(
                                  isExpanded: true,
                                  style: TextStyle(
                                      fontSize: 22.sp, color: Colors.black),
                                  itemHeight: 75.h,
                                  value: selectedNumPerson,
                                  hint: Text('Select number of people'),
                                  items: numPersonItems,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedNumPerson = newValue;
                                    });
                                  }),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25.h,
                        ),
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text('Discount rate',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  border:
                                      Border.all(color: kColorTextDarkGrey)),
                              child: DropdownButton(
                                  isExpanded: true,
                                  style: TextStyle(
                                      fontSize: 22.sp, color: Colors.black),
                                  itemHeight: 75.h,
                                  value: selectedDiscountRate,
                                  hint: Text('Select an discount rate'),
                                  items: discountRateItems,
                                  onChanged: (newValue) {
                                    // print(widget.attendeeList['points']);
                                    setState(() {
                                      selectedDiscountRate = newValue;
                                    });
                                  }),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 52.h,
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            Map<dynamic, dynamic> membershipMap = {
                              'course': selectedCourse,
                              'original_price': selectedPrice,
                              'times_per_week': selectedTimesPerWeek,
                              'duration': selectedDuration,
                              'num_person': selectedNumPerson,
                              'discount_rate': selectedDiscountRate,
                            };
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    StaffMembershipConfirmPage(
                                      attendeeList: widget.attendeeList,
                                      membershipMap: membershipMap,
                                      userId: widget.userId,
                                    )));
                          },
                          label: Text('Check Out',
                              style: TextStyle(fontSize: 20.sp)),
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all<Size>(
                                Size(300, 80)), // ボタンの幅と高さを設定
                          ),
                        ),
                        SizedBox(
                          height: 25.h,
                        ),
                        SizedBox(
                          height: 52.h,
                        ),
                      ],
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
}
