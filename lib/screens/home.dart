import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wellbee/screens/questionnaire/questionnaire_attendee.dart';
import 'package:wellbee/main.dart';
import 'package:wellbee/services/version_check_service.dart';
import 'package:wellbee/screens/attendee/attendee.dart';
import 'package:wellbee/screens/graph/graph_attendee.dart';
import 'package:wellbee/screens/point/point.dart';
import 'package:wellbee/screens/reservation/membership.dart';
import 'package:wellbee/screens/qr/qr_reservation.dart';
import 'package:wellbee/screens/video/video_course_select.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/convert.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/dialogue_awesome.dart';
import 'package:wellbee/services/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  int _unreadCount = 0;

  Future<void> _fetchUnreadCount() async {
    try {
      final token = await SharedPrefs.fetchAccessToken();
      if (token == null) return;
      var url = Uri.parse(
          '${baseUri}attendances/mailbox/unread-count/?token=$token');
      var response = await http.get(url, headers: {
        "Authorization": 'JWT $token',
        "Content-Type": "application/json"
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _unreadCount = data['unread_count'] ?? 0;
          });
        }
      }
    } catch (e) {
      // silently fail
    }
  }

  void _initFCM() {
    final fcmService = FCMService();
    fcmService.initialize();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _fetchUnreadCount();
    });
  }

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

  Future<dynamic> onLaunchAndroidUrl() async {
    final Uri url = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.wellbee.app&pcampaignid=web_share');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<dynamic> onLaunchIOSUrl() async {
    final Uri url =
        Uri.parse('https://apps.apple.com/app/wellbee-app/id6737229335');
    await launchUrl(url, mode: LaunchMode.externalApplication);
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

  Future<void> _checkVersion() async {
    final status = await VersionCheckService.check();
    if (!mounted) return;
    final launchUrl = Platform.isIOS ? onLaunchIOSUrl : onLaunchAndroidUrl;
    if (status == VersionStatus.forceUpdate) {
      VersionUpCustomAwesomeDialogue(
        titleText: 'Update Required',
        desc: 'Please update the app to continue.',
        callback: launchUrl,
      ).show(context);
    } else if (status == VersionStatus.updateAvailable) {
      SoftUpdateCustomAwesomeDialogue(
        titleText: 'New Version Available',
        desc: 'A new version of the app is available.',
        onUpdate: launchUrl,
      ).show(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _initFCM();
    _fetchUnreadCount();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkVersion();
      _fetchAttendee();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: ColorfulSafeArea(
          color: kColorPrimary,
          child: Column(
            children: [
              Container(
                width: 390.w,
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
                        top: 16.h,
                        bottom: 18.h,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // GestureDetector(
                              //   onTap: () async {
                              //     await Navigator.of(context).push(
                              //       MaterialPageRoute(
                              //           builder: (context) =>
                              //               const MailboxListPage()),
                              //     );
                              //     _fetchUnreadCount();
                              //   },
                              //   child: Stack(
                              //     clipBehavior: Clip.none,
                              //     children: [
                              //       Icon(Icons.mail_outline,
                              //           color: Colors.white, size: 28.sp),
                              //       if (_unreadCount > 0)
                              //         Positioned(
                              //           right: -6,
                              //           top: -6,
                              //           child: Container(
                              //             padding: EdgeInsets.all(4.w),
                              //             decoration: const BoxDecoration(
                              //               color: Colors.red,
                              //               shape: BoxShape.circle,
                              //             ),
                              //             constraints: BoxConstraints(
                              //               minWidth: 18.w,
                              //               minHeight: 18.w,
                              //             ),
                              //             child: Text(
                              //               '$_unreadCount',
                              //               style: TextStyle(
                              //                 color: Colors.white,
                              //                 fontSize: 11.sp,
                              //                 fontWeight: FontWeight.bold,
                              //               ),
                              //               textAlign: TextAlign.center,
                              //             ),
                              //           ),
                              //         ),
                              //     ],
                              //   ),
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
                                  child: Card(
                                    color: Colors.white.withOpacity(0.12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    elevation: 0,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                        vertical: 14.h,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            color: Colors.white70,
                                            size: 28.sp,
                                          ),
                                          SizedBox(width: 14.w),
                                          Expanded(
                                            child: Text(
                                              'No Reservation',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 36.h,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12.r),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 14.w),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        MembershipPage(),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                'Reserve',
                                                style: TextStyle(
                                                  color: kColorPrimary,
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
                                      child: reservation[
                                                      'slot_course_image_url'] !=
                                                  null &&
                                              reservation[
                                                      'slot_course_image_url']
                                                  .toString()
                                                  .isNotEmpty
                                          ? Image.network(
                                              reservation[
                                                  'slot_course_image_url'],
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                  'lib/assets/invi_course_pic/female_fitness.png',
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
                                            )
                                          : Image.asset(
                                              'lib/assets/invi_course_pic/female_fitness.png',
                                              fit: BoxFit.cover,
                                            ),
                                    )
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 28.h),
                          Text(
                            'Services',
                            style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12.h),
                          GridView.count(
                                      crossAxisCount: 2,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      mainAxisSpacing: 10.h,
                                      crossAxisSpacing: 10.w,
                                      childAspectRatio: 1.5,
                                      children: [
                                        _ServiceTile(
                                          icon: CupertinoIcons.person,
                                          color: kColorPrimary,
                                          bgColor: const Color(0xFFE8F5F0),
                                          label: 'Member',
                                          sub: 'بەشداربوو',
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        AttendeePage()));
                                          },
                                        ),
                                        _ServiceTile(
                                          icon: CupertinoIcons.doc_text,
                                          color: const Color(0xFF3B5FCC),
                                          bgColor: const Color(0xFFEBF0FE),
                                          label: 'Health Survey',
                                          sub: 'ساخلەمی',
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        SurveyAttendeePage()));
                                          },
                                        ),
                                        _ServiceTile(
                                          icon: CupertinoIcons.chart_bar,
                                          color: const Color(0xFFC27D1A),
                                          bgColor: const Color(0xFFFEF5E7),
                                          label: 'Graph',
                                          sub: 'شێوە',
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        GraphAttendeePage()));
                                          },
                                        ),
                                        _ServiceTile(
                                          icon: CupertinoIcons.creditcard,
                                          color: kColorPrimary,
                                          bgColor: const Color(0xFFE8F5F0),
                                          label: 'Membership',
                                          sub: 'ئەندام',
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        MembershipPage()));
                                          },
                                        ),
                                        _ServiceTile(
                                          icon: CupertinoIcons.qrcode,
                                          color: const Color(0xFF3B5FCC),
                                          bgColor: const Color(0xFFEBF0FE),
                                          label: 'Reservation',
                                          sub: 'حجزکرنا من',
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        QrReservationPage()));
                                          },
                                        ),
                                        _ServiceTile(
                                          icon: CupertinoIcons.star,
                                          color: const Color(0xFFC27D1A),
                                          bgColor: const Color(0xFFFEF5E7),
                                          label: 'Wellbee Point',
                                          sub: 'خالێن وێلبی',
                                          onTap: () async {
                                            final fetchedUserData =
                                                await _fetchAttendee();
                                            final userId =
                                                fetchedUserData?[0]['user_id'];
                                            final points =
                                                fetchedUserData?[0]['points'];
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (_) => PointPage(
                                                        userId: userId,
                                                        points: points)));
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),
                                    _VideoTile(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const VideoCourseSelectPage()));
                                      },
                                    ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
  }
}

class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final VoidCallback onTap;

  const _VideoTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: kColorPrimary,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(CupertinoIcons.play_fill, color: Colors.white, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Videos',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Watch course videos at home',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
