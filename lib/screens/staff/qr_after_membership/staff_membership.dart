// import 'package:booking_calendar/booking_calendar.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/membership/membership_add.dart';
import 'package:wellbee/screens/membership/membership_attendee.dart';
// import 'package:wellbee/screens/reservation/reservation_create.dart';
import 'package:wellbee/screens/reservation/reservation_membership.dart';
import 'package:wellbee/screens/staff/qr_after_membership/staff_membership_add.dart';
import 'package:wellbee/screens/staff/qr_after_membership/staff_membership_attendee.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/convert.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:wellbee/ui_parts/ticket.dart';

class _Header extends StatelessWidget {
  String title;
  String subtitle;

  _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
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
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              subtitle,
              style: TextStyle(
                  fontSize: 22.h,
                  fontWeight: FontWeight.w300,
                  color: kColorTextDarkGrey),
            ),
          )
        ],
      ),
    );
  }
}

class StaffMembershipPage extends StatefulWidget {
  String pk;
  StaffMembershipPage({
    Key? key,
    required this.pk,
  }) : super(key: key);

  @override
  _StaffMembershipPageState createState() => _StaffMembershipPageState();
}

class _StaffMembershipPageState extends State<StaffMembershipPage> {
  String? token = '';
  String? courseName = '';

  @override
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  @override
  void initState() {
    super.initState();
    // _fetchMyAllMembership();
  }

  Future<List<dynamic>?> _fetchStaffMembership() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse(
          '${baseUri}attendances/membership/membership_by_staff?user_id=${widget.pk}&token=$token');
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
        } else if (data.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('There is no available membership.')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Some Error occurred.Try again later')));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: Column(
            children: [
              _Header(
                title: 'Membership',
                subtitle: 'All membership of the user',
              ),
              SizedBox(height: 20.h),
              FutureBuilder(
                future: _fetchStaffMembership(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                            child: Text(
                                'No Membership Available...\nPurchase Membership!',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                ))),
                      ],
                    );
                  } else {
                    final membershipList = snapshot.data!;
                    // print(membershipList);
                    return Expanded(
                      child: ListView.builder(
                          itemCount: membershipList.length,
                          itemBuilder: (context, index) {
                            // request_join_timesとmax_join_timesの比較
                            final requested_join_times =
                                membershipList[index]['requested_join_times'];
                            final max_join_times =
                                membershipList[index]['max_join_times'];
                            final isAlreadyMaxRequest =
                                requested_join_times == max_join_times;

                            // already_join_timesとmax_join_timesの比較
                            final already_join_times =
                                membershipList[index]['already_join_times'];
                            final isAlreadyMaxJoin =
                                already_join_times == max_join_times;

                            bool is_expired = false;
                            DateTime formattedDate = DateTime.parse(
                                membershipList[index]['expire_day']);

                            DateTime today = DateTime.now();

                            if (formattedDate.isBefore(today)) {
                              is_expired = true;
                            }

                            return Column(
                              children: [
                                isAlreadyMaxJoin || is_expired
                                    ? Stack(
                                        children: [
                                          Container(
                                            height: 120.h,
                                            alignment: Alignment.center,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [],
                                            ),
                                          ),
                                          Opacity(
                                            opacity: 0.3,
                                            child: TicketList(
                                                membershipList:
                                                    membershipList[index]),
                                          )
                                        ],
                                      )
                                    : isAlreadyMaxRequest || is_expired
                                        ? Stack(
                                            children: [
                                              Container(
                                                height: 120.h,
                                                alignment: Alignment.center,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        'Reached to max request times',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 22.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800)),
                                                  ],
                                                ),
                                              ),
                                              Opacity(
                                                opacity: 0.3,
                                                child: TicketList(
                                                    membershipList:
                                                        membershipList[index]),
                                              )
                                            ],
                                          )
                                        : TicketList(
                                            membershipList:
                                                membershipList[index]),
                                SizedBox(height: 10.h),
                              ],
                            );
                          }),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Buy New Membership', style: TextStyle(fontSize: 20.sp)),
        icon: Icon(Icons.attach_money, size: 40),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  StaffMembershipAttendeePage(pk: widget.pk)));
        },
      ),
    );
  }
}
