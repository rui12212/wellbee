import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/calendar/calendar.dart';
import 'package:wellbee/screens/staff/course/course.dart';
import 'package:wellbee/screens/staff/qr_after/user_home.dart';
import 'package:wellbee/screens/staff/qr_after_point/point_decrease.dart';
import 'package:wellbee/screens/staff/qr_after_point/point_increase.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:http/http.dart' as http;

class _Header extends StatelessWidget {
  String title;
  String pk;

  _Header({
    required this.title,
    required this.pk,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                Text(
                  title,
                  style:
                      TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: const CircleBorder(
                          side: BorderSide(
                              color: Color.fromARGB(255, 206, 204, 204),
                              width: 5))),
                  child: const Icon(Icons.chevron_left,
                      color: Color.fromARGB(255, 155, 152, 152)),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                      builder: (context) {
                        return UserHomePage(pk: pk);
                      },
                    ), ((route) => false));
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PointSelectPage extends StatefulWidget {
  String pk;
  PointSelectPage(
      // this.newUser,
      {
    Key? key,
    required this.pk,
  }) : super(key: key);

  @override
  _PointSelectPageState createState() => _PointSelectPageState();
}

class _PointSelectPageState extends State<PointSelectPage> {
  String? token = '';

  Future<Map<String, dynamic>?> _fetchPoint() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url =
          Uri.parse('${baseUri}accounts/users/${widget.pk}/?token=$token');
      var response = await Future.any([
        http.get(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json"
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request Timeout"))
      ]);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty && data != null) {
          // print(data);
          return data;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Error occurred. You may not have taken survey')));
        }
      } else if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Internet Error occurred')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong. Try again later')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Other Error: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      _Header(title: 'Select Point Use', pk: widget.pk),
                    ],
                  ),
                  FutureBuilder(
                      future: _fetchPoint(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          return Container(
                            height: 600.h,
                            child: Column(
                              children: [Text('No User can be found')],
                            ),
                          );
                        } else {
                          final fetchedUser = snapshot.data!;
                          return Container(
                            height: 600.h,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Current Point',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 20.sp)),
                                Text('${fetchedUser['points']}pt',
                                    style: TextStyle(
                                        fontSize: 50.sp,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(
                                  height: 26.h,
                                ),
                                FilledButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PointIncreasePage(
                                                    pk: widget.pk,
                                                    point: fetchedUser[
                                                        'points'])));
                                  },
                                  icon: const Icon(Icons.arrow_upward_outlined),
                                  label: Text('Increase Point',
                                      style: TextStyle(fontSize: 20.sp)),
                                  style: ButtonStyle(
                                    minimumSize:
                                        MaterialStateProperty.all<Size>(
                                            Size(300, 80)), // ボタンの幅と高さを設定
                                  ),
                                ),
                                SizedBox(
                                  height: 52.h,
                                ),
                                FilledButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PointDecreasePage(
                                                    pk: widget.pk,
                                                    point: fetchedUser[
                                                        'points'])));
                                  },
                                  icon:
                                      const Icon(Icons.arrow_downward_outlined),
                                  label: Text('Decrease Point',
                                      style: TextStyle(fontSize: 20.sp)),
                                  style: ButtonStyle(
                                    minimumSize:
                                        MaterialStateProperty.all<Size>(
                                            Size(300, 80)), // ボタンの幅と高さを設定
                                  ),
                                ),
                                SizedBox(
                                  height: 52.h,
                                ),
                              ],
                            ),
                          );
                        }
                      })
                ],
              ),
            ),
          ),
        ));
  }
}
