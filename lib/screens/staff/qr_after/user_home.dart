import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/auth/staff_top_page.dart';
import 'package:wellbee/screens/staff/qr_after_attendee/attendee_all.dart';
import 'package:wellbee/screens/staff/qr_after_graph/staff_attendee.dart';
import 'package:wellbee/screens/staff/qr_after_membership/staff_membership.dart';
import 'package:wellbee/screens/staff/qr_after_point/point_select.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/dialogue_awesome.dart';

class UserHomePage extends ConsumerStatefulWidget {
  final String pk;
  const UserHomePage({Key? key, required this.pk}) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends ConsumerState<UserHomePage> {
  bool isFetchedDataNull = true;
  String? token;

  Future<Map<String, dynamic>?> _fetchFirstAttendee() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url =
          Uri.parse('${baseUri}attendances/attendee/first_attendee/').replace(
        queryParameters: {'token': token, 'user_id': widget.pk},
      );
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
        if (data.isNotEmpty) return data;
      } else if (response.statusCode >= 400) {
        _showSnack('Internet Error occurred.');
      } else {
        _showSnack('Something went wrong. Try again later');
      }
    } catch (e) {
      _showSnack('Error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchClosestMembership() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url =
          Uri.parse('${baseUri}attendances/membership/closest_membership/')
              .replace(queryParameters: {'token': token, 'user_id': widget.pk});
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
        _showSnack('Internet Error occurred.');
      } else {
        _showSnack('Something went wrong. Try again later');
      }
    } catch (e) {
      _showSnack('Error: $e');
    }
    return null;
  }

  Future fetchUserSummary() async {
    final closestMembership = await _fetchClosestMembership();
    final firstAttendee = await _fetchFirstAttendee();
    if (closestMembership == null || closestMembership.isEmpty || closestMembership['course_name'] == null) {
      isFetchedDataNull = true;
      return {
        'name': firstAttendee!['name'],
        'duration': 'No Membership',
        'expire_day': 'No Membership',
        'course': 'No Membership',
        'already_join_times': 'No',
        'max_join_times': 'No',
        'last_check_in': 'No',
      };
    } else {
      isFetchedDataNull = false;
      return {
        'name': firstAttendee!['name'],
        'duration': '${closestMembership['duration']} month member',
        'expire_day': closestMembership['expire_day'],
        'already_join_times': closestMembership['already_join_times'].toString(),
        'max_join_times': closestMembership['max_join_times'].toString(),
        'course': closestMembership['course_name'],
        'last_check_in': '${closestMembership['last_check_in']}',
      };
    }
  }

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  void showAwesomeDialog() {
    CustomAwesomeDialogueForCancelReservation(
      titleText: 'Go back to Staff Home',
      desc: 'Are you sure to go back?',
      callback: () async {
        await Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => StaffTopPage(0)));
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: FutureBuilder(
            future: fetchUserSummary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 400.h,
                  child: const Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final d = snapshot.data;
                final DateTime today = DateTime.now();
                Color statusColor = kColorPrimary;

                try {
                  if (!isFetchedDataNull) {
                    final DateTime expireDay = DateTime.parse(d['expire_day']);
                    final Duration untilExpire = expireDay.difference(today);

                    if (untilExpire.inDays <= 7) {
                      statusColor = const Color(0xFFB7100A);
                    } else if (untilExpire.inDays <= 14) {
                      statusColor = const Color(0xFFEEC223);
                    }
                  }
                } catch (_) {}

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────────────────────
                    Row(
                      children: [
                       
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Customer Profile',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade500)),
                              Text(
                                d['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // ── Membership Card ──────────────────────────────────
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Status bar
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.r),
                                topRight: Radius.circular(20.r),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isFetchedDataNull
                                      ? 'No Active Membership'
                                      : 'Active Membership',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12.sp),
                                ),
                                Text(
                                  'Exp: ${d['expire_day']}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          // Body
                          Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: SizedBox(
                                    width: 80.w,
                                    height: 80.w,
                                    child: _courseImage(d['course']),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          d['course'],
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey.shade800),
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(d['duration'],
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey.shade500)),
                                      SizedBox(height: 8.h),
                                      _infoRow(
                                        Icons.fitness_center_rounded,
                                        '${d['already_join_times']} / ${d['max_join_times']} sessions',
                                        statusColor,
                                      ),
                                      SizedBox(height: 4.h),
                                      _infoRow(
                                        Icons.access_time_rounded,
                                        'Last: ${d['last_check_in']}',
                                        Colors.grey.shade400,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // ── Menu ─────────────────────────────────────────────
                    Text('Menu',
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.w700)),
                    SizedBox(height: 12.h),
                    GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _gridItem(
                          icon: Icons.person_2_outlined,
                          title: 'Member',
                          color: const Color(0xFFE8344E),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => StaffAttendeeAllPage(
                                      userId: widget.pk))),
                        ),
                        _gridItem(
                          icon: Icons.airplane_ticket_outlined,
                          title: 'Membership',
                          color: const Color(0xFFD4A017),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      StaffMembershipPage(pk: widget.pk))),
                        ),
                        _gridItem(
                          icon: Icons.auto_graph_outlined,
                          title: 'Graph',
                          color: const Color(0xFF039674),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      GraphAttendeePage(userId: widget.pk))),
                        ),
                        _gridItem(
                          icon: Icons.point_of_sale_outlined,
                          title: 'Point',
                          color: const Color(0xFF077CE3),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      PointSelectPage(pk: widget.pk))),
                        ),
                        _gridItem(
                          icon: Icons.exit_to_app_outlined,
                          title: 'Go Back',
                          color: Colors.grey.shade500,
                          onTap: showAwesomeDialog,
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 13.sp, color: color),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
        ),
      ],
    );
  }

  Widget _gridItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Image _courseImage(String course) {
    const base = 'lib/assets/invi_course_pic/';
    if (course == 'Yoga' ||
        course == 'Kids Yoga(A)' ||
        course == 'Kids Yoga(B)' ||
        course == 'Kids Yoga KG') {
      return Image.asset('${base}invi_yoga.png', fit: BoxFit.cover);
    } else if (course == 'Dance' ||
        course == 'Kids Zumba' ||
        course == 'Zumba') {
      return Image.asset('${base}invi_dance.png', fit: BoxFit.cover);
    } else if (course == 'Karate' || course == 'Kids Karate') {
      return Image.asset('${base}invi_karate.png', fit: BoxFit.cover);
    } else if (course == 'Music' || course == 'Kids Music') {
      return Image.asset('${base}invi_music.png', fit: BoxFit.cover);
    } else if (course == 'Kids Gym(A)' || course == 'Kids Gym(B)') {
      return Image.asset('${base}male_fitness.png', fit: BoxFit.cover);
    } else if (course == 'Pilates') {
      return Image.asset('${base}invi_pilates.png', fit: BoxFit.cover);
    } else if (course == 'Family Pilates') {
      return Image.asset('${base}invi_family_pilates.png', fit: BoxFit.cover);
    } else if (course == 'Family Yoga') {
      return Image.asset('${base}invi_family_yoga.png', fit: BoxFit.cover);
    } else if (course == 'Private Yoga@Studio' ||
        course == 'Private Yoga@Home') {
      return Image.asset('${base}private_yoga.png', fit: BoxFit.cover);
    } else if (course == 'Private Pilates@Studio' ||
        course == 'Private Pilates@Home') {
      return Image.asset('${base}private_pilates.png', fit: BoxFit.cover);
    } else {
      return Image.asset('${base}female_fitness.png', fit: BoxFit.cover);
    }
  }
}
