import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wellbee/version/version_info.dart';
import 'package:wellbee/main.dart';
import 'package:wellbee/screens/attendee/attendee.dart';
import 'package:wellbee/screens/graph/graph.dart';
import 'package:wellbee/screens/graph/graph_attendee.dart';
import 'package:wellbee/screens/point/point.dart';
import 'package:wellbee/screens/reservation/membership.dart';
import 'package:wellbee/screens/qr/qr_reservation.dart';
import 'package:wellbee/screens/questionnaire/questinnaire_attendee.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/convert.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/dialogue_awesome.dart';
import 'package:wellbee/ui_parts/display.dart';
import '../assets/inet.dart';
import 'package:http/http.dart' as http;

class CourseTime extends StatelessWidget {
  final String courseName;
  final String startTime;
  final String endTime;
  final String dateOfWeek;
  final String courseDate;

  const CourseTime({
    Key? key,
    required this.courseName,
    required this.startTime,
    required this.endTime,
    required this.dateOfWeek,
    required this.courseDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.amber,
      width: 180.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15.h),
          Text(courseName.toString(),
              style: courseName.length > 12
                  ? TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)
                  : TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
          SizedBox(height: 10.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${startTime.toString()}-${endTime.toString()} ',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white)),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('$dateOfWeek , ${courseDate}',
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white)),
                  // Text(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

List<Map<String, dynamic>> myReservations = [];
String? token = '';

class _HomePageState extends State<HomePage> {
  bool isUpdateNeeded = false;
  bool isIos = false;

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  Future<Map<String, dynamic>?> _fetchReservation() async {
    try {
      token = await SharedPrefs.fetchAccessToken();
      // print(token);
      var url = Uri.parse(
          '${baseUri}reservations/reservation/my_reservations/?token=$token');
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
        if (data.isEmpty) {
          return null;
        } else if (data.isNotEmpty) {
          return data[0];
        }
      } else if (response.statusCode >= 400) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Internet Error occurred: $e.')));
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Something went wrong. Try again later')));
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      });
    }
  }

  Future<List<dynamic>?> _fetchAttendee() async {
    try {
      token = await SharedPrefs.fetchAccessToken();
      var url =
          Uri.parse('${baseUri}attendances/attendee/my_attendee/?token=$token');
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

  void judgeOSType() {
    if (Platform.isIOS) {
      setState(
        () {
          isIos = true;
        },
      );
    } else if (Platform.isAndroid) {
      setState(
        () {
          isIos = false;
        },
      );
    }
  }

  _fetchLatestVersion() async {
    try {
      // await DialogGenerator.showLoadingDialog(context: context);
      token = await SharedPrefs.fetchAccessToken();
      // print(token);
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Internet Error occurred.')));
      } else {
        var url =
            Uri.parse('${baseUri}versions/version/latest_version?token=$token');
        var response = await Future.any([
          http.get(url, headers: {"Authorization": 'JWT $token'}),
          Future.delayed(const Duration(seconds: 5),
              () => throw TimeoutException("Request timeout"))
        ]);
        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(response.body);
          return data;
        } else if (response.statusCode >= 400) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Internet Error occurred.')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Something went wrong. Try again later')));
        }
      }
    } catch (e) {
      // Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<bool?> checkVersionInformation() async {
    final Map<String, dynamic> latestVersionMap = await _fetchLatestVersion();
    final double latestVersion = latestVersionMap['version'];
    List<String> parts = currentVersion.split('.');
    final majorUpdate = parts[0];
    final middleUpdate = parts[1];
    final minorUpdate = parts[2];
    final String combined = "${majorUpdate}.${middleUpdate}${minorUpdate}";
    final double modifiedCurrentVersion = double.parse(combined);
    if (latestVersion > modifiedCurrentVersion) {
      isUpdateNeeded = true;
      return isUpdateNeeded;
    } else if (modifiedCurrentVersion >= latestVersion) {
      isUpdateNeeded = false;
      return isUpdateNeeded;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error occur')));
    }
  }

  Future<dynamic> onLaunchAndroidUrl() async {
    final Uri url = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.wellbee.app&pcampaignid=web_share');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // エラーハンドリング: URLを開けない場合の処理
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: Search the latest version on Google Play')));
    }
  }

  Future<dynamic> onLaunchIOSUrl() async {
    // print('haha');
    final Uri url =
        Uri.parse('https://apps.apple.com/app/wellbee-app/id6737229335');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // エラーハンドリング: URLを開けない場合の処理
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: Search the latest version on Apple Store')));
    }
  }

  void showAwesomeDialog() {
    CustomAwesomeDialogueForCancelReservation(
      titleText: 'Sign Out',
      desc: 'Are you sure to Sign out?\nYour auto login will be off!',
      callback: () async {
        await SharedPrefs.clearAuthInfo();
        await Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: ((context) {
          return SignInPage();
        })));
      },
    ).show(context);
  }

  @override
  void initState() {
    super.initState();
    judgeOSType();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool? updateNeeded = await checkVersionInformation();
      if (updateNeeded != null && updateNeeded == true) {
        VersionUpCustomAwesomeDialogue(
                titleText: 'New Version Released',
                desc: 'Please update the app to the newest version',
                callback: isIos == true ? onLaunchIOSUrl : onLaunchAndroidUrl)
            .show(context);
      } else if (updateNeeded != null && updateNeeded == false) {
        return;
      } else {
        showSnackBar(Colors.red, 'version check error');
      }
      _fetchAttendee();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: ColorfulSafeArea(
          color: kColorPrimary,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 390.w,
                  // height: 200.h,
                  child: Material(
                    color: kColorPrimary,
                    // elevation: 68,
                    shadowColor: kColorPrimary,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 24.w,
                        right: 24.w,
                        top: 8.h,
                        bottom: 18.h,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              (Text('Next Reservation is...',
                                  style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white))),
                              // ElevatedButton(
                              //   style: ElevatedButton.styleFrom(
                              //     backgroundColor: kColorPrimary,
                              //     minimumSize: Size(10, 30),
                              //   ),
                              //   onPressed: () {
                              //     showAwesomeDialog();
                              //   },
                              //   child: Text('Leave',
                              //       style: TextStyle(color: Colors.white60)),
                              // ),
                            ],
                          ),
                          FutureBuilder(
                            future: _fetchReservation(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty ||
                                  snapshot.data == null) {
                                return Container(
                                  width: 390.w,
                                  // height: 300.h,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 15.h,
                                      ),
                                      Text('No Reservation',
                                          style: TextStyle(
                                              fontSize: 28.h,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      Text('1.Add Member from "Member" Page',
                                          style: TextStyle(
                                              fontSize: 16.h,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white)),
                                      Text('2.Visit Wellbee and buy Membership',
                                          style: TextStyle(
                                              fontSize: 16.h,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white)),
                                      Text('3.Make a Reservation',
                                          style: TextStyle(
                                              fontSize: 16.h,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white))
                                    ],
                                  ),
                                );
                              } else {
                                final reservation = snapshot.data!;
                                final DateTime intDate =
                                    DateTime.parse(reservation['date']);
                                String formattedDateOfWeek =
                                    DateFormat.EEEE('en').format(intDate);
                                final courseName =
                                    reservation['slot_course_name'];
                                final startTime =
                                    reservation['slot_start_time'];
                                final endTime = reservation['slot_end_time'];
                                String formattedStartTime =
                                    IntConverter.formatTime(startTime);
                                String formattedEndTime =
                                    IntConverter.formatTime(endTime);
                                final dateOfWeek = formattedDateOfWeek;
                                final date = reservation['date'];
                                return Row(
                                  children: [
                                    Expanded(
                                      child: CourseTime(
                                        courseName: courseName,
                                        startTime: formattedStartTime,
                                        endTime: formattedEndTime,
                                        courseDate: date,
                                        dateOfWeek: dateOfWeek,
                                      ),
                                    ),
                                    Container(
                                        width: 130.w,
                                        height: 110.h,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: reservation['slot_course_name'] ==
                                                          'Yoga' ||
                                                      reservation['slot_course_name'] ==
                                                          'Kids Yoga(A)' ||
                                                      reservation['slot_course_name'] ==
                                                          'Kids Yoga(B)' ||
                                                      reservation['slot_course_name'] ==
                                                          'Kids Yoga KG'
                                                  ? AssetImage(
                                                      'lib/assets/invi_course_pic/invi_yoga.png')
                                                  : reservation[
                                                                  'slot_course_name'] ==
                                                              'Dance' ||
                                                          reservation['slot_course_name'] ==
                                                              'Kids ' ||
                                                          reservation['slot_course_name'] ==
                                                              'Zumba'
                                                      ? AssetImage(
                                                          'lib/assets/invi_course_pic/invi_dance.png')
                                                      : reservation['slot_course_name'] ==
                                                                  'Karate' ||
                                                              reservation['slot_course_name'] ==
                                                                  'Kids Karate'
                                                          ? AssetImage(
                                                              'lib/assets/invi_course_pic/invi_karate.png')
                                                          : reservation['slot_course_name'] ==
                                                                      'Music' ||
                                                                  reservation[
                                                                          'slot_course_name'] ==
                                                                      'Kids Music'
                                                              ? AssetImage(
                                                                  'lib/assets/invi_course_pic/invi_music.png')
                                                              : reservation['slot_course_name'] ==
                                                                          'Kids Gym(A)' ||
                                                                      reservation['slot_course_name'] ==
                                                                          'Kids Gym(B)'
                                                                  ? AssetImage(
                                                                      'lib/assets/invi_course_pic/male_fitness.png')
                                                                  : reservation['slot_course_name'] ==
                                                                          'Pilates'
                                                                      ? AssetImage(
                                                                          'lib/assets/invi_course_pic/invi_pilates.png')
                                                                      : reservation['slot_course_name'] ==
                                                                              'Family Pilates'
                                                                          ? AssetImage('lib/assets/invi_course_pic/invi_family_pilates.png')
                                                                          : reservation['slot_course_name'] == 'Family Yoga'
                                                                              ? AssetImage('lib/assets/invi_course_pic/invi_family_yoga.png')
                                                                              : reservation['slot_course_name'] == 'Private Yoga@Studio' || reservation['slot_course_name'] == 'Private Yoga@Home'
                                                                                  ? AssetImage('lib/assets/invi_course_pic/private_yoga.png')
                                                                                  : reservation['slot_course_name'] == 'Private Pilates@Studio' || reservation['slot_course_name'] == 'Private Pilates@Home'
                                                                                      ? AssetImage('lib/assets/invi_course_pic/private_pilates.png')
                                                                                      : AssetImage('lib/assets/invi_course_pic/female_fitness.png')),
                                        ))
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      SafeArea(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 28.h),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 20.0.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Wellbee Service',
                                      style: TextStyle(
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 15.h,
                                    ),
                                    Container(
                                      height: 200.h,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: <Widget>[
                                          HomeCard(
                                              image:
                                                  'lib/assets/attendee_pic/attendee.png',
                                              text: 'Member\nبەشداربوو',
                                              pass: AttendeePage()),
                                          HomeCard(
                                              image:
                                                  'lib/assets/home_pic/survey.png',
                                              text:
                                                  'Health Survey\nراپرسیا ساخلەمیێ',
                                              pass: SurveyAttendeePage()),
                                          HomeCard(
                                              image:
                                                  'lib/assets/home_pic/graph.png',
                                              text: 'Graph\nشێوە',
                                              pass: GraphAttendeePage()),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    InkWell(
                                        child: Container(
                                          height: 140.h,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: AssetImage(
                                                    'lib/assets/home_pic/ticket.png')),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              gradient: LinearGradient(
                                                  begin: Alignment.bottomRight,
                                                  stops: [
                                                    0.3,
                                                    0.9
                                                  ],
                                                  colors: [
                                                    Colors.black
                                                        .withOpacity(.8),
                                                    Colors.black.withOpacity(.2)
                                                  ]),
                                            ),
                                            child: Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                child: Text(
                                                  'Membership & Reservation\nئەندام و حجزکرن',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20.sp),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MembershipPage()));
                                        }),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    InkWell(
                                        child: Container(
                                          height: 140.h,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: AssetImage(
                                                    'lib/assets/home_pic/reservation.png')),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              gradient: LinearGradient(
                                                  begin: Alignment.bottomRight,
                                                  stops: [
                                                    0.3,
                                                    0.9
                                                  ],
                                                  colors: [
                                                    Colors.black
                                                        .withOpacity(.8),
                                                    Colors.black.withOpacity(.2)
                                                  ]),
                                            ),
                                            child: Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                child: Text(
                                                  'My Reservation\nحجزکرنا من',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20.sp),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      QrReservationPage()));
                                        }),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    InkWell(
                                        child: Container(
                                          height: 140.h,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: AssetImage(
                                                    'lib/assets/home_pic/point.png')),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              gradient: LinearGradient(
                                                  begin: Alignment.bottomRight,
                                                  stops: [
                                                    0.3,
                                                    0.9
                                                  ],
                                                  colors: [
                                                    Colors.black
                                                        .withOpacity(.8),
                                                    Colors.black.withOpacity(.2)
                                                  ]),
                                            ),
                                            child: Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                child: Text(
                                                  'Wellbee Point\nخالێن وێلبی',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20.sp),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () async {
                                          final fetchedUserData =
                                              await _fetchAttendee();
                                          final userId =
                                              fetchedUserData?[0]['user_id'];
                                          final points =
                                              fetchedUserData?[0]['points'];
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PointPage(
                                                          userId: userId,
                                                          points: points)));
                                        }),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
