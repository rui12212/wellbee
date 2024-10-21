import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/qr_after/user_home.dart';
import 'package:wellbee/ui_function/convert.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/dialogue_awesome.dart';

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

class StaffMembershipConfirmPage extends StatefulWidget {
  Map<dynamic, dynamic> attendeeList;
  Map<dynamic, dynamic> membershipMap;
  String userId;

  StaffMembershipConfirmPage({
    Key? key,
    required this.attendeeList,
    required this.membershipMap,
    required this.userId,
  }) : super(key: key);

  @override
  _StaffMembershipConfirmPageState createState() =>
      _StaffMembershipConfirmPageState();
}

class _StaffMembershipConfirmPageState
    extends State<StaffMembershipConfirmPage> {
  String? token = '';
  int totalPrice = 0;
  int finalPrice = 0;

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  void _createMembership() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse('${baseUri}attendances/membership/');
      var response = await Future.any([
        http.post(url,
            body: jsonEncode({
              'user': widget.attendeeList['user_id'],
              'attendee': widget.attendeeList['id'],
              'course': IntConverter.convertCourseToNum(
                  widget.membershipMap['course']),
              'original_price': widget.membershipMap['original_price'],
              'times_per_week': widget.membershipMap['times_per_week'],
              'duration': widget.membershipMap['duration'],
              'num_person': widget.membershipMap['num_person'],
              'discount_rate': widget.membershipMap['discount_rate'],
            }),
            headers: {
              "Authorization": 'JWT $token',
              'Content-Type': 'application/json',
            }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 201) {
        // List<dynamic> data = jsonDecode(response.body);
        // if (data.isNotEmpty) {
        showSnackBar(kColorPrimary, 'Purchase Membership success!');
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) {
            return UserHomePage(pk: widget.userId);
          },
        ), ((route) => false));
      } else if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Internet Error occurred. Try again later')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong. Try again later')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  calcTotalPrice() {
    int value = widget.membershipMap['original_price'] *
        widget.membershipMap['times_per_week'] *
        widget.membershipMap['duration'] *
        widget.membershipMap['num_person'];
    totalPrice = value;
    return totalPrice;
  }

  calcFinalDiscountedPrice(int int) {
    final value = int * widget.membershipMap['discount_rate'];
    final convertedValue = value.toInt();
    finalPrice = convertedValue;
  }

  @override
  void initState() {
    super.initState();
    totalPrice = calcTotalPrice();
    calcFinalDiscountedPrice(totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
              height: 700.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SingleChildScrollView(
                child: Column(children: [
                  _Header(),
                  _Question(
                    question: 'Confirm Membership',
                    name: widget.attendeeList['name'],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(30),
                      height: 500.h,
                      width: 390.w,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: FractionalOffset.topLeft,
                              end: FractionalOffset.bottomRight,
                              colors: [
                                kColorPrimary,
                                Color.fromARGB(255, 188, 250, 216),
                              ],
                              stops: const [
                                0.0,
                                1.0
                              ]),
                          borderRadius: BorderRadius.all(Radius.circular(70))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10.h,
                          ),
                          _DetailRow(
                            title: 'Course Name:',
                            value: widget.membershipMap['course'],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          _DetailRow(
                            title: 'Price per Month:',
                            value:
                                '${widget.membershipMap['original_price']} \$',
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          _DetailRow(
                            title: 'Duration:',
                            value: '${widget.membershipMap['duration']} month',
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          _DetailRow(
                            title: 'Times Per Week:',
                            value:
                                '${widget.membershipMap['times_per_week']} time',
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          _DetailRow(
                            title: 'Number of People:',
                            value:
                                '${widget.membershipMap['num_person']} people',
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          _DetailRow(
                            title: 'Total Price:',
                            value: '${totalPrice}\$',
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Divider(),
                          SizedBox(
                            height: 10.h,
                          ),
                          _SumDetailRow(
                            title: 'Discount Rate:',
                            value:
                                '${100 - widget.membershipMap['discount_rate'] * 100}\%',
                          ),
                          _SumDetailRow(
                            title: 'Final Price:',
                            value: '${finalPrice}\$',
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      print(
                        IntConverter.convertCourseToNum(
                            widget.membershipMap['course']),
                      );
                      CustomAwesomeDialogue(
                        titleText: 'Check out',
                        desc:
                            'Did you confirm the contents?\nDid you receive the payment?',
                        callback: _createMembership,
                      ).show(context);
                    },
                    child: Text('Check Out',
                        style: TextStyle(
                          color: kColorPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                        )),
                  ),
                  SizedBox(
                    height: 50.h,
                  ),
                ]),
              )),
        ));
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;

  _DetailRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w300,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}

class _SumDetailRow extends StatelessWidget {
  final String title;
  final String value;

  _SumDetailRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
