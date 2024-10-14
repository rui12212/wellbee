import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/display.dart';

import '../../ui_parts/color.dart';
import 'package:qr_flutter/qr_flutter.dart';

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Row(
        children: [
          TextButton(
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
        ],
      ),
    );
  }
}

class _Question extends StatelessWidget {
  String question;

  _Question({
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80.h,
        child: Column(
          children: [
            Text(question,
                style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w300))
          ],
        ));
  }
}

class PointPage extends StatefulWidget {
  String userId;
  int points;
  PointPage({Key? key, required this.userId, required this.points})
      : super(key: key);

  @override
  _PointPageState createState() => _PointPageState();
}

class _PointPageState extends State<PointPage> {
  String? token = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _Header(),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                      padding: EdgeInsets.all(20),
                      height: 670.h,
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
                      child: Container(
                        height: 500.h,
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: [
                            SizedBox(height: 50.h),
                            QrImageView(
                              data: '${baseUri}accounts/users/${widget.userId}',
                              version: QrVersions.auto,
                              size: 150.0.h,
                            ),
                            SizedBox(height: 20.h),
                            _DetailRow(
                              // title: 'Wellbee Point',
                              value: '${widget.points}',
                              // value: '500 pt',
                            ),
                            SizedBox(height: 20.h),
                            Container(
                              height: 300.h,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'How to get Wellbee Point?',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        height: 60.h,
                                        width: 60.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(70)),
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: AssetImage(
                                                  'lib/assets/home_pic/point_reserve.png')),
                                        ),
                                      ),

                                      // alignment: Alignment.bottomCenter,
                                      Center(
                                          child: Container(
                                        width: 220.w,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('1 Point/time',
                                                style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text('Reserve & attend the course',
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight:
                                                        FontWeight.w300)),
                                          ],
                                        ),
                                      )),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        height: 60.h,
                                        width: 60.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(70)),
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: AssetImage(
                                                  'lib/assets/home_pic/point_survey.png')),
                                        ),
                                      ),
                                      Center(
                                          child: Container(
                                        width: 220.w,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('1 Point/time',
                                                style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text('Answer the Health Survey',
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight:
                                                        FontWeight.w300)),
                                          ],
                                        ),
                                      )),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        height: 60.h,
                                        width: 60.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(70)),
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: AssetImage(
                                                  'lib/assets/home_pic/point_item.png')),
                                        ),
                                      ),
                                      Container(
                                        width: 220.w,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('1 Point/5,000IQD',
                                                style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text('Purchase Wellbee items',
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight:
                                                        FontWeight.w300)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        height: 60.h,
                                        width: 60.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(70)),
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: AssetImage(
                                                  'lib/assets/home_pic/point_invite.png')),
                                        ),
                                      ),
                                      Container(
                                        width: 220.w,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('1 Point/person',
                                                style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text('Invite friends to Wellbee',
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight:
                                                        FontWeight.w300)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ));
  }
}

class _DetailRow extends StatelessWidget {
  // final String title;
  final String value;

  _DetailRow({required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.baseline,
        children: [
          // Text(
          //   title,
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.w300,
          //   ),
          // ),
          Text(
            value,
            style: TextStyle(
                fontSize: 60.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          SizedBox(
            width: 20.w,
          ),
          Text(
            'pt',
            style: TextStyle(
                fontSize: 50.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ],
      ),
    );
  }
}
