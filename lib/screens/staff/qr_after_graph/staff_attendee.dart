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
import 'package:wellbee/screens/staff/qr_after_attendee/attendee_detail.dart';
import 'package:wellbee/screens/staff/qr_after_graph/staff_graph.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/color.dart';
import 'package:wellbee/ui_parts/display.dart';
import 'package:wellbee/screens/attendee/attendee_update.dart';

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
                              color: Color.fromARGB(255, 216, 214, 214),
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

class GraphAttendeePage extends StatefulWidget {
  String userId;
  GraphAttendeePage({Key? key, required this.userId}) : super(key: key);

  @override
  _GraphAttendeePageState createState() => _GraphAttendeePageState();
}

class _GraphAttendeePageState extends State<GraphAttendeePage> {
  String? token = '';

  Future<List<dynamic>?> _fetchAttendee() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse(
          '${baseUri}attendances/attendee/attendee_by_staff?user_id=${widget.userId}');
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
                  subtitle: 'Tap to show health graph'),
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
                                    builder: (context) => StaffGraphPage(
                                        attendeeList: attendeeList[index])));
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
