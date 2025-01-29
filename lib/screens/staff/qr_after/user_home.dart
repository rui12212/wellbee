import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/home.dart';
import 'package:wellbee/screens/staff/auth/staff_top_page.dart';
import 'package:wellbee/screens/staff/qr_after_attendee/attendee_all.dart';
import 'package:wellbee/screens/staff/calendar/calendar.dart';
import 'package:wellbee/screens/staff/qr_after_graph/staff_attendee.dart';
import 'package:wellbee/screens/staff/qr_after_membership/staff_membership.dart';
import 'package:wellbee/screens/staff/qr_after_point/point_select.dart';
import 'package:wellbee/ui_function/provider.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/dialogue_awesome.dart';

class _Header extends StatelessWidget {
  String title;
  String subtitle;

  _Header({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 90.h,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Column(
              children: [
                Text(
                  title,
                  style:
                      TextStyle(fontSize: 22.sp, fontWeight: FontWeight.normal),
                ),
                Text(
                  subtitle,
                  style:
                      TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiddleHeader extends StatelessWidget {
  String title;

  _MiddleHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 90.h,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Column(
              children: [
                Text(
                  title,
                  style:
                      TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserHomePage extends ConsumerStatefulWidget {
  final String pk;
  UserHomePage({
    Key? key,
    required this.pk,
  }) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends ConsumerState<UserHomePage> {
  bool isFetchedDataNull = true;

  Future<Map<String, dynamic>?> _fetchUser() async {
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

  Future<Map<String, dynamic>?> _fetchFirstAttendee() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse('${baseUri}attendances/attendee/first_attendee/')
          .replace(queryParameters: {
        'token': token,
        'user_id': widget.pk,
      });
      ;
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

  Future<Map<String, dynamic>?> _fetchClosestMembership() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url =
          Uri.parse('${baseUri}attendances/membership/closest_membership/')
              .replace(queryParameters: {
        'token': token,
        'user_id': widget.pk,
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
        Map<String, dynamic> data = jsonDecode(response.body);
        return data;
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

  // Future<Map<String, dynamic>?> _fetchCheckIn() async {
  //   try {
  //     token = await SharedPrefs.fetchStaffAccessToken();
  //     var url = Uri.parse('${baseUri}attendances/checkin/staff_checkin')
  //         .replace(queryParameters: {
  //       'token': token,
  //       'user_id': widget.pk,
  //     });
  //     ;
  //     var response = await Future.any([
  //       http.get(url, headers: {
  //         "Authorization": 'JWT $token',
  //         "Content-Type": "application/json"
  //       }),
  //       Future.delayed(const Duration(seconds: 15),
  //           () => throw TimeoutException("Request timeout"))
  //     ]);
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> data = jsonDecode(response.body);
  //       if (data.isNotEmpty) {
  //         return data;
  //       }
  //     } else if (response.statusCode >= 400) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Internet Error occurred.')));
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //           content: Text('Something went wrong. Try again later')));
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('Error: $e')));
  //   }
  // }

  Future fetchUserSummary() async {
    final closestMembership = await _fetchClosestMembership();
    final firstAttendee = await _fetchFirstAttendee();
    if (closestMembership!.values.contains(null)) {
      Map<String, dynamic> userSummary = {
        'name': firstAttendee!['name'],
        'duration': 'No Membership',
        'expire_day': 'No Membership',
        'course': 'No Membership',
        'already_join_times': 'No',
        'max_join_times': 'No',
        'last_check_in': 'No',
      };
      isFetchedDataNull = true;
      return userSummary;
    } else {
      Map<String, dynamic> userSummary = {
        'name': firstAttendee!['name'],
        'duration': '${closestMembership!['duration'].toString()} month member',
        'expire_day': closestMembership['expire_day'],
        'already_join_times':
            closestMembership['already_join_times'].toString(),
        'max_join_times': closestMembership['max_join_times'].toString(),
        'course': closestMembership['course_name'],
        'last_check_in': '${closestMembership['last_check_in']}',
      };
      isFetchedDataNull = false;
      return userSummary;
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isExpireDayWithIn2Week = false;
    bool isExpireDayWithIn1Week = false;
    bool isLastCheckInOver1Week = false;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: FutureBuilder(
                future: fetchUserSummary(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final fetchedUserSummary = snapshot.data;
                    final DateTime today = DateTime.now();
                    try {
                      if (isFetchedDataNull == false) {
                        final DateTime expireDay =
                            DateTime.parse(fetchedUserSummary['expire_day']);
                        final DateTime lastCheckIn =
                            DateTime.parse(fetchedUserSummary['last_check_in']);
                        final Duration differenceSinceCheckIn =
                            today.difference(lastCheckIn);
                        bool isLastCheckInOver7Days =
                            differenceSinceCheckIn.inDays >= 7;
                        final Duration differenceUntilExpireDay =
                            expireDay.difference(today);
                        bool isExpireDayWithin14Days =
                            differenceUntilExpireDay.inDays <= 14;
                        bool isExpireDayWithin7Days =
                            differenceUntilExpireDay.inDays <= 7;

                        if (isExpireDayWithin14Days == true &&
                            isExpireDayWithin7Days == false) {
                          //   Future(() {
                          // setState(() {
                          isExpireDayWithIn2Week = true;
                          //   });
                          // });
                        } else if (isExpireDayWithin7Days == true &&
                            isExpireDayWithin14Days == true) {
                          //   Future(() {
                          // setState(() {
                          isExpireDayWithIn2Week = false;
                          isExpireDayWithIn1Week = true;
                          //   });
                          // });
                        } else if (isLastCheckInOver7Days == true) {
                          // Future(() {
                          //   setState(() {
                          isLastCheckInOver1Week = true;
                          //   });
                          // });
                        }
                      } else if (isFetchedDataNull == true) {
                        // Future(() {
                        //   setState(() {
                        isExpireDayWithIn2Week = false;
                        isExpireDayWithIn1Week = false;
                        //   });
                        // });
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                    return Column(
                      children: [
                        _Header(
                            title: 'Name',
                            subtitle: fetchedUserSummary['name']),
                        SizedBox(
                          height: 10.h,
                        ),
                        Column(
                          children: [
                            Container(
                              height: 220.h,
                              width: 400.w,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: isExpireDayWithIn2Week
                                        ? Color.fromARGB(255, 238, 194, 35)
                                        : isExpireDayWithIn1Week
                                            ? const Color.fromARGB(
                                                255, 183, 16, 4)
                                            : kColorPrimary,
                                    width: 5.h),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.white.withOpacity(1), // 影の色（半透明）
                                    spreadRadius: 0, // 影の広がり
                                    blurRadius: 0, // ぼかし具合
                                    offset: Offset(2, 4), // 影の位置（X方向、Y方向）
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.h),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    height: 40.h,
                                    width: double.infinity,
                                    color: isExpireDayWithIn2Week
                                        ? Color.fromARGB(255, 238, 194, 35)
                                        : isExpireDayWithIn1Week
                                            ? const Color.fromARGB(
                                                255, 183, 16, 4)
                                            : kColorPrimary,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Exp: ',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.h,
                                                fontWeight: FontWeight.bold)),
                                        Text(fetchedUserSummary['expire_day'],
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20.h,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    child: _buildMembership(
                                        name: fetchedUserSummary['name'],
                                        course: fetchedUserSummary['course'],
                                        duration:
                                            '${fetchedUserSummary['duration']}',
                                        alreadyJoinedTimes: fetchedUserSummary[
                                            'already_join_times'],
                                        maxJoinTimes: fetchedUserSummary[
                                            'max_join_times'],
                                        lastCheckIn:
                                            fetchedUserSummary['last_check_in'],
                                        imagePath: fetchedUserSummary['course'] == 'Yoga' ||
                                                fetchedUserSummary['course'] ==
                                                    'Kids Yoga(A)' ||
                                                fetchedUserSummary['course'] ==
                                                    'Kids Yoga(B)' ||
                                                fetchedUserSummary['course'] ==
                                                    'Kids Yoga KG'
                                            ? Image.asset(
                                                'lib/assets/invi_course_pic/invi_yoga.png')
                                            : fetchedUserSummary['course'] == 'Dance' ||
                                                    fetchedUserSummary['course'] ==
                                                        'Kids Zumba' ||
                                                    fetchedUserSummary['course'] ==
                                                        'Zumba'
                                                ? Image.asset(
                                                    'lib/assets/invi_course_pic/invi_dance.png')
                                                : fetchedUserSummary['course'] == 'Karate' ||
                                                        fetchedUserSummary['course'] ==
                                                            'Kids Karate'
                                                    ? Image.asset(
                                                        'lib/assets/invi_course_pic/invi_karate.png')
                                                    : fetchedUserSummary['course'] == 'Music' ||
                                                            fetchedUserSummary['course'] ==
                                                                'Kids Music'
                                                        ? Image.asset(
                                                            'lib/assets/invi_course_pic/invi_music.png')
                                                        : fetchedUserSummary['course'] ==
                                                                    'Kids Gym(A)' ||
                                                                fetchedUserSummary['course'] ==
                                                                    'Kids Gym(B)'
                                                            ? Image.asset('lib/assets/invi_course_pic/male_fitness.png')
                                                            : fetchedUserSummary['course'] == 'Pilates'
                                                                ? Image.asset('lib/assets/invi_course_pic/invi_pilates.png')
                                                                : fetchedUserSummary['course'] == 'Family Pilates'
                                                                    ? Image.asset('lib/assets/invi_course_pic/invi_family_pilates.png')
                                                                    : fetchedUserSummary['course'] == 'Family Yoga'
                                                                        ? Image.asset('lib/assets/invi_course_pic/invi_family_yoga.png')
                                                                        : fetchedUserSummary['course'] == 'Private Yoga@Studio' || fetchedUserSummary['course'] == 'Private Yoga@Home'
                                                                            ? Image.asset('lib/assets/invi_course_pic/private_yoga.png')
                                                                            : fetchedUserSummary['course'] == 'Private Pilates@Studio' || fetchedUserSummary['course'] == 'Private Pilates@Home'
                                                                                ? Image.asset('lib/assets/invi_course_pic/private_pilates.png')
                                                                                : Image.asset('lib/assets/invi_course_pic/female_fitness.png')),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        _MiddleHeader(title: 'Home Menu'),
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          height: 260.h,
                          child: GridView.count(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          StaffAttendeeAllPage(
                                              userId: widget.pk)));
                                },
                                child: _buildGridItem(
                                  icon: Icons.person_2_outlined,
                                  title: "Member",
                                  fontSize: 16.h,
                                  colorStart: Color.fromRGBO(247, 160, 180, 1),
                                  colorEnd: Color.fromRGBO(194, 66, 83, 1),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          StaffMembershipPage(pk: widget.pk)));
                                },
                                child: _buildGridItem(
                                  icon: Icons.airplane_ticket_outlined,
                                  title: "Membership",
                                  fontSize: 13.w,
                                  colorStart:
                                      Color.fromARGB(255, 238, 233, 173),
                                  colorEnd: Color.fromARGB(255, 205, 196, 32),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => GraphAttendeePage(
                                          userId: widget.pk)));
                                },
                                child: _buildGridItem(
                                  icon: Icons.auto_graph_outlined,
                                  title: "Graph",
                                  fontSize: 16.h,
                                  colorStart:
                                      Color.fromARGB(255, 173, 238, 223),
                                  colorEnd: Color.fromARGB(255, 3, 150, 116),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          PointSelectPage(pk: widget.pk)));
                                },
                                child: _buildGridItem(
                                  icon: Icons.point_of_sale_outlined,
                                  title: "Point",
                                  fontSize: 16.h,
                                  colorStart:
                                      Color.fromARGB(255, 168, 199, 224),
                                  colorEnd: Color.fromARGB(255, 7, 124, 227),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  showAwesomeDialog();
                                },
                                child: _buildGridItem(
                                  icon: Icons.exit_to_app_outlined,
                                  title: "Go Back",
                                  fontSize: 16.h,
                                  colorStart:
                                      const Color.fromARGB(255, 224, 219, 219),
                                  colorEnd: Color.fromARGB(255, 119, 111, 111),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                }),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required String title,
    required double? fontSize,
    required Color colorStart,
    required Color colorEnd,
    // required String subtitle,
    // Future<dynamic>? callback,
    // void callbackDialog,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: FractionalOffset.bottomRight,
            end: FractionalOffset.topLeft,
            colors: [
              colorEnd,
              colorStart,
            ],
            stops: const [
              0.7,
              1.0
            ]),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8), // 影の色（半透明）
            spreadRadius: 1, // 影の広がり
            blurRadius: 10, // ぼかし具合
            offset: Offset(2, 4), // 影の位置（X方向、Y方向）
          ),
        ],
        // color: kColorPrimary,
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.all(6.0).h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30.0.h, color: const Color.fromARGB(255, 3, 72, 5)),
          SizedBox(height: 12.0.h),
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 20,
                ),
              ],
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.0.h),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildMembership(
      {required String name,
      required String course,
      required String duration,
      required String lastCheckIn,
      required Image imagePath,
      required String alreadyJoinedTimes,
      required String maxJoinTimes}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            alignment: Alignment.center,
            width: 100.w,
            height: 120.h,
            child: imagePath,
            decoration: BoxDecoration(
                // border: Border.all(color: kColorPrimary, width: 2.h),
                borderRadius: BorderRadius.circular(12))),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                course,
                style: TextStyle(
                  fontSize: 20.sp,
                  color: kColorTextDarkGrey,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                duration,
                style: TextStyle(
                  fontSize: 20.sp,
                  color: kColorTextDarkGrey,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${alreadyJoinedTimes.toString()} / ${maxJoinTimes.toString()} max times',
                style: TextStyle(
                  fontSize: 20.sp,
                  color: kColorTextDarkGrey,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'check in: $lastCheckIn',
                style: TextStyle(
                  fontSize: 20.sp,
                  color: kColorTextDarkGrey,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
