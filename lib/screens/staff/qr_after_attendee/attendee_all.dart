import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/attendee/attendee_add.dart';
import 'package:wellbee/screens/staff/qr_after/user_home.dart';
import 'package:wellbee/screens/staff/qr_after_attendee/attendee_detail.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/display.dart';
import 'package:wellbee/screens/attendee/attendee_update.dart';

class _Header extends StatelessWidget {
  String title;
  String subtitle;
  String userId;

  _Header({required this.title, required this.subtitle, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.r,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 30.w, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: const CircleBorder(
                          side: BorderSide(
                              color: Color.fromARGB(255, 216, 214, 214),
                              width: 5))),
                  child: const Icon(Icons.chevron_left,
                      color: Color.fromARGB(255, 155, 152, 152)),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                      builder: (context) {
                        return UserHomePage(pk: userId);
                      },
                    ), ((route) => false));
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
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w300,
                  color: kColorTextDarkGrey),
            ),
          )
        ],
      ),
    );
  }
}

class StaffAttendeeAllPage extends StatefulWidget {
  String userId;
  StaffAttendeeAllPage({Key? key, required this.userId}) : super(key: key);

  @override
  _StaffAttendeeAllPageState createState() => _StaffAttendeeAllPageState();
}

class _StaffAttendeeAllPageState extends State<StaffAttendeeAllPage> {
  String? token = '';

  Future<List<dynamic>?> _fetchAttendee() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse(
          '${baseUri}attendances/attendee/attendee_by_staff?user_id=${widget.userId}&token=$token');
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
          print(data);
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
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              _Header(
                  title: 'Wellbee Member',
                  subtitle: 'Select for Member detail ',
                  userId: widget.userId),
              FutureBuilder(
                future: _fetchAttendee(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No attendee registered.'));
                  } else {
                    final attendeeList = snapshot.data!;
                    // print(attendeeList);
                    return Expanded(
                      child: ListView.builder(
                        itemCount: attendeeList.length,
                        itemBuilder: (context, index) {
                          if (attendeeList[index]['goal'] == null) {
                            attendeeList[index]['goal'] = '';
                          }
                          if (attendeeList[index]['reason'] == null) {
                            attendeeList[index]['reason'] = '';
                          }
                          return InkWell(
                              child: AttendeeDisplay(
                                  attendeeName: attendeeList[index]['name'],
                                  gender: attendeeList[index]['gender'],
                                  dateOfBirth: attendeeList[index]
                                      ['date_of_birth'],
                                  goal: attendeeList[index]['goal']),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        StaffAttendeeDetailPage(
                                            attendeeList:
                                                attendeeList[index])));
                              });
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
