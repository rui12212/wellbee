import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/screens/staff/auth/staff_top_page.dart';
import 'package:wellbee/screens/staff/calendar/calendar.dart';
import 'package:wellbee/screens/staff/qr_after/user_home.dart';
import 'package:wellbee/ui_function/convert.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';
import 'package:http/http.dart' as http;
import 'package:wellbee/ui_parts/dialogue_awesome.dart';
import 'package:wellbee/ui_parts/display.dart';

class CheckInPage extends StatefulWidget {
  final String id;
  CheckInPage({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _CheckInPageState createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final TextEditingController _numPersonController = TextEditingController();
  String? token = '';
  int selectedNumPerson = 1;

  List<DropdownMenuItem<dynamic>> numPersonItems = List.generate(5, (index) {
    List numPersonList = [
      1,
      2,
      3,
      4,
      5,
    ];
    int numPerson = (numPersonList[index]);

    return DropdownMenuItem(
        value: numPerson,
        child: Padding(
            padding: const EdgeInsets.all(10), child: Text('${numPerson}')));
  });

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
  showSnackBar(color, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(text)),
    );
  }

  Future<Map<String, dynamic>?> _fetchScannedReservation() async {
    try {
      token = await SharedPrefs.fetchStaffAccessToken();
      var url = Uri.parse('${baseUri}reservations/reservation/qr_reservation/')
          .replace(
              queryParameters: {'reservation_id': widget.id, 'token': token});
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
          return data[0];
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

  _createCheckIn(Map<String, dynamic> scannedData) async {
    DateTime formattedDate = DateTime.parse(scannedData['slot_date']);
    DateTime today = DateTime.now();

    if (formattedDate.year == today.year &&
        formattedDate.month == today.month &&
        formattedDate.day == today.day) {
      try {
        token = await SharedPrefs.fetchStaffAccessToken();
        var url = Uri.parse('${baseUri}attendances/checkin/?token=$token');
        var response = await Future.any([
          http.post(url,
              body: jsonEncode({
                'reservation': scannedData['id'],
                'num_person': selectedNumPerson,
              }),
              headers: {
                "Authorization": 'JWT $token',
                'Content-Type': 'application/json',
              }),
          Future.delayed(const Duration(seconds: 15),
              () => throw TimeoutException("Request timeout"))
        ]);
        if (response.statusCode == 201) {
          // List<dynamic> data = jsonDecode(response.body);
          // if (data.isNotEmpty) {
          showSnackBar(kColorPrimary, 'Check In Success!');
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (context) {
              return UserHomePage(pk: scannedData['user_id']);
            },
          ), ((route) => false));
        } else if (response.statusCode >= 400) {
          showSnackBar(Colors.red,
              'Error: You already checked in OR you need a new membership');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Something went wrong. Try again later')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } else {
      showSnackBar(Colors.red, 'This reservation is NOT TODAY');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('Check In',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold)),
            backgroundColor: kColorPrimary),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
            ),
            child: SingleChildScrollView(
              child: FutureBuilder(
                  future: _fetchScannedReservation(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Container(
                        height: 500.h,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error occured. No reservation.',
                                style: TextStyle(fontSize: 16.h)),
                            SizedBox(height: 20.h),
                            FilledButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                  builder: (context) {
                                    return StaffTopPage(0);
                                  },
                                ), ((route) => false));
                              },
                              icon: const Icon(Icons.arrow_back_ios),
                              label: Text('Go Back to Staff Home',
                                  style: TextStyle(fontSize: 20.sp)),
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all<Size>(
                                    Size(300, 80)), // ボタンの幅と高さを設定
                              ),
                            ),
                          ],
                        ),
                      ));
                    } else {
                      final Map<String, dynamic> scannedReservation =
                          snapshot.data!;
                      final formattedStartTime = IntConverter.formatTime(
                          scannedReservation['slot_start_time']);
                      final formattedEndTime = IntConverter.formatTime(
                          scannedReservation['slot_end_time']);
                      return Column(
                        children: [
                          ReservationCheckList(
                            slot_course_name:
                                scannedReservation['slot_course_name'],
                            slot_date: scannedReservation['slot_date'],
                            slot_start_time: formattedStartTime,
                            slot_end_time: formattedEndTime,
                            attendee_name: scannedReservation['attendee_name'],
                          ),
                          SizedBox(height: 18.h),
                          Column(
                            children: [
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                      'Number of Attendee(For Family Course!)',
                                      style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500))),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    border:
                                        Border.all(color: kColorTextDarkGrey)),
                                child: DropdownButton(
                                    isExpanded: true,
                                    style: TextStyle(
                                        fontSize: 22.sp, color: Colors.black),
                                    itemHeight: 75.h,
                                    value: selectedNumPerson,
                                    hint: Text('Select number of people'),
                                    items: numPersonItems,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedNumPerson = newValue;
                                      });
                                    }),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30.h,
                          ),
                          FilledButton.icon(
                            onPressed: () {
                              CustomAwesomeDialogue(
                                  titleText: 'Confirm Check In',
                                  desc:
                                      'Check In for ${scannedReservation['attendee_name']} \n ${scannedReservation['slot_date']}-$formattedStartTime-$formattedEndTime',
                                  callback: () {
                                    _createCheckIn(scannedReservation);
                                  }).show(context);
                              // _createCheckIn();
                            },
                            icon: const Icon(Icons.person),
                            label: Text('Create CheckIn',
                                style: TextStyle(fontSize: 20.sp)),
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(250, 70)), // ボタンの幅と高さを設定
                            ),
                          ),
                          SizedBox(height: 20.h),
                          FilledButton.icon(
                            onPressed: () {
                              showAwesomeDialog();
                            },
                            icon: const Icon(Icons.chevron_left_outlined),
                            label: Text('Back to Home',
                                style: TextStyle(fontSize: 20.sp)),
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(250, 70)), // ボタンの幅と高さを設定
                            ),
                          ),
                          SizedBox(
                            height: 30.h,
                          ),
                          // Button->関数->view
                        ],
                      );
                    }
                  }),
            ),
          ),
        ));
  }
}
