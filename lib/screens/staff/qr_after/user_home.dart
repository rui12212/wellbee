import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/home.dart';
import 'package:wellbee/screens/staff/auth/staff_top_page.dart';
import 'package:wellbee/screens/staff/qr_after_attendee/attendee_all.dart';
import 'package:wellbee/screens/staff/calendar/calendar.dart';
import 'package:wellbee/screens/staff/qr_after_graph/staff_attendee.dart';
import 'package:wellbee/screens/staff/qr_after_membership/staff_membership.dart';
import 'package:wellbee/screens/staff/qr_after_point/point_select.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/dialogue_awesome.dart';

class UserHomePage extends StatefulWidget {
  final String pk;
  UserHomePage({
    Key? key,
    required this.pk,
  }) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>?> _fetchUser() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse('${baseUri}accounts/users/${widget.pk}');
      var response = await Future.any([
        http.get(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json"
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
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

  void showAwesomeDialog() {
    CustomAwesomeDialogueForCancelReservation(
      titleText: 'Go back to Staff Home',
      desc: 'Are you sure to go back?',
      callback: () async {
        await Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: ((context) {
          return StaffTopPage(0);
        })));
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //     automaticallyImplyLeading: false,
        //     title: Text('User Home',
        //         style: TextStyle(
        //             color: Colors.white,
        //             fontSize: 28,
        //             fontWeight: FontWeight.bold)),
        //     backgroundColor: kColorPrimary),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
            ),
            child: FutureBuilder(
                future: _fetchUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Text('No attendee registered'));
                  } else {
                    final userData = snapshot.data!;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('User phone:',
                                style: TextStyle(
                                    fontSize: 25.sp,
                                    fontWeight: FontWeight.w300)),
                            Text(userData['phone_number'],
                                style: TextStyle(
                                    fontSize: 25.sp,
                                    fontWeight: FontWeight.w300)),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        InkWell(
                            child: Container(
                                height: 100.h,
                                width: 390.w,
                                decoration: BoxDecoration(
                                    border: Border.symmetric(
                                        horizontal: BorderSide(width: 0.2))),
                                child: Row(
                                  children: [
                                    Icon(Icons.person_2_outlined,
                                        color:
                                            Color.fromARGB(255, 97, 198, 187),
                                        size: 30.h),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text('Wellbee Member',
                                        style: TextStyle(fontSize: 26.sp))
                                  ],
                                )),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      StaffAttendeeAllPage(userId: widget.pk)));
                            }),
                        InkWell(
                            child: Container(
                                height: 100.h,
                                width: 390.w,
                                decoration: BoxDecoration(
                                    border: Border.symmetric(
                                        horizontal: BorderSide(width: 0.2))),
                                child: Row(
                                  children: [
                                    Icon(Icons.airplane_ticket_outlined,
                                        color:
                                            Color.fromARGB(255, 97, 198, 187),
                                        size: 30.h),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text('Membership',
                                        style: TextStyle(fontSize: 26.sp))
                                  ],
                                )),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      StaffMembershipPage(pk: widget.pk)));
                            }),
                        InkWell(
                            child: Container(
                                height: 100.h,
                                width: 390.w,
                                decoration: BoxDecoration(
                                    border: Border.symmetric(
                                        horizontal: BorderSide(width: 0.2))),
                                child: Row(
                                  children: [
                                    Icon(Icons.auto_graph_outlined,
                                        color:
                                            Color.fromARGB(255, 97, 198, 187),
                                        size: 30.h),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text('Graph',
                                        style: TextStyle(fontSize: 26.sp))
                                  ],
                                )),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      GraphAttendeePage(userId: widget.pk)));
                            }),
                        InkWell(
                            child: Container(
                                height: 100.h,
                                width: 390.w,
                                decoration: BoxDecoration(
                                    border: Border.symmetric(
                                        horizontal: BorderSide(width: 0.2))),
                                child: Row(
                                  children: [
                                    Icon(Icons.point_of_sale_outlined,
                                        color:
                                            Color.fromARGB(255, 97, 198, 187),
                                        size: 30.h),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text('Wellbee Point',
                                        style: TextStyle(fontSize: 26.sp))
                                  ],
                                )),
                            onTap: () {
                              // print(userData['points']);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      PointSelectPage(pk: widget.pk)));
                            }),
                        // SizedBox(
                        //   height: 5.h,
                        // ),
                        InkWell(
                            child: Container(
                                height: 100.h,
                                width: 390.w,
                                decoration: BoxDecoration(
                                    border: Border.symmetric(
                                        horizontal: BorderSide(width: 0.2))),
                                child: Row(
                                  children: [
                                    Icon(Icons.exit_to_app_outlined,
                                        color:
                                            Color.fromARGB(255, 97, 198, 187),
                                        size: 30.h),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text('Go back to Staff Page',
                                        style: TextStyle(fontSize: 26.sp))
                                  ],
                                )),
                            onTap: () {
                              // print(userData['points']);
                              showAwesomeDialog();
                            }),
                      ],
                    );
                  }
                }),
          ),
        ));
  }
}
