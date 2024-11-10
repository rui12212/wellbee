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
                style: TextStyle(fontSize: 28.h, fontWeight: FontWeight.w300)),
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
  // late DateTime newDate = DateTime(2000);
  int selectedPrice = 10;
  double selectedDiscountRate = 1.0;
  int selectedNumPerson = 1;
  int selectedMinus = 0;
  late DateTime newDate = DateTime.now();

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

  List<DropdownMenuItem> monthItems = List.generate(19, (index) {
    List numItems = [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
    ];
    int numMonth = (numItems[index]);
    return DropdownMenuItem(
        value: numMonth,
        child: Padding(
            padding: const EdgeInsets.all(10), child: Text('$numMonth month')));
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

  List<DropdownMenuItem<dynamic>> minusItems = List.generate(11, (index) {
    List numItems = [
      0,
      10,
      20,
      30,
      40,
      50,
      60,
      70,
      80,
      90,
      100,
    ];
    int numMinus = (numItems[index]);
    return DropdownMenuItem(
        value: numMinus,
        child: Padding(
            padding: const EdgeInsets.all(10), child: Text('$numMinus')));
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
                                underline: SizedBox.shrink(),
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
                                    value: 'Kids Yoga KG',
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('Kids Yoga KG'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Kids Yoga(A)',
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('Kids Yoga(A)'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Kids Yoga(B)',
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('Kids Yoga(B)'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Pilates',
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('Pilates'),
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
                                    value: 'Kids Taiso(A)',
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('Kids Taiso(A)'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Kids Taiso(B)',
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('Kids Taiso(B)'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Family Yoga',
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('Family Yoga'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Family Pilates',
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('Family Pilates'),
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
                                  underline: SizedBox.shrink(),
                                  itemHeight: 75.h,
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
                                underline: SizedBox.shrink(),
                                itemHeight: 75.h,
                                isExpanded: true,
                                style: TextStyle(
                                    fontSize: 22.sp, color: Colors.black),
                                items: monthItems,
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
                                underline: SizedBox.shrink(),
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
                                  underline: SizedBox.shrink(),
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
                                child: Text('Minus(\$)',
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
                                  underline: SizedBox.shrink(),
                                  isExpanded: true,
                                  style: TextStyle(
                                      fontSize: 22.sp, color: Colors.black),
                                  itemHeight: 75.h,
                                  value: selectedMinus,
                                  hint: Text('Select an minus amount(\$)'),
                                  items: minusItems,
                                  onChanged: (newValue) {
                                    // print(widget.attendeeList['points']);
                                    setState(() {
                                      selectedMinus = newValue;
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
                                  underline: SizedBox.shrink(),
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
                          height: 15.h,
                        ),
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text('Start Day',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            Container(
                              width: 390.w,
                              height: 65.h,
                              child: TextButton(
                                style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all<Size>(
                                      Size(150, 50)), // ボタンのサイズを設定
                                  side: MaterialStateProperty.all<BorderSide>(
                                    BorderSide(
                                        color: kColorTextDarkGrey,
                                        width: 1), // 枠線の色と幅を設定
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10), // 枠線の角を丸くする
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  final DateTime? _selectedDate =
                                      await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2024),
                                    lastDate: DateTime(2030),
                                  );
                                  if (_selectedDate != null) {
                                    setState(
                                      () {
                                        newDate = _selectedDate;
                                      },
                                    );
                                  }
                                },
                                child: Text(
                                  '${newDate.year}/${newDate.month}/${newDate.day}',
                                  style: TextStyle(
                                      fontSize: 22.sp,
                                      color:
                                          Color.fromARGB(255, 161, 154, 154)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 52.h,
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            // Family以外が1人より上なら
                            if ((selectedCourse != 'Family Yoga' &&
                                    selectedCourse != 'Family Pilates') &&
                                selectedNumPerson > 1) {
                              print(selectedCourse);
                              // print(selectedNumPerson);
                              showSnackBar(Colors.red,
                                  'Only Family Yoga & Family Pilates has more than 1 number of person');
                              return;
                              // Familyが1人なら
                            } else if ((selectedCourse == 'Family Yoga' ||
                                    selectedCourse == 'Family Pilates') &&
                                selectedNumPerson == 1) {
                              // print(selectedCourse);
                              // print(selectedNumPerson);
                              showSnackBar(Colors.red,
                                  'Only Family Yoga & Family Pilates has more than 1 number of person');
                              return;
                            } else {
                              final String formattedDate =
                                  DateFormat('yyyy-MM-dd').format(newDate);

                              Map<dynamic, dynamic> membershipMap = {
                                'course': selectedCourse,
                                'original_price': selectedPrice,
                                'times_per_week': selectedTimesPerWeek,
                                'duration': selectedDuration,
                                'num_person': selectedNumPerson,
                                'minus': selectedMinus,
                                'discount_rate': selectedDiscountRate,
                                'start_day': formattedDate.toString(),
                              };
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      StaffMembershipConfirmPage(
                                        attendeeList: widget.attendeeList,
                                        membershipMap: membershipMap,
                                        userId: widget.userId,
                                      )));
                            }
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
