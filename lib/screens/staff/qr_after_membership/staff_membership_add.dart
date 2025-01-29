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
import 'package:wellbee/screens/staff/qr_after_membership/staff_private_membership_confirm.dart';
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
            Text(
              name,
              style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            )
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
  final TextEditingController _discountController = TextEditingController();

  String? token = '';
  String selectedCourse = 'Yoga';
  int selectedTimes = 1;
  int selectedDuration = 1;
  // late DateTime newDate = DateTime(2000);
  int selectedPrice = 54;
  double selectedDiscountRate = 1.0;
  int selectedNumPerson = 1;
  int selectedOffer = 0;
  late DateTime newDate = DateTime.now();
  List<DropdownMenuItem<String>> courseDropDownItems = [];
  bool isFixedPrice = false;
  int times = 1;
  int private_total_price = 50;
  bool is_private = false;
  bool is_kids = false;

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  @override
  void initState() {
    super.initState();
    createCourseDropDown();
    // _fetchMyAllMembershipAdd();
  }

  // List<DropdownMenuItem> originalPriceItems = List.generate(15, (index) {
  //   int price = (index + 1) * 10;
  //   return DropdownMenuItem(
  //       value: price,
  //       child: Padding(
  //           padding: const EdgeInsets.all(10), child: Text('${price}\$')));
  // });

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

  List<DropdownMenuItem> monthItems = List.generate(4, (index) {
    List numItems = [
      1,
      3,
      6,
      12,
    ];
    int numMonth = (numItems[index]);
    return DropdownMenuItem(
        value: numMonth,
        child: Padding(
            padding: const EdgeInsets.all(10), child: Text('$numMonth month')));
  });

  List<DropdownMenuItem> privateMonthItems = List.generate(3, (index) {
    List numItems = [
      1,
      2,
      3,
    ];
    int numMonth = (numItems[index]);
    return DropdownMenuItem(
        value: numMonth,
        child: Padding(
            padding: const EdgeInsets.all(10), child: Text('$numMonth month')));
  });

  List<DropdownMenuItem<int>> privateTimesItems = List.generate(10, (index) {
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
    ];
    int numTimes = (numItems[index]);
    return DropdownMenuItem(
        value: numTimes,
        child: Padding(
            padding: const EdgeInsets.all(10), child: Text('$numTimes time')));
  });

  // List<DropdownMenuItem<dynamic>> minusItems = List.generate(11, (index) {
  //   List numItems = [
  //     0,
  //     10,
  //     20,
  //     30,
  //     40,
  //     50,
  //     60,
  //     70,
  //     80,
  //     90,
  //     100,
  //   ];
  //   int numMinus = (numItems[index]);
  //   return DropdownMenuItem(
  //       value: numMinus,
  //       child: Padding(
  //           padding: const EdgeInsets.all(10), child: Text('$numMinus')));
  // });

  Future<List<dynamic>?> _fetchAllCourse() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse('${baseUri}attendances/course/?token=$token');
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
        List courseList = [];
        if (data.isNotEmpty) {
          for (int i = 0; i < 14; i++) {
            courseList.add(data[i]['course_name']);
          }
          return courseList;
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

  Future createCourseDropDown() async {
    final courseList = await _fetchAllCourse();
    final int countsCourse = courseList!.length;
    List<DropdownMenuItem<String>> courseItems =
        List.generate(countsCourse, (index) {
      String course = (courseList![index]);
      return DropdownMenuItem(
          value: course,
          child: Padding(
              padding: const EdgeInsets.all(10), child: Text('$course')));
    });

    if (mounted) {
      setState(() {
        courseDropDownItems = courseItems;
      });
    }
  }

  List<DropdownMenuItem<dynamic>> totalPriceItems = List.generate(5, (index) {
    List priceItems = [
      54,
      144,
      252,
      360,
      135,
    ];
    int priceItem = (priceItems[index]);
    return DropdownMenuItem(
        value: priceItem,
        child: Padding(
            padding: const EdgeInsets.all(10), child: Text('$priceItem')));
  });

  List<DropdownMenuItem<dynamic>> offerPriceItems = List.generate(4, (index) {
    List offerItems = [
      0,
      48,
      42,
      30,
    ];
    int offerItem = (offerItems[index]);
    int month = index == 1
        ? 3
        : index == 2
            ? 6
            : 12;
    return DropdownMenuItem(
        value: offerItem,
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: offerItem == 0
                ? Text('No Offer')
                : Text('1month Free($month months course)')));
  });

  List<DropdownMenuItem<dynamic>> kidsOfferPriceItems =
      List.generate(2, (index) {
    List offerItems = [
      0,
      45,
    ];
    int offerItem = (offerItems[index]);
    return DropdownMenuItem(
        value: offerItem,
        child: Padding(
            padding: EdgeInsets.all(10),
            child: offerItem == 0
                ? Text('No Offer')
                : Text('1month Free(kids course)')));
  });

  void updatePrice() {
    if (['Yoga', 'Pilates', 'Zumba'].contains(selectedCourse)) {
      is_private = false;
      is_kids = false;
      switch (selectedDuration) {
        case 1:
          selectedPrice = 54;
          break;
        case 2:
          selectedDuration = 1;
          selectedPrice = 54;
          break;
        case 3:
          selectedPrice = 144;
          break;
        case 6:
          selectedPrice = 252;
          break;
        case 12:
          selectedPrice = 360;
          break;
        default:
          selectedPrice = 54;
      }
      isFixedPrice = true;
      // offer関連のエラー
    } else if (selectedOffer == 45 &&
        ['Yoga', 'Pilates', 'Zumba'].contains(selectedCourse)) {
      is_private = false;
      is_kids = false;
      setState(() {
        selectedCourse = 'Yoga';
        selectedDuration = 1;
        selectedPrice = 54;
        selectedOffer = 0;
      });
      showSnackBar(Colors.red, 'Error:Select course correctly');
    } else if ([
              48,
              42,
              30,
            ].contains(selectedOffer) &&
            [
              'Private Yoga@Studio',
              'Private Pilates@Studio',
              'Private Yoga@Home',
              'Private Pilates@Home',
            ].contains(selectedCourse) ||
        [
              48,
              42,
              30,
            ].contains(selectedOffer) &&
            [
              'Kids Zumba',
              'Kids Karate',
              'Kids Gym(A)',
              'Kids Gym(B)',
              'Kids Yoga KG',
              'Kids Yoga(A)',
              'Kids Yoga(B)'
            ].contains(selectedCourse)) {
      setState(() {
        selectedCourse = 'Yoga';
        selectedDuration = 1;
        selectedPrice = 54;
        selectedOffer = 0;
      });
      showSnackBar(Colors.red, 'Error:Select course correctly');
    } else if ([
      'Kids Zumba',
      'Kids Karate',
      'Kids Gym(A)',
      'Kids Gym(B)',
      'Kids Yoga KG',
      'Kids Yoga(A)',
      'Kids Yoga(B)'
    ].contains(selectedCourse)) {
      selectedDuration = 3;
      selectedPrice = 135;
      isFixedPrice = true;
      is_private = false;
      is_kids = true;
    } else if ([
          'Private Yoga@Studio',
          'Private Pilates@Studio',
          'Private Yoga@Home',
          'Private Pilates@Home',
        ].contains(selectedCourse) &&
        [6, 12].contains(selectedDuration)) {
      setState(() {
        selectedCourse = 'Yoga';
        selectedDuration = 1;
        selectedPrice = 54;
      });
      showSnackBar(Colors.red, 'Error:Select course correctly');
    } else if ([
      'Private Yoga@Studio',
      'Private Pilates@Studio',
    ].contains(selectedCourse)) {
      final monthlyPrice = 50;
      setState(() {
        selectedPrice = monthlyPrice * selectedTimes;
      });
      isFixedPrice = true;
      is_private = true;
    } else if ([
      'Private Yoga@Home',
      'Private Pilates@Home',
    ].contains(selectedCourse)) {
      final monthlyPrice = 60;
      setState(() {
        selectedPrice = monthlyPrice * selectedTimes;
      });
      isFixedPrice = true;
      is_private = true;
    }
  }

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
                  height: 580.r,
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
                          height: 20.h,
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
                                items: courseDropDownItems,
                                value: selectedCourse,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedCourse = value!;
                                    updatePrice();
                                  });
                                  if (![
                                    'Kids Zumba',
                                    'Kids Karate',
                                    'Kids Gym(A)',
                                    'Kids Gym(B)',
                                    'Kids Yoga KG',
                                    'Kids Yoga(A)',
                                    'Kids Yoga(B)'
                                  ].contains(selectedCourse)) {
                                    selectedOffer = 0;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
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
                              child: is_private == false
                                  ? DropdownButton(
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
                                          updatePrice();
                                        });
                                      },
                                    )
                                  : DropdownButton(
                                      underline: SizedBox.shrink(),
                                      itemHeight: 75.h,
                                      isExpanded: true,
                                      style: TextStyle(
                                          fontSize: 22.sp, color: Colors.black),
                                      items: privateMonthItems,
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
                        is_private == true
                            ? Column(
                                children: [
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  Align(
                                      alignment: Alignment.topLeft,
                                      child: Text('Times',
                                          style: TextStyle(
                                              color: kColorTextDarkGrey,
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.w500))),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        border: Border.all(
                                            color: kColorTextDarkGrey)),
                                    child: DropdownButton(
                                      underline: SizedBox.shrink(),
                                      itemHeight: 75.h,
                                      isExpanded: true,
                                      style: TextStyle(
                                          fontSize: 22.sp, color: Colors.black),
                                      items: privateTimesItems,
                                      value: selectedTimes,
                                      onChanged: (int? value) {
                                        setState(() {
                                          selectedTimes = value!;
                                          updatePrice();
                                          // updatePrice();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox(),
                        SizedBox(
                          height: 25.h,
                        ),
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text('Price',
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
                              child: isFixedPrice == false
                                  ? DropdownButton(
                                      underline: SizedBox.shrink(),
                                      itemHeight: 75.h,
                                      value: selectedPrice,
                                      isExpanded: true,
                                      style: TextStyle(
                                          fontSize: 22.sp, color: Colors.black),
                                      hint: Text('Select an original price'),
                                      items: totalPriceItems,
                                      onChanged: (dynamic newValue) {
                                        setState(() {
                                          selectedPrice = newValue as int;
                                        });
                                      })
                                  : Container(
                                      width: double.infinity,
                                      alignment: Alignment.centerLeft,
                                      height: 75.h,
                                      child: Text('$selectedPrice\$',
                                          style: TextStyle(fontSize: 24.h))),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25.h,
                        ),
                        SizedBox(
                          height: 25.h,
                        ),
                        SizedBox(
                          height: 25.h,
                        ),
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text('Offer',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            is_private == false
                                ? Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        border: Border.all(
                                            color: kColorTextDarkGrey)),
                                    child: DropdownButton(
                                        underline: SizedBox.shrink(),
                                        isExpanded: true,
                                        style: TextStyle(
                                            fontSize: 22.sp,
                                            color: Colors.black),
                                        itemHeight: 75.h,
                                        value: selectedOffer,
                                        hint:
                                            Text('Select an minus amount(\$)'),
                                        items: is_kids == false
                                            ? offerPriceItems
                                            : kidsOfferPriceItems,
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedOffer = newValue as int;
                                            updatePrice();
                                          });
                                        }),
                                  )
                                : Container(
                                    width: double.infinity,
                                    alignment: Alignment.centerLeft,
                                    height: 75.h,
                                    child: Text('No Offer',
                                        style: TextStyle(fontSize: 24.h))),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text('Discount(\$)',
                                    style: TextStyle(
                                        color: kColorTextDarkGrey,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500))),
                            LeftCustomTextBox(
                              label: '',
                              hintText: '0',
                              inputType: TextInputType.number,
                              controller: _discountController,
                            ).textFieldDecoration(),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text('Discount(%)',
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
                          height: 52.h,
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            final discountAmount =
                                _discountController.text.trim();
                            int? intDiscountAmount =
                                int.tryParse(discountAmount);
                            if (intDiscountAmount == null) {
                              intDiscountAmount = 0;
                            }
                            final String formattedDate =
                                DateFormat('yyyy-MM-dd').format(newDate);

                            if (is_private == false) {
                              if (['Yoga', 'Zumba', 'Pilates']
                                      .contains(selectedCourse) &&
                                  selectedOffer != 0) {
                                if (selectedDuration == 1 &&
                                    [48, 42, 30].contains(selectedOffer)) {
                                  showSnackBar(Colors.red,
                                      'Course duration&Offer does NOT match');
                                  return;
                                } else if (selectedDuration == 3 &&
                                    selectedOffer != 48) {
                                  showSnackBar(Colors.red,
                                      'Course duration&Offer does NOT match');
                                  return;
                                } else if (selectedDuration == 6 &&
                                    selectedOffer != 42) {
                                  showSnackBar(Colors.red,
                                      'Course duration&Offer does NOT match');
                                  return;
                                } else if (selectedDuration == 12 &&
                                    selectedOffer != 30) {
                                  showSnackBar(Colors.red,
                                      'Course duration&Offer does NOT match');
                                  return;
                                }
                              }

                              Map<dynamic, dynamic> membershipMap = {
                                'course': selectedCourse,
                                'duration': selectedDuration,
                                'total_price': selectedPrice,
                                'offer': selectedOffer,
                                'minus': intDiscountAmount,
                                'discount_rate': selectedDiscountRate,
                                'start_day': formattedDate.toString(),
                              };
                              // print(membershipMap);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      StaffMembershipConfirmPage(
                                        attendeeList: widget.attendeeList,
                                        membershipMap: membershipMap,
                                        userId: widget.userId,
                                      )));
                            } else if (is_private == true) {
                              Map<dynamic, dynamic> membershipMap = {
                                'course': selectedCourse,
                                'duration': selectedDuration,
                                'times': selectedTimes,
                                'total_price': selectedPrice,
                                'minus': intDiscountAmount,
                                'offer': selectedOffer,
                                'discount_rate': selectedDiscountRate,
                                'start_day': formattedDate.toString(),
                              };
                              // print(membershipMap);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      StaffPrivateMembershipConfirmPage(
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
