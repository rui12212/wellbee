// import 'package:booking_calendar/booking_calendar.dart';
import 'dart:async';
import 'dart:convert';
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
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/convert.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:wellbee/ui_parts/ticket.dart';

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(24.r),
                  child: Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20.sp,
                      color: kColorTextDarkGrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: kColorTextDarkGrey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class MembershipPage extends StatefulWidget {
  MembershipPage({
    Key? key,
  }) : super(key: key);

  @override
  _MembershipPageState createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
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

  Future<List<dynamic>?> _fetchMyAvailableMembership() async {
    try {
      token = await SharedPrefs.fetchAccessToken();
      var url = Uri.parse(
          '${baseUri}attendances/membership/my_all_membership/?token=$token');
      var response = await Future.any([
        http.get(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json"
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request timeout"))
      ]);
      print(response);
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
              const _Header(
                title: 'Membership',
                subtitle: 'Choose Membership for booking',
              ),
              SizedBox(height: 20.h),
              FutureBuilder(
                future: _fetchMyAvailableMembership(),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 50.h),
                            Container(
                              height: 300.h,
                              width: 300.h,
                              decoration: BoxDecoration(
                                // borderRadius:
                                //     BorderRadius.all(Radius.circular(70)),
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                        'lib/assets/home_pic/no_membership.png')),
                              ),
                            ),
                            SizedBox(height: 30.h),
                            Align(
                              alignment: Alignment.center,
                              child: Text('No Membership Available...',
                                  style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w300)),
                            ),
                            Text('Buy Membership at Wellbee Studio',
                                style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w300)),
                          ],
                        ),
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

                            return Column(
                              children: [
                                InkWell(
                                    child: isAlreadyMaxJoin
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
                                                        'Reached to max join times',
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
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
                                        : isAlreadyMaxRequest
                                            ? Stack(
                                                children: [
                                                  Container(
                                                    height: 120.h,
                                                    alignment: Alignment.center,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                            'Reached to max request times',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
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
                                                            membershipList[
                                                                index]),
                                                  )
                                                ],
                                              )
                                            : TicketList(
                                                membershipList:
                                                    membershipList[index]),
                                    onTap: isAlreadyMaxJoin
                                        ? null
                                        : isAlreadyMaxRequest
                                            ? null
                                            : () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ReservationMembershipPage(
                                                                membershipList:
                                                                    membershipList[
                                                                        index])));
                                              }),
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
      // floatingActionButton: FloatingActionButton.extended(
      //   label: Text('Buy New Membership', style: TextStyle(fontSize: 20)),
      //   icon: Icon(Icons.attach_money, size: 40),
      //   onPressed: () {
      //     Navigator.of(context).push(MaterialPageRoute(
      //         builder: (context) => MembershipAttendeePage()));
      //   },
      // ),
    );
  }
}
