// import 'package:booking_calendar/booking_calendar.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/dm/message_send.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/ticket.dart';

class _Header extends StatelessWidget {
  String title;
  _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 24.w, fontWeight: FontWeight.bold)),
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
        ],
      ),
    );
  }
}

class MessageAttendeeSelectPage extends ConsumerStatefulWidget {
  MessageAttendeeSelectPage({
    Key? key,
  });

  @override
  _MessageAttendeeSelectPageState createState() =>
      _MessageAttendeeSelectPageState();
}

class _MessageAttendeeSelectPageState
    extends ConsumerState<MessageAttendeeSelectPage> {
  String? token = '';
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

  Future<List<dynamic>?> _fetchAllAvailableMembership() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse(
          '${baseUri}attendances/membership/all_dm_attendee?token=$token');
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
    // final isCanTakeSurvey = ref.watch(isCanTakeSurveyProvider);

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
                title: 'DM to Attendee',
              ),
              Container(
                height: 555.h,
                child: FutureBuilder(
                  future: _fetchAllAvailableMembership(),
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
                              child: Text('No Attendee Shown',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                  ))),
                        ],
                      );
                    } else {
                      final membershipList = snapshot.data;
                      return ListView.builder(
                          itemCount: membershipList!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                                // key: ValueKey('membership-$index'),
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: InkWell(
                                    child: DMTicketList(
                                      membershipList: membershipList[index],
                                    ),
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) {
                                          return DMMessageSendPage(
                                              userId: membershipList[index]
                                                  ['user_id']);
                                        },
                                      ));
                                    }));
                          });
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
