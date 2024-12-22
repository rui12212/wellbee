import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/dialogue_awesome.dart';

class _Header extends StatelessWidget {
  String title;

  _Header({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

  Future<Map<String, dynamic>?> _fetchCheckIn() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse('${baseUri}attendances/checkin/staff_checkin')
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

  Future fetchUserSummary() async {
    final closestMembership = await _fetchClosestMembership();
    final firstAttendee = await _fetchFirstAttendee();
    final checkin = await _fetchCheckIn();

    if (closestMembership!.isNotEmpty && checkin!.isNotEmpty) {
      final DateTime dateTime = DateTime.parse(checkin['created_at']);
      final formattedLastCheckInDay = DateFormat('yyyy-MM-dd').format(dateTime);
      Map<String, dynamic> userSummary = {
        'name': firstAttendee!['name'],
        'duration': closestMembership['duration'].toString(),
        'expire_day': closestMembership['expire_day'],
        'course': closestMembership['course_name'],
        'last_check_in': formattedLastCheckInDay,
      };
      return userSummary;
    } else if (closestMembership.isEmpty) {
      Map<String, dynamic> userSummary = {
        'name': firstAttendee!['name'],
        'duration': 'No Membership',
        'expire_day': 'No Membership',
        'course': 'No Membership',
        'last_check_in': 'No Check In',
      };
      return userSummary;
    } else if (checkin!.isEmpty) {
      Map<String, dynamic> userSummary = {
        'name': firstAttendee!['name'],
        'duration': closestMembership['duration'],
        'expire_day': closestMembership['expire_day'],
        'course': closestMembership['course_name'],
        'last_check_in': 'No Check In',
      };
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
  Widget build(BuildContext context) {
    return Scaffold(
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
                  final DateTime expireDay =
                      DateTime.parse(fetchedUserSummary['expire_day']);
                  final DateTime lastCheckIn =
                      DateTime.parse(fetchedUserSummary['last_check_in']);
                  final Duration differenceSinceCheckIn =
                      today.difference(lastCheckIn);
                  bool isLastCheckInOver7Days =
                      differenceSinceCheckIn.inDays >= 7;
                  final Duration differenceUntilExpireDay =
                      today.difference(expireDay);
                  bool isExpireDayWithin14Days =
                      differenceUntilExpireDay.inDays <= 14;
                  return Column(
                    children: [
                      _Header(title: 'Name: ${fetchedUserSummary['name']}'),
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(15),
                            child: _buildMembership(
                              name: fetchedUserSummary['name'],
                              course: fetchedUserSummary['course'],
                              duration:
                                  '${fetchedUserSummary['duration']} month',
                              expireDay: fetchedUserSummary['expire_day'],
                              lastCheckIn: fetchedUserSummary['last_check_in'],
                            ),
                            height: 200.h,
                            width: 400.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: FractionalOffset.bottomRight,
                                  end: FractionalOffset.topLeft,
                                  colors: [
                                    kColorPrimary,
                                    Color.fromARGB(255, 188, 250, 216),
                                  ],
                                  stops: const [
                                    0.7,
                                    1.0
                                  ]),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withOpacity(0.8), // 影の色（半透明）
                                  spreadRadius: 1, // 影の広がり
                                  blurRadius: 10, // ぼかし具合
                                  offset: Offset(2, 4), // 影の位置（X方向、Y方向）
                                ),
                              ],
                              color: kColorPrimary,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 530.h,
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => StaffAttendeeAllPage(
                                        userId: widget.pk)));
                              },
                              child: _buildGridItem(
                                icon: Icons.person_2_outlined,
                                title: "Member",
                                subtitle: "Wellbee Member",
                                // footer: "3 Events",
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
                                subtitle: "New&Old Ticket",
                                // footer: "4 Items",
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        GraphAttendeePage(userId: widget.pk)));
                              },
                              child: _buildGridItem(
                                icon: Icons.auto_graph_outlined,
                                title: "Graph",
                                subtitle: "Health Charts",
                                // footer: "",
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
                                title: "Wellbee Point",
                                subtitle: "Up/Down Points",
                                // footer: "",
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                showAwesomeDialog();
                              },
                              child: _buildGridItem(
                                icon: Icons.exit_to_app_outlined,
                                title: "Go Back",
                                subtitle: "Back to Staff Home",
                                // footer: "",
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
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required String title,
    required String subtitle,
    // Future<dynamic>? callback,
    // void callbackDialog,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: FractionalOffset.bottomRight,
            end: FractionalOffset.topLeft,
            colors: [
              kColorPrimary,
              Color.fromARGB(255, 188, 250, 216),
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
        color: kColorPrimary,
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40.0.h, color: const Color.fromARGB(255, 3, 72, 5)),
          SizedBox(height: 16.0.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.0.h,
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
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.0.h,
              color: Colors.white70,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildMembership({
    required String name,
    required String course,
    required String duration,
    required String expireDay,
    required String lastCheckIn,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Name',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 20,
                    ),
                  ],
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 20,
                    ),
                  ],
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Course',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 20,
                    ),
                  ],
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                course,
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 20,
                    ),
                  ],
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Duration',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 20,
                    ),
                  ],
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                duration,
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 20,
                    ),
                  ],
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expire Day',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 20,
                    ),
                  ],
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                expireDay,
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 20,
                    ),
                  ],
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last Check In',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 20,
                    ),
                  ],
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                lastCheckIn,
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 20,
                    ),
                  ],
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
